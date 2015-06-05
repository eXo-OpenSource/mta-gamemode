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
			[ITEM_RADIO] = 2000,
			
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
		function(itemId, amount)
			if not tonumber(itemId) or not tonumber(amount) then return end
			-- Todo: Add anticheat checks here

			local price = items[itemId]
			if not price then return end
			price = price * amount

			if client:getMoney() >= price then
				client:getInventory():addItem(itemId, amount)
				client:takeMoney(price)
			else
				client:sendError(_("Du hast nicht genügend Geld für diesen Einkauf!", client))
			end
		end
	)
end
