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
