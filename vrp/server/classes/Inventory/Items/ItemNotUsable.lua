-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemNotUsable.lua
-- *  PURPOSE:     class for items that are not usable via right clicking
-- *
-- ****************************************************************************
ItemNotUsable = inherit(ItemNew)

function ItemNotUsable:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	player:sendInfo(_("Dieses Item ist so nicht einsetzbar.", player))
	return false
end