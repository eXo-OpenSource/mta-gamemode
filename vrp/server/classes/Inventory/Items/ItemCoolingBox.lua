-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemCoolingBox.lua
-- *  PURPOSE:     Cooling box item class
-- *
-- ****************************************************************************
ItemCoolingBox = inherit(ItemNew)

function ItemCoolingBox:use()
	local player = self.m_Inventory:getPlayer()

	if not InventoryManager:getSingleton():getInventory(DbElementType.CoolingBox, self.m_Item.Id, true) then
		InventoryManager:getSingleton():createPermanentInventory(self.m_Item.Id, DbElementType.CoolingBox, FISHING_BAGS[self:getTechnicalName()].max, 3)
	end

	player:triggerEvent("openInventory", self:getName(), DbElementType.CoolingBox, self.m_Item.Id, "small")

	return true
end

function ItemCoolingBox.canBuy(player, itemName)
	if not FISHING_EQUIPMENT[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_EQUIPMENT[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_EQUIPMENT[itemName].level)
end