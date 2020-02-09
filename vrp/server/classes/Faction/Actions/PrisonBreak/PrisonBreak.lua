-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/PrisonBreak/PrisonBreak.lua
-- *  PURPOSE:     Prison Break Class
-- *
-- ****************************************************************************

PrisonBreak = inherit(Object)
PrisonBreak.OfficerCountdown = 7 * 60 * 1000
PrisonBreak.KeycardsCountdown = 2 * 60 * 1000
PrisonBreak.DoorsCountdown = 12 * 60 * 1000

function PrisonBreak:constructor(player)
	self.m_Entrance = PrisonBreakManager:getSingleton().m_Entrance

	self.m_Officer = PrisonBreakManager:getSingleton().m_Officer

	self.m_WeaponBoxPlayers = {}

	self.m_OfficerEnemies = {}
	self.m_OfficerCountdown = 0

	self.m_KeycardPlayers = {}

	self.m_Faction = player:getFaction()

	---Binds
	self.m_GetWeaponsFromBoxBind = bind(self.getWeaponsFromBox, self)

	-- Events
	for k, box in pairs(PrisonBreakManager:getSingleton().m_WeaponBoxes) do
		addEventHandler("onElementClicked", box, self.m_GetWeaponsFromBoxBind)
	end
	self.m_PlayerQuitOrDieFunc = bind(self.Event_PlayerQuitOrDie, self)
	PlayerManager:getSingleton():getWastedHook():register(self.m_PlayerQuitOrDieFunc)
	PlayerManager:getSingleton():getQuitHook():register(self.m_PlayerQuitOrDieFunc)
	
	self:start()
	Jail:getSingleton():setPrisonBreak(true)
end

function PrisonBreak:destructor()
	for k, box in pairs(PrisonBreakManager:getSingleton().m_WeaponBoxes) do
		removeEventHandler("onElementClicked", box, self.m_GetWeaponsFromBoxBind)
	end

	for key, player in pairs(self.m_KeycardPlayers) do
		PrisonBreak:removeKeycardFromPlayer(player)
	end
	self.m_KeycardPlayers = {}

	PlayerManager:getSingleton():getWastedHook():unregister(self.m_PlayerQuitOrDieFunc)
	PlayerManager:getSingleton():getQuitHook():unregister(self.m_PlayerQuitOrDieFunc)

	Jail:getSingleton():setPrisonBreak(false)
	PrisonBreakManager:getSingleton():stop()
end

function PrisonBreak:Event_PlayerQuitOrDie(player)
	PrisonBreak:removeKeycardFromPlayer(player)
end

function PrisonBreak:PedTargetRefresh(count, startingPlayer)
	if count == 0 then return false end
	local attackers = self.m_Officer:getAttackers()
	
	for attacker in pairs(attackers) do
		if self.m_OfficerCountdown < PrisonBreak.OfficerCountdown then
			attacker:sendShortMessage("Bedrohung zu " .. math.round((self.m_OfficerCountdown / PrisonBreak.OfficerCountdown) * 100, 1) .. " % abgeschlossen.")
		end
	end

	self.m_OfficerCountdown = self.m_OfficerCountdown + count * (DEBUG and 100000 or 1000)

	if self.m_OfficerCountdown >= PrisonBreak.OfficerCountdown then
		if not self.m_KeycardsActive then
			self:setKeycardTimeout()
		end
		if isTimer(self.m_KeycardDeactivateTimer) then
			for attacker in pairs(attackers) do
				if isElement(attacker) and not table.find(self.m_KeycardPlayers, attacker) then
					attacker:triggerEvent("Countdown", math.floor( getTimerDetails (self.m_KeycardDeactivateTimer) / 1000), "Keycards")
					attacker:getInventory():giveItem("Keycard", 1)
					attacker:sendSuccess("Du hast eine Keycard erhalten!")
					table.insert(self.m_KeycardPlayers, attacker)
				end
			end
		end
		self.m_OfficerCountdown = PrisonBreak.OfficerCountdown
	end
end

function PrisonBreak:setKeycardTimeout()
	self.m_KeycardsActive = true
	self.m_KeycardDeactivateTimer = setTimer(function ()
		for key, player in pairs(self.m_KeycardPlayers) do
			PrisonBreak:removeKeycardFromPlayer(player)
		end
		self.m_KeycardPlayers = {}
	end, PrisonBreak.KeycardsCountdown, 1)
end

function PrisonBreak:start()
	PlayerManager:getSingleton():breakingNews("Das Gefängnis meldet höchste Sicherheitswarnung. Gefahrenlage unbekannt!")
	Discord:getSingleton():outputBreakingNews("Das Gefängnis meldet höchste Sicherheitswarnung. Gefahrenlage unbekannt!")
	FactionState:getSingleton():sendWarning("Das Gefängnis meldet höchste Sicherheitswarnung mit Bitte um Unterstützung!", "Neuer Einsatz", true, {3583, -1614, 23.5})

	self.m_Entrance:destroy()

	for key, player in pairs(self.m_Faction:getOnlinePlayers()) do
		player:triggerEvent("Countdown", math.floor(PrisonBreak.DoorsCountdown / 1000), "Ausbruch")
	end

	setTimer(function ()
		Jail:getSingleton():closeGates()
		self:finish()
	end, PrisonBreak.DoorsCountdown, 1)
end

function PrisonBreak:getWeaponsFromBox(button, state, player)
	if
		button ~= "left"
		or state ~= "down"
	then
		return
	end

	if self.m_WeaponBoxPlayers[player:getId()] then
		player:sendError("Du hast bereits Waffen aus dem Lager erhalten!");
		return
	end

	player:giveWeapon(24, 90);
	player:giveWeapon(31, 250);

	self.m_WeaponBoxPlayers[player:getId()] = true
	player:sendSuccess("Du hast Waffen aus dem Lager erhalten!");
end

function PrisonBreak:finish()
	PlayerManager:getSingleton():breakingNews("Das Gefängnis meldet verminderte Sicherheitswarnung. Alle Tore sind wieder geschlossen!")
	Discord:getSingleton():outputBreakingNews("Das Gefängnis meldet verminderte Sicherheitswarnung. Alle Tore sind wieder geschlossen!")

	ActionsCheck:getSingleton():endAction()

	delete(self)
end

function PrisonBreak:removeKeycardFromPlayer(player)
	if player and isElement(player) and player:getInventory() then
		if player:getInventory():getItemAmount("Keycard") and player:getInventory():getItemAmount("Keycard") > 0 then
			player:getInventory():removeAllItem("Keycard")
			player:sendError("Deine Keycard wurde deaktiviert und aus deinem Inventar entfernt!")
		end
	end
end
