-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/WareManager.lua
-- *  PURPOSE:     Ware Manager class
-- *
-- ****************************************************************************
WareManager = inherit(Singleton)
WareManager.Map = {}
addRemoteEvents{"Ware:tryJoinLobby", "Ware:tryLeaveLobby", "Ware:requestLobbys", "Ware:onPedClick" }

local MAX_PLAYERS_PER_WARE = 12

function WareManager:constructor()
	for i = 1, 5 do
		WareManager.Map[#WareManager.Map+1] = Ware:new(i)
	end

	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.bInWare then
				player:triggerEvent("abortDeathGUI", true)
				player.bInWare:onDeath(player, killer, weapon)
				return true
			end
		end
	)

	Player.getQuitHook():register(
		function(player)
			if player.bInWare then
				self:leaveLobby(player)
			end
		end
	)

	addEventHandler("Ware:tryJoinLobby", root, bind(self.Event_onTryJoinLobby, self))
	addEventHandler("Ware:tryLeaveLobby", root , bind(self.Event_onLeaveLobby, self))
	addEventHandler("Ware:requestLobbys", root, bind(self.Event_refreshGUI, self))
	addEventHandler("Ware:onPedClick", root , bind(self.Event_onPedClick, self))
end

function WareManager:Event_refreshGUI()
	if not client then return end
	client:triggerEvent("Ware:wareOpenGUI", WareManager.Map)
end

function WareManager:Event_onLeaveLobby()
	self:leaveLobby(client)
end

function WareManager:leaveLobby(player, isServerStop)
	if not player then return end
	if not player.bInWare then return end

	player.bInWare:leavePlayer(player)

	if not isServerStop then
		player:sendShortMessage(_("Du hast die Lobby verlassen!", player), "Ware", {255, 125, 0})
	end
end

function WareManager:Event_onTryJoinLobby( id )
	if client then
		if WareManager.Map[id] then
			if #WareManager.Map[id]:getPlayers() < MAX_PLAYERS_PER_WARE then
				self.Map[id]:joinPlayer(client)
			end
		end
	end
end

function WareManager:Event_onPedClick()
	client:triggerEvent("Ware:wareOpenGUI", WareManager.Map)
end

