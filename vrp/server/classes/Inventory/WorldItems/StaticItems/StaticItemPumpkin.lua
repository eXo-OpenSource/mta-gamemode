-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/StaticItemPumpkin.lua
-- *  PURPOSE:     StaticItemPumpkin class
-- *
-- ****************************************************************************

StaticItemPumpkin = inherit(StaticWorldItem)

function StaticItemPumpkin:constructor(position, rotation, interior, dimension)
    self.m_ItemClass = "pumpkin"
    self.m_ItemAmount = 1

    StaticWorldItem.constructor(self, 1935, position, rotation, interior, dimension)
end

function StaticItemPumpkin:onCollect(player)
    player:giveAchievement(109) -- Finde deinen ersten Kürbis
	if player:getInventoryOld():getItemAmount("Osterei") >= 50 then
		player:giveAchievement(110) -- Kürbissammler
	end
end