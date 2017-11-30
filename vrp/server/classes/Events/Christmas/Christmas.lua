Christmas = inherit(Singleton)

Christmas.ms_Bonus = {
	{
		["Text"] = "Schutzweste",
		["Image"] = "Bonus_Vest.png",
		["Packages"] = 0,
		["CandyCane"] = 5,
		["Type"] = "Special"
	},
	{
		["Text"] = "250g Weed",
		["Image"] = "Bonus_Weed.png",
		["Packages"] = 1,
		["CandyCane"] = 5,
		["Type"] = "Item",
		["ItemName"] = "Weed",
		["ItemAmount"] = 250
	},
	{
		["Text"] = "Dildo",
		["Image"] = "Bonus_Dildo.png",
		["Packages"] = 3,
		["CandyCane"] = 5,
		["Type"] = "Weapon",
		["WeaponId"] = 10,
		["Ammo"] = 1
	},
	{
		["Text"] = "10.000$",
		["Image"] = "Bonus_Money.png",
		["Packages"] = 3,
		["CandyCane"] = 10,
		["Type"] = "Money",
		["MoneyAmount"] = 10000
	},
	{
		["Text"] = "100 Punkte",
		["Image"] = "Bonus_Points.png",
		["Packages"] = 3,
		["CandyCane"] = 10,
		["Type"] = "Points",
		["PointsAmount"] = 100
	},
	{
		["Text"] = "Neutrales Karma",
		["Image"] = "Bonus_Karma.png",
		["Packages"] = 60,
		["CandyCane"] = 100,
		["Type"] = "Special"
	},
	{
		["Text"] = "Nick Change",
		["Image"] = "Bonus_NickChange.png",
		["Packages"] =100,
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
		["Packages"] = 200,
		["CandyCane"] = 200,
		["Type"] = "Special"
	},
	{
		["Text"] = "Comet",
		["Image"] = "Bonus_Comet.png",
		["Packages"] = 350,
		["CandyCane"] = 500,
		["Type"] = "Vehicle",
		["VehicleModel"] = 480
	},
	{
		["Text"] = "Pizza-Boy",
		["Image"] = "Bonus_PizzaBoy.png",
		["Packages"] = 400,
		["CandyCane"] = 550,
		["Type"] = "Vehicle",
		["VehicleModel"] = 448
	}
}

function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()

	self.m_BankServerAccount = BankServer.get("event.halloween")

	WheelOfFortune:new(Vector3(1479, -1700.3, 14.2), 0)

	addRemoteEvents{"eventRequestBonusData", "eventBuyBonus"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
	addEventHandler("eventBuyBonus", root, bind(self.Event_buyBonus, self))
end

function Christmas:Event_requestBonusData()
	client:triggerEvent("eventReceiveBonusData", Christmas.ms_Bonus)
end

function Christmas:Event_buyBonus(bonusId)
	local playerPackages = client:getInventory():getItemAmount("Päckchen", true)
	local playerCandyCane = client:getInventory():getItemAmount("Zuckerstange", true)

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
		if client:getInventory():getFreePlacesForItem(bonus["ItemName"]) >= bonus["ItemAmount"] then
			client:getInventory():giveItem(bonus["ItemName"], bonus["ItemAmount"])
		else
			client:sendError(_("Du hast nicht genug Platz in deinem Inventar!", client))
			return
		end
	elseif bonus["Type"] == "Vehicle" then
		local vehicle = PermanentVehicle.create(client, bonus["VehicleModel"], 1492.67, -1724.68, 13.23, 0, 0, 270, nil, false)
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
		client:getInventory():giveItem("Kleidung", 1, bonus["SkinId"])
		client:sendShortMessage("Der Skin wurde in dein Inventar gelegt!")
	elseif bonus["Type"] == "Special" then
		if bonus["Text"] == "Schutzweste" then
			client:setArmor(100)
		elseif bonus["Text"] == "Karma Reset" then
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

	client:getInventory():removeItem("Zuckerstange", bonus["CandyCane"])
	client:getInventory():removeItem("Päckchen", bonus["Packages"])
	client:sendSuccess(_("Du hast erfolgreich den Bonus %s für %d Päckchen und %d Zuckerstange/n gekauft!", client, bonus["Text"], bonus["Packages"], bonus["CandyCane"]))
	StatisticsLogger:getSingleton():addHalloweenLog(client, bonus["Text"], bonus["Packages"], bonus["CandyCane"])

end
