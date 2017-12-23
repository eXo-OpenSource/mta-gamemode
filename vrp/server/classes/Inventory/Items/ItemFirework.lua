-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFirework.lua
-- *  PURPOSE:     Firework items Class
-- *
-- ****************************************************************************
ItemFirework = inherit(Item)

function ItemFirework:constructor()
end

function ItemFirework:destructor()
end

function ItemFirework:use(player, itemId, bag, place, itemName)
	if not FIREWORK_ENABLED then
		player:sendError("Das Feuerwerk ist zurzeit deaktiviert!")
		return
	end

	if player:getInterior() == 0 and player:getDimension() == 0 then

		local rnd = 0
		if itemName == "Raketen Batterie" then rnd = math.random(5, 8)
		elseif itemName == "Römische Kerze" then rnd = math.random(10, 15)
		elseif itemName == "Römische Kerzen Batterie" then rnd = math.random(10, 15)
		end
		triggerClientEvent(root, "onClientFireworkStart", player, itemName, serialiseVector(player:getPosition()), rnd)
		player:getInventory():removeItem(itemName, 1)
	else
		player:sendError("Du kannst kein Feuerwerk in einem Interior zünden!")
	end
end
