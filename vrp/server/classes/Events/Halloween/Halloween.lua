Halloween = inherit(Singleton)
Halloween.ms_HouseTTCooldown = 1000 * 60 * 60 -- 1 hour cooldown for each individual house in ms
Halloween.ms_Phrases = {
	single = {
		"Hier bitteschön, lass es dir schmecken!",
		"Das ist für dich!",
		"Na wer hat sich denn hier verkleidet?"
	},
	multi = {
		"Ihr seid mir aber eine Gruselbande!",
		"Oh! Hab ich mich erschkreckt! Hier bitte!",
		"Wenn das nicht die Nachbargeister sind - Bitteschön!",
	},
}

Halloween.ms_Bonus = {
	{
		["Text"] = "Schutzweste",
		["Pumpkin"] = 1,
		["Sweets"] = 5,
		["Type"] = "Special"
	},
	{
		["Text"] = "50 Weed",
		["Pumpkin"] = 5,
		["Sweets"] = 15,
		["Type"] = "Item",
		["ItemName"] = "Weed",
		["ItemAmount"] = 50
	},
	{
		["Text"] = "5 Heroin",
		["Pumpkin"] = 5,
		["Sweets"] = 20,
		["Type"] = "Item",
		["ItemName"] = "Heroin",
		["ItemAmount"] = 3
	},
	{
		["Text"] = "Deagle (20 Schuss)",
		["Pumpkin"] = 10,
		["Sweets"] = 25,
		["Type"] = "Weapon",
		["WeaponId"] = 24,
		["Ammo"] = 20
	},
	{
		["Text"] = "Dildo",
		["Pumpkin"] = 15,
		["Sweets"] = 25,
		["Type"] = "Weapon",
		["WeaponId"] = 10,
		["Ammo"] = 1
	},
	{
		["Text"] = "5.000$",
		["Pumpkin"] = 20,
		["Sweets"] = 75,
		["Type"] = "Money",
		["MoneyAmount"] = 5000
	},
	{
		["Text"] = "10.000$",
		["Pumpkin"] = 30,
		["Sweets"] = 100,
		["Type"] = "Money",
		["MoneyAmount"] = 10000
	},
	{
		["Text"] = "Payday Bonus",
		["Pumpkin"] = 35,
		["Sweets"] = 300,
		["Type"] = "Special"
	},
	{
		["Text"] = "Karma Reset",
		["Pumpkin"] = 50,
		["Sweets"] = 300,
		["Type"] = "Special"
	},
	{
		["Text"] = "Nick Change",
		["Pumpkin"] = 65,
		["Sweets"] = 275,
		["Type"] = "Special"
	},
	{
		["Text"] = "Zombie Skin",
		["Pumpkin"] = 75,
		["Sweets"] = 300,
		["Type"] = "Special"
	},
	{
		["Text"] = "75.000$",
		["Pumpkin"] = 85,
		["Sweets"] = 499,
		["Type"] = "Money",
		["MoneyAmount"] = 75000
	},
	{
		["Text"] = "30 Tage VIP",
		["Pumpkin"] = 95,
		["Sweets"] = 600,
		["Type"] = "Special"
	},
	{
		["Text"] = "Romero",
		["Image"] = "Bonus_Romero.png",
		["Pumpkin"] = 110,
		["Sweets"] = 850,
		["Type"] = "Vehicle",
		["Model"] = 442
	},
	{
		["Text"] = "Bravura",
		["Pumpkin"] = 125,
		["Sweets"] = 900,
		["Type"] = "Vehicle",
		["Model"] = 442
	},
	{
		["Text"] = "Hausmarker",
		["Pumpkin"] = 150,
		["Sweets"] = 999,
		["Type"] = "Special"
	}
}

