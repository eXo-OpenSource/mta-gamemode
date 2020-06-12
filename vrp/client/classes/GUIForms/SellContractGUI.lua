-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SellContractGUI.lua
-- *  PURPOSE:     Sell Contract GUI class
-- *
-- ****************************************************************************

SellContractGUI = inherit(GUIForm)
inherit(Singleton, SellContractGUI)
addRemoteEvents{"openSellContractGUI", "closeSellContractGUI", "onPurchaseConfirmationReceive"}

function SellContractGUI.openContract(...)
    SellContractGUI:new(...)
end
addEventHandler("openSellContractGUI", root, SellContractGUI.openContract)

function SellContractGUI.closeContract()
    if SellContractGUI:isInstantiated() then
        delete(SellContractGUI:getSingleton())
    end
end
addEventHandler("closeSellContractGUI", root, SellContractGUI.closeContract)

function SellContractGUI:constructor(seller, purchaser, product, productIdLabel, productId, informationLabel, information, price, sellerSignature)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 14)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kaufvertrag", false, true, self)
	
	self.m_Title = GUIGridLabel:new(1, 0, 11, 2, ("Kaufvertrag - %s"):format(product), self.m_Window)
	self.m_Title:setAlignX("center")
    self.m_Title:setHeader()
    
	
	self.m_IdHeaderLabel = GUIGridLabel:new(2, 2, 5, 1, productIdLabel, self.m_Window)
    self.m_IdHeaderLabel:setAlignX("center")
    
	self.m_IdLabel = GUIGridLabel:new(2, 3, 5, 1, productId, self.m_Window)
	self.m_IdLabel:setAlignX("center")
    self.m_IdLabel:setHeader("sub")
    
	
	self.m_DistanceHeaderLabel = GUIGridLabel:new(6, 2, 5, 1, informationLabel, self.m_Window)
	self.m_DistanceHeaderLabel:setAlignX("center")

	self.m_DistanceLabel = GUIGridLabel:new(6, 3, 5, 1, information, self.m_Window)
	self.m_DistanceLabel:setAlignX("center")
    self.m_DistanceLabel:setHeader("sub")
    
	
	self.m_SellerLabel = GUIGridLabel:new(2, 5, 2, 1, "Verkäufer:", self.m_Window)
	self.m_SellerEdit = GUIGridLabel:new(4, 5, 7, 1, "", self.m_Window)
	
	self.m_BuyerLabel = GUIGridLabel:new(2, 6, 2, 1, "Käufer:", self.m_Window)
	self.m_BuyerEdit = GUIGridEdit:new(4, 6, 7, 1, self.m_Window)
	
	self.m_PriceLabel = GUIGridLabel:new(2, 7, 2, 1, "Preis:", self.m_Window)
    self.m_PriceEdit = GUIGridEdit:new(4, 7, 7, 1, self.m_Window)
    self.m_PriceEdit:setNumeric(true, true)
    
	
    self.m_SignSeller = GUIGridSkribble:new(2, 10, 4, 2, self.m_Window)
    
	self.m_SignSellerLabel = GUIGridLabel:new(2, 12, 4, 1, ("%s\n%s"):format(seller and seller:getName() or "Verkäufer", self:getDate()), self.m_Window)
    self.m_SignSellerLabel:setAlignX("center")
    
	
    self.m_SignBuyer = GUIGridSkribble:new(7, 10, 4, 2, self.m_Window)
    
    self.m_SignBuyerLabel = GUIGridLabel:new(7, 12, 4, 1, ("%s\n%s"):format(buyer and buyer:getName() or "Käufer", self:getDate()), self.m_Window)
    self.m_SignBuyerLabel:setAlignX("center")

    self:addSellerDetails(seller, sellerSignature)
    self:addProductDetails(price)

    self.m_ConfirmationBind = bind(self.receivePurchaseConfirmation, self)
    addEventHandler("onPurchaseConfirmationReceive", root, self.m_ConfirmationBind)
end

function SellContractGUI:destructor()
    GUIForm.destructor(self)
    triggerServerEvent("onSellContractTradeAbort", localPlayer, self.m_Seller)
end

function SellContractGUI:getDate()
    local time = getRealTime()
	time.month = time.month+1
	time.year = time.year-100
	for index, value in pairs(time) do
		value = tostring(value)
		if #value == 1 then time[index] = "0"..value end
	end
    return ("%s.%s.%s"):format(time.monthday, time.month, time.year)
end

function SellContractGUI:addSellerDetails(seller, sellerSignature)
    self.m_Seller = seller
    self.m_SellerEdit:setText(seller:getName())
    if sellerSignature then
        delete(self.m_BuyerEdit)
        delete(self.m_PriceEdit)
        self.m_BuyerEdit = GUIGridLabel:new(4, 6, 7, 1, localPlayer:getName(), self.m_Window)
        self.m_PriceEdit = GUIGridLabel:new(4, 7, 7, 1, "", self.m_Window)

        self.m_SignSeller:drawSyncData(sellerSignature, false)

        self.m_SignBuyer:setDrawingEnabled(true)
        self.m_SignBuyerButton = GUIGridButton:new(7, 13, 4, 1, _"Unterschreiben", self.m_Window)
        self.m_SignBuyerButton.onLeftClick = function()
            self.m_SignBuyer:setDrawingEnabled(false)
            self:onPurchaserConfirm(seller)
        end
    else
        self.m_SignSeller:setDrawingEnabled(true)
        self.m_SignSellerButton = GUIGridButton:new(2, 13, 4, 1, _"Unterschreiben", self.m_Window)
        self.m_SignSellerButton.onLeftClick = function()
            self.m_SignSeller:setDrawingEnabled(false)
            self:onSellerConfirm()
        end
    end
end

function SellContractGUI:onSellerConfirm()
    local purchaserName = self.m_BuyerEdit:getText()
    local purchaser = getPlayerFromName(purchaserName)
    local price = tonumber(self.m_PriceEdit:getText())
    if not purchaser then
        ErrorBox:new(_"Kein Spieler unter dem angegebenen Namen gefunden!")
        return
    end
    if Vector3(localPlayer.position-purchaser.position):getLength() > 15 then
        ErrorBox:new(_"Der Spieler ist zu weit weg!")
        return
    end
    if price and price > 0 then
        ErrorBox:new(_"Bitte gib einen Verkaufspreis an!")
        return
    end

    delete(self.m_BuyerEdit)
    delete(self.m_PriceEdit)
    self.m_BuyerEdit = GUIGridLabel:new(4, 6, 7, 1, purchaserName, self.m_Window)
    self.m_PriceEdit = GUIGridLabel:new(4, 7, 7, 1, price, self.m_Window)
    
    delete(self.m_SignSellerButton)
    triggerServerEvent("onReceiveSellContractSignature", localPlayer, localPlayer, "seller", self.m_SignSeller:getSyncData(), purchaser, price)
end

function SellContractGUI:onPurchaserConfirm(seller)
    delete(self.m_SignBuyerButton)
    triggerServerEvent("onReceiveSellContractSignature", localPlayer, seller, "purchaser", self.m_SignBuyer:getSyncData())
end

function SellContractGUI:addProductDetails(price)
    if price then
        self.m_PriceEdit:setText(price)
    end
end

function SellContractGUI:receivePurchaseConfirmation(purchaserSignature)
    self.m_SignBuyer:drawSyncData(purchaserSignature, false)
end