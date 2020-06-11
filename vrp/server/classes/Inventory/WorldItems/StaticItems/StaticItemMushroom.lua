-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/StaticItemMushroom.lua
-- *  PURPOSE:     StaticItemMushroom class
-- *
-- ****************************************************************************

StaticItemMushroom = inherit(StaticWorldItem)

function StaticItemMushroom:constructor(position, rotation, interior, dimension)
    if chance(50) then
        self.m_Model = 1947
        self.m_isMagic = true
        self.m_ItemClass = "shrooms"
        self.m_ItemAmount = 1
    else
        self.m_Model = 1882
        self.m_isMagic = false
        self.m_ItemClass = "mushroom"
        self.m_ItemAmount = 1
    end

    StaticWorldItem.constructor(self, self.m_Model, position, rotation, interior, dimension)
end