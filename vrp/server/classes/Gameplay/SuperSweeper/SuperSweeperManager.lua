SuperSweeperManager = inherit(Singleton)
SuperSweeperManager.Map = {}


--[[
	MUST
	- Sweeper with weapons - spawn it colt - done
	- Pickups with give random pickups, short invicibilty or instant explosion - done
	- Round goes until someone has 30 kills?

	SHOULD
	- Lobby with prices (100 to 5000$ entry, split upon top 3 (66%, 22%, 11%) or winner takes all)
	- Multiple maps
	- Different modes
	- Spectate

	----------------------------------

	TODO
	- Add round end
	- Implement persistent statistics (kills, money earned)
	- Make it easier to find the enemy??
	- Improve zone push back
	- Additional items like "oil", "short invsibility" or "smoke"

https://dev.prineside.com/en/gtasa_samp_model_id/model/19898-OilFloorStain1/

	DONE
	- Weapon despawn if vehicle gets destroyed
	- Fix zone
	- Stop vehicle shooting if driver leaves it
	- Add second instant dead zone
	- Add dead zone if too high
	- Add instant death when leaving the vehicle
	- Show players on minimap
	- Improve speed of sweeper
	- Add scoreboard
	- Add HUD for sweeper
	- Add instant death if in water
	- Bug that prevents vehicle from burning (after second spawn?)
	- Add repair pickup?
	- Add pickup notification?
	- Limit minigun to 30 seconds??
	- Implement lobby creation
	- In the death screen it shows the wrong player (always suicide!)
	- Add hit sound
	- Disable limiter
	- Disable cruise control
	- Disable seatbelt
	- Disable admin repair for super sweeper vehicles
	- Disable motor on/off (x) and breaks
	- Add special text if player hits instant kill zone and if they drown
	- F11 shows the HUD and Radar again
	- Add health bar
]]

SuperSweeperManager.Maps = {
	sf_downtown = {
		name = "SF Downtown",
		selectable = true,
		interior = 0,
		border = {
			position = Vector2(-2017.423, 702.944),
			size = Vector2(533.162, 499.877),
			minHeight = 0,
			maxHeight = 100,
		},
		spawns = {
			{ position = Vector3(-1494.9501953125, 727.7548828125, 6.9096584320068), rotation = Vector3(0.1702880859375, 0, 62.034301757813) },
			{ position = Vector3(-1700.9443359375, 709.462890625, 24.615629196167), rotation = Vector3(0, 359.99447631836, 18.8525390625) },
			{ position = Vector3(-1784.6826171875, 708.8193359375, 34.650386810303), rotation = Vector3(0.2252197265625, 7.877197265625, 1.6973876953125) },
			{ position = Vector3(-1830.8583984375, 711.0244140625, 37.051212310791), rotation = Vector3(9.0032958984375, 0.3240966796875, 357.97302246094) },
			{ position = Vector3(-1888.73046875, 711.87890625, 45.170475006104), rotation = Vector3(0, 359.99447631836, 20.797119140625) },
			{ position = Vector3(-1986.98046875, 712.3447265625, 46.287647247314), rotation = Vector3(0, 359.99447631836, 89.884643554688) },
			{ position = Vector3(-1657.7900390625, 818.234375, 17.298141479492), rotation = Vector3(14.386596679688, 19.275512695313, 17.056274414063) },
			{ position = Vector3(-1787.921875, 809.146484375, 24.615726470947), rotation = Vector3(359.9670715332, 359.99447631836, 17.193603515625) },
			{ position = Vector3(-2014.1162109375, 820.6435546875, 45.170421600342), rotation = Vector3(0, 359.99447631836, 315.6591796875) },
			{ position = Vector3(-1592.68359375, 898.8662109375, 8.9517288208008), rotation = Vector3(0, 359.99447631836, 5.4052734375) },
			{ position = Vector3(-1740.861328125, 901.6728515625, 24.811101913452), rotation = Vector3(0, 359.99447631836, 15.347900390625) },
			{ position = Vector3(-1987.494140625, 949.1669921875, 45.17041015625), rotation = Vector3(0, 0, 191.64001464844) },
			{ position = Vector3(-1852.404296875, 949.4619140625, 34.767631530762), rotation = Vector3(359.81875610352, 354.88583374023, 182.07643127441) },
			{ position = Vector3(-1737.875, 975.7822265625, 17.31109046936), rotation = Vector3(0, 359.99447631836, 4.6527099609375) },
			{ position = Vector3(-1686.5244140625, 1058.3369140625, 17.311100006104), rotation = Vector3(0, 359.99447631836, 130.078125) },
			{ position = Vector3(-1577.35546875, 951.6962890625, 6.912543296814), rotation = Vector3(359.99447631836, 359.98901367188, 5.570068359375) },
			{ position = Vector3(-1630.1455078125, 1090.3095703125, 7.0525593757629), rotation = Vector3(358.94537353516, 359.00024414063, 271.77981567383) },
			{ position = Vector3(-1522.275390625, 1109.724609375, 6.9125728607178), rotation = Vector3(0.02197265625, 0.032958984375, 91.950073242188) },
			{ position = Vector3(-1799.8212890625, 1198.37109375, 24.844537734985), rotation = Vector3(0, 359.99447631836, 182.56530761719) },
			{ position = Vector3(-1895.25, 1197.4443359375, 44.052852630615), rotation = Vector3(12.821044921875, 0.17578125, 179.63189697266) },
			{ position = Vector3(-1942.9091796875, 1193.306640625, 45.167572021484), rotation = Vector3(0.1922607421875, 0.10986328125, 178.95080566406) },
			{ position = Vector3(-2010.4677734375, 1193.9677734375, 45.169040679932), rotation = Vector3(0.054931640625, 0.054931640625, 179.53308105469) },
			{ position = Vector3(-2009.21484375, 1085.9404296875, 55.44388961792), rotation = Vector3(0, 359.99447631836, 240.95764160156) },
			{ position = Vector3(-1808.5654296875, 1120.0185546875, 45.17049407959), rotation = Vector3(0, 359.99447631836, 179.87365722656) },
			{ position = Vector3(-1815.8876953125, 1073.55078125, 45.803295135498), rotation = Vector3(0, 359.99447631836, 300.85510253906) },
			{ position = Vector3(-1681.8818359375, 1109.990234375, 54.428272247314), rotation = Vector3(0, 359.99447631836, 89.901092529297) },
			{ position = Vector3(-1698.0234375, 1027.7314453125, 44.931030273438), rotation = Vector3(359.8681640625, 359.80227661133, 99.640502929688) },
			{ position = Vector3(-1856.787109375, 1042.537109375, 45.811088562012), rotation = Vector3(0, 359.99447631836, 82.452362060547) }
		},
		crates = {
			Vector3(-1595.0341796875, 1168.9765625, 6.9125990867615),
			Vector3(-1788.0498046875, 1186.85546875, 24.701694488525),
			Vector3(-1883.0771484375, 1177.4775390625, 45.021995544434),
			Vector3(-1966.326171875, 1066.9541015625, 55.295478820801),
			Vector3(-1794.6162109375, 1103.31640625, 45.020702362061),
			Vector3(-1714.021484375, 925.8125, 24.467353820801),
			Vector3(-1897.8974609375, 925.0673828125, 34.740707397461),
			Vector3(-2004.4296875, 885.130859375, 45.021987915039),
			Vector3(-1899.099609375, 844.58984375, 34.740772247314),
			Vector3(-1714.5849609375, 844.90625, 24.459415435791),
			Vector3(-1546.8828125, 845.1328125, 6.7605838775635),
			Vector3(-1550.7978515625, 731.6376953125, 6.7641739845276),
			Vector3(-1712.2353515625, 731.6435546875, 24.459367752075),
			Vector3(-1898.8818359375, 731.671875, 45.022026062012),
			Vector3(-2001.8212890625, 731.03515625, 45.199512481689)
		}
	}
}

SuperSweeperManager.Weapon = {
	[574] = {
		["colt 45"] = {
			name = "Colt 45",
			offset = Vector3(0, 1.7, 0),
			rotation = Vector3(0, 0, 90)
		},
		["deagle"] = {
			name = "Deagle",
			offset = Vector3(0, 1.7, 0),
			rotation = Vector3(0, 0, 90)
		},
		["uzi"] = {
			name = "Uzi",
			offset = Vector3(0, 1.75, 0),
			rotation = Vector3(0, 0, 90)
		},
		["mp5"] = {
			name = "MP5",
			offset = Vector3(0, 1.7, 0),
			rotation = Vector3(0, 0, 90)
		},
		["ak-47"] = {
			name = "AK-47",
			offset = Vector3(0, 1.7, 0),
			rotation = Vector3(0, 0, 90)
		},
		["m4"] = {
			name = "M4",
			offset = Vector3(0, 1.5, 0),
			rotation = Vector3(0, 0, 90)
		},
		["tec-9"] = {
			name = "Tec-9",
			offset = Vector3(0, 1.7, 0),
			rotation = Vector3(0, 0, 90)
		},
		["minigun"] = {
			name = "Minigun",
			offset = Vector3(0, 1.5, 0),
			rotation = Vector3(0, 30, 90)
		}
	}
}

function SuperSweeperManager:constructor()
	self.m_Modes = {
		["default"] = SuperSweeperDefault
	}

	self.m_BankServer = BankServer.get("gameplay.superSweeper")

	self.m_Blip = Blip:new("SuperSweeper.png", -1494.234, 920.223)
	self.m_Blip:setDisplayText("SuperSweeper-Arena", BLIP_CATEGORY.Leisure)
	self.m_Marker = createMarker(Vector3(-1494.234, 920.223, 7.188), "corona", 2, 255, 125, 0)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.Event_onMarkerHit, self))

	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.m_SuperSweeperLobby then
				player:triggerEvent("abortDeathGUI", true, true)
				player.m_SuperSweeperLobby:onWasted(player, killer, weapon)
				return true
			end
			if killer and killer.m_SuperSweeperLobby then
				killer:givePoints(1)
			end
		end
	)

	PlayerManager:getSingleton():getAFKHook():register(
		function(player)
			if player.m_SuperSweeperLobby then
				player.m_SuperSweeperLobby:removePlayer(player)
			end
		end
	)

	Player.getQuitHook():register(
		function(player)
			if player.m_SuperSweeperLobby then
				player.m_SuperSweeperLobby:removePlayer(player)
			end
		end
	)

	Player.getChatHook():register(
		function(player, text, type)
			if player.m_SuperSweeperLobby then
				return player.m_SuperSweeperLobby:onPlayerChat(player, text, type)
			end
		end
	)

	core:getStopHook():register(
		function()
			for id, lobby in pairs(SuperSweeperManager.Map) do
				for player, data in pairs(lobby.m_Players) do
					lobby:removePlayer(player, true)
				end
			end
		end
	)

	addRemoteEvents{"superSweeperRequestLobbys", "superSweeperJoinLobby", "superSweeperLeaveLobby", "superSweeperRequestCreateData", "superSweeperCreateLobby"}
	addEventHandler("superSweeperRequestLobbys", root, bind(self.requestLobbys, self))
	addEventHandler("superSweeperJoinLobby", root, bind(self.joinLobby, self))
	addEventHandler("superSweeperLeaveLobby", root, bind(self.leaveLobby, self))
	addEventHandler("superSweeperRequestCreateData", root, bind(self.requestCreateData, self))
	addEventHandler("superSweeperCreateLobby", root, bind(self.createPlayerLobby, self))

	self:loadServerLobbys()
end

function SuperSweeperManager:destructor()
end

function SuperSweeperManager:loadServerLobbys()
	self:createLobby("Lobby #1", "Server", "default", 20, "sf_downtown")
	self:createLobby("Lobby #2", "Server", "default", 20, "sf_downtown")
end

function SuperSweeperManager:createLobby(name, owner, mode, maxPlayer, map, password, settings)
	if not self.m_Modes[mode] then
		outputDebugString("Mode not found!", 1)
		return
	end

	local id = #SuperSweeperManager.Map+1
	SuperSweeperManager.Map[id] = self.m_Modes[mode]:new(id, name, owner, mode, maxPlayer, map, password, settings)
end

function SuperSweeperManager:requestLobbys()
	local lobbyTable = {}
	for id, lobby in pairs(SuperSweeperManager.Map) do
		lobbyTable[id] = {
			["name"] = lobby.m_Name,
			["players"] = lobby:getPlayerCount(),
			["map"] = SuperSweeperManager.Maps[lobby.m_Map].name,
			["mode"] = self.m_Modes[lobby.m_Mode].Name,
			["password"] = lobby.m_Password,
			["state"] = lobby.m_State,
			["playerNames"] = lobby:getPlayerString()
		}
	end
	client:triggerEvent("superSweeperReceiveLobbys", lobbyTable)
end

function SuperSweeperManager:joinLobby(id)
	if client:isFactionDuty() and client:getFaction():isStateFaction() then
		client:sendError(_("Du darfst nicht im Dienst in eine SW-Lobby! (Fraktion)", client))
		return
	end

	if client:isCompanyDuty() then
		client:sendError(_("Du darfst nicht im Dienst in eine SW-Lobby! (Unternehmen)", client))
		return
	end

	if SuperSweeperManager.Map[id] then
		SuperSweeperManager.Map[id]:addPlayer(client)
	else
		client:sendMessage(_("Lobby nicht gefunden!", client), 255, 0, 0)
	end
end

function SuperSweeperManager:Event_onMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and not hitElement.vehicle and dim and hitElement:isLoggedIn() then
		hitElement:triggerEvent("superSweeperOpenLobbyGUI")
	end
end

function SuperSweeperManager:requestCreateData()
	local maps = {}
	local modes = {}

	for index, map in pairs(SuperSweeperManager.Maps) do
		if map.selectable then
			maps[index] = map
		end
	end

	for index, mode in pairs(self.m_Modes) do
		modes[index] = {
			name = mode.Name,
			supportedPriceTypes = mode.SupportedPriceTypes,
			settings = mode.Settings
		}
	end
	
	client:triggerEvent("superSweeperReceiveCreateData", maps, modes)
end

function SuperSweeperManager:createPlayerLobby(map, password, settings)
	if client:transferBankMoney(self.m_BankServer, 500, "Super Sweeper Lobby", "Gameplay", "SuperSweeper") then
		local lobbyName = ("%s´s Lobby"):format(client:getName())
		self:createLobby(lobbyName, client, "default", 300, map, password, settings)
	else
        client:sendError(_("Du hast nicht genug Geld! (500$)", client))
	end
end

function SuperSweeperManager:leaveLobby()
	if client.m_SuperSweeperLobby and not client:isDead() then
		client.m_SuperSweeperLobby:removePlayer(client)
	end
end
