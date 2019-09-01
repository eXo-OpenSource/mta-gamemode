-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemEmptyCan.lua
-- *  PURPOSE:     Item Empty Watering-Can class
-- *
-- ****************************************************************************
ItemCan = inherit(ItemNew)

function ItemCan:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	ItemCanManager:getSingleton():toggleCan(player, self.m_Item.Id)
end
