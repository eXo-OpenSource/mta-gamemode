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
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	if value then
		local skinID = tonumber(value)
		if skinID then
			if not player:isFactionDuty() then
				player:setSkin(skinID, true)
				player:meChat(true, "wechselt seine Kleidung.")
			else
				player:sendError(_("Du kannst im Dienst nicht deine Kleidung wechseln!", player))
			end
		end
	end
end
