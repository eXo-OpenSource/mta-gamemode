Christmas = inherit(Singleton)

Christmas.ms_Bonus = {
	{
		["Text"] = "Schutzweste",
		["Image"] = "Bonus_Vest.png",
		["Packages"] = 1,
		["CandyCane"] = 25,
		["Type"] = "Special"
	},
	{
		["Text"] = "50 Weed",
		["Image"] = "Bonus_Weed.png",
		["Packages"] = 5,
		["CandyCane"] = 75,
		["Type"] = "Item",
		["ItemName"] = "Weed",
		["ItemAmount"] = 50
	},
	{
		["Text"] = "5 Heroin",
		["Image"] = "Bonus_Heroin.png",
		["Packages"] = 5,
		["CandyCane"] = 100,
		["Type"] = "Item",
		["ItemName"] = "Heroin",
		["ItemAmount"] = 5
	},
	{
		["Text"] = "Deagle (20 Schuss)",
		["Image"] = "Bonus_Deagle.png",
		["Packages"] = 10,
		["CandyCane"] = 150,
		["Type"] = "Weapon",
		["WeaponId"] = 24,
		["Ammo"] = 20
	},
	{
		["Text"] = "Dildo",
		["Image"] = "Bonus_Dildo.png",
		["Packages"] = 15,
		["CandyCane"] = 200,
		["Type"] = "Weapon",
		["WeaponId"] = 10,
		["Ammo"] = 1
	},
	{
		["Text"] = "5.000$",
		["Image"] = "Bonus_Money.png",
		["Packages"] = 20,
		["CandyCane"] = 350,
		["Type"] = "Money",
		["MoneyAmount"] = 5000
	},
	{
		["Text"] = "10.000$",
		["Image"] = "Bonus_Money.png",
		["Packages"] = 30,
		["CandyCane"] = 500,
		["Type"] = "Money",
		["MoneyAmount"] = 10000
	},
	{
		["Text"] = "Payday Bonus",
		["Image"] = "Bonus_Payday.png",
		["Packages"] = 50,
		["CandyCane"] = 700,
		["Type"] = "Special"
	},
	{
		["Text"] = "Karma Reset",
		["Image"] = "Bonus_Karma.png",
		["Packages"] = 70,
		["CandyCane"] = 1300,
		["Type"] = "Special"
	},
	{
		["Text"] = "Nick Change",
		["Image"] = "Bonus_NickChange.png",
		["Packages"] = 75,
		["CandyCane"] = 1400,
		["Type"] = "Special"
	},
	{
		["Text"] = "Zombie Skin",
		["Image"] = "Bonus_Zombie.png",
		["Packages"] = 100,
		["CandyCane"] = 2000,
		["Type"] = "Special"
	},
	{
		["Text"] = "75.000$",
		["Image"] = "Bonus_Money.png",
		["Packages"] = 125,
		["CandyCane"] = 2400,
		["Type"] = "Money",
		["MoneyAmount"] = 75000
	},
	{
		["Text"] = "30 Tage VIP",
		["Image"] = "Bonus_VIP.png",
		["Packages"] = 150,
		["CandyCane"] = 3000,
		["Type"] = "Special"
	},
	{
		["Text"] = "Romero",
		["Image"] = "Bonus_Romero.png",
		["Packages"] = 240,
		["CandyCane"] = 4200,
		["Type"] = "Vehicle",
		["VehicleModel"] = 442
	},
	{
		["Text"] = "Bravura",
		["Image"] = "Bonus_Bravura.png",
		["Packages"] = 250,
		["CandyCane"] = 4500,
		["Type"] = "Vehicle",
		["VehicleModel"] = 401
	}
}

function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()
	WheelOfFortune:new(Vector3(1479, -1700.3, 14.2), 0)

	addRemoteEvents{"eventRequestBonusData", "eventBuyBonus"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
	addEventHandler("eventBuyBonus", root, bind(self.Event_buyBonus, self))
end

function Christmas:Event_requestBonusData()
	client:triggerEvent("eventReceiveBonusData", Halloween.ms_Bonus)
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
		local vehicle = PermanentVehicle.create(client, bonus["VehicleModel"], 956.881, -1115.489, 23.398, 0, 0, 180, nil, false)
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

	client:getInventory():removeItem("Suessigkeiten", bonus["CandyCane"])
	client:getInventory():removeItem("Kürbis", bonus["Packages"])
	client:sendSuccess(_("Du hast erfolgreich den Bonus %s für %d Kürbisse und %d Süßigkeiten gekauft!", client, bonus["Text"], bonus["Packages"], bonus["CandyCane"]))
	StatisticsLogger:getSingleton():addHalloweenLog(client, bonus["Text"], bonus["Packages"], bonus["CandyCane"])

end
