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
        elseif self:getOwner() == player then
            return true
        else
            if isElement(self:getOwner()) then player:sendError(_("Dieses Objekt gehört %s", player, self:getOwner():getName())) end
            return false
        end
    elseif action == WorldItem.Action.Collect then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            return true 
        elseif self:getOwner() == player then
            return true
        else
            if isElement(self:getOwner()) then player:sendError(_("Dieses Objekt gehört %s", player, self:getOwner():getName())) end
            return false
        end
    elseif action == WorldItem.Action.Delete then
        if WorldItem.hasPlayerPermissionTo(self, player, action) then -- does the player have superuser rights (admin)?
            if self:getPlacer().isLoggedIn and self:getPlacer():isLoggedIn() and self:getObject() then
                local x, y, z = getElementPosition(self:getObject())
                local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
                self:getPlacer():sendWarning(_("%s %s hat dein Objekt %s in %s, %s gelöscht!", self:getPlacer(),
                    RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2), 10000)
            end
            return true 
        elseif self:getOwner() == player then
            return true
        else
            if isElement(self:getOwner()) then player:sendError(_("Dieses Objekt gehört %s", player, self:getOwner():getName())) end
            return false
        end
    end
end