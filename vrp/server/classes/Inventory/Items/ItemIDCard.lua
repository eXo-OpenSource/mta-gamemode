-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemIDCard.lua
-- *  PURPOSE:     Id Card
-- *
-- ****************************************************************************
ItemIDCard = inherit(ItemNew)

function ItemIDCard:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	player:triggerEvent("closeInventory")
	player:triggerEvent("showIDCard")

	return true
end
