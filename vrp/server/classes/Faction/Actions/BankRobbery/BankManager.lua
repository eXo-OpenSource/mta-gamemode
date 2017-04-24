function BankManager:constructor()
	self.m_Banks = {
		["Palomino"] = BankPalomio,
		["LosSantos"] = BankLosSantos
	}

	self.m_CurrentBank = false
	self.m_IsBankrobRunning = false

	for name, class in pairs(self.m_Banks) do
		class:new()
	end

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

function BankManager:Event_onStartHacking()
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

function BankManager:Event_onDisarmAlarm()
	if client:getFaction() and client:getFaction() then
		if self.m_IsBankrobRunning then
			triggerClientEvent("bankAlarmStop", root)
		else
			client:sendError(_("Derzeit läuft kein Bankraub!", client))
		end
	end
end

function BankManager:Event_onHackSuccessful()
	for player, bool in pairs(self.m_CircuitBreakerPlayers) do
		player:triggerEvent("forceCircuitBreakerClose")
		player:sendSuccess(_("Das Sicherheitssystem wurde von %s geknackt! Die Safetür ist offen", player, client:getName()))
		player.m_InCircuitBreak = false
		self.m_CircuitBreakerPlayers[player] = nil
	end
	self.m_CircuitBreakerPlayers = {	}
	client:giveKarma(-5)

	self.m_CurrentBank:openSafeDoor()
end

function BankManager:Event_DeloadBag(veh)
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

