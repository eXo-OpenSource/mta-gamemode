Christmas = inherit(Singleton)

Christmas.ms_Bonus = {
	{
		["Text"] = "Radio",
		["Image"] = "Bonus_Radio.png",
		["Packages"] = 1,
		["CandyCane"] = 5,
		["Type"] = "Item",
		["ItemName"] = "Radio",
		["ItemAmount"] = 1
	},
	{
		["Text"] = "250g Weed",
		["Image"] = "Bonus_Weed.png",
		["Packages"] = 3,
		["CandyCane"] = 7,
		["Type"] = "Item",
		["ItemName"] = "Weed",
		["ItemAmount"] = 250
	},
	{
		["Text"] = "Messer",
		["Image"] = "Bonus_Knife.png",
		["Packages"] = 5,
		["CandyCane"] = 10,
		["Type"] = "Weapon",
		["WeaponId"] = 4,
		["Ammo"] = 1
	},
	{
		["Text"] = "15.000$",
		["Image"] = "Bonus_Money.png",
		["Packages"] = 5,
		["CandyCane"] = 10,
		["Type"] = "Money",
		["MoneyAmount"] = 15000
	},
	{
		["Text"] = "250 Punkte",
		["Image"] = "Bonus_Points.png",
		["Packages"] = 3,
		["CandyCane"] = 10,
		["Type"] = "Points",
		["PointsAmount"] = 250
	},
	{
		["Text"] = "Neutrales Karma",
		["Image"] = "Bonus_Karma.png",
		["Packages"] = 50,
		["CandyCane"] = 90,
		["Type"] = "Special"
	},
	{
		["Text"] = "Nick Change",
		["Image"] = "Bonus_NickChange.png",
		["Packages"] =75,
		["CandyCane"] = 100,
		["Type"] = "Special"
	},
	{
		["Text"] = "Weihnachts-Skin",
		["Image"] = "Bonus_ChristmasSkin.png",
		["Packages"] = 120,
		["CandyCane"] = 150,
		["Type"] = "Skin",
		["SkinId"] = 244
	},
	{
		["Text"] = "30 Tage VIP",
		["Image"] = "Bonus_VIP.png",
		["Packages"] = 175,
		["CandyCane"] = 200,
		["Type"] = "Special"
	},
	{
		["Text"] = "FCR-900",
		["Image"] = "Bonus_FCR.png",
		["Packages"] = 350,
		["CandyCane"] = 500,
		["Type"] = "Vehicle",
		["VehicleModel"] = 521
	},
	{
		["Text"] = "Remington",
		["Image"] = "Bonus_Remington.png",
		["Packages"] = 450,
		["CandyCane"] = 700,
		["Type"] = "Vehicle",
		["VehicleModel"] = 534
	}
}


function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()

	self.m_BankServerAccount = BankServer.get("event.christmas")

	if EVENT_CHRISTMAS_MARKET then
		WheelOfFortune:new(Vector3(1479, -1700.3, 14.2), 0) -- in front of tree
		WheelOfFortune:new(Vector3(1479, -1692.3, 14.2), 180) -- in back of tree
		--other wheels on side of market
		WheelOfFortune:new(Vector3(1455.52, -1662.81, 14.16), 80)
		WheelOfFortune:new(Vector3(1454.12, -1669.74, 14.17), 70)
		WheelOfFortune:new(Vector3(1455.73, -1654.92, 14.16), 95)
		WheelOfFortune:new(Vector3(1504.01, -1658.57, 14.12), 260)
		WheelOfFortune:new(Vector3(1506.11, -1651.70, 14.11), 245)
		WheelOfFortune:new(Vector3(1509.73, -1645.62, 14.11), 230)

		FerrisWheelManager:getSingleton():addWheel(Vector3(1479.35, -1665.9, 26.5), 0)
	end


	createObject(3861, 1456.84, -1748.18, 13.72, 0, 0, 170) --QuestShop (before market opens) BonusShop (after Event)
	createObject(3861, 1453.17, -1744.94, 13.72, 0, 0, 115) --Firework Shop

	addRemoteEvents{"eventRequestBonusData", "eventBuyBonus"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
	addEventHandler("eventBuyBonus", root, bind(self.Event_buyBonus, self))
end

function Christmas:Event_requestBonusData()
	client:triggerEvent("eventReceiveBonusData", Christmas.ms_Bonus)
end

function Christmas:Event_buyBonus(bonusId)
	local playerPackages = client:getInventoryOld():getItemAmount("Päckchen", true)
	local playerCandyCane = client:getInventoryOld():getItemAmount("Zuckerstange", true)

	local bonus = Christmas.ms_Bonus[bonusId]
	if not bonus then return end

	if playerPackages < bonus["Packages"] then
		client:sendError(_("Du hast nicht genug Päckchen! (%d)", client, bonus["Packages"]))
		return
	end

	if playerCandyCane < bonus["CandyCane"] then
		client:sendError(_("Du hast nicht genug Zuckerstangen! (%d)", client, bonus["CandyCane"]))
		return
	end

	if bonus["Type"] == "Weapon" then
		client:giveWeapon(bonus["WeaponId"], bonus["Ammo"])
	elseif bonus["Type"] == "Item" then
		if client:getInventoryOld():getFreePlacesForItem(bonus["ItemName"]) >= bonus["ItemAmount"] then
			client:getInventoryOld():giveItem(bonus["ItemName"], bonus["ItemAmount"])
		else
			client:sendError(_("Du hast nicht genug Platz in deinem Inventar!", client))
			return
		end
	elseif bonus["Type"] == "Vehicle" then
		local vehicle = VehicleManager:getSingleton():createNewVehicle(client, VehicleTypes.Player, bonus["VehicleModel"], 1492.67, -1724.68, 13.23, 0, 0, 270)
		if vehicle then
			setTimer(function(player, vehicle)
				player:warpIntoVehicle(vehicle)
				player:triggerEvent("vehicleBought")
			end, 100, 1, client, vehicle)
		else
			client:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", client), 255, 0, 0)
		end

	elseif bonus["Type"] == "Money" then
		self.m_BankServerAccount:transferMoney(client, bonus["MoneyAmount"], "Weihnachts-Event", "Event", "Weihnachten")
	elseif bonus["Type"] == "Points" then
		client:givePoints(bonus["PointsAmount"])
		client:sendShortMessage(_("%d Punkte erhalten!", client, bonus["PointsAmount"]))
	elseif bonus["Type"] == "Skin" then
		client:getInventoryOld():giveItem("Kleidung", 1, bonus["SkinId"])
		client:sendShortMessage("Der Skin wurde in dein Inventar gelegt!")
	elseif bonus["Type"] == "Special" then
		if bonus["Text"] == "Schutzweste" then
			client:setArmor(100)
		elseif bonus["Text"] == "Neutrales Karma" then
			client:setKarma(0)
		elseif bonus["Text"] == "Nick Change" then
			outputChatBox("Bitte schreib ein Ticket um den Nick-Change von einem Admin durchführen zu lassen.", client, 0, 255, 0)
			outputChatBox("Schreib unbedingt dazu, dass du diesen durchs Weichnachts Event kostenlos erhälst!", client, 0, 255, 0)
		elseif bonus["Text"] == "30 Tage VIP" then
			if DEBUG then
				client:sendError(_("Im DEBUG Modus (Testserver) nicht verfügbar!", client))
				return
			end
			client.m_Premium:giveEventMonth()
		end
	end

	client:getInventoryOld():removeItem("Zuckerstange", bonus["CandyCane"])
	client:getInventoryOld():removeItem("Päckchen", bonus["Packages"])
	client:sendSuccess(_("Du hast erfolgreich den Bonus %s für %d Päckchen und %d Zuckerstange/n gekauft!", client, bonus["Text"], bonus["Packages"], bonus["CandyCane"]))
	StatisticsLogger:getSingleton():addHalloweenLog(client, bonus["Text"], bonus["Packages"], bonus["CandyCane"])

end
