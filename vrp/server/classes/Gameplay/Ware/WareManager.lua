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

	PlayerManager:getSingleton():getWastedHook():register(
		function(player, killer, weapon)
			if player.bInWare then
				if ExecutionPed.Map[player] then delete(ExecutionPed.Map[player]) end
				if player:getExecutionPed() then delete(player:getExecutionPed()) end
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


	GlobalTimer:getSingleton():registerEvent(bind(self.announceEvent, self), "WareManager", nil, 13, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.restartEvent, self), "WareManager", nil, 13, 13)
	
	GlobalTimer:getSingleton():registerEvent(bind(self.announceEvent, self), "WareManager", nil, 15, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.restartEvent, self), "WareManager", nil, 15, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.announceEvent, self), "WareManager", nil, 17, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.restartEvent, self), "WareManager", nil, 17, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.announceEvent, self), "WareManager", nil, 19, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.restartEvent, self), "WareManager", nil, 19, 13)
	
	
	GlobalTimer:getSingleton():registerEvent(bind(self.announceEvent, self), "WareManager", nil, 21, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.restartEvent, self), "WareManager", nil, 21, 13)


	GlobalTimer:getSingleton():registerEvent(bind(self.announceEvent, self), "WareManager", nil, 23, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.restartEvent, self), "WareManager", nil, 23, 13)
	
end

function WareManager:restartEvent() 
	for i = 1, 5 do
		if WareManager.Map[i] then
			WareManager.Map[i]:delete()
			WareManager.Map[i] = nil
		end
	end
	for i = 1, 5 do
		WareManager.Map[#WareManager.Map+1] = Ware:new(i)
	end
	for k, player in ipairs(getElementsByType("player")) do 
		player:sendInfo(_("Das Ware-Event hat begonnen!", player))
	end
end

function WareManager:stopEvent(i) 
	if WareManager.Map[i] then
		WareManager.Map[i]:delete()
		WareManager.Map[i] = nil
	end
end

function WareManager:announceEvent()
	for k, player in ipairs(getElementsByType("player")) do 
		player:sendInfo(_("In 10 Minuten startet das Ware-Event, begib dich zum Friedhof um mitzumachen!", player))
	end
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
			if client:isFactionDuty() or client:isCompanyDuty() then
				client:sendError(_("Du darfst nicht im Dienst sein!", client))
				return
			end
			if #WareManager.Map[id]:getPlayers() < MAX_PLAYERS_PER_WARE then
				self.Map[id]:joinPlayer(client)
			end
		end
	end
end

function WareManager:Event_onPedClick()
	client:triggerEvent("Ware:wareOpenGUI", WareManager.Map)
end

