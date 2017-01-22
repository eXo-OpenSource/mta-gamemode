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
	}
}

function DeathmatchManager:constructor()
	self:loadServerRooms()


	self.m_Marker = createMarker(1498.56, -1582.00, 13.55, "corona", 2, 255, 125, 0)
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

	Player.getQuitHook():register(function()
		if source.deathmatchRoom then
			source.deathmatchRoom:removePlayer(source)
		end
	end)


	addRemoteEvents{"deathmatchRequestLobbys", "deathmatchJoinLobby"}
	addEventHandler("deathmatchRequestLobbys", root, bind(self.requestLobbys, self))
	addEventHandler("deathmatchJoinLobby", root, bind(self.joinLobby, self))

end

function DeathmatchManager:createRoom(name, owner, map, weapons, mode, maxPlayer)
	local id = #DeathmatchManager.Rooms+1
	DeathmatchManager.Rooms[id] = DeathmatchRoom:new(id, name, owner, map, weapons, mode, maxPlayer)
end

function DeathmatchManager:loadServerRooms()
	self:createRoom("Deagle-Deathmatch LVPD #1", "Server", "lvpd", {24}, "default", 300)
	self:createRoom("Deagle-Deathmatch LVPD #2", "Server", "lvpd", {24}, "default", 300)
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
	if DeathmatchManager.Rooms[id] then
		DeathmatchManager.Rooms[id]:addPlayer(client)
	else
		client:sendMessage("Raum nicht gefunden!", 255, 0, 0)
	end
end

addCommandHandler("gh", function(player)
outputChatBox(("Vector3(%.2f, %.2f, %.2f),"):format(getElementPosition(player)))
end)
