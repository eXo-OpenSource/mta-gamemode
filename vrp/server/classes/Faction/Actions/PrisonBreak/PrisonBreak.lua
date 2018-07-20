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
--PrisonBreak.DoorsCountdown = 20 * 60 * 1000
PrisonBreak.DoorsCountdown = 5 * 60 * 1000
PrisonBreak.OfficerCount = 5

function PrisonBreak:constructor()
	self.m_Entrance = PrisonBreakManager:getSingleton().m_Entrance

	self.m_Officer = PrisonBreakManager:getSingleton().m_Officer
	addEventHandler("onPlayerTarget", root, bind(self.getKeycardsFromOfficer, self))

	self.m_OfficerEnemies = {}
	self.m_OfficerCountdown = PrisonBreak.OfficerCountdown

	self.m_Keycards = false

	for k, box in pairs(PrisonBreakManager:getSingleton().m_WeaponBoxes) do
		addEventHandler("onElementClicked", box, bind(self.getWeaponsFromBox, self))
	end

	self.m_WeaponBoxPlayers = {}
end

function PrisonBreak:destructor()
	removeEventHandler("onPlayerTarget", root, bind(self.getKeycardsFromOfficer, self))
	
	for k, box in pairs(PrisonBreakManager:getSingleton().m_WeaponBoxes) do
		removeEventHandler("onElementClicked", box, bind(self.getWeaponsFromBox, self))
	end

	PrisonBreakManager:getSingleton():stop()
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

function PrisonBreak:getKeycardsFromOfficer(target)
	local sourcePlayer = source

	if self.m_Officer ~= target then
		for key, player in pairs(self.m_OfficerEnemies) do
			if player == source then
				self.m_OfficerEnemies[key] = nil
			end
		end

		if #self.m_OfficerEnemies == 0 then
			self.m_Officer:setAnimation()
			self.m_OfficerCountdown = PrisonBreak.OfficerCountdown
			
			if self.m_OfficerTimer then
				killTimer(self.m_OfficerTimer)
				self.m_OfficerTimer = nil
			end
		end

		return
	end

	table.insert(self.m_OfficerEnemies, source)
	self.m_Officer:setAnimation("ped", "handsup", -1, false)

	if #self.m_OfficerEnemies == 1 then
		self.m_OfficerTimer = setTimer(function ()
			self.m_OfficerCountdown = self.m_OfficerCountdown - #self.m_OfficerEnemies * 1000
			sourcePlayer:sendShortMessage("Bedrohung zu " .. math.round((self.m_OfficerCountdown / PrisonBreak.OfficerCountdown) * 100, 1) .. " % abgeschlossen.") -- BUG

			if self.m_OfficerCountdown <= 0 then
				self.m_Keycards = true

				setTimer(function ()
					self.m_Keycards = false
				end, PrisonBreak.KeycardsCountdown, 1)

				for key, player in pairs(self.m_Faction:getOnlinePlayers()) do
					player:triggerEvent("Countdown", math.floor(PrisonBreak.KeycardsCountdown / 1000), "Keycards")	
				end

				killTimer(self.m_OfficerTimer)
				self.m_OfficerTimer = nil
				self.m_OfficerCountdown = PrisonBreak.OfficerCountdown
			end
		end, 1000, 0)
	end
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