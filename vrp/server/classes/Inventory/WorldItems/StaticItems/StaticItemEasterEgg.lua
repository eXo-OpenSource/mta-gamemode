-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/StaticItemEasterEgg.lua
-- *  PURPOSE:     StaticItemEasterEgg class
-- *
-- ****************************************************************************

StaticItemEasterEgg = inherit(StaticWorldItem)

function StaticItemEasterEgg:constructor(position, rotation, interior, dimension)
    self.m_ItemClass = "easterEgg"
    self.m_ItemAmount = 1

    StaticWorldItem.constructor(self, 1933, position, rotation, interior, dimension)
end

function StaticItemEasterEgg:onCollect(player)
    player:giveAchievement(88) -- Finde dein erstes Osterei
	if player:getInventoryOld():getItemAmount("Osterei") >= 50 then
		player:giveAchievement(89) -- Ostereisammler
	end
end