-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GangArea.lua
-- *  PURPOSE:     Gang area (turfing) class
-- *
-- ****************************************************************************
GangArea = inherit(Object)

function GangArea:constructor(Id, areaPosition, width, height)
	self.m_Id = Id
	self.m_ColShape = createColRectangle(areaPosition.X, areaPosition.Y, width, height)
	self.m_RadarArea = RadarArea:new(areaPosition.X, areaPosition.Y+height, width, height, tocolor(0, 255, 0, 200)) -- todo: Move to the client
	self.m_OwnerGroup = false
	
	self.m_TurfingPlayers = {}
	self.m_DefendingPlayers = {}
	self.m_TurfingGroup = false
	self.m_TurfingTimer = nil
	self.m_TurfingProgress = 100
	
	addEventHandler("onColShapeHit", self.m_ColShape, bind(self.Area_Enter, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.Area_Leave, self))
end

function GangArea:destructor()
	destroyElement(self.m_ColShape)
	destroyElement(self.m_RadarArea)
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
			hitElement:triggerEvent("gangAreaTurfStart")
		end
		
		if group == self.m_OwnerGroup then
			table.insert(self.m_DefendingPlayers, hitElement)
			hitElement:triggerEvent("gangAreaTurfStart")
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
			hitElement:triggerEvent("gangAreaTurfStop", TURFING_STOPREASON_LEAVEAREA, self.m_TurfingGroup:getName())
		end
		idx = table.find(self.m_DefendingPlayers, hitElement)
		if idx then
			table.remove(self.m_DefendingPlayers, idx)
			hitElement:triggerEvent("gangAreaTurfStop", TURFING_STOPREASON_LEAVEAREA, self.m_TurfingGroup:getName())
		end
		
		-- Return here since it doesn't make sense to check for changes if nothing has changed
		if not idx then
			return
		end
		
		-- Check if the gangarea was successfully defended
		if #self.m_TurfingPlayers == 0 then
			if self.m_OwnerGroup then
				for k, player in pairs(self.m_TurfingPlayers) do
					player:triggerEvent("gangAreaTurfStop", TURFING_STOPREASON_DEFENDED, self.m_TurfingGroup:getName())
				end
				for k, player in pairs(self.m_DefendingPlayers) do
					player:triggerEvent("gangAreaTurfStop", TURFING_STOPREASON_DEFENDED, self.m_TurfingGroup:getName())
				end
			end
			
			-- Stop attacking mode
			self.m_TurfingGroup = false
			self.m_TurfingProgress = 100
			self.m_DefendingPlayers = {}
			
			killTimer(self.m_TurfingTimer)
			self.m_TurfingTimer = nil
		end
	end
end

function GangArea:updateTurfing()
	-- Using a timer interval of 4 seconds results in a overall turfing time of 400 seconds (4000ms * 100)
	self.m_TurfingProgress = self.m_TurfingProgress - 1
	
	-- Tripple speed if the area has no owner group
	if not self.m_OwnerGroup then
		self.m_TurfingProgress = self.m_TurfingProgress - 2
	end
	
	if self.m_TurfingProgress <= 0 then
		-- Looks like the gang area has a new owner :)
		self.m_OwnerGroup = self.m_TurfingGroup
		self.m_TurfingProgress = 100
		self.m_TurfingGroup = false
		killTimer(self.m_TurfingTimer)
		self.m_TurfingTimer = nil
		
		for k, player in pairs(self.m_TurfingPlayers) do
			player:triggerEvent("gangAreaTurfStop", TURFING_STOPREASON_NEWOWNER, self.m_OwnerGroup:getName())
		end
		for k, player in pairs(self.m_DefendingPlayers) do
			player:triggerEvent("gangAreaTurfStop", TURFING_STOPREASON_NEWOWNER, self.m_OwnerGroup:getName())
		end
		
		self.m_TurfingPlayers = {}
		self.m_DefendingPlayers = {}
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
	self.m_TurfingTimer = setTimer(bind(self.updateTurfing, self), 4000, 0)
	
	-- Tell the client that we're turfing now
	if self.m_OwnerGroup then
		local onlinePlayers = self.m_OwnerGroup:getOnlinePlayers()
		for k, player in pairs(onlinePlayers) do
			local x, y, z = getElementPosition(self.m_Wall)
			player:sendWarning(_("Achtung! Eines eurer Gebiete in %s wird angegriffen!", player, getZoneName(x, y, z, false)))
		end
	end
	
	-- Add all players of the attacking group within the gangarea to the gangwar
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		player:triggerEvent("gangAreaTurfStart")
		table.insert(self.m_TurfingPlayers, player)
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
