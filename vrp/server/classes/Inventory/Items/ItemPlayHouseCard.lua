-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/ItemPlayHouseCard.lua
-- *  PURPOSE:     ItemPlayHouseCard
-- *
-- ****************************************************************************
ItemPlayHouseCard = inherit( Item )

function ItemPlayHouseCard:constructor()

end

function ItemPlayHouseCard:destructor()

end

function ItemPlayHouseCard:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	if value then
		local current = getRealTime().timestamp
		local state
		if tonumber(value) then 
			local duration = tonumber(value) - current 
			if duration > 0 then 
				state = true
			end
		end
		if state then
			player:sendShortMessage(_("Diese Karte ist aktiv und läuft am %s ab!", player, getOpticalTimestamp(tonumber(value))))
		else 
			player:sendShortMessage(_("Diese Karte ist abelaufen am %s!", player, getOpticalTimestamp(tonumber(value))))
		end
	end
end
