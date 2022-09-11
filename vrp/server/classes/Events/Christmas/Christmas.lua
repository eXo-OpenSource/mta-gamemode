Christmas = inherit(Singleton)

Christmas.ms_Bonus = {
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
		["Text"] = "Mr. Whoopee",
		["Image"] = "Bonus_Whoopee.png",
		["Packages"] = 550,
		["CandyCane"] = 850,
		["Type"] = "Vehicle",
		["VehicleModel"] = 423
	}
}


local day = getRealTime().monthday
local month = getRealTime().month+1

if month == 12 and day >= 6 and day <= 12 then
	Christmas.ms_PricePoolName = "Christmas2021-1"
	Christmas.ms_PricePoolEnd = 1639328400
	Christmas.ms_PricePoolPrices = {
		{"vehicle", 571},
		{"money", 100000},
		{"money", 100000},

		{"vehicle", 534},
		{"money", 100000},
		{"money", 100000},

		{"VIP", 1},
	}
elseif month == 12 and day <= 19 then
	Christmas.ms_PricePoolName = "Christmas2021-2"
	Christmas.ms_PricePoolEnd = 1639933200
	Christmas.ms_PricePoolPrices = {
		{"vehicle", 437},
		{"money", 100000},
		{"money", 100000},

		{"vehicle", 586},
		{"money", 100000},
		{"money", 100000},

		{"VIP", 1},
	}
elseif month == 12 and day <= 26 then
	Christmas.ms_PricePoolName = "Christmas2021-3"
	Christmas.ms_PricePoolEnd = 1640538000
	Christmas.ms_PricePoolPrices = {
		{"vehicle", 448},
		{"money", 100000},
		{"money", 100000},

		{"vehicle", 445},
		{"money", 100000},
		{"money", 100000},

		{"VIP", 1},
	}
end

function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()
	self.m_AdventCalender = {}

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

	addRemoteEvents{"eventRequestBonusData", "eventBuyBonus", "Christmas:openDoor"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
	addEventHandler("eventBuyBonus", root, bind(self.Event_buyBonus, self))
	addEventHandler("Christmas:openDoor", root, bind(self.openDoor, self))

	if Christmas.ms_PricePoolName then
		self.m_PricePool = PricePoolManager:getSingleton():getPricePool(Christmas.ms_PricePoolName, "Päckchen", Christmas.ms_PricePoolPrices, Christmas.ms_PricePoolEnd)
		if self.m_PricePool then
			PricePoolManager:getSingleton():createPed(self.m_PricePool, 185, Vector3(1481.55, -1697.34, 14.05), 165)
		end
	end
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
		client:getInventory():giveItem("Kleidung", 1, bonus["SkinId"])
		client:sendShortMessage("Der Skin wurde in dein Inventar gelegt!")
	elseif bonus["Type"] == "Special" then
		if bonus["Text"] == "Schutzweste" then
			client:setArmor(100)
		elseif bonus["Text"] == "Nick Change" then
			outputChatBox(_("Bitte schreib ein Ticket um den Nick-Change von einem Admin durchführen zu lassen.", client), client, 0, 255, 0)
			outputChatBox(_("Schreib unbedingt dazu, dass du diesen durchs Weichnachts Event kostenlos erhälst!", client), client, 0, 255, 0)
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

function Christmas:openDoor()
	if not self.m_AdventCalender[client:getId()] then
		if client:getInventory():giveItem("Päckchen", 5) then
			client:sendSuccess("Du hast 5 Päckchen erhalten!")
			self.m_AdventCalender[client:getId()] = true
		end
	else
		client:sendError("Du hast das Türchen bereits geöffnet!")
	end
end