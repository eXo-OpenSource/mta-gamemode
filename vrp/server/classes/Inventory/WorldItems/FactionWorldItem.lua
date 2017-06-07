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

function FactionWorldItem:hasPlayerPermissionTo(player, action)
	if not isElement(player) or player:getType() ~= "player" then return false end
    local rank = self.m_MinRank or 0
	if action == WorldItem.Action.Move then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            return true 
        end
        if player:getFaction() == self:getOwner() then
            if player:getFaction():getPlayerRank(player) >= rank then
                return true
            else
                player:sendError(_("Dazu benötigst du mindestens Rang %d", player, rank))
            end
        elseif self:getPlacer() == player and not self.m_SuperOwner then
            return true
        else
            player:sendError(_("Dieses Objekt gehört der Fraktion %s", player, self:getOwner():getName()))
            return false
        end
        return false
    elseif action == WorldItem.Action.Collect then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            return true 
        end
        if player:getFaction() == self:getOwner() then
            if player:getFaction():getPlayerRank(player) >= rank then
                return true
            else
                player:sendError(_("Dazu benötigst du mindestens Rang %d", player, rank))
            end
        elseif self:getPlacer() == player and not self.m_SuperOwner then
            return true
        else
            player:sendError(_("Dieses Objekt gehört der Fraktion %s", player, self:getOwner():getName()))
            return false
        end
        return false
    elseif action == WorldItem.Action.Delete then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            if self:getObject() and not (player:getFaction():getPlayerRank(player) >= OBJECT_DELETE_MIN_RANK) then --just show it if the player used his moderator rights
                local x, y, z = getElementPosition(self:getObject())
                local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
                self:getOwner():sendShortMessage(_("%s %s hat euer Objekt %s in %s, %s gelöscht!", self:getPlacer(),
                    RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2), 10000)
            end
            return true 
        end
        if player:getFaction():getPlayerRank(player) >= OBJECT_DELETE_MIN_RANK then
            return true
        else
            player:sendError(_("Um das Objekt zu löschen benötigst du mindestens Rang %d", player, OBJECT_DELETE_MIN_RANK))
            return false
        end
    end
end
