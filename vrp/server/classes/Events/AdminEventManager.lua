AdminEventManager = inherit(Singleton)

function AdminEventManager:constructor()
	self.m_EventRunning = false
	self.m_CurrentEvent = false

	self.m_EventVehicles = {}
	self.m_EventVehiclesAmount = 0

	addCommandHandler("teilnehmen", bind(self.joinEvent, self))

	addRemoteEvents{"adminEventRequestData", "adminEventToggle", "adminEventTrigger", "adminEventAllVehiclesAction", "adminEventCreateVehicles"}
	addEventHandler("adminEventRequestData", root, bind(self.requestData, self))
	addEventHandler("adminEventToggle", root, bind(self.toggle, self))
	addEventHandler("adminEventTrigger", root, bind(self.onEventTrigger, self))
	addEventHandler("adminEventAllVehiclesAction", root, bind(self.allVehiclesTrigger, self))
	addEventHandler("adminEventCreateVehicles", root, bind(self.createVehicles, self))
end

function AdminEventManager:onEventTrigger(func)
	if client:getRank() <= ADMIN_RANK_PERMISSION["event"] then return end
	if not self.m_EventRunning or not self.m_CurrentEvent then
		client:sendError(_("Es läuft aktuell kein Event!", client))
	end

	if func == "setTeleportPoint" then
		self.m_CurrentEvent:setTeleportPoint(client)
	elseif func == "teleportPlayers" then
		self.m_CurrentEvent:teleportPlayers(client)
	end
	self:sendData(client)
end

function AdminEventManager:allVehiclesTrigger(func)
	if client:getRank() <= ADMIN_RANK_PERMISSION["event"] then return end
	if not self.m_EventRunning or not self.m_CurrentEvent then
		client:sendError(_("Es läuft aktuell kein Event!", client))
	end
	if func == "delete" then
		self.m_CurrentEvent:deleteEventVehicles(client)
	elseif func == "freeze" then
		self.m_CurrentEvent:freezeEventVehicles(client)
	elseif func == "unfreeze" then
		self.m_CurrentEvent:unfreezeEventVehicles(client)
	end
	self:sendData(client)
end

function AdminEventManager:createVehicles(amount, direction)
	if client:getRank() <= ADMIN_RANK_PERMISSION["event"] then return end
	if not self.m_EventRunning or not self.m_CurrentEvent then
		client:sendError(_("Es läuft aktuell kein Event!", client))
	end

	self.m_CurrentEvent:createVehiclesInRow(client, amount, direction)
	self:sendData(client)
end

function AdminEventManager:joinEvent(player)
	if not self.m_EventRunning or not self.m_CurrentEvent then
		player:sendError(_("Es läuft aktuell kein Event!", player))
	end

	self.m_CurrentEvent:joinEvent(player)
end

function AdminEventManager:toggle()
	if self.m_EventRunning and self.m_CurrentEvent then
		delete(self.m_CurrentEvent)
		self.m_EventRunning = false
		Admin:getSingleton():sendShortMessage(_("%s hat ein Adminevent beendet!", client, client:getName()))
	else
		self.m_CurrentEvent = AdminEvent:new()
		self.m_EventRunning = true
		Admin:getSingleton():sendShortMessage(_("%s hat ein Adminevent gestartet!", client, client:getName()))
	end
	self:sendData(client)
end

function AdminEventManager:requestData()
	self:sendData(client)
end

function AdminEventManager:sendData(player)
	if self.m_EventRunning and self.m_CurrentEvent then
		self.m_CurrentEvent:sendGUIData(player)
	else
		player:triggerEvent("adminEventReceiveData", false)
	end
end

