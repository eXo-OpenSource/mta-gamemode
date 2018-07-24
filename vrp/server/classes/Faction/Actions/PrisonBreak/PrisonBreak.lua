-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/PrisonBreak/PrisonBreak.lua
-- *  PURPOSE:     Prison Break Class
-- *
-- ****************************************************************************

PrisonBreak = inherit(Object)
PrisonBreak.BombCountdown = 10 * 1000
PrisonBreak.OfficerCountdown = 5 * 60 * 1000
PrisonBreak.KeycardsCountdown = 2 * 60 * 1000
PrisonBreak.DoorsCountdown = 20 * 60 * 1000
PrisonBreak.OfficerCount = 5

function PrisonBreak:constructor()
	self.m_Entrance = PrisonBreakManager:getSingleton().m_Entrance

	self.m_Officer = PrisonBreakManager:getSingleton().m_Officer

	self.m_WeaponBoxPlayers = {}

	self.m_OfficerEnemies = {}
	self.m_OfficerCountdown = PrisonBreak.OfficerCountdown

	self.m_KeycardPlayers = {}

	---Binds
	self.m_GetWeaponsFromBoxBind = bind(self.getWeaponsFromBox, self)

	-- Events
	for k, box in pairs(PrisonBreakManager:getSingleton().m_WeaponBoxes) do
		addEventHandler("onElementClicked", box, self.m_GetWeaponsFromBoxBind)
	end

end

function PrisonBreak:destructor()
	for k, box in pairs(PrisonBreakManager:getSingleton().m_WeaponBoxes) do
		removeEventHandler("onElementClicked", box, self.m_GetWeaponsFromBoxBind)
	end

	for key, player in pairs(self.m_KeycardPlayers) do
		PrisonBreak.RemoveKeycard(player)
		table.remove(self.m_KeycardPlayers, key)
	end

	PrisonBreakManager:getSingleton():stop()
end

function PrisonBreak:Ped_Targetted(ped, attacker)

end

function PrisonBreak:PedTargetRefresh(count, startingPlayer)
	if count == 0 then return false end
	local attackers = self.m_Officer:getAttackers()
	
	for attacker in pairs(attackers) do
		if self.m_OfficerCountdown > 0 then
			attacker:sendShortMessage("Bedrohung zu " .. math.round((self.m_OfficerCountdown / PrisonBreak.OfficerCountdown) * 100, 1) .. " % abgeschlossen.")
		end
	end

	self.m_OfficerCountdown = self.m_OfficerCountdown - count * 1000

	if self.m_OfficerCountdown <= 0 then
		for attacker in pairs(attackers) do
			if isElement(attacker) then
				attacker:triggerEvent("Countdown", math.floor(PrisonBreak.KeycardsCountdown / 1000), "Keycards")
				attacker:getInventory():giveItem("Keycard", 1)
				attacker:sendSuccess("Du hast eine Keycard erhalten!")
				table.insert(self.m_KeycardPlayers, attacker)
			end
		end

		setTimer(function ()
			for key, player in pairs(self.m_KeycardPlayers) do
				PrisonBreak.RemoveKeycard(player)
				table.remove(self.m_KeycardPlayers, key)
			end
		end, PrisonBreak.KeycardsCountdown, 1)

		killTimer(self.m_OfficerTimer)
		self.m_OfficerTimer = nil
		self.m_OfficerCountdown = PrisonBreak.OfficerCountdown
	end
end

function PrisonBreak:placeBomb(player)
	self.m_Faction = player:getFaction()

	if
		not self.m_Faction
		or not self.m_Faction:isEvilFaction()
		or getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) > 5
		or not ActionsCheck:getSingleton():isActionAllowed(player)
	then
		delete(self)

		return
	end

	if FactionState:getSingleton():countPlayers() < PrisonBreak.OfficerCount then
		player:sendError("Es sind nicht genügend Staatsfraktionisten online!")

		delete(self)

		return
	end

	if not player:getInventory():removeItem("Sprengstoff", 1) then
		player:sendError("Du hast keine Bombe im Inventar!")

		delete(self)

		return
	end

	ActionsCheck:getSingleton():setAction("Knastausbruch")

	self.m_Bomb = createObject(1654, self.m_Entrance:getPosition(), Vector3(0, 0, 180))

	for key, player in pairs(self.m_Faction:getOnlinePlayers()) do
		player:triggerEvent("Countdown", math.floor(PrisonBreak.BombCountdown / 1000), "Explosion")
	end

	self.m_BombCoutdownTimer = setTimer(bind(self.explodeBomb, self), PrisonBreak.BombCountdown, 1)
end

function PrisonBreak:explodeBomb()
	PlayerManager:getSingleton():breakingNews("Das Gefängnis meldet höchste Sicherheitswarnung. Gefahrenlage unbekannt!")
	Discord:getSingleton():outputBreakingNews("Das Gefängnis meldet höchste Sicherheitswarnung. Gefahrenlage unbekannt!")
	FactionState:getSingleton():sendWarning("Das Gefängnis meldet höchste Sicherheitswarnung mit Bitte um Unterstützung!", "Neuer Einsatz", true, {3583, -1614, 23.5})

	createExplosion(self.m_Bomb:getPosition(), 2)
	self.m_Bomb:destroy()
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

function PrisonBreak.RemoveKeycard(player)
	if player and isElement(player) and player:getInventory() then
		if player:getInventory():getItemAmount("Keycard") > 0 then
			player:getInventory():removeAllItem("Keycard")
			player:sendError("Deine Keycard wurde deaktiviert und aus deinem Inventar entfernt!")
		end
	end
end
