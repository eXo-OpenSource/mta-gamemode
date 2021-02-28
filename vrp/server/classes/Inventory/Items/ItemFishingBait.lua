-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFishingBait.lua
-- *  PURPOSE:     Fishing bait item class
-- *
-- ****************************************************************************
ItemFishingBait = inherit(ItemNew)

function ItemFishingBait:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	local baitAmount = self.m_Inventory:getItemAmount(self.m_ItemData.TechnicalName)
	local fishingRods = {}

	for fishingRod, fishingRodData in pairs(FISHING_RODS) do
		local fishingRodItem = self.m_Inventory:getItem(fishingRod)
		if fishingRodData.baitSlots > 0 and fishingRodItem then
			table.insert(fishingRods, fishingRod)
		end
	end

	player:triggerEvent("showEquipmentSelectionGUI", fishingRods, self.m_Item, baitAmount)

	return true
end

function ItemFishingBait:useSecondary()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	if self:getTechnicalName() == "bait" then
		if math.random(1, 100) <= 2 then
			player:giveAchievement(105) --Proteine?!
			player:kill()
			return true, true
		end
		
		local instance = ItemFood:new(self.m_Inventory, self.m_ItemData, self.m_Item)
		local success, remove, removeAll = instance:use()
		delete(instance)

		if success then
			return true, true
		end
	end
end

function ItemFishingBait.canBuy(player, itemName)
	if not FISHING_EQUIPMENT[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_EQUIPMENT[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_EQUIPMENT[itemName].level)
end