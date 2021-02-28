-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFishingAccessorie.lua
-- *  PURPOSE:     Fishing accessorie item class
-- *
-- ****************************************************************************
ItemFishingAccessorie = inherit(ItemNew)

function ItemFishingAccessorie:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	local accessorieAmount = self.m_Inventory:getItemAmount(self.m_ItemData.TechnicalName)
	local fishingRods = {}

	for fishingRod, fishingRodData in pairs(FISHING_RODS) do
        local fishingRodItem = self.m_Inventory:getItem(fishingRod)
        if fishingRodData.accessorieSlots > 0 and fishingRodItem then
            table.insert(fishingRods, fishingRodItem)
        end
    end

	player:triggerEvent("showEquipmentSelectionGUI", fishingRods, self.m_Item, accessorieAmount)

	return true
end

function ItemFishingAccessorie.canBuy(player, itemName)
	if not FISHING_EQUIPMENT[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_EQUIPMENT[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_EQUIPMENT[itemName].level)
end