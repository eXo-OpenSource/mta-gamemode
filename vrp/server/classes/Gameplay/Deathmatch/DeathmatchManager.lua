-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     Deathmatch Manager class
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)
DeathmatchManager.Rooms = {}
DeathmatchManager.Maps = {
	["lvpd"] = {
		["Name"] = "LVPD",
		["Custom"] = false,
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
		["Custom"] = false,
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
		["Custom"] = false,
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
	}
}

function DeathmatchManager:constructor()
	self:loadServerRooms()

	Blip:new("SniperGame.png", 1327.88, -1556.25)
	self.m_Marker = createMarker(1327.88, -1556.25, 13.55, "corona", 2, 255, 125, 0)
	addEventHandler("onMarkerHit", self.m_Marker, function(hitElement, dim)
		if hitElement:getType() == "player" and not hitElement.vehicle and dim then
			hitElement:triggerEvent("deathmatchOpenLobbyGUI")
		end
	end)

	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.deathmatchRoom then
				player:triggerEvent("abortDeathGUI", true)

				player.deathmatchRoom:respawnPlayer(player, true, killer, weapon)
				return true
			end
		end
	)

	Player.getQuitHook():register(
		function(player)
			if player.deathmatchRoom then
				player.deathmatchRoom:removePlayer(player)
			end
		end
	)

	Player.getChatHook():register(
		function(player, text, type)
			if player.deathmatchRoom then
				return player.deathmatchRoom:onPlayerChat(player, text, type)
			end
		end
	)

	core:getStopHook():register(
		function()
			for id, room in pairs(DeathmatchManager.Rooms) do
				for player, data in pairs(room.m_Players) do
					room:removePlayer(player, true)
				end
			end
		end
	)


	addRemoteEvents{"deathmatchRequestLobbys", "deathmatchJoinLobby", "deathmatchLeaveArena"}
	addEventHandler("deathmatchRequestLobbys", root, bind(self.requestLobbys, self))
	addEventHandler("deathmatchJoinLobby", root, bind(self.joinLobby, self))
	addEventHandler("deathmatchLeaveArena", root, bind(self.leaveArena, self))
end

function DeathmatchManager:createRoom(name, owner, map, weapons, mode, maxPlayer)
	local id = #DeathmatchManager.Rooms+1
	DeathmatchManager.Rooms[id] = DeathmatchRoom:new(id, name, owner, map, weapons, mode, maxPlayer)
end

function DeathmatchManager:loadServerRooms()
	self:createRoom("Deagle LVPD #1", "Server", "lvpd", {24}, "default", 300)
	self:createRoom("Deagle LVPD #2", "Server", "lvpd", {24}, "default", 300)
	self:createRoom("M4 LVPD #1", "Server", "lvpd", {31}, "default", 300)
	self:createRoom("Deagle Battlefield #1", "Server", "battlefield", {24}, "default", 300)
	self:createRoom("M4 Battlefield #1", "Server", "battlefield", {31}, "default", 300)
	self:createRoom("Sniper Battlefield #1", "Server", "battlefield", {34}, "default", 300)
	self:createRoom("Deagle Motel #1", "Server", "motel", {24}, "default", 10)
	self:createRoom("M4 Motel #1", "Server", "motel", {31}, "default", 10)
end

function DeathmatchManager:requestLobbys()
	local lobbyTable = {}
	for id, lobby in pairs(DeathmatchManager.Rooms) do
		lobbyTable[id] = {
			["name"] = lobby.m_Name,
			["players"] = lobby:getPlayerCount(),
			["map"] = lobby.m_MapName,
			["mode"] = lobby.m_Mode
		}
	end
	client:triggerEvent("deathmatchReceiveLobbys", lobbyTable)
end

function DeathmatchManager:joinLobby(id)
	if client:isFactionDuty() then
		client:sendError(_("Du darfst nicht im Dienst in eine DM-Lobby! (Fraktion)", client))
		return
	end

	if client:isCompanyDuty() then
		client:sendError(_("Du darfst nicht im Dienst in eine DM-Lobby! (Fraktion)", client))
		return
	end

	if DeathmatchManager.Rooms[id] then
		DeathmatchManager.Rooms[id]:addPlayer(client)
	else
		client:sendMessage("Raum nicht gefunden!", 255, 0, 0)
	end
end

function DeathmatchManager:leaveArena()
	if client.deathmatchRoom and not client:isDead() then
		client.deathmatchRoom:removePlayer(client)
	end
end

addCommandHandler("gh", function(player)
outputChatBox(("Vector3(%.2f, %.2f, %.2f),"):format(getElementPosition(player)))
end)