function Halloween:constructor()
	DrawContest:new()
	self.m_TrickOrTreatPIDs = {}

	self.m_EventSign = createObject(1903, 1484.80, -1710.70, 12.4, 0, 0, 90)
	self.m_EventSign:setDoubleSided(true)

	Player.getScreamHook():register(
		function(player, text)
			Halloween:getSingleton():checkForTTScream(player, text)
		end
	)

	local romero = TemporaryVehicle.create(442, 937.79999, -1120.6, 23.8, 24)
	romero:setColor(0, 0, 0)
	romero:setFrozen(true)
    romero:setLocked(true)
	romero:setVariant(255, 255)
	romero:setMaxHealth(2000, true)
	romero:setBulletArmorLevel(2)
	romero:setRepairAllowed(false)
	romero:toggleRespawn(false)
	romero:setAlwaysDamageable(true)
	romero.m_DisableToggleHandbrake = true


	addRemoteEvents{"eventRequestBonusData"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
end

function Halloween:initTTPlayer(pId)
	if not self.m_TrickOrTreatPIDs[pId] then
		self.m_TrickOrTreatPIDs[pId] = {
			visitedHouses = {},
			lastVisited = 0,
		}
	end
end

function Halloween:registerTrickOrTreat(pId, houseId, time)
	local player = DatabasePlayer.getFromId(pId)
	if isElement(player) and getElementType(player) == "player" then
		self:initTTPlayer(pId)
		local d = self.m_TrickOrTreatPIDs[pId]
		if not d.currentHouseId then
			if not d.visitedHouses[houseId] or (getTickCount() - d.visitedHouses[houseId]) > Halloween.ms_HouseTTCooldown then
				outputDebug("registered tt", player)
				d.currentHouseId = houseId
				d.trickStarted = getTickCount()
				d.playersNearby = {}
				table.insert(d.playersNearby, player:getId())
				player:triggerEvent("Countdown", time/1000, "Süßes oder Saures")
				player:sendInfo(_("Schreie 'Süßes oder Saures!', um die Bewohner auf dich aufmerksam zu machen.", player))

				for i, v in pairs(getElementsByType("player")) do
					self:initTTPlayer(v:getId())
					if HouseManager:getSingleton().m_Houses[houseId]:isPlayerNearby(v) and not self.m_TrickOrTreatPIDs[v:getId()].currentHouseId then
						if not self.m_TrickOrTreatPIDs[v:getId()].visitedHouses[houseId] or (getTickCount() - self.m_TrickOrTreatPIDs[v:getId()].visitedHouses[houseId]) > Halloween.ms_HouseTTCooldown then
							table.insert(d.playersNearby, v:getId())
							self.m_TrickOrTreatPIDs[v:getId()].trickStarted = getTickCount()
							self.m_TrickOrTreatPIDs[v:getId()].currentHouseId = houseId

							v:triggerEvent("Countdown", time/1000, "Süßes oder Saures")
							v:sendInfo(_("Schreie 'Süßes oder Saures!', um die Bewohner auf dich aufmerksam zu machen.", player))
						else
							v:sendError(_("Hier warst du schon! Komm später wieder.", v))
						end
					end
				end
			else
				player:sendError(_("Hier warst du schon! Komm später wieder.", player))
			end
		end
	end
end

function Halloween:checkForTTScream(player, text)
	local pId = player:getId()
	if player.vehicle or player:getPrivateSync("isAttachedToVehicle") then return end

	self:initTTPlayer(pId)
	local d = self.m_TrickOrTreatPIDs[pId]
	if text:lower():gsub("ß", "ss"):find("süsses oder saures") then
		outputDebug("chatted tt", player)
		d.lastMessage = getTickCount()
	end
end

function Halloween:finishTrickOrTreat(pId, houseId)
	if self.m_TrickOrTreatPIDs[pId] and self.m_TrickOrTreatPIDs[pId].playersNearby then
		local pCount = table.size(self.m_TrickOrTreatPIDs[pId].playersNearby)
		local ownerId = HouseManager:getSingleton().m_Houses[houseId]:getOwner()
		local ownerAtHome = (ownerId and ownerId ~= 0) and chance(75) or 0 -- chance that somebody is there to give sweets
		local rndPhrase = Halloween.ms_Phrases[pCount > 1 and "multi" or "single"]
			rndPhrase = rndPhrase[math.random(1, #rndPhrase)]

		for i, v in pairs(self.m_TrickOrTreatPIDs[pId].playersNearby) do --this includes "player" as he gets inserted in registerTrickOrTreat
			local d = self.m_TrickOrTreatPIDs[v]
			local pl = DatabasePlayer.getFromId(v)
			if pl and isElement(pl) then
				if d.currentHouseId == houseId then
					if HouseManager:getSingleton().m_Houses[houseId]:isPlayerNearby(pl) then
						if d.lastMessage and d.lastMessage >= d.trickStarted and (getTickCount() - d.lastVisited) > 30000 then
							if ownerAtHome then
								local rnd = math.random(1, math.min(5, pCount))
								pl:getInventory():giveItem("Suessigkeiten", rnd)
								pl:sendSuccess(_("Du hast %d %s bekommen!", pl, rnd, rnd > 1 and "Süßigkeiten" or "Süßigkeit"))
								pl:sendMessage(("Bewohner sagt: %s"):format(rndPhrase), 200, 200, 200)
							else
								pl:sendShortMessage(_("Es scheint niemand zu Hause zu sein...", pl))
							end
							d.visitedHouses[houseId] = getTickCount()
							d.lastVisited = getTickCount()
						end
					else
						pl:sendWarning(_("Du musst in der Nähe der Tür bleiben um Süßigkeiten zu bekommen!", pl))
					end
				end
			end
			d.currentHouseId = nil
			d.lastMessage = nil
		end
	end
end

function Halloween:Event_requestBonusData()
	client:triggerEvent("eventReceiveBonusData", Halloween.ms_Bonus)
end
