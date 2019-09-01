-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(ItemWorld)

function ItemRadio:constructor()
	self.m_WorldItemClass = RadioWorldItem
end

function ItemRadio:destructor()
end
