-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemHealpack.lua
-- *  PURPOSE:     Healpack Item class
-- *
-- ****************************************************************************

ItemHealpack = inherit(ItemNew)

function ItemHealpack:use()
	local player = self.m_Inventory:getPlayer()

	if not player then return false end

	player:meChat(true, "benutzt ein Medikit!")
	player:setHealth(100)

	return true, true
end
