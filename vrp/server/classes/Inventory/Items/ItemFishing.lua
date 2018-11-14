-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemFishing.lua
-- *  PURPOSE:     Fishing item class
-- *
-- ****************************************************************************
ItemFishing = inherit(Item)

function ItemFishing:constructor()

end

function ItemFishing:destructor()

end

function ItemFishing:canBuy(player, itemName)
	if not FISHING_EQUIPMENT[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_EQUIPMENT[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_EQUIPMENT[itemName].level)
end

function ItemFishing:isFishingRod(itemName)
	for _, fishingRod in pairs(FISHING_RODS) do
		if fishingRod == itemName then
			return true
		end
	end
end

function ItemFishing:isCoolingBag(itemName)
	for _, coolingBag in pairs(FISHING_COOLING_BAGS) do
		if coolingBag == itemName then
			return true
		end
	end
end

function ItemFishing:use(player, itemId, bag, place, itemName)
	if self:isFishingRod(itemName) then
		Fishing:getSingleton():inventoryUse(player)
		return
	end

	if self:isCoolingBag(itemName) then
		local value = fromJSON(player:getInventory():getItemValueByBag("Items", place))

		if value then
			for _, v in pairs(value) do
				v.fishName = Fishing:getSingleton():getFishNameFromId(v.Id)
			end
		end

		player:triggerEvent("closeInventory")
		player:triggerEvent("showCoolingBag", itemName, value)
		return
	end

	if itemName == "Köder" then
		local playerInventory = player:getInventory()
		local baitAmount = playerInventory:getItemAmount("Köder")
		local fishingRods = {}

		for _, fishingRod in pairs(FISHING_RODS) do
			if playerInventory:getItemAmount(fishingRod) > 0 then
				table.insert(fishingRods, fishingRod)
			end
		end

		player:triggerEvent("showBaidSelectionGUI", fishingRods, baitAmount)
		return
	end
end

function ItemFishing:useSecondary(player, itemId, bag, place, itemName)
	if itemName == "Bambusstange" then
		player:sendError("Diese Angel bietet keine Interaktion!")
		return
	end

	if itemName == "Angelrute" or itemName == "Profi Angelrute" then
		player:triggerEvent("closeInventory")
		player:triggerEvent("showFishingRodGUI", itemName)
		return
	end
end
