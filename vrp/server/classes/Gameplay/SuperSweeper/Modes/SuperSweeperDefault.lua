-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/SuperSweeper/Modes/SuperSweeperDefault.lua
-- *  PURPOSE:     SuperSweeper Default Lobby class
-- *
-- ****************************************************************************

SuperSweeperDefault = inherit(SuperSweeperLobby)

SuperSweeperDefault.Name = "DM"

SuperSweeperDefault.SupportedPriceTypes = {
	{name = "winnerTakesAll", label = "Nur Gewinner"},
	{name = "top3", label = "Top 3 (67%%, 22%%, 11%%)"}
}

SuperSweeperDefault.Settings = {
	["timeLimit"] = {name = "timeLimit", label = "Zeitlimit", type = "number", unit = "min", description = "Von 15 bis 60 Minuten", default = 15, range = {min = 5, max = 60}},
	["scoreLimit"] = {name = "scoreLimit", label = "Punktelimit", type = "number", description = "Von 5 bis 120 Punkte", default = 45, range = {min = 5, max = 120}},
	["minigunTime"] = {name = "minigunTime", label = "Minigun Zeit", type = "number", unit = "s", description = "Von 10 bis unendlich (Wert = 0) Sekunden", default = 60, range = {min = 10, max = 0}},
	["crates"] = {name = "crates", label = "Kisten", type = "bool", description = "Sollen Kisten mit zufälligen Gegenstände gespawnt werden?", default = true},
	["crateRespawnTime"] = {name = "crateRespawnTime", label = "Kisten Respawn Zeit", type = "number", unit = "s", description = "Von 5 bis unendlich (Wert = 0) Sekunden", default = 30, range = {min = 5, max = 0}},
	["itemChances"] = {name = "itemChances", label = "Items", type = "list/number", description = "Bei dem Wert 0 wird das Item deaktiviert.",
		values = {
			["colt 45"] = {name = "colt 45", label = "Colt 45", weapon = true, default = 30},
			["deagle"] = {name = "deagle", label = "Deagle", weapon = true, default = 30},
			["uzi"] = {name = "uzi", label = "Uzi", weapon = true, default = 25},
			["mp5"] = {name = "mp5", label = "MP5", weapon = true, default = 25},
			["ak-47"] = {name = "ak-47", label = "AK-47", weapon = true, default = 20},
			["m4"] = {name = "m4", label = "M4", weapon = true, default = 20},
			["tec-9"] = {name = "tec-9", label = "Tec-9", weapon = true, default = 15},
			["minigun"] = {name = "minigun", label = "Minigun", weapon = true, default = 5},
			["oil"] = {name = "oil", label = "Öl", weapon = false, default = 10},
			["smoke"] = {name = "smoke", label = "Rauch", weapon = false, default = 10},
			["invisibility"] = {name = "invisibility", label = "Unsichtbarkeit", weapon = false, default = 5},
			["heal"] = {name = "heal", label = "Heilen", weapon = false, default = 40},
			["nothing"] = {name = "nothing", label = "nichts", weapon = false, default = 10}
		}
	},
	["spawnWeapon"] = {name = "spawnWeapon", label = "Spawn Waffe", type = "select", default = "colt 45",
		values = {
			["colt 45"] = {name = "colt 45", label = "Colt 45"},
			["deagle"] = {name = "deagle", label = "Deagle"},
			["uzi"] = {name = "uzi", label = "Uzi"},
			["mp5"] = {name = "mp5", label = "MP5"},
			["ak-47"] = {name = "ak-47", label = "AK-47"},
			["m4"] = {name = "m4", label = "M4"},
			["tec-9"] = {name = "tec-9", label = "Tec-9"},
			["minigun"] = {name = "minigun", label = "Minigun"},
			["random"] = {name = "random", label = "Zufall"}
		}
	}
}

function SuperSweeperDefault:constructor(id, name, owner, mode, maxPlayer, map, password, settings) 
	self.m_Settings = {}
	self.m_ItemChances = {}
	self.m_WeaponChances = {}

	for key, value in pairs(SuperSweeperDefault.Settings) do
		if value.type == "number" then
			self.m_Settings[value.name] = value.default or 0
		elseif value.type == "bool" then
			self.m_Settings[value.name] = value.default or true
		elseif value.type == "select" then
			self.m_Settings[value.name] = value.default or value.values[1]
		elseif value.type == "list/number" then
			self.m_Settings[value.name] = {}

			for key2, value2 in pairs(value.values) do
				self.m_Settings[value.name][value2.name] = value2.default or 0
			end
		end
	end
	
	for key, value in pairs(settings or {}) do
		self.m_Settings[key] = value
	end

	for key, value in pairs(self.m_Settings["itemChances"]) do
		if value ~= 0 then
			self.m_ItemChances[key] = value

			if SuperSweeperDefault.Settings["itemChances"] and
			SuperSweeperDefault.Settings["itemChances"].values[key] and
			SuperSweeperDefault.Settings["itemChances"].values[key].weapon then
				if key ~= "minigun" or (key == "minigun" and self.m_Settings["minigunTime"] == 0) then
					self.m_WeaponChances[key] = value
				end
			end
		end
	end
	
	SuperSweeperLobby.constructor(self, id, name, owner, mode, maxPlayer, map, password, settings)

	self.m_OnColCrateHit = bind(self.Event_onColCrateHit, self)
	self.m_ResetWeapon = bind(self.resetWeapon, self)
	self.m_Crates = {}

	if self.m_Settings["crates"] then
		for k, position in ipairs(SuperSweeperManager.Maps[self.m_Map].crates) do
			local respawnTime = self.m_Settings["crateRespawnTime"] * 1000
			if respawnTime == 0 then respawnTime = 24 * 60 * 60 * 1000 end
			local pickup = Pickup(position, 3, 2977, respawnTime)
			pickup:setDimension(self.m_Dimension)
			pickup:setInterior(self.m_Interior)

			local collider = createColSphere(position, 3)
			collider:setDimension(self.m_Dimension)
			collider:setInterior(self.m_Interior)
			pickup.m_Collider = collider
			collider.m_Pickup = pickup

			addEventHandler("onColShapeHit", collider, self.m_OnColCrateHit)

			table.insert(self.m_Crates, pickup)
		end
	end
end

function SuperSweeperDefault:destructor()
	SuperSweeperLobby.destructor(self)

	for k, v in ipairs(self.m_Crates) do
		v:destroy()
	end
end

function SuperSweeperDefault:Event_onColCrateHit(player, matchingDimension)
	if matchingDimension and player:getType() == "player" and player.vehicle and player.m_SuperSweeperVehicle == player.vehicle then
		if source.m_Pickup and source.m_Pickup.spawned then
			source.m_Pickup:use(player)

			local action = nil
			local totalNumber = 0
			local numberCounter = 0
			local number = 0

			for k, v in pairs(self.m_ItemChances) do
				totalNumber = totalNumber + v
			end

			number = math.floor(math.random() * totalNumber)

			for k, v in pairs(self.m_ItemChances) do
				if numberCounter <= number and (numberCounter + v) >= number then
					action = k
					break
				else
					numberCounter = numberCounter + v
				end
			end
			
			if SuperSweeperManager.Weapon[player.vehicle.model] and SuperSweeperManager.Weapon[player.vehicle.model][action] then
				if player.vehicle.m_MinigunTimer then
					killTimer(player.vehicle.m_MinigunTimer)
					player.vehicle.m_MinigunTimer = nil
					player:triggerEvent("CountdownStop", "Minigun")
				end

				if action == "minigun" and self.m_Settings["minigunTime"] ~= 0 then
					local lastWeapon = player.vehicle:getWeapon()
					player:triggerEvent("Countdown", self.m_Settings["minigunTime"], "Minigun")

					player.vehicle.m_MinigunTimer = setTimer(self.m_ResetWeapon, self.m_Settings["minigunTime"] * 1000, 1, player, player.vehicle, lastWeapon)
				end
				self:setWeapon(player.vehicle, action)
				player:sendShortMessage(_("In der Box befand sich eine %s.", player, SuperSweeperManager.Weapon[player.vehicle.model][action].name), _("Super Sweeper", player), nil, 1500)
			else
				if action == "heal" then
					player.vehicle:fix()
					player:sendShortMessage(_("Dein Fahrzeug wurde repariert.", player), _("Super Sweeper", player), nil, 1500)
				elseif action == "oil" then

				elseif action == "smoke" then
				
				elseif action == "invisibility" then

				else
					player:sendShortMessage(_("Diese Box war leer.", player), _("Super Sweeper", player), nil, 1500)
				end
			end
		end
	end
end

function SuperSweeperDefault:resetWeapon(player, vehicle, weapon)
	if not weapon or weapon == "minigun" then weapon = "colt 45" end
	self:setWeapon(vehicle, weapon)
	player.vehicle.m_MinigunTimer = nil
	player:triggerEvent("CountdownStop", "Minigun")
end

function SuperSweeperDefault:getSpawnWeapon(player)
	if self.m_Settings["spawnWeapon"] == "random" then
		local weapon = nil
		local totalNumber = 0
		local numberCounter = 0
		local number = 0

		for k, v in pairs(self.m_WeaponChances) do
			totalNumber = totalNumber + v
		end

		number = math.floor(math.random() * totalNumber)

		for k, v in pairs(self.m_WeaponChances) do
			if numberCounter <= number and (numberCounter + v) >= number then
				weapon = k
				break
			else
				numberCounter = numberCounter + v
			end
		end
		outputConsole(inspect(self.m_WeaponChances))
		outputConsole(inspect(number))
		outputConsole(inspect(weapon))

		return weapon or "colt 45"
	end

	return self.m_Settings["spawnWeapon"] or "colt 45"
end

function SuperSweeperDefault:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("superSweeperRefreshGUI", self.m_Players)
	end
end

function SuperSweeperDefault:addPlayer(player)
	SuperSweeperLobby.addPlayer(self, player)

	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0
	}
	-- giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
	self:refreshGUI()
	SuperSweeperLobby.respawnPlayer(self, player)
end

function SuperSweeperDefault:removePlayer(player, isServerStop)
	SuperSweeperLobby.removePlayer(self, player, isServerStop)
	self.m_Players[player] = nil

	if not isServerStop then
		player:triggerEvent("superSweeperCloseGUI")
		self:refreshGUI()
	end
end

function SuperSweeperDefault:onWasted(player, killer, weapon)
	SuperSweeperLobby.onWasted(self, player, killer, weapon)
	local vehicleWeapon = nil

	if player.m_SuperSweeperVehicle and player.m_SuperSweeperVehicle.m_LastHitBy then
		local vehicle = player.m_SuperSweeperVehicle.m_LastHitBy
		if vehicle.m_Player and isElement(vehicle.m_Player) then
			vehicleWeapon = vehicle:getData("weapon")
			self:increaseKill(vehicle.m_Player, vehicleWeapon, true)
		end
	end
	self:increaseDead(player, vehicleWeapon, true)
	player.m_SuperSweeperLobby:respawnPlayer(player, true)
end
