-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBomb.lua
-- *  PURPOSE:     C4 bomb item class
-- *
-- ****************************************************************************
ItemSlam = inherit(ItemWorld)

function ItemSlam:constructor()
	self.m_WorldItemClass = SlamWorldItem
end

function ItemSlam:destructor()
end
