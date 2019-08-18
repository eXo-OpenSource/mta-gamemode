-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/FactionWorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
FactionWorldItem = inherit(WorldItem)

function FactionWorldItem:setFactionSuperOwner(state) --disallows the owner to interact with the object if he is not part of the OwnerGroup
	self.m_SuperOwner = state
	self.m_Object:setData("SuperOwner", state, true)
end

function FactionWorldItem:setMinRank(rank)
	self.m_MinRank = rank
	self.m_Object:setData("MinRank", rank, true)
end

function FactionWorldItem:hasPlayerPermissionTo(player, action) --override this with group specific permissions, but always check for admin rights
	if not isElement(player) or player:getType() ~= "player" then return false end

	if ADMIN_RANK_PERMISSION[action] and player:getRank() >= ADMIN_RANK_PERMISSION[action] then -- admin rights
		return true
	end

	local faction = player:getFaction()
	if not faction then
		return false
	end

	local rank = self.m_MinRank or 0



	if self.m_ElementType == DbElementType.Faction then
		if self.m_ElementId == faction:getId() then
			if faction:getPlayerRank(player) >= rank then
				if action == WorldItem.Action.Move then
					return true
				elseif action == WorldItem.Action.Collect then
					return true
				elseif action == WorldItem.Action.Delete then
					return false
				end
			else
				player:sendError(_("Dazu benötigst du mindestens Rang %d.", player, rank))
				return false
			end
		else
			return false
		end
	else
		return false
	end

	return false

	--[[
	if not isElement(player) or player:getType() ~= "player" then return false end
	local rank = self.m_MinRank or 0
	if action == WorldItem.Action.Move then
		if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
			if self:getObject() and (player:getFaction() ~= self:getOwner() or not (player:isFactionDuty())) then --just show it if the player used his moderator rights
				local x, y, z = getElementPosition(self:getObject())
				local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				self:getOwner():sendShortMessage(("%s %s verschiebt euer Objekt %s in %s, %s!"):format(RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2))
				return true
			end
		end
		if player:getFaction() == self:getOwner() and player:isFactionDuty() then
			if player:getFaction():getPlayerRank(player) >= rank then
				return true
			else
				player:sendError(_("Dazu benötigst du mindestens Rang %d.", player, rank))
			end
		elseif self:getPlacer() == player and not self.m_SuperOwner then
			return true
		else
			player:sendError(_("Dieses Objekt gehört der Fraktion %s.", player, self:getOwner():getName()))
			return false
		end
		return false
	elseif action == WorldItem.Action.Collect then
		if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
			--outputDebug("admin rights")
			return true
		end
		if player:getFaction() == self:getOwner() and player:isFactionDuty() then
			--outputDebug("faction and duty")
			if player:getFaction():getPlayerRank(player) >= rank then
				--outputDebug("rank")
				return true
			else
				player:sendError(_("Dazu benötigst du mindestens Rang %d.", player, rank))
			end
		elseif self:getPlacer() == player and not self.m_SuperOwner then
			 --outputDebug("private")
			return true
		else
			player:sendError(_("Dieses Objekt gehört der Fraktion %s.", player, self:getOwner():getName()))
			return false
		end
		return false
	elseif action == WorldItem.Action.Delete then
		if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
			if self:getObject() and (player:getFaction() ~= self:getOwner() or not (player:isFactionDuty())) then --just show it if the player used his moderator rights
				local x, y, z = getElementPosition(self:getObject())
				local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				self:getOwner():sendShortMessage(("%s %s hat euer Objekt %s in %s, %s gelöscht!"):format(RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2))
				return true
			end
		end
		if player:getFaction() == self:getOwner() and player:isFactionDuty() then
			if player:getFaction():getPlayerRank(player) >= OBJECT_DELETE_MIN_RANK then
				local x, y, z = getElementPosition(self:getObject())
				local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				self:getOwner():sendShortMessage(("%s hat das Objekt %s in %s, %s gelöscht!"):format(player:getName(), self.m_ItemName, zone1, zone2))
				return true
			else
				player:sendError(_("Um das Objekt %s zu löschen benötigst du mindestens Rang %d", player, self.m_ItemName, OBJECT_DELETE_MIN_RANK))
				return false
			end
		else
			player:sendError(_("Dieses Objekt gehört der Fraktion %s", player, self:getOwner():getName()))
			return false
		end
	end]]
end
