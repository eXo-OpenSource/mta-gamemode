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
	local inventory = player:getInventoryOld()
	local value = InventoryOld:getItemValueByBag( bag, place)
	if value then
		local skinID = tonumber(value)
		if skinID then
			if player:getData("isInDeathMatch") then
				player:sendError(_("Du kannst deine Kleidung nicht während des Aufenthaltes in einer DM-Lobby wechseln!", player))
				return false
			end
			if not player:isFactionDuty() then
				player:setSkin(skinID, true)
				player:meChat(true, "wechselt seine Kleidung.")
			else
				if player:getFaction():isEvilFaction() then
					player:sendError(_("Du musst die Farben deiner Fraktion tragen!", player))
				else
					player:sendError(_("Du kannst im Dienst nicht deine Kleidung wechseln!", player))
				end
			end
		end
	end
end
