Halloween = inherit(Singleton)
Halloween.ms_HouseTTCooldown = 1000 * 60 * 60 -- 1 hour cooldown for each individual house in ms
Halloween.ms_Phrases = {
	single = {
		"Hier bitteschön, lass es dir schmecken!",
		"Das ist für dich!",
		"Hier, für dich!",
		"Das hab ich noch im Schrank gefunden.",
		"Na wer hat sich denn hier verkleidet?",
		"Lass es dir schmecken!",
	},
	multi = {
		"Ihr seid mir aber eine Gruselbande!",
		"Na mal sehen ob das für euch reicht...",
		"Oh! Hab ich mich erschreckt! Hier bitte!",
		"Wenn das nicht die Nachbargeister sind - Bitteschön!",
		"Da brauche ich aber eine große Tüte.",
		"Hier, die feinsten Naschereien!",
	},
}

Halloween.ms_Bonus = {
	{
		["Text"] = "10.000$",
		["Image"] = "Bonus_Money.png",
		["Pumpkin"] = 30,
		["Sweets"] = 500,
		["Type"] = "Money",
		["MoneyAmount"] = 10000
	},
	{
		["Text"] = "Payday Bonus",
		["Image"] = "Bonus_Payday.png",
		["Pumpkin"] = 50,
		["Sweets"] = 700,
		["Type"] = "Special"
	},
	{
		["Text"] = "Karma Reset",
		["Image"] = "Bonus_Karma.png",
		["Pumpkin"] = 70,
		["Sweets"] = 1300,
		["Type"] = "Special"
	},
	{
		["Text"] = "Nick Change",
		["Image"] = "Bonus_NickChange.png",
		["Pumpkin"] = 75,
		["Sweets"] = 1400,
		["Type"] = "Special"
	},
	{
		["Text"] = "Zombie Skin",
		["Image"] = "Bonus_Zombie.png",
		["Pumpkin"] = 100,
		["Sweets"] = 2000,
		["Type"] = "Special"
	},
	{
		["Text"] = "75.000$",
		["Image"] = "Bonus_Money.png",
		["Pumpkin"] = 125,
		["Sweets"] = 2400,
		["Type"] = "Money",
		["MoneyAmount"] = 75000
	},
	{
		["Text"] = "30 Tage VIP",
		["Image"] = "Bonus_VIP.png",
		["Pumpkin"] = 150,
		["Sweets"] = 3000,
		["Type"] = "Special"
	},
	{
		["Text"] = "Romero",
		["Image"] = "Bonus_Romero.png",
		["Pumpkin"] = 450,
		["Sweets"] = 4200,
		["Type"] = "Vehicle",
		["VehicleModel"] = 442
	},
	{
		["Text"] = "Broadway",
		["Image"] = "Bonus_Broadway.png",
		["Pumpkin"] = 650,
		["Sweets"] = 4500,
		["Type"] = "Vehicle",
		["VehicleModel"] = 575
	}
}

Halloween.ms_QuestRewards = {
	{pumpkins=2, sweets=5},
	{pumpkins=5, sweets=15},
	{pumpkins=2, sweets=10},
	{pumpkins=10, sweets=25},
}

function Halloween:constructor()
	DrawContest:new()
	WareManager:new()
	self.m_TrickOrTreatPIDs = {}

	self.m_EventSign = createObject(1903, 1507.73, -1753.96, 12.59, 0, 0, 270)
	self.m_EventSign:setDoubleSided(true)
	self.m_BankServerAccount = BankServer.get("event.halloween")

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


	addRemoteEvents{"eventRequestBonusData", "eventBuyBonus", "Halloween:giveGhostCleaner", "Halloween:takeGhostCleaner", "Halloween:requestQuestState", "Halloween:requestQuestUpdate"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
	addEventHandler("eventBuyBonus", root, bind(self.Event_buyBonus, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerQuit, self))
	addEventHandler("Halloween:giveGhostCleaner", root, bind(self.Event_giveGhostCleaner, self))
	addEventHandler("Halloween:takeGhostCleaner", root, bind(self.Event_takeGhostCleaner, self))
	addEventHandler("Halloween:requestQuestState", root, bind(self.requestQuestState, self))
	addEventHandler("Halloween:requestQuestUpdate", root, bind(self.requestQuestUpdate, self))

	self:initHalloweenDM()
	self:createQuestMarkers()

	HalloweenEasterEggs:new()
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
					if HouseManager:getSingleton().m_Houses[houseId]:isPlayerNearby(v) and not self.m_TrickOrTreatPIDs[v:getId()].currentHouseId and v:getInterior() == 0 and v:getDimension() == 0 then
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
		local ownerAtHome = (ownerId and ownerId ~= 0) and chance(75) or false -- chance that somebody is there to give sweets
		local rndPhrase = Halloween.ms_Phrases[pCount > 1 and "multi" or "single"]
			rndPhrase = rndPhrase[math.random(1, #rndPhrase)]

		for i, v in pairs(self.m_TrickOrTreatPIDs[pId].playersNearby) do --this includes "player" as he gets inserted in registerTrickOrTreat
			local d = self.m_TrickOrTreatPIDs[v]
			local pl = DatabasePlayer.getFromId(v)
			if pl and isElement(pl) then
				if d.currentHouseId == houseId then
					if HouseManager:getSingleton().m_Houses[houseId]:isPlayerNearby(pl) then
						if d.lastMessage and d.lastMessage >= d.trickStarted and (getTickCount() - d.lastVisited) > 20000 then
							if ownerAtHome then
								local rnd = math.random(1, math.min(5, pCount))
								if pl.m_IsWearingHelmet == "Kürbis" then --pumpkin head bonus
									rnd = rnd + (chance(5) and 1 or 0)
								elseif pl:getModel() == 310 then --zombie skin bonus
									rnd = rnd + (chance(15) and 1 or 0)
								end
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
				pl.m_HouseDoorBellCooldown = false
			end
			d.currentHouseId = nil
			d.lastMessage = nil
		end
	end
end

function Halloween:Event_requestBonusData()
	client:triggerEvent("eventReceiveBonusData", Halloween.ms_Bonus)
end

function Halloween:Event_buyBonus(bonusId)
	local playerSweets = client:getInventory():getItemAmount("Suessigkeiten", true)
	local playerPumpinks = client:getInventory():getItemAmount("Kürbis", true)
	local bonus = Halloween.ms_Bonus[bonusId]
	if not bonus then return end

	if playerSweets < bonus["Sweets"] then
		client:sendError(_("Du hast nicht genug Süßigkeiten! (%d)", client, bonus["Sweets"]))
		return
	end

	if playerPumpinks < bonus["Pumpkin"] then
		client:sendError(_("Du hast nicht genug Kürbisse! (%d)", client, bonus["Pumpkin"]))
		return
	end

	if bonus["Type"] == "Weapon" then
		client:giveWeapon(bonus["WeaponId"], bonus["Ammo"])
	elseif bonus["Type"] == "Item" then
		if client:getInventory():getFreePlacesForItem(bonus["ItemName"]) >= bonus["ItemAmount"] then
			client:getInventory():giveItem(bonus["ItemName"], bonus["ItemAmount"])
		else
			client:sendError(_("Du hast nicht genug Platz in deinem Inventar!", client))
			return
		end
	elseif bonus["Type"] == "Vehicle" then
		local vehicle = VehicleManager:getSingleton():createNewVehicle(client, VehicleTypes.Player, bonus["VehicleModel"], 956.881, -1115.489, 23.398, 0, 0, 180)
		if vehicle then
			setTimer(function(player, vehicle)
				player:warpIntoVehicle(vehicle)
				player:triggerEvent("vehicleBought")
			end, 100, 1, client, vehicle)
		else
			client:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", client), 255, 0, 0)
		end

	elseif bonus["Type"] == "Money" then
		self.m_BankServerAccount:transferMoney(client, bonus["MoneyAmount"], "Halloween-Event", "Event", "Halloween")
	elseif bonus["Type"] == "Special" then
		if bonus["Text"] == "Schutzweste" then
			client:setArmor(100)
		elseif bonus["Text"] == "Payday Bonus" then
			if not client.m_HalloweenPaydayBonus then
				client.m_HalloweenPaydayBonus = 2000
			else
				client:sendError(_("Du hast den Payday Bonus bereits aktiviert!", client))
				return
			end
		elseif bonus["Text"] == "Karma Reset" then
			client:setKarma(0)
		elseif bonus["Text"] == "Nick Change" then
			outputChatBox("Bitte schreib ein Ticket um den Nick-Change von einem Admin durchführen zu lassen.", client, 0, 255, 0)
			outputChatBox("Schreib unbedingt dazu, dass du diesen durchs Halloween Event kostenlos erhälst!", client, 0, 255, 0)
		elseif bonus["Text"] == "Zombie Skin" then
			client:getInventory():giveItem("Kleidung", 1, 310)
			client:sendShortMessage("Der Zombie-Skin wurde in dein Inventar gelegt!")
		elseif bonus["Text"] == "30 Tage VIP" then
			client.m_Premium:giveEventMonth()
		end
	end

	client:getInventory():removeItem("Suessigkeiten", bonus["Sweets"])
	client:getInventory():removeItem("Kürbis", bonus["Pumpkin"])
	client:sendSuccess(_("Du hast erfolgreich den Bonus %s für %d Kürbisse und %d Süßigkeiten gekauft!", client, bonus["Text"], bonus["Pumpkin"], bonus["Sweets"]))
	StatisticsLogger:getSingleton():addHalloweenLog(client, bonus["Text"], bonus["Pumpkin"], bonus["Sweets"])

end

function Halloween:initHalloweenDM()
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 12, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 12, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 14, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 14, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 16, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 16, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 18, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 18, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 20, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 20, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 22, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 22, 13)

	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmMessage, self), "HalloweenDmMsg", nil, 00, 03)
	GlobalTimer:getSingleton():registerEvent(bind(self.halloweenDmStart, self), "HalloweenDmMsg", nil, 00, 13)
end

function Halloween:halloweenDmMessage()
	for index, playeritem in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
		playeritem:sendShortMessage(_("Um %d:13 startet ein Halloween Special an der DM-Arena!", playeritem, getRealTime().hour), _("Halloween-DM", playeritem), {255, 130, 0})
	end
end

function Halloween:halloweenDmStart()
	DeathmatchManager:getSingleton():createLobby("Halloween Event", "Server", "halloween", {}, "halloween", 10)
	for index, playeritem in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
		playeritem:sendShortMessage(_("Die Halloween-Deathmatch Lobby wurde geöffnet!", playeritem), _("Halloween-DM", playeritem), {255, 130, 0})
	end
end

function Halloween:Event_giveGhostCleaner()
	giveWeapon(client, 27, 9999, true)
end

function Halloween:Event_takeGhostCleaner()
	takeWeapon(client, 27)
end

function Halloween:onPlayerQuit()
	takeWeapon(source, 27)
end

function Halloween:createQuestMarkers()
	self.m_QuestEnterExits = {
		[1] = {
			InteriorEnterExit:new(Vector3(2751.914, -1962.834, 13.548), Vector3(-42.56, 1405.99, 1084.43), 270, 0, 8, 13, 0, 0)
		},
		[2] = {
			InteriorEnterExit:new(Vector3(1851.825, -2135.402, 15.388), Vector3(-68.89, 1351.71, 1080.21), 0, 180, 6, 13, 0, 0),
			InteriorEnterExit:new(Vector3(986.370, -1624.505, 14.930), Vector3(2365.25, -1135.06, 1050.88), 0, 90, 8, 13, 0, 0),
			InteriorEnterExit:new(Vector3(824.521, -1423.724, 14.496), Vector3(-261.17, 1456.69, 1084.37), 90, 0, 4, 13, 0, 0),
			InteriorEnterExit:new(Vector3(2092.063, -1166.489, 26.586), Vector3(318.55, 1114.98, 1083.88), 0, 90, 5, 13, 0, 0)
		},
		[3] = {
			InteriorEnterExit:new(Vector3(2058.01, -1697.27, 13.55), Vector3(2270.01, -1210.48, 1047.56), 90, 0, 10, 13, 0, 0)
		},
		[4] = {
			InteriorEnterExit:new(Vector3(2539.86, -1303.96, 34.95), Vector3(2542.45, -1304.00, 1025.07), 90, 270, 2, 13, 0, 0)
		}
	}
end

function Halloween:requestQuestState()
	local state = self:getQuestState(client)
	client:triggerEvent("Halloween:sendQuestState", state)
end

function Halloween:getQuestState(player)
	local result = sql:queryFetchSingle("SELECT Quest FROM ??_halloween_quest WHERE UserId = ?", sql:getPrefix(), player:getId())
	return result and result.Quest or 0 
end

function Halloween:requestQuestUpdate(quest)
	self:setQuestState(client, quest)

	client:getInventory():giveItem("Kürbis", Halloween.ms_QuestRewards[quest].pumpkins)
    client:getInventory():giveItem("Suessigkeiten", Halloween.ms_QuestRewards[quest].sweets)

    client:sendSuccess(_("Du hast %s Kürbisse und und %s Süßigkeiten erhalten!", client, Halloween.ms_QuestRewards[quest].pumpkins, Halloween.ms_QuestRewards[quest].sweets))
end

function Halloween:setQuestState(player, quest)
	if quest == 1 then
		sql:queryExec("INSERT INTO ??_halloween_quest (UserId, Quest) VALUES (?, ?)", sql:getPrefix(), player:getId(), 1)
	else
		sql:queryExec("UPDATE ??_halloween_quest SET Quest = ? WHERE UserId = ?", sql:getPrefix(), quest, player:getId())
	end
end