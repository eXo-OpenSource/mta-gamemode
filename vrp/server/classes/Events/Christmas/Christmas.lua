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
		["Packages"] = 35, --75
		["CandyCane"] = 50, --50
		["Type"] = "Special"
	},
	{
		["Text"] = "Weihnachts-Skin",
		["Image"] = "Bonus_ChristmasSkin.png",
		["Packages"] = 60, --120
		["CandyCane"] = 75, --150
		["Type"] = "Skin",
		["SkinId"] = 244
	},
	{
		["Text"] = "Lebkuchen-Maske",
		["Image"] = "Bonus_GingerbreadMask.png",
		["Packages"] = 75, --150
		["CandyCane"] = 90, --180
		["Type"] = "Special",
	},
	{
		["Text"] = "30 Tage VIP",
		["Image"] = "Bonus_VIP.png",
		["Packages"] = 100, --175
		["CandyCane"] = 125, --200
		["Type"] = "Special"
	},
	{
		["Text"] = "Mr. Whoopee",
		["Image"] = "Bonus_Whoopee.png",
		["Packages"] = 275, --550
		["CandyCane"] = 425, --850
		["Type"] = "Vehicle",
		["VehicleModel"] = 423
	},
	{
		["Text"] = "Nebula",
		["Image"] = "Bonus_Nebula.png",
		["Packages"] = 350, --700
		["CandyCane"] = 800, --1600
		["Type"] = "Vehicle",
		["VehicleModel"] = 516
	}
}


local day = getRealTime().monthday
local month = getRealTime().month+1

if month == 12 and day >= 5 and day <= 11 then
    Christmas.ms_PricePoolName = "Christmas2022-1"
    Christmas.ms_PricePoolEnd = 1670778000
    Christmas.ms_PricePoolPrices = {
        {"money", 150000},
        {"vehicle", 463 },
         
        {"money", 150000}, 
        {"vehicle", 422}, 

        {"money", 150000}, 
        {"VIP", 1}
    }
elseif month == 12 and day >= 12 and day <= 18 then
    Christmas.ms_PricePoolName = "Christmas2022-2"
    Christmas.ms_PricePoolEnd = 1671382800
    Christmas.ms_PricePoolPrices = {
        {"money", 150000}, 
        {"vehicle", 459}, 
        
        {"money", 150000}, 
        {"vehicle", 480}, 
        
        {"money", 150000}, 
        {"VIP", 1}
    }
elseif month == 12 and day >= 19 and day <= 25 then
    Christmas.ms_PricePoolName = "Christmas2022-3"
    Christmas.ms_PricePoolEnd = 1671987600
    Christmas.ms_PricePoolPrices = {
        {"money", 150000}, 
        {"vehicle", 521},
        
        {"money", 150000},
        {"vehicle", 587}, 
        
        {"money", 150000},
        {"VIP", 1}
    }
elseif (month == 12 and day >= 26) or (month == 1 and day <= 1) then
    Christmas.ms_PricePoolName = "Christmas2022-4"
    Christmas.ms_PricePoolEnd = 1672592400
    Christmas.ms_PricePoolPrices = {
        {"money", 150000}, 
        {"vehicle", 434}, 
        
        {"money", 150000}, 
        {"vehicle", 534},

        {"money", 150000}, 
        {"VIP", 1}
    }
end

function Christmas:constructor()
	self.m_QuestManager = QuestManager:new()
	self.m_AdventCalender = {}

	self.m_BankServerAccount = BankServer.get("event.christmas")

	if EVENT_CHRISTMAS_MARKET then
		WheelOfFortune:new(Vector3(1479.24, -1671.78, 14.55), 0) -- in front of tree
		WheelOfFortune:new(Vector3(1484.21, -1665.72, 14.55), 90) -- right side of tree
		WheelOfFortune:new(Vector3(1474.46, -1665.92, 14.55), 270) -- left side of tree
		--other wheels on side of market
		WheelOfFortune:new(Vector3(1455.52, -1662.81, 14.16), 80)
		WheelOfFortune:new(Vector3(1454.12, -1669.74, 14.17), 70)
		WheelOfFortune:new(Vector3(1455.73, -1654.92, 14.16), 95)
		WheelOfFortune:new(Vector3(1504.01, -1658.57, 14.12), 260)
		WheelOfFortune:new(Vector3(1506.11, -1651.70, 14.11), 245)
		WheelOfFortune:new(Vector3(1509.73, -1645.62, 14.11), 230)

		FerrisWheelManager:getSingleton():addWheel(Vector3(1496.9004, -1697.5, 26.6), 90)
	end

	local tree = createObject(2077, 1479.6392, -1666.17, 12.0589, 0, 0, 0)
	local treeLOD = createObject(2077, 1479.6392, -1666.17, 12.0589, 0, 0, 0, true)
	setLowLODElement(tree, treeLOD)

	createObject(3861, 1456.84, -1748.18, 13.72, 0, 0, 170) --QuestShop (before market opens) BonusShop (after Event)
	createObject(3861, 1453.17, -1744.94, 13.72, 0, 0, 115) --Firework Shop

	addRemoteEvents{"eventRequestBonusData", "eventBuyBonus", "Christmas:openDoor"}
	addEventHandler("eventRequestBonusData", root, bind(self.Event_requestBonusData, self))
	addEventHandler("eventBuyBonus", root, bind(self.Event_buyBonus, self))
	addEventHandler("Christmas:openDoor", root, bind(self.openDoor, self))

	if Christmas.ms_PricePoolName then
		self.m_PricePool = PricePoolManager:getSingleton():getPricePool(Christmas.ms_PricePoolName, "Päckchen", Christmas.ms_PricePoolPrices, Christmas.ms_PricePoolEnd)
		if self.m_PricePool then
			PricePoolManager:getSingleton():createPed(self.m_PricePool, 185, Vector3(1476.20, -1670.43, 14.55), 190.62)
		end
	end

	ChristmasEasterEggs:new()
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
		elseif bonus["Text"] == "Lebkuchen-Maske" then
			client:getInventory():giveItem("Lebkuchen-Maske", 1)
			client:sendShortMessage("Die Maske wurde in dein Inventar gelegt!")
		end
	end

	client:getInventory():removeItem("Zuckerstange", bonus["CandyCane"])
	client:getInventory():removeItem("Päckchen", bonus["Packages"])
	client:sendSuccess(_("Du hast erfolgreich den Bonus %s für %d Päckchen und %d Zuckerstange/n gekauft!", client, bonus["Text"], bonus["Packages"], bonus["CandyCane"]))
	StatisticsLogger:getSingleton():addEventShopLog(client, bonus["Text"], bonus["Packages"], bonus["CandyCane"])

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