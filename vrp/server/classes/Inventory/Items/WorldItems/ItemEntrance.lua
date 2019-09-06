-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemEntrance.lua
-- *  PURPOSE:     Entrance item class
-- *
-- ****************************************************************************
ItemEntrance = inherit(ItemWorld)

function ItemEntrance:constructor()
	self.m_WorldItemClass = EntranceWorldItem
end

function ItemEntrance:destructor()
end
