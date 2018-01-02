-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFirework.lua
-- *  PURPOSE:     Firework items Class
-- *
-- ****************************************************************************
ItemFirework = inherit(Item)

ItemFirework.Cooldown = { -- in Seconds
	["Römische Kerzen Batterie"] = 20,
	["Raketen Batterie"] = 20,
	["Rakete"] = 1,
	["Römische Kerze"] = 5,
	["Rohrbombe"] = 5,
	["Kugelbombe"] = 5,
}

function ItemFirework:constructor()
end

function ItemFirework:destructor()
end

function ItemFirework:use(player, itemId, bag, place, itemName)
	if not FIREWORK_ENABLED then
		player:sendError("Das Feuerwerk ist zurzeit deaktiviert!")
		return
	end

	if player.vehicle then
		player:sendError("Du kannst kein Feuerwerk in einem Fahrzeug zünden!")
		return
	end

	if player:getInterior() == 0 and player:getDimension() == 0 then
		if ItemFirework.Cooldown[itemName] then
			if not player.fireworkCooldown then player.fireworkCooldown = {} end
			if player.fireworkCooldown[itemName] then
				if not timestampCoolDown(player.fireworkCooldown[itemName], ItemFirework.Cooldown[itemName]) then
					player:sendError(_("Du kannst die %s nicht so knapp hintereinander nutzen!", player, itemName))
					return
				end
			end
			player.fireworkCooldown[itemName] = getRealTime().timestamp
		end

		local rnd = 0

		if itemName == "Raketen Batterie" then rnd = math.random(5, 8)
		elseif itemName == "Römische Kerze" then rnd = math.random(10, 15)
		elseif itemName == "Römische Kerzen Batterie" then rnd = math.random(7, 12)
		end
		player:meChat(true, _("zündet eine/n %s!", player, itemName))

		triggerClientEvent(root, "onClientFireworkStart", player, itemName, serialiseVector(player:getPosition()), rnd)
		player:getInventory():removeItem(itemName, 1)
	else
		player:sendError("Du kannst kein Feuerwerk in einem Interior zünden!")
	end
end
