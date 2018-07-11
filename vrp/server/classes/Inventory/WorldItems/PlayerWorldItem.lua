-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/PlayerWorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
PlayerWorldItem = inherit(WorldItem)

function PlayerWorldItem:hasPlayerPermissionTo(player, action)
	if not isElement(player) or player:getType() ~= "player" then return false end
	if action == WorldItem.Action.Move then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            return true 
        elseif self:getOwner() == player:getId() then
            return true
        else
            if self:getOwner() then player:sendError(_("Dieses Objekt gehört nicht dir!", player)) end
            return false
        end
    elseif action == WorldItem.Action.Collect then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
		    local x, y, z = getElementPosition(self:getObject())
            local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
			StatisticsLogger:getSingleton():worldItemLog( "Collect", "Player", player:getId(), self:getOwner(), self:getDataBaseId() or 0, zone1, zone2)
			return true 
        elseif self:getOwner() == player:getId() then
			local x, y, z = getElementPosition(self:getObject())
            local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
			StatisticsLogger:getSingleton():worldItemLog( "Collect", "Player", player:getId(), self:getOwner(), self:getDataBaseId() or 0, zone1, zone2)
            return true
        else
            if self:getOwner() then player:sendError(_("Dieses Objekt gehört nicht dir!", player)) end
            return false
        end
    elseif action == WorldItem.Action.Delete then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            if player.isLoggedIn and player:isLoggedIn() and self:getObject() then
                local x, y, z = getElementPosition(self:getObject())
                local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
				StatisticsLogger:getSingleton():worldItemLog( "Delete", "Player", player:getId(), self:getOwner(), self:getDataBaseId() or 0, zone1, zone2)
				local placer = self:getPlacer() 
				if type(placer) == "number" then 
					placer = DatabasePlayer.getFromId(placer)
					if placer and isElement(placer) then 
						placer:sendWarning(_("%s %s hat dein Objekt %s in %s, %s gelöscht!", placer,
						RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2), 10000)
					end
				end
            end
            return true 
        elseif self:getOwner() == player:getId() then
			local x, y, z = getElementPosition(self:getObject())
            local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
			StatisticsLogger:getSingleton():worldItemLog( "Collect", "Player", player:getId(), self:getOwner(), self:getDataBaseId() or 0, zone1, zone2)
            return true
        else
            if isElement(self:getOwner()) then player:sendError(_("Dieses Objekt gehört nicht dir!", player)) end
            return false
        end
    end
end