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
	if not FISHING_BAGS[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_BAGS[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_BAGS[itemName].level)
end

function ItemFishing:use(player, itemId, bag, place, itemName)
	if itemName == "Angelrute" then
		Fishing:getSingleton():inventoryUse(player)
		return
	end

	if itemName == "Köder" then
		player:sendError("Du kannst den Köder so nicht benutzen.") --todo?!
		return
	end

	local value = fromJSON(player:getInventory():getItemValueByBag("Items", place))

	if value then
		for _, v in pairs(value) do
			v.fishName = Fishing:getSingleton():getFishNameFromId(v.Id)
		end
	end

	player:triggerEvent("closeInventory")
	player:triggerEvent("showCoolingBag", itemName, value)
end

function ItemFishing:useSecondary(player, itemId, bag, place, itemName)
	if itemName == "Angelrute" then
		player:triggerEvent("closeInventory")
		player:triggerEvent("showFishingRodGUI")
		return
	end
end
