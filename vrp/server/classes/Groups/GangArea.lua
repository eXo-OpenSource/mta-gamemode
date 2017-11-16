-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GangArea.lua
-- *  PURPOSE:     Gang area (turfing) class
-- *
-- ****************************************************************************
GangArea = inherit(Object)

function GangArea:constructor(Id, areaPosition, width, height, resourcesPerDistribution)
	self.m_Id = Id
	local result = sql:queryFetchSingle("SELECT Owner, State FROM ??_gangareas WHERE Id = ?", sql:getPrefix(), self.m_Id)

	self.m_ColShape = createColRectangle(areaPosition.x, areaPosition.y, width, height)
	self.m_RadarArea = RadarArea:new(areaPosition.x, areaPosition.y+height, width, height, {0, 255, 0, 200}) -- todo: Move to the client
	if not result then
		self.m_OwnerGroup = false
	else
		self.m_OwnerGroup = GroupManager:getSingleton():getFromId(result.Owner)
		if self.m_OwnerGroup then -- May fail due to a deleted group
			setElementData(self.m_ColShape, "OwnerName", self.m_OwnerGroup:getName())
		end
	end

	-- Sync some data to the client | that's probably a bit hacky
	setElementID(self.m_ColShape, "GangArea"..Id)

	self.m_TurfingPlayers = {}
	self.m_DefendingPlayers = {}
	self.m_TurfingGroup = false
	self.m_TurfingTimer = nil
	self.m_TurfingProgress = 100
	self.m_TurfingDirection = nil -- true: attacking; false: defending

	self.m_ResourcesPerDistribution = resourcesPerDistribution
	self.m_BankAccountServer = BankServer.get("group.gangarea")

	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.Area_Enter, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.Area_Leave, self))
end

function GangArea:destructor()
	self.m_ColShape:destroy()
	delete(self.m_RadarArea)
end

function GangArea:getOwnerGroup()
	return self.m_OwnerGroup
end

function GangArea:Area_Enter(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if not self.m_TurfingGroup then
			return
		end
		local group = hitElement:getGroup()
		if not group then
			return
		end

		-- Push to the turfing players list if the player is a member of the attacking or defending group
		if group == self.m_TurfingGroup then
			table.insert(self.m_TurfingPlayers, hitElement)
			hitElement:triggerEvent("gangAreaTurfStart", self.m_Id, self.m_TurfingGroup:getName(), self.m_TurfingProgress)
		end

		if group == self.m_OwnerGroup then
			table.insert(self.m_DefendingPlayers, hitElement)
			hitElement:triggerEvent("gangAreaTurfStart", self.m_Id, self.m_TurfingGroup:getName(), self.m_TurfingProgress)
		end
	end
end

function GangArea:Area_Leave(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if not self.m_TurfingGroup then
			return
		end

		local idx = table.find(self.m_TurfingPlayers, hitElement)
		if idx then
			table.remove(self.m_TurfingPlayers, idx)
			hitElement:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_LEAVEAREA, self.m_TurfingGroup:getName())
		end
		idx = table.find(self.m_DefendingPlayers, hitElement)
		if idx then
			table.remove(self.m_DefendingPlayers, idx)
			hitElement:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_LEAVEAREA, self.m_TurfingGroup:getName())
		end

		-- Check if the gangarea was successfully defended
		if #self.m_TurfingPlayers == 0 then
			if self.m_OwnerGroup then
				hitElement:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_DEFENDED, self.m_TurfingGroup:getName())
				for k, player in pairs(self.m_DefendingPlayers) do
					player:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_DEFENDED, self.m_TurfingGroup:getName())

					-- Give successful players a few points
					player:givePoints(20)
				end
			end

			-- Stop attacking mode
			self.m_TurfingGroup = false
			self.m_TurfingProgress = 100
			self.m_DefendingPlayers = {}

			killTimer(self.m_TurfingTimer)
			self.m_TurfingTimer = nil
			self.m_RadarArea:setFlashing(false)
		end
	end
end

function GangArea:updateTurfing()
	-- Using a timer interval of 4 seconds results in a overall turfing time of 400 seconds (4000ms * 100)
	if #self.m_TurfingPlayers > 0 or #self.m_DefendingPlayers > 0 then
		if self.m_TurfingDirection then
			-- Attacking mode
			self.m_TurfingProgress = self.m_TurfingProgress - 1

			-- Tripple speed if the area has no owner group
			if not self.m_OwnerGroup then
				self.m_TurfingProgress = self.m_TurfingProgress - 2 -- We don't need to take the turfing direction into account as defending is not possible if there isn't any owner group
			end
		else
			-- Defending mode
			self.m_TurfingProgress = self.m_TurfingProgress + 1
		end
	end

	if self.m_TurfingProgress <= 0 then
		-- Looks like the gang area has a new owner :)
		self:setOwner(self.m_TurfingGroup)
		self.m_TurfingProgress = 100
		self.m_TurfingGroup = false
		killTimer(self.m_TurfingTimer)
		self.m_TurfingTimer = nil

		for k, player in pairs(self.m_TurfingPlayers) do
			player:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_NEWOWNER, self.m_OwnerGroup:getName())

			-- Give successful players a few points
			player:givePoints(20)
		end
		for k, player in pairs(self.m_DefendingPlayers) do
			player:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_NEWOWNER, self.m_OwnerGroup:getName())
		end

		self.m_TurfingPlayers = {}
		self.m_DefendingPlayers = {}
		self.m_RadarArea:setFlashing(false)
		return
	end

	if self.m_TurfingProgress > 100 then
		-- Area was successfully defended
		self.m_TurfingProgress = 100
		self.m_TurfingGroup = false
		killTimer(self.m_TurfingTimer)
		self.m_TurfingTimer = nil

		for k, player in pairs(self.m_TurfingPlayers) do
			player:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_DEFENDED, self.m_OwnerGroup:getName())
		end
		for k, player in pairs(self.m_DefendingPlayers) do
			player:triggerEvent("gangAreaTurfStop", self.m_Id, TURFING_STOPREASON_DEFENDED, self.m_OwnerGroup:getName())

			-- Give successful players a few points
			player:givePoints(20)
		end

		self.m_TurfingPlayers = {}
		self.m_DefendingPlayers = {}
		self.m_RadarArea:setFlashing(false)
		return
	end

	for k, player in pairs(self.m_TurfingPlayers) do
		player:triggerEvent("gangAreaTurfUpdate", self.m_TurfingProgress)
	end
	for k, player in pairs(self.m_DefendingPlayers) do
		player:triggerEvent("gangAreaTurfUpdate", self.m_TurfingProgress)
	end
