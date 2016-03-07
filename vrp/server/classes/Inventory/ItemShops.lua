-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemShops.lua
-- *  PURPOSE:     Item shops class
-- *
-- ****************************************************************************
ItemShops = inherit(Singleton)
addEvent("itemBuy", true)

function ItemShops:constructor()
	self:addShop(Vector3(1352.4, -1758.7, 13.5), Vector3(-30.98, -91.9, 1003.5), 0, 0, Vector3(-28, -89.9, 1002.7), 18,
		{
			["Radio"] = 2000,
			["Zigaretten"] = 10,
			["Wuerfel"] = 10

		})
end

function ItemShops:addShop(enterPosition, exitPosition, enterRotation, exitRotation, markerPosition, interiorId, items)
	InteriorEnterExit:new(enterPosition, exitPosition, enterRotation, exitRotation, interiorId)
	local marker = Marker(markerPosition, "cylinder", 1, 255, 255, 0, 200)
	marker:setInterior(interiorId)
	Blip:new("Shop.png", enterPosition.x, enterPosition.y)

	addEventHandler("onMarkerHit", marker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				hitElement:triggerEvent("itemShopGUI", items)
			end
		end
	)

	addEventHandler("itemBuy", root,
		function(item, amount)
			if not item or not tonumber(amount) then return end
			-- Todo: Add anticheat checks here

			local price = items[item]
			if not price then return end
			price = price * amount

			if client:getMoney() >= price then
				if client:getInventory():getFreePlacesForItem(item) >= amount then
					client:getInventory():giveItem(item, amount)
					client:takeMoney(price)
				else
					client:sendError(_("Die maximale Anzahl dieses Items beträgt %d!", client, client:getInventory():getMaxItemAmount(item)))
				end
			else
				client:sendError(_("Du hast nicht genügend Geld für diesen Einkauf!", client))
			end
		end
	)
end
