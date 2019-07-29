-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemKeyPad.lua
-- *  PURPOSE:     Key Pad item class
-- *
-- ****************************************************************************
ItemKeyPad = inherit(ItemWorld)
ItemKeyPad.Map = {}

function ItemKeyPad:constructor()
	self.m_WorldItemClass = KeyPadWorldItem
end

function ItemKeyPad:destructor()
end
