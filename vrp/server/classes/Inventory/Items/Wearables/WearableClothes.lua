-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableShirt.lua
-- *  PURPOSE:     Wearable Clotes
-- *
-- ****************************************************************************
WearableClothes = inherit( Item )

function WearableClothes:constructor()

end

function WearableClothes:destructor()

end

function WearableClothes:use(player, itemId, bag, place, itemName)
	local inventory = InventoryManager:getSingleton():getPlayerInventory(player)
	local value = inventory:getItemValueByBag( bag, place)
	if value then 
	
	end
end
