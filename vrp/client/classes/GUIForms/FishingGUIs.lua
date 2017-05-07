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

	self.m_GridList = GUIGridList:new(5, 35, 250, self.m_Height - 75, self.m_Window)
	self.m_GridList:addColumn(_"Fisch", 0.6)
	self.m_GridList:addColumn(_"Größe (cm)", 0.4)

	self.m_AddAll = GUIButton:new(5, self.m_Height - 35, 250, 25, _"Alle hinzufügen", self.m_Window)
	self.m_AddAll.onLeftClick = bind(FishingTradeGUI.addAllFish, self)
	self.m_AddFish = GUIButton:new(260, 35, 25, self.m_Height - 75, ">>", self.m_Window):setFontSize(1)
	self.m_AddFish.onLeftClick = bind(FishingTradeGUI.addFish, self)

	GUILabel:new(300, 35, 200, 20, _"Fisch:", self.m_Window)
	GUILabel:new(300, 50, 200, 20, _"Qualität:", self.m_Window)
	GUILabel:new(300, 65, 200, 20, _"Normal Preis:", self.m_Window)
	GUILabel:new(300, 90, 200, 20, _"Qualität Bonus:", self.m_Window)
	GUILabel:new(300, 105, 200, 20, _"Level Bonus:", self.m_Window)
	GUILabel:new(300, 120, 200, 20, _"Seltenheits Bonus:", self.m_Window)
	self.m_FishNameLabel = GUILabel:new(450, 35, 200, 20, "", self.m_Window)
	self.m_QualityLabel = GUILabel:new(450, 50, 200, 20, "", self.m_Window)
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
					self.m_QualityLabel:setText(fish.Quality or "-")
					self.m_PriceLabel:setText(("%s$"):format(Fishes[fish.Id].DefaultPrice))
					self.m_QualityBonusLabel:setText(fish.quality == 2 and "50%" or (fish.quality == 1 and "25%" or "-"))
					self.m_LevelBonusLabel:setText("-")
					self.m_RareBonusLabel:setText(("%d%%"):format(Fishes[fish.Id].PriceBonus*100))
				end
		end
	end
end

function FishingTradeGUI:addFish()
	local item = self.m_GridList:getSelectedItem()
	if item then
		self.m_GridList:removeItemByItem(item)
		local sellItem = self.m_SellList:addItem(item.fishName, item.fishSize)
		sellItem.fishId = item.Id
		sellItem.fishName = item.fishName
		sellItem.fishSize = item.size
	end
end

function FishingTradeGUI:addAllFish()
	for _, item in pairs(self.m_GridList:getItems()) do
		if item and item.onLeftClick then
			local sellItem = self.m_SellList:addItem(item.fishName, item.fishSize)
			sellItem.fishId = item.Id
			sellItem.fishName = item.fishName
			sellItem.fishSize = item.size
		end
	end

	self.m_GridList:clear()
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

function FishPricingGUI:constructor(Fishes)
	GUIForm.constructor(self, screenWidth/2-580/2, screenHeight/2-400/2, 580, 400)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Fisch Preis Tabelle", true, true, self)

	GUILabel:new(10, 30, self.m_Width - 20, 30, "Immer auf dem neusten Stand.. Seltene Fische geben einen Bonus!", self.m_Window)

	self.m_PriceList = GUIGridList:new(10, 60, self.m_Width-20, self.m_Height-70, self.m_Window)
	self.m_PriceList:addColumn(_"Fisch", .4)
	self.m_PriceList:addColumn(_"Preis", .3)
	self.m_PriceList:addColumn(_"Bonus", .3)

	table.sort(Fishes, function(a, b) return a.PriceBonus > b.PriceBonus end)
	for _, fish in ipairs(Fishes) do
		local item = self.m_PriceList:addItem(fish.Name_EN, ("%s$"):format(fish.DefaultPrice), ("%s%d%%"):format(fish.PriceBonus > 0 and "+" or "", fish.PriceBonus*100))
		item:setColumnColor(3, tocolor(255*(1-fish.PriceBonus), 255*fish.PriceBonus, 0))
	end
end

addEventHandler("openFishPricingGUI", root,
	function(...)
		FishPricingGUI:new(...)
	end
)

----------------------------------------------------------------------------------------------------------------------
FishingInformationGUI = inherit(GUIForm)
inherit(Singleton, FishingInformationGUI)

function FishingInformationGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-580/2, screenHeight/2-400/2, 580, 400)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Informationen zum Angeln", true, true, self)

	GUILabel:new(10, 35, self.m_Width - 20, 24,
		[[Hallo werter Angel Freund,
		ich bin Angler Lutz und werde dir nun einige Grundlagen zum Angeln erklären!

		Bevor du loslegen kannst, benötigst du logischerweiße eine Angel und etwas, wo du deinen Fang aufbewahren kannst. Das bekommst du alles im Angelshop, der hier ganz in der Nähe ist.
		Abhängig von deinen Fähigkeiten, kannst du größere Kühltaschen kaufen, um mehr Fische lagern zu können. Bedenke aber das deine Fische verderben können!

		Das Handeln kann manchmal Glücksache sein. Grundsätzlich sind seltene Fische mehr Wert. Ich bekomme im Stundentakt neue Informationen rein. Es lohnt sich also erst mal ein Blick in die Preistabelle zu werfen. Vor allem wenn du weißt, welche Fische man wo und wann fangen kann.]]
		, self.m_Window)

	local startTour = GUIButton:new(self.m_Width - 155, self.m_Height - 30, 150, 25, "Tour starten!", self.m_Window):setBackgroundColor(Color.Red)
	startTour.onLeftClick =
		function()
			outputChatBox("TODO")
			self:delete()
		end
end

----------------------------------------------------------------------------------------------------------------------
FishingPedGUI = inherit(GUIButtonMenu)
inherit(Singleton, FishingPedGUI)

function FishingPedGUI:constructor()
	GUIButtonMenu.constructor(self, "Angler Lutz")
	self:addItem(_"Preistabelle ansehen", Color.LightBlue,
		function()
			triggerServerEvent("clientRequestFishPricing", localPlayer)
			self:delete()
		end
	)
	self:addItem(_"Fische verkaufen", Color.LightBlue,
		function()
			triggerServerEvent("clientRequestFishTrading", localPlayer)
			self:delete()
		end
	)
	self:addItem(_"Mehr informationen", Color.LightBlue,
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

function FishingRodGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-150, screenHeight/2-75, 300, 150)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Angelrute", true, true, self)

	--todo
	-- FishingRod condition (if added)
	-- Add baits?!
end

addEventHandler("showFishingRodGUI", root,
	function(...)
		if not FishingRodGUI:isInstantiated() then
			FishingRodGUI:new(...)
		end
	end
)