end

function GangArea:startTurfing(group)
	if self.m_TurfingTimer then
		return false
	end

	self.m_TurfingGroup = group
	self.m_TurfingDirection = true
	self.m_TurfingTimer = setTimer(bind(self.updateTurfing, self), 4000, 0)
	self.m_RadarArea:setFlashing(true)

	-- Tell the client that we're turfing now
	if self.m_OwnerGroup then
		local onlinePlayers = self.m_OwnerGroup:getOnlinePlayers()
		for k, player in pairs(onlinePlayers) do
			local x, y, z = getElementPosition(self.m_ColShape)
			player:sendWarning(_("Achtung! Eines eurer Gebiete in %s wird angegriffen!", player, getZoneName(x, y, z, false)))
		end
	end

	-- Add all players of the attacking group within the gangarea to the gangwar
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getGroup() == self.m_TurfingGroup then
			player:triggerEvent("gangAreaTurfStart", self.m_Id, self.m_TurfingGroup:getName())
			table.insert(self.m_TurfingPlayers, player)
		elseif player:getGroup() == self.m_OwnerGroup then
			player:triggerEvent("gangAreaTurfStart", self.m_Id, self.m_TurfingGroup:getName())
			table.insert(self.m_DefendingPlayers, player)
		end
	end

	return true
end

function GangArea:sendMessage(message, ...)
	if self.m_OwnerGroup then
		for k, player in pairs(self.m_OwnerGroup:getOnlinePlayers()) do
			player:sendMessage(_(message, player, ...))
		end
	end

	for k, player in pairs(self.m_TurfingPlayers) do
		player:sendMessage(_(message, player, ...))
	end
end

function GangArea:setTurfingDirection(direction)
	self.m_TurfingDirection = direction
end

function GangArea:isTurfingInProgress()
	return self.m_TurfingTimer ~= nil
end

function GangArea:removeTurfingPlayer(player)
	local idx = table.find(self.m_TurfingPlayers, player)
	if idx then
		table.remove(self.m_TurfingPlayers, idx)
	end
	idx = table.find(self.m_DefendingPlayers, player)
	if idx then
		table.remove(self.m_DefendingPlayers, idx)
	end
end

function GangArea:setOwner(newOwner)
	self.m_OwnerGroup = newOwner
	setElementData(self.m_ColShape, "OwnerName", self.m_OwnerGroup and self.m_OwnerGroup:getName() or "")

	if self.m_OwnerGroup then
		sql:queryExec("INSERT INTO ??_gangareas (Id, Owner) VALUES(?, ?) ON DUPLICATE KEY UPDATE Owner = ?", sql:getPrefix(), self.m_Id, self.m_OwnerGroup:getId(), self.m_OwnerGroup:getId())
	else
		sql:queryExec("DELETE FROM ??_gangareas WHERE Id = ?", sql:getPrefix(), self.m_Id)
	end

	if not self.m_OwnerGroup and self:isTurfingInProgress() then
		killTimer(self.m_TurfingTimer)
		self.m_TurfingTimer = nil
		self.m_TurfingGroup = false
	end
end

function GangArea:distributeResources()
	-- Do we have an owner?
	if not self.m_OwnerGroup then
		return false
	end

	-- Do not distribute resources if noone is online
	if #self.m_OwnerGroup:getOnlinePlayers() == 0 then
		return false
	end

	self.m_OwnerGroup:distributeMoney(self.m_BankAccountServer, self.m_ResourcesPerDistribution, "Gang Area", "Group", "GangArea")
	return true
end

function GangArea:canBeTurfed()
	-- Check if the gang area has no owner
	if not self.m_OwnerGroup then
		return true
	end

	-- Check if noone is playing
	if #self.m_OwnerGroup:getOnlinePlayers() > 0 then
		return true
	end

	-- Check if noone was playing (use MySQL statement directly instead of loading all data)
	for playerId in pairs(self.m_OwnerGroup:getPlayers(true)) do
		local row = sql:queryFetchSingle("SELECT DATE_ADD(LastLogin, INTERVAL 24 HOUR) > NOW() AS WasOnline FROM ??_account WHERE Id = ?", sql:getPrefix(), playerId)
		if row.WasOnline == 1 then
			return false
		end
	end

	return true
end
