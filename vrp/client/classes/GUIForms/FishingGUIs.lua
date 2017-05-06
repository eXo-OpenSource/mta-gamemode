-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
FishingTradeGUI = inherit(GUIForm)
inherit(Singleton, FishingTradeGUI)

addRemoteEvents{}

function FishingTradeGUI:constructor()
end

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
			outputChatBox("Dann aber schnell!")
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
