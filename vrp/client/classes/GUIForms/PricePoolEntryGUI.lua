-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PricePoolEntryGUI.lua
-- *  PURPOSE:     PricePool Entry GUI class
-- *
-- ****************************************************************************

PricePoolEntryGUI = inherit(GUIForm)
inherit(Singleton, PricePoolEntryGUI)
addRemoteEvents{"openPricePoolEntryWindow", "updatePricePoolEntryWindow", "openPricePoolRaffleWindow"}

function PricePoolEntryGUI:constructor(pricepoolId, entryTable, price, pricelist, raffledate, active)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 12)

	self.m_PricePoolId = pricepoolId

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Der Preispool", true, true, self)
	
	self.m_HeaderLabel = GUIGridLabel:new(1, 1, 9, 1, _"Der Preispool", self.m_Window):setHeader():setAlignX("center")
	
	self.m_TextLabel = GUIGridLabel:new(1, 2, 9, 5, _"Der Preispool funktioniert wie folgt: Jeder Spieler erhält die Möglichkeit Lose zu erwerben, um an der Verlosung teilzunehmen. Je mehr Lose ein Spieler erwirbt, desto größer wird seine Chance auf den Gewinn. Zum Zeitpunkt der Verlosung können sich alle Spieler hier einfinden und gemeinsam mitfiebern.", self.m_Window)
	
	self.m_BuyHeaderLabel = GUIGridLabel:new(1, 7, 9, 1, "Mitspielen?", self.m_Window):setHeader():setAlignX("center")
	self.m_PriceLabel = GUIGridLabel:new(1, 8, 9, 1, _("Aktueller Preis pro Los: 1 %s", price), self.m_Window):setHeader("sub"):setAlignX("center")
	self.m_DateLabel = GUIGridLabel:new(1, 9, 9, 1, _("Verlosung: %s Uhr", raffledate), self.m_Window):setHeader("sub"):setAlignX("center")
	
	self.m_AmountEditBox = GUIGridEdit:new(3, 10, 2, 1, self.m_Window):setCaption(_"Anzahl"):setNumeric(true, true)
	self.m_BuyLabel = GUIGridLabel:new(5, 10, 4, 1, _"Los(e) erwerben", self.m_Window):setHeader("sub")
	
	self.m_BuyButton = GUIGridButton:new(3, 11, 5, 1, _"Mitspielen!", self.m_Window)
	self.m_BuyButton.onLeftClick = function()
		if tonumber(self.m_AmountEditBox:getText()) > 0 then
			triggerServerEvent("buyPricePoolEntries", localPlayer, pricepoolId, tonumber(self.m_AmountEditBox:getText()))
			self.m_AmountEditBox:setText("")
			self.m_BuyButton:setEnabled(false)
			setTimer(function() self.m_BuyButton:setEnabled(true) end, 2000, 1)
		end
	end
	if active == false then
		self.m_BuyButton:setEnabled(false)
	end

    self.m_PriceButton = GUIGridButton:new(10, 11, 6, 1, _"Preisliste anzeigen", self.m_Window)
    self.m_PriceButton.onLeftClick = function() if PricePoolPriceGUI:isInstantiated() then delete(PricePoolPriceGUI:getSingleton()) else PricePoolPriceGUI:new(pricelist) end end
	
	self.m_GridList = GUIGridGridList:new(10, 1, 6, 10, self.m_Window)
	self.m_GridList:addColumn(_"Lose (Insg.)", 0.65)
	self.m_GridList:addColumn(_"0", 0.35)
	self.m_GridList:setSortable{"0"}
	self.m_GridList:setSortColumn("0", "down")

	local entryAmount = 0
	for name, entries in pairs(entryTable) do
		self.m_GridList:addItem(name, entries)
		entryAmount = entryAmount + entries
	end
	self.m_GridList:setColumnText(2, entryAmount)
end

function PricePoolEntryGUI:destructor()
    GUIForm.destructor(self)
    if PricePoolPriceGUI:isInstantiated() then
        delete(PricePoolPriceGUI:getSingleton())
    end
end

addEventHandler("openPricePoolEntryWindow", root, 
	function(...)
		PricePoolEntryGUI:new(...)
	end
)

addEventHandler("updatePricePoolEntryWindow", root, 
	function(pricepoolId, entryTable)
		if PricePoolEntryGUI:isInstantiated() then
			if PricePoolEntryGUI:getSingleton().m_PricePoolId == pricepoolId then
				PricePoolEntryGUI:getSingleton().m_GridList:clear()
				local entryAmount = 0
				for name, entries in pairs(entryTable) do
					PricePoolEntryGUI:getSingleton().m_GridList:addItem(name, entries)
					entryAmount = entryAmount + entries
				end
				PricePoolEntryGUI:getSingleton().m_GridList:setColumnText(2, entryAmount)
			end
		end
	end
)

addEventHandler("openPricePoolRaffleWindow", root,
	function(pricepoolId, players, winner, price)
		if PricePoolEntryGUI:isInstantiated() then
			if PricePoolEntryGUI:getSingleton().m_PricePoolId == pricepoolId then
				PricePoolEntryGUI:getSingleton().m_BuyButton:setEnabled(false)

				if PricePoolRaffleGUI:isInstantiated() then
					delete(PricePoolRaffleGUI:getSingleton())
				end
				PricePoolRaffleGUI:new(players, winner, price)
				PricePoolRaffleGUI:getSingleton():startRoll()
			end
		end
	end
)