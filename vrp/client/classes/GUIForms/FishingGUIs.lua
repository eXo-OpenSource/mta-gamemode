-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
FishingTradeGUI = inherit(GUIForm)
inherit(Singleton, FishingTradeGUI)

addRemoteEvents{"openFishTradeGUI"}

function FishingTradeGUI:constructor(CoolingBags, Fishes)
	GUIForm.constructor(self, screenWidth/2-600/2, screenHeight/2-400/2, 600, 400)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fischhandel mit Angler Lutz", true, true, self)

	self.m_FishTable = Fishes

	self.m_GridList = GUIGridList:new(5, 35, 250, self.m_Height - 75, self.m_Window)
	self.m_GridList:addColumn(_"Fisch", 0.6)
	self.m_GridList:addColumn(_"Größe (cm)", 0.4)

	self.m_AddAll = GUIButton:new(5, self.m_Height - 35, 250, 25, _"Alle hinzufügen", self.m_Window)
	self.m_AddAll.onLeftClick = bind(FishingTradeGUI.addAllFish, self)
	self.m_AddFish = GUIButton:new(260, 35, 25, self.m_Height - 75, FontAwesomeSymbols.Right, self.m_Window):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false):setBackgroundColor(Color.Accent)
	self.m_AddFish.onLeftClick = bind(FishingTradeGUI.addFish, self)

	GUILabel:new(300, 35, 200, 20, _"Fisch:", self.m_Window)
	GUILabel:new(300, 50, 200, 20, _"Qualität:", self.m_Window)
	GUILabel:new(300, 65, 200, 20, _"Normal Preis:", self.m_Window)
	GUILabel:new(300, 90, 200, 20, _"Qualität Bonus:", self.m_Window)
	GUILabel:new(300, 105, 200, 20, _"Level Bonus:", self.m_Window)
	GUILabel:new(300, 120, 200, 20, _"Seltenheits Bonus:", self.m_Window)
	self.m_FishNameLabel = GUILabel:new(450, 35, 200, 20, "", self.m_Window)
	self.m_QualityLabel = GUILabel:new(450, 50, 200, 20, "", self.m_Window):setFont(FontAwesome(20)):setFontSize(1):setColor(Color.Yellow)
	self.m_PriceLabel = GUILabel:new(450, 65, 200, 20, "", self.m_Window)
	self.m_QualityBonusLabel = GUILabel:new(450, 90, 200, 20, "", self.m_Window)
	self.m_LevelBonusLabel = GUILabel:new(450, 105, 200, 20, "", self.m_Window)
	self.m_RareBonusLabel = GUILabel:new(450, 120, 200, 20, "", self.m_Window)

	self.m_SellList = GUIGridList:new(300, 145, 295, 180, self.m_Window)
	self.m_SellList:addColumn(_"Fisch", 0.6)
	self.m_SellList:addColumn(_"Größe (cm)", 0.4)

	GUILabel:new(300, 330, 200, 25, _"Gesamte Vergütung:", self.m_Window)
	self.m_TotalPaymentLabel = GUILabel:new(450, 330, 200, 25, "0$", self.m_Window)

	self.m_Sell = GUIButton:new(300, self.m_Height - 35, 295, 25, _"Verkaufen!", self.m_Window):setBackgroundColor(Color.Red)
	self.m_Sell.onLeftClick = bind(FishingTradeGUI.requestTrade, self)

	local fisherLevel = localPlayer:getPrivateSync("FishingLevel")

	for _, bag in pairs(CoolingBags) do
		self.m_GridList:addItemNoClick(bag.name)

		table.sort(bag.content, function(a, b) return a.size > b.size end)

		for _, fish in pairs(bag.content) do
			local item = self.m_GridList:addItem(fish.fishName, fish.size)
			item.fishId = fish.Id
			item.fishName = fish.fishName
			item.fishSize = fish.size
			item.fishQuality = fish.quality

			item.onLeftClick =
				function()
					self.m_FishNameLabel:setText(fish.fishName)
					self.m_QualityLabel:setText((FontAwesomeSymbols.Star):rep(fish.quality + 1)):setColor(fish.quality == 0 and Color.Brown or (fish.quality == 1 and Color.LightGrey or (fish.quality == 2 and Color.Yellow or Color.Purple)))
					self.m_PriceLabel:setText(("%s$"):format(Fishes[fish.Id].DefaultPrice))
					self.m_QualityBonusLabel:setText(fish.quality == 3 and "100%" or (fish.quality == 2 and "50%" or (fish.quality == 1 and "25%" or "-")))
					self.m_LevelBonusLabel:setText(fisherLevel >= 10 and "50%" or (fisherLevel >= 5 and "25%" or "-"))
					self.m_RareBonusLabel:setText(("%d%%"):format(Fishes[fish.Id].RareBonus*100))
				end
		end
	end
end

function FishingTradeGUI:addFish()
	local item = self.m_GridList:getSelectedItem()
	if item then
		self.m_GridList:removeItemByItem(item)
		local sellItem = self.m_SellList:addItem(item.fishName, item.fishSize)
		sellItem.fishId = item.fishId
		sellItem.fishName = item.fishName
		sellItem.fishSize = item.fishSize
		sellItem.fishQuality = item.fishQuality

		self:updateTotalPrice()
		self:resetLabels()
	end
end

function FishingTradeGUI:addAllFish()
	for _, item in pairs(self.m_GridList:getItems()) do
		if item and item.onLeftClick then
			local sellItem = self.m_SellList:addItem(item.fishName, item.fishSize)
			sellItem.fishId = item.fishId
			sellItem.fishName = item.fishName
			sellItem.fishSize = item.fishSize
			sellItem.fishQuality = item.fishQuality
		end
	end

	self.m_GridList:clear()
	self:updateTotalPrice()
	self:resetLabels()
end

function FishingTradeGUI:updateTotalPrice()
	local fishingLevel = localPlayer:getPrivateSync("FishingLevel")
	local fishingLevelMultiplicator = fishingLevel >= 10 and 1.5 or (fishingLevel >= 5 and 1.25 or 1)
	local totalPrice = 0

	for _, item in pairs(self.m_SellList:getItems()) do
		if item.fishId then
			local default = self.m_FishTable[item.fishId].DefaultPrice
			local qualityMultiplicator = item.fishQuality == 3 and 2 or (item.fishQuality == 2 and 1.5 or (item.fishQuality == 1 and 1.25 or 1))
			local rareBonusMultiplicator = self.m_FishTable[item.fishId].RareBonus + 1

			totalPrice = totalPrice + default*fishingLevelMultiplicator*qualityMultiplicator*rareBonusMultiplicator
		end
	end

	self.m_TotalPaymentLabel:setText(math.floor(totalPrice))
end

function FishingTradeGUI:requestTrade()
	if #self.m_SellList:getItems() > 0 then
		triggerServerEvent("clientSendFishTrading", localPlayer, self.m_SellList:getItems())
		self.m_SellList:clear()
	else
		WarningBox:new("Du musst zu erst Fische zum verkaufen hinzufügen!")
	end
end

function FishingTradeGUI:resetLabels()
	self.m_FishNameLabel:setText("")
	self.m_QualityLabel:setText("")
	self.m_PriceLabel:setText("")
	self.m_QualityBonusLabel:setText("")
	self.m_LevelBonusLabel:setText("")
	self.m_RareBonusLabel:setText("")
end

addEventHandler("openFishTradeGUI", root,
	function(...)
		FishingTradeGUI:new(...)
	end
)

----------------------------------------------------------------------------------------------------------------------
FishPricingGUI = inherit(GUIForm)
inherit(Singleton, FishPricingGUI)

addRemoteEvents{"openFishPricingGUI"}

function FishPricingGUI:constructor(Fishes, speciesCaught)
	GUIForm.constructor(self, screenWidth/2-580/2, screenHeight/2-400/2, 580, 400)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Preistabelle", true, true, self)

	GUILabel:new(10, 30, self.m_Width - 20, 30, "Immer auf dem neusten Stand.. Seltene Fische geben einen Bonus!", self.m_Window)

	self.m_PriceList = GUIGridList:new(10, 60, self.m_Width-20, self.m_Height-70, self.m_Window)
	self.m_PriceList:addColumn(_"Fisch", .4)
	self.m_PriceList:addColumn(_"Preis", .3)
	self.m_PriceList:addColumn(_"Bonus", .3)

	table.sort(Fishes, function(a, b) return a.RareBonus > b.RareBonus end)
	for _, fish in ipairs(Fishes) do
		if speciesCaught[fish.Id] then
			local item = self.m_PriceList:addItem(fish.Name_DE, ("%s$"):format(fish.DefaultPrice), ("%s%d%%"):format(fish.RareBonus > 0 and "+" or "", fish.RareBonus*100))
			item:setColumnColor(3, tocolor(255*(1-fish.RareBonus), 255, 255*(1-fish.RareBonus)))
		else
			self.m_PriceList:addItem("???", "-", "-")
		end
	end
end

addEventHandler("openFishPricingGUI", root,
	function(...)
		FishPricingGUI:new(...)
	end
)

----------------------------------------------------------------------------------------------------------------------
FisherStatisticsGUI = inherit(GUIForm)
inherit(Singleton, FisherStatisticsGUI)

addRemoteEvents{"openFisherStatisticsGUI"}

function FisherStatisticsGUI:constructor(Statistics)
	GUIForm.constructor(self, screenWidth/2-580/2, screenHeight/2-400/2, 580, 400)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Fischer Statistiken", true, true, self)

	GUILabel:new(10, 30, self.m_Width - 20, 30, "Ich update mich stündlich!", self.m_Window)

	self.m_Statistics = GUIGridList:new(10, 60, self.m_Width-20, self.m_Height-70, self.m_Window)
	self.m_Statistics:addColumn(_"Spieler", .6)
	self.m_Statistics:addColumn(_"Gefangene Fische", .4)

	for _, data in ipairs(Statistics) do
		self.m_Statistics:addItem(data.Name, data.FishCaught)
	end
end

addEventHandler("openFisherStatisticsGUI", root,
	function(...)
		FisherStatisticsGUI:new(...)
	end
)
----------------------------------------------------------------------------------------------------------------------
FishingInformationGUI = inherit(GUIForm)
inherit(Singleton, FishingInformationGUI)

function FishingInformationGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-580/2, screenHeight/2-400/2, 580, 400)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Informationen zum Angeln", true, true, self)

	GUILabel:new(10, 35, self.m_Width - 20, 24,
		[[Hallo du!
		Wenn du möchtest erkläre ich dir in mehreren Schritten wie du Angeln kannst.

		1) Verhalten der Fische (1:30 Minuten)


		2) Fangen der Fische (1:30 Minuten)
		]]
		--3) Handeln mit Fische (todo)
		, self.m_Window)

	local cutscene1 = GUIButton:new(10, 140, 150, 25, "Anschauen!", self.m_Window):setBackgroundColor(Color.Red)
	local cutscene2 = GUIButton:new(10, 220, 150, 25, "Anschauen!", self.m_Window):setBackgroundColor(Color.Red)
	local cutscene3 = GUIButton:new(10, 300, 150, 25, "Anschauen!", self.m_Window):setBackgroundColor(Color.Red):hide()

	cutscene1.onLeftClick =
		function()
			self:delete()

			CutscenePlayer:getSingleton():playCutscene("FishingBehavior",
				function()
					fadeCamera(true)
					nextframe(setCameraTarget, localPlayer)
				end, 0)
		end

	cutscene2.onLeftClick =
		function()
			self:delete()
			CutscenePlayer:getSingleton():playCutscene("FishingCatch",
				function()
					fadeCamera(true)
					nextframe(setCameraTarget, localPlayer)
				end, 0)
		end

	cutscene3.onLeftClick =
		function()
			self:delete()
		end
end

----------------------------------------------------------------------------------------------------------------------
FishingPedGUI = inherit(GUIButtonMenu)
inherit(Singleton, FishingPedGUI)

function FishingPedGUI:constructor()
	GUIButtonMenu.constructor(self, "Angler Lutz")
	self:addItem(_"Preistabelle ansehen", Color.Accent,
		function()
			triggerServerEvent("clientRequestFishPricing", localPlayer)
			self:delete()
		end
	)
	self:addItem(_"Fische verkaufen", Color.Accent,
		function()
			triggerServerEvent("clientRequestFishTrading", localPlayer)
			self:delete()
		end
	)
	self:addItem(_"Statistiken", Color.Accent,
		function()
			triggerServerEvent("clientRequestFishStatistics", localPlayer)
			self:delete()
		end
	)
	self:addItem(_"Mehr informationen", Color.Accent,
		function()
			FishingInformationGUI:new()
			self:delete()
		end
	)
end

----------------------------------------------------------------------------------------------------------------------
FishingRodGUI = inherit(GUIForm)
inherit(Singleton, FishingRodGUI)

addRemoteEvents{"showFishingRodGUI"}

function FishingRodGUI:constructor(fishingRodName, equipments)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 3)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Width/2, 300, 150)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, fishingRodName, true, true, self)
	local infoLabel = GUIGridLabel:new(1, 3, 8, 1, "", window):setFont(VRPFont(22)):setFontSize(1):setAlign("center", "center")

	for i, equipment in ipairs(equipments) do
		local slot = GUIGridRectangle:new((i-1)*2+1, 1, 2, 2, Inventory.Color.ItemBackground, window)

		if equipment then
			local itemIcon = Inventory:getSingleton():getItemData()[equipment].Icon
			local itemAmount = Inventory:getSingleton():getItemAmount(equipment)
			local amountText = itemAmount > 1 and itemAmount or ""
			local textWidth = VRPTextWidth(amountText, 22) + 10

			GUIImage:new(5, 5, slot.m_Width - 10, slot.m_Height - 10, "files/images/Inventory/items/" .. itemIcon, slot)

			if itemAmount > 1 then
				GUIRectangle:new(slot.m_Width - textWidth, slot.m_Height-15, textWidth, 15, Color.Background, slot)
				GUILabel:new(0, slot.m_Height - 15, slot.m_Width - 5, 15, amountText, slot):setAlign("right", "center"):setFont(VRPFont(22)):setFontSize(1):setColor(Color.Orange)
			end

			slot.onHover =
				function()
					slot:setColor(Inventory.Color.ItemBackgroundHover)
					infoLabel:setText(equipment)
				end

			slot.onUnhover =
				function()
					slot:setColor(Inventory.Color.ItemBackground)
					infoLabel:setText("")
				end

			slot.onLeftClick =
				function()
					triggerServerEvent("clientRemoveFishingRodEquipment", localPlayer, fishingRodName, equipment)
					self:delete()
				end
		end
	end


end

addEventHandler("showFishingRodGUI", root,
	function(...)
		if not FishingRodGUI:isInstantiated() then
			FishingRodGUI:new(...)
		end
	end
)

----------------------------------------------------------------------------------------------------------------------
EquipmentSelectionGUI = inherit(GUIForm)
inherit(Singleton, EquipmentSelectionGUI)

addRemoteEvents{"showEquipmentSelectionGUI"}

function EquipmentSelectionGUI:constructor(fishingRods, equipmentName, equipmentAmount)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 2 + #fishingRods)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("%s (%s)", equipmentName, equipmentAmount), true, true, self)
	self.m_Combobox = GUIGridCombobox:new(1, 1, 6, 1, "Angelrute auswählen", window)

	for _, fishingRod in pairs(fishingRods) do
		local item = self.m_Combobox:addItem(fishingRod)
		item.fishingRodName = fishingRod
	end

	local button = GUIGridButton:new(7, 1, 3, 1, "Hinzufügen", window)
	button.onLeftClick =
		function()
			if not self.m_Combobox:getSelectedItem() then return end
			local selectedFishingRod = self.m_Combobox:getSelectedItem().fishingRodName
			if selectedFishingRod then
				triggerServerEvent("clientAddFishingRodEquipment", localPlayer, selectedFishingRod, equipmentName)
				self:delete()
			end
		end
end

addEventHandler("showEquipmentSelectionGUI", root,
	function(...)
		if not EquipmentSelectionGUI:isInstantiated() then
			EquipmentSelectionGUI:new(...)
		end
	end
)

----------------------------------------------------------------------------------------------------------------------
FishEncyclopedia = inherit(GUIForm)
inherit(Singleton, FishEncyclopedia)

addRemoteEvents{"receiveCaughtFishSpecies"}

function FishEncyclopedia:constructor(fishList, fishSpecies)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 19)
	self.m_Height = grid("y", 19)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Fischlexikon", true, true, self)

	local row = 0
	for i, fish in ipairs(fishList) do
		local i = i - 9*row

		local background = GUIGridRectangle:new(1 + 2*(i-1), row*2 + 1, 2, 2, Color.LightGrey, window)

		if fishSpecies[fish.Id] then
			background.onLeftClick =
			function()
				self:hide()
				FishSpeciesGUI:new(fish, fishSpecies)
			end

			local path = ("files/images/Fishing/Fish/%s.png"):format(fish.Id)
			local isImage = fileExists(path)
			GUIImage:new(5, 5, background.m_Width - 5, background.m_Height - 5, isImage and path or "files/images/Fishing/Fish.png", background)
			GUIRectangle:new(0, background.m_Height - 15, background.m_Width, 15, Color.Background, background)
			GUILabel:new(0, background.m_Height - 15, background.m_Width, 15, fish.Name_DE:len() > 9 and ("%s.."):format(fish.Name_DE:sub(0, 9)) or fish.Name_DE, background):setAlign("center", "center"):setFontSize(1):setFont(VRPFont(20)):setTooltip(fish.Name_DE, "bottom")
		else
			GUILabel:new(0, 0, background.m_Width, background.m_Height, "?", background):setAlign("center", "center"):setFontSize(1):setFont(VRPFont(70, false, true))
		end

		if i%9 == 0 then row = row + 1 end
	end
end

addEventHandler("receiveCaughtFishSpecies", root,
	function(...)
		if FishEncyclopedia:isInstantiated() then
			delete(FishEncyclopedia:getSingleton())
		end

		FishEncyclopedia:new(...)
	end
)

----------------------------------------------------------------------------------------------------------------------
FishSpeciesGUI = inherit(GUIForm)
inherit(Singleton, FishSpeciesGUI)

function FishSpeciesGUI:constructor(fish, speciesData)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, fish.Name_DE, true, true, self)

	window:addBackButton(
		function()
			delete(self)
			FishEncyclopedia:getSingleton():show()
		end
	)

	local path = ("files/images/Fishing/Fish/%s.png"):format(fish.Id)
	local isImage = fileExists(path)
	GUIGridImage:new(3, 1, 3, 3, isImage and path or "files/images/Fishing/Fish.png", window)
	GUIGridLabel:new(1, 5, 5, 1, "Fischname:\nZuletzt gefangen:\nRekord Größe:\nOrte:\nUhrzeiten:\nWetter:\nJahreszeiten:", window)
end
