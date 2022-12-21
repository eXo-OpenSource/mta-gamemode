-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     Deathmatch Manager class
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)
DeathmatchManager.Lobbys = {}
DeathmatchManager.AllowedWeapons = {22, 24, 25, 29, 30, 31, 33, }

DeathmatchManager.Maps = {
	["lvpd"] = {
		["Name"] = "LVPD",
		["Selectable"] = true,
		["Interior"] = 3,
		["Spawns"] = {
			Vector3(236.65, 154.73, 1003.02),
			Vector3(238.38, 177.07, 1003.03),
			Vector3(246.71, 188.92, 1008.17),
			Vector3(285.35, 180.23, 1007.18),
			Vector3(220.75, 146.60, 1003.02),
			Vector3(215.72, 146.15, 1003.02),
			Vector3(210.31, 147.52, 1003.02),
			Vector3(218.15, 167.28, 1003.02),
			Vector3(192.08, 158.01, 1003.02),
			Vector3(190.98, 178.94, 1003.02)
		}
	},
	["battlefield"] = {
		["Name"] = "Battlefield",
		["Selectable"] = true,
		["Interior"] = 10,
		["Spawns"] = {
			Vector3(-970.98, 1089.47, 1345.00),
			Vector3(-969.97, 1065.87, 1345.03),
			Vector3(-974.52, 1061.50, 1345.67),
			Vector3(-972.67, 1026.37, 1345.05),
			Vector3(-994.18, 1026.69, 1341.84),
			Vector3(-1016.96, 1027.34, 1343.53),
			Vector3(-1048.10, 1027.41, 1343.01),
			Vector3(-1082.96, 1028.50, 1342.49),
			Vector3(-1114.83, 1030.55, 1343.19),
			Vector3(-1131.51, 1029.42, 1345.73),
			Vector3(-1131.67, 1044.07, 1345.74),
			Vector3(-1132.18, 1062.74, 1345.76),
			Vector3(-1128.14, 1095.27, 1345.77),
			Vector3(-1111.04, 1093.00, 1341.85),
			Vector3(-1080.47, 1090.71, 1342.89),
			Vector3(-1052.53, 1087.76, 1343.11),
			Vector3(-1026.47, 1087.18, 1343.42),
			Vector3(-1032.71, 1067.85, 1344.23),
		}
	},
	["motel"] = {
		["Name"] = "Jefferson Motel",
		["Selectable"] = true,
		["Interior"] = 15,
		["Spawns"] = {
			Vector3(2226.547, -1183.308, 1029.8),
			Vector3(2227, -1138, 1029.5),
			Vector3(2252, -1160, 1029.5),
			Vector3(2240, -1194, 1033.5),
			Vector3(2238, -1194, 1029.5),
			Vector3(2204, -1198, 1029.5),
			Vector3(2187, -1182, 1029.5),
			Vector3(2186, -1181, 1033.5),
			Vector3(2196, -1177, 1029.5),
			Vector3(2190, -1139, 1029.5),
			Vector3(2193, -1147, 1033.5),
		}
	},
	["maddogg"] = {
		["Name"] = "Madd Dogg Villa",
		["Selectable"] = true,
		["Interior"] = 5,
		["Spawns"] = {
			Vector3(1262.13, -784.74, 1091.91),
			Vector3(1274.61, -794.30, 1089.93),
			Vector3(1288.18, -795.60, 1089.94),
			Vector3(1273.25, -804.24, 1089.93),
			Vector3(1290.73, -803.15, 1089.94),
			Vector3(1278.16, -822.33, 1089.94),
			Vector3(1287.17, -815.41, 1089.94),
			Vector3(1282.48, -838.02, 1089.94),
			Vector3(1288.86, -829.02, 1085.64),
			Vector3(1248.18, -828.43, 1084.01),
			Vector3(1240.60, -824.41, 1083.16),
			Vector3(1233.14, -807.81, 1084.01),
			Vector3(1247.46, -804.39, 1084.01),
			Vector3(1266.11, -795.17, 1084.01),
			Vector3(1299.69, -792.40, 1084.01),
			Vector3(1260.89, -781.16, 1084.01),
			Vector3(1272.76, -812.83, 1084.01),
			Vector3(1234.27, -755.69, 1084.01),
			Vector3(1278.67, -811.38, 1085.63),
		}
	},
	["atrium"] = {
		["Name"] = "LS Atrium",
		["Selectable"] = true,
		["Interior"] = 18,
		["Spawns"] = {
			Vector3(1709.63, -1642.70, 20.22),
			Vector3(1702.18, -1658.83, 20.23),
			Vector3(1733.73, -1640.94, 23.76),
			Vector3(1709.90, -1663.32, 23.71),
			Vector3(1711.47, -1676.65, 27.22),
			Vector3(1733.59, -1656.11, 27.24),
			Vector3(1713.43, -1642.42, 27.22),
			Vector3(1733.67, -1662.42, 20.25),
			Vector3(1714.17, -1673.17, 20.23),
			Vector3(1721.30, -1647.92, 20.23),
		}
	},
	["caligulas"] = {
		["Name"] = "Caligulas Keller",
		["File"] = 	"files/maps/DMArena/Caligulas.map",
		["Selectable"] = true,
		["Interior"] = 1,
		["Spawns"] = {
			Vector3(2148.09, 1613.78, 1000.97),
			Vector3(2145.03, 1602.95, 1006.17),
			Vector3(2170.80, 1602.27, 999.97),
			Vector3(2191.74, 1614.34, 999.98),
			Vector3(2217.97, 1612.61, 999.98),
			Vector3(2232.55, 1584.73, 999.96),
			Vector3(2207.66, 1551.83, 1007.50),
			Vector3(2187.68, 1578.90, 999.97),
			Vector3(2176.50, 1601.57, 999.98),
			Vector3(2157.72, 1612.97, 999.97),
			Vector3(2153.52, 1621.63, 993.69),
			Vector3(2144.40, 1639.91, 993.58),
		}
	},

	["halloween"] = {
		["Name"] = "Halloween",
		["File"] = 	"files/maps/DMArena/Halloween.map",
		["Selectable"] = false,
		["Interior"] = 0,
		["Spawns"] = {
			Vector3(-1317.79, 2529.04, 87.65),
		}
	}
}

function DeathmatchManager:constructor()
	self.ms_Modes = {
		["default"] = DeathmatchDefault,
		["halloween"] = DeathmatchHalloween
	}

	self:loadServerLobbys()
	self.m_BankServer = BankServer.get("gameplay.deathmatch")
	local b = Blip:new("SniperGame.png", 1327.88, -1556.25)
	b:setDisplayText("Paintball-Arena", BLIP_CATEGORY.Leisure)
	self.m_Marker = createMarker(1327.88, -1556.25, 13.55, "corona", 2, 255, 125, 0)
	addEventHandler("onMarkerHit", self.m_Marker, function(hitElement, dim)
		if hitElement:getType() == "player" and not hitElement.vehicle and dim and hitElement:isLoggedIn() then
			hitElement:triggerEvent("deathmatchOpenLobbyGUI", self.m_Marker)
		end
	end)
	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.deathmatchLobby then
				player:triggerEvent("abortDeathGUI", true)
				player.deathmatchLobby:onWasted(player, killer, weapon)
				return true
			end
			if killer and killer.deathmatchLobby then
				killer:givePoints(1)
			end
		end
	)

	PlayerManager:getSingleton():getAFKHook():register(
		function(player)
			if player.deathmatchLobby then
				player.deathmatchLobby:removePlayer(player)
			end
		end
	)

	Player.getQuitHook():register(
		function(player)
			if player.deathmatchLobby then
				player.deathmatchLobby:removePlayer(player)
			end
		end
	)

	Player.getChatHook():register(
		function(player, text, type)
			if player.deathmatchLobby then
				return player.deathmatchLobby:onPlayerChat(player, text, type)
			end
		end
	)

	core:getStopHook():register(
		function()
			for id, lobby in pairs(DeathmatchManager.Lobbys) do
				for player, data in pairs(lobby.m_Players) do
					lobby:removePlayer(player, true)
				end
			end
		end
	)

	addRemoteEvents{"deathmatchRequestLobbys", "deathmatchJoinLobby", "deathmatchLeaveLobby", "deathmatchRequestCreateData", "deathmatchCreateLobby", "deathmatchSendPlayerSelectedWeapons"}
	addEventHandler("deathmatchRequestLobbys", root, bind(self.requestLobbys, self))
	addEventHandler("deathmatchJoinLobby", root, bind(self.joinLobby, self))
	addEventHandler("deathmatchLeaveLobby", root, bind(self.leaveLobby, self))
	addEventHandler("deathmatchRequestCreateData", root, bind(self.requestCreateData, self))
	addEventHandler("deathmatchCreateLobby", root, bind(self.createPlayerLobby, self))
	addEventHandler("deathmatchSendPlayerSelectedWeapons", root, bind(self.givePlayerDeathmatchWeapons, self))

	--Development
	if DEBUG and EVENT_HALLOWEEN then
		addCommandHandler("halloweendm", function()
			self:createLobby("Halloween Event", "Server", "halloween", {}, "halloween", 10)
			for index, player in pairs(getElementsByType("player")) do
				player:sendShortMessage("Die Halloween-Deathmatch Lobby wurde geöffnet!")
			end
		end)
	end
end

function DeathmatchManager:createLobby(name, owner, map, weapons, mode, maxPlayer, password)
	if not self.ms_Modes[mode] then
		outputDebugString("DM-Mode not found!", 1)
		return
	end

	local id = #DeathmatchManager.Lobbys+1
	DeathmatchManager.Lobbys[id] = self.ms_Modes[mode]:new(id, name, owner, map, weapons, mode, maxPlayer, password)
end

function DeathmatchManager:loadServerLobbys()
	self:createLobby("Deagle LVPD #1", "Server", "lvpd", {24}, "default", 300)
	self:createLobby("Zufällige Waffen LVPD #1", "Server", "lvpd", Randomizer:getRandomOf(math.random(1, #DeathmatchManager.AllowedWeapons), DeathmatchManager.AllowedWeapons), "default", 300)
	self:createLobby("Deagle Battlefield #1", "Server", "battlefield", {24}, "default", 300)
	self:createLobby("Zufällige Waffen Battlefield #1", "Server", "battlefield", Randomizer:getRandomOf(math.random(1, #DeathmatchManager.AllowedWeapons), DeathmatchManager.AllowedWeapons), "default", 300)
	--self:createLobby("Sniper Battlefield #1", "Server", "battlefield", {34}, "default", 300)
	self:createLobby("Deagle Motel #1", "Server", "motel", {24}, "default", 10)
	self:createLobby("Zufällige Waffen Motel #1", "Server", "motel", Randomizer:getRandomOf(math.random(1, #DeathmatchManager.AllowedWeapons), DeathmatchManager.AllowedWeapons), "default", 10)
	self:createLobby("Deagle Atrium #1", "Server", "atrium", {24}, "default", 10)
	self:createLobby("Zufällige Waffen Atrium #1", "Server", "atrium", Randomizer:getRandomOf(math.random(1, #DeathmatchManager.AllowedWeapons), DeathmatchManager.AllowedWeapons), "default", 10)
	self:createLobby("Deagle Caligulas Keller #1", "Server", "caligulas", {24}, "default", 10)
	self:createLobby("Zufällige Waffen Caligulas #1", "Server", "caligulas", Randomizer:getRandomOf(math.random(1, #DeathmatchManager.AllowedWeapons), DeathmatchManager.AllowedWeapons), "default", 10)
	self:createLobby("Deagle Madd Dogg #1", "Server", "maddogg", {24}, "default", 10)
	self:createLobby("Zufällige Waffen Madd Dogg #1", "Server", "maddogg", Randomizer:getRandomOf(math.random(1, #DeathmatchManager.AllowedWeapons), DeathmatchManager.AllowedWeapons), "default", 10)
end

function DeathmatchManager:requestLobbys()
	local lobbyTable = {}
	for id, lobby in pairs(DeathmatchManager.Lobbys) do
		lobbyTable[id] = {
			["name"] = lobby.m_Name,
			["players"] = lobby:getPlayerCount(),
			["map"] = lobby.m_MapName,
			["mode"] = lobby.m_Mode,
			["password"] = lobby.m_Password,
			["playerNames"] = lobby:getPlayerString(),
			["weapons"] = lobby:getWeaponString()
		}
	end
	client:triggerEvent("deathmatchReceiveLobbys", lobbyTable)
end

function DeathmatchManager:requestCreateData()
	local maps = {}
	for index, map in pairs(DeathmatchManager.Maps) do
		if map.Selectable then
			maps[index] = map
		end
	end
	client:triggerEvent("deathmatchReceiveCreateData", maps, DeathmatchManager.AllowedWeapons)
end

function DeathmatchManager:createPlayerLobby(map, weapon, password)
	if client:getMoney() >= 500 then
		client:transferMoney(self.m_BankServer, 500, "Deathmatch Lobby", "Gameplay", "Deathmatch")
		local lobbyName = ("%s´s Lobby"):format(client:getName())
		self:createLobby(lobbyName, client, map, weapon, "default", 300, password)
	else
        client:sendError(_("Du hast nicht genug Geld dabei! (500$)", client))
	end
end

function DeathmatchManager:joinLobby(id)
	if client:isFactionDuty() and client:getFaction():isStateFaction() then
		client:sendError(_("Du darfst nicht im Dienst in eine DM-Lobby! (Fraktion)", client))
		return
	end

	if client:isCompanyDuty() then
		client:sendError(_("Du darfst nicht im Dienst in eine DM-Lobby! (Unternehmen)", client))
		return
	end
	if DeathmatchManager.Lobbys[id] then
		DeathmatchManager.Lobbys[id]:addPlayer(client)
	else
		client:sendMessage("Lobby nicht gefunden!", 255, 0, 0)
	end
end

function DeathmatchManager:unregisterLobby(id)
	if DeathmatchManager.Lobbys[id] then
		DeathmatchManager.Lobbys[id] = nil
	else
		outputDebugString("DeathmatchManager: Unable to unregister Lobby! ID: "..id.." not found!")
	end
end

function DeathmatchManager:leaveLobby()
	if client.deathmatchLobby and not client:isDead() then
		client.deathmatchLobby:removePlayer(client)
	end
end

function DeathmatchManager:isDamageAllowed(player, attacker, weapon)
	if client.deathmatchLobby.isDamageAllowed then
		return player.deathmatchLobby:isDamageAllowed(player, attacker, weapon)
	end
	return true
end

function DeathmatchManager:givePlayerDeathmatchWeapons(weapons)
	if client.deathmatchLobby then
		client.deathmatchLobby:giveWeapons(client, weapons)
	end
end