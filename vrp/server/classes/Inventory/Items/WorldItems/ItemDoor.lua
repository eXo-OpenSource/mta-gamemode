-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDoor.lua
-- *  PURPOSE:     Door item class
-- *
-- ****************************************************************************
ItemDoor = inherit(ItemWorld)

function ItemDoor:constructor()
	self.m_WorldItemClass = DoorWorldItem
end

function ItemDoor:destructor()
end
