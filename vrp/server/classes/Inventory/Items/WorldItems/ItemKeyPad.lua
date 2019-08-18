-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemKeyPad.lua
-- *  PURPOSE:     Key Pad item class
-- *
-- ****************************************************************************
ItemKeyPad = inherit(ItemWorld)

function ItemKeyPad:constructor()
	self.m_WorldItemClass = KeyPadWorldItem
end

function ItemKeyPad:destructor()
end
