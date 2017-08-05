BankRobberyManager = inherit(Singleton)
BANKROB_VAULT_OPEN_TIME = 3*(60*1000)

function BankRobberyManager:constructor()
	self.m_Banks = {}
	self.m_CurrentBank = false
	self.m_IsBankrobRunning = false
	self.m_CircuitBreakerPlayers = {}

	self.m_Banks["Palomino"] = BankPalomino:new()
	self.m_Banks["LosSantos"] = BankLosSantos:new()

	addRemoteEvents{"bankRobberyPcHack", "bankRobberyPcDisarm", "bankRobberyPcHackSuccess", "bankRobberyLoadBag", "bankRobberyDeloadBag"}

	self.m_OnStartHack = bind(self.Event_onStartHacking, self)
	self.m_OnDisarm = bind(self.Event_onDisarmAlarm, self)
	self.m_OnSuccess = bind(self.Event_onHackSuccessful, self)

	addEventHandler("bankRobberyPcHack", root, self.m_OnStartHack)
	addEventHandler("bankRobberyPcDisarm", root,self.m_OnDisarm )
	addEventHandler("bankRobberyLoadBag", root, bind(self.Event_LoadBag, self))
	addEventHandler("bankRobberyDeloadBag", root, bind(self.Event_DeloadBag, self))
	addEventHandler("bankRobberyPcHackSuccess", root, self.m_OnSuccess)

end

function BankRobberyManager:startRob(bank)
	self.m_IsBankrobRunning = true
	self.m_CurrentBank = bank
end

function BankRobberyManager:stopRob()
	self.m_IsBankrobRunning = false
	self.m_CurrentBank = false

	if self.m_CircuitBreakerPlayers then
		for player, bool in pairs(self.m_CircuitBreakerPlayers) do
			if isElement(player) then
				player:triggerEvent("forceCircuitBreakerClose")
				self.m_CircuitBreakerPlayers[player] = nil
				player.m_InCircuitBreak = false
			end
		end
	end
	if self.m_OpenVaulTimer then
		if isTimer(self.m_OpenVaulTimer) then
			stopTimer(self.m_OpenVaulTimer)
			if self.m_RobFaction then
				for k, pl in ipairs(self.m_RobFaction:getOnlinePlayers()) do
					pl:triggerEvent("CountdownStop","Safe offen:")
				end
			end
		end
	end
	ActionsCheck:getSingleton():endAction()
	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "stop", self.m_RobPlayer, self.m_RobFaction, "faction")
end

function BankRobberyManager:Event_onStartHacking()
	if client:getFaction() and client:getFaction():isEvilFaction() then
		if self.m_IsBankrobRunning then
			self.m_CircuitBreakerPlayers[client] = true
			client.m_InCircuitBreak = true
			triggerClientEvent(client, "startCircuitBreaker", client, "bankRobberyPcHackSuccess")
		else
			client:sendError(_("Derzeit läuft kein Bankraub!", client))
		end
	end
end

function BankRobberyManager:Event_onDisarmAlarm()
	if client:getFaction() and client:getFaction() then
		if self.m_IsBankrobRunning then
			triggerClientEvent("bankAlarmStop", root)
		else
			client:sendError(_("Derzeit läuft kein Bankraub!", client))
		end
	end
end

function BankRobberyManager:Event_onHackSuccessful()
	for player, bool in pairs(self.m_CircuitBreakerPlayers) do
		if isElement(player) then
			player:triggerEvent("forceCircuitBreakerClose")
			player:sendSuccess(_("Das Sicherheitssystem wurde von %s geknackt! Die Safetür ist offen", player, client:getName()))
			player.m_InCircuitBreak = false
			self.m_CircuitBreakerPlayers[player] = nil
		end
	end
	self.m_CircuitBreakerPlayers = {}
	client:giveKarma(-5)
	local brobFaction = client:getFaction()
	for k, player in ipairs(brobFaction:getOnlinePlayers()) do
		player:triggerEvent("Countdown", (BANKROB_VAULT_OPEN_TIME/1000), "Safe offen:")
	end
	self.m_OpenVaulTimer = setTimer(bind(self.m_CurrentBank.openSafeDoor,self.m_CurrentBank), BANKROB_VAULT_OPEN_TIME, 1)
end


function BankRobberyManager:Event_LoadBag(veh)
	if client:getFaction() then
		if VEHICLE_BAG_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client.vehicle then
					local bag = client:getPlayerAttachedObject()
					if #getAttachedElements(veh) < VEHICLE_BAG_LOAD[veh.model]["count"] then
						if bag then
							local count = #getAttachedElements(veh)
							client:detachPlayerObject(bag)
							bag:attach(veh, VEHICLE_BAG_LOAD[veh.model][count+1])
						else
							client:sendError(_("Du hast keinen Geldsack dabei!", client))
						end
					else
						client:sendError(_("Das Fahrzeug ist bereits voll beladen!", client))
					end
				else
					client:sendError(_("Du darfst in keinem Fahrzeug sitzen!", client))
				end
			else
				client:sendError(_("Du bist zuweit vom Truck entfernt!", client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht beladen werden!", client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Geldäcke abladen!", client))
	end
end

function BankRobberyManager:Event_DeloadBag(veh)
	if client:getFaction() then
		if VEHICLE_BAG_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client.vehicle then
					for key, bag in pairs (getAttachedElements(veh)) do
						if bag.model == 1550 then
							bag:detach(self.m_Truck)
							if client:getFaction():isStateFaction() and client:isFactionDuty() then
								self.m_CurrentBank:statePeopleClickBag(client, bag)
								return
							else
								client:attachPlayerObject(bag)
								return
							end
						end
					end
					client:sendError(_("Es befindet sich kein Geldsack im Truck!", client))
					return
				else
					client:sendError(_("Du darfst in keinem Fahrzeug sitzen!", client))
				end
			else
				client:sendError(_("Du bist zuweit vom Truck entfernt!", client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht entladen werden!", client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Geldsäcke abladen!", client))
	end
end

