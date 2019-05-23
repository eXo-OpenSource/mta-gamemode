-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppEPT.lua
-- *  PURPOSE:     EPT App class
-- *
-- ****************************************************************************
AppMarketPlace = inherit(PhoneApp)

function AppMarketPlace:constructor()
	addRemoteEvents{"onAppGetServercall"}
	PhoneApp.constructor(self, "Marktplatz", "IconEPT.png")
	addEventHandler("onAppGetServercall", localPlayer, bind(self.Event_onServerResponse, self))
end

function AppMarketPlace:showMarkets(markets)
	self:clear()
	self.m_Page = 1
	local elements = {}
	elements.header = GUILabel:new(10, 10, self.m_Form.m_Width-20, 50, _"Märkte", self.m_Tabs.m_Browser)
	elements.list = GUIGridList:new(10, 60, self.m_Form.m_Width-20, self.m_Form.m_Height-160, self.m_Tabs.m_Browser)
	elements.list:addColumn(_"Name", .6)
	elements.list:addColumn(_"Angebote", .4)
	for id, v in pairs(markets) do
		local item = elements.list:addItem(v.m_Name, v.m_Size)
		item.onLeftClick = function() self:onMarketClick(id) end
		item:setColumnAlignX(2, "center")
	end
	self.m_Form.m_Elements = elements
end

function AppMarketPlace:showMarket(market)
	self:clear()
	self.m_SelectedMarket = market.m_Id
	self.m_Page = 2
	local elements = {}
	elements.header = GUILabel:new(10, 10, self.m_Form.m_Width-20, 50, ("%s"):format(market.m_Name), self.m_Tabs.m_Browser)
	elements.back = GUIButton:new(self.m_Form.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self.m_Tabs.m_Browser):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Accent):setHoverColor(Color.White):setFontSize(1)
	elements.back.onLeftClick = function() triggerServerEvent("Marketplace:getMarkets", localPlayer) end
	elements.list = GUIGridList:new(10, 60, self.m_Form.m_Width-20, self.m_Form.m_Height-160, self.m_Tabs.m_Browser)
	elements.list:addColumn(_"Gegenstand", .4)
	elements.list:addColumn(_"Preis/Stk", .3)
	elements.list:addColumn(_"Stück", .3)

	local item = elements.list:addItem("• Verkauf", "", "")
	for i = 1, 3 do
		item:setColumnColor(i, Color.Cyan)
	end
	for i = 1, 3 do 
		item:setColumnAlignX(i, "center")
	end
	item:setClickable(false)
	local count = 0
	for k, v in pairs(market.m_Map) do
		if v.m_Quantity > 0 then
			if v.m_Type == "sell" then 
				local item = elements.list:addItem((MARKETPLACE_ITEM_DISPLAY[v.m_Item] and (MARKETPLACE_ITEM_DISPLAY[v.m_Item]):format(v.m_Value)) or v.m_ItemName, ("%s$"):format(v.m_Price), v.m_Quantity)
				for i = 1, 3 do
					item:setColumnColor(i, Color.White)
				end
				for i = 2, 3 do 
					item:setColumnAlignX(i, "center")
				end
				item.onLeftClick = function() self:onOfferClick(v.m_Id) end
				count = count + 1
			end
		end
	end
	if count == 0 then 
		local item = elements.list:addItem("", "", "")
		for i = 2, 3 do 
			item:setColumnAlignX(i, "center")
		end
		item:setClickable(false)
	end

	local item = elements.list:addItem("• Ankauf", "", "")
	for i = 1, 3 do
		item:setColumnColor(i, Color.Orange)
	end
	for i = 1, 3 do 
		item:setColumnAlignX(i, "center")
	end
	item:setClickable(false)
	count = 0 
	for k, v in pairs(market.m_Map) do
		if v.m_Quantity > 0 then
			if v.m_Type == "buy" then 
				local item = elements.list:addItem((MARKETPLACE_ITEM_DISPLAY[v.m_Item] and (MARKETPLACE_ITEM_DISPLAY[v.m_Item]):format(v.m_Value)) or v.m_ItemName, ("%s$"):format(v.m_Price), v.m_Quantity)
				for i = 1, 3 do
					item:setColumnColor(i, Color.White)
				end
				for i = 2, 3 do 
					item:setColumnAlignX(i, "center")
				end
				item.onLeftClick = function() self:onOfferClick(v.m_Id) end
				count = count + 1
			end
		end
	end

	if count == 0 then 
		local item = elements.list:addItem("", "", "")
		for i = 2, 3 do 
			item:setColumnAlignX(i, "center")
		end
		item:setClickable(false)
	end
	self.m_Form.m_Elements = elements
end

function AppMarketPlace:showOffer(offer)
	self:clear()
	self.m_Page = 3
	local elements = {}
	elements.bg = GUIRectangle:new(10,55+20, self.m_Form.m_Width-20, 170, Color.Background, self.m_Tabs.m_Browser)
	elements.header = GUILabel:new(10, 10, self.m_Form.m_Width-20, 50, ("Angebot - %s"):format(offer.m_Id), self.m_Tabs.m_Browser)
	elements.type = GUILabel:new(15, 60+20, self.m_Form.m_Width-20, 50, ("%s"):format(MARKET_OFFERTYPE_TO_STRING[offer.m_Type]), self.m_Tabs.m_Browser):setFontSize(0.8)
	elements.line = GUIRectangle:new(10,100+20, self.m_Form.m_Width-20, 1, Color.White, self.m_Tabs.m_Browser)
	elements.offerItem = GUILabel:new(15, 110+20, self.m_Form.m_Width-20, 30, (MARKETPLACE_ITEM_DISPLAY[offer.m_Item] and (MARKETPLACE_ITEM_DISPLAY[offer.m_Item]):format(offer.m_Value)) or offer.m_ItemName, self.m_Tabs.m_Browser):setFontSize(0.8)
	elements.offerPrice = GUILabel:new(15, 140+20, self.m_Form.m_Width-20, 30, ("$%s Pro Stück"):format(offer.m_Price), self.m_Tabs.m_Browser):setFontSize(0.8)
	elements.offerQuantity = GUILabel:new(15, 170+20, self.m_Form.m_Width-20, 30, ("Stückzahl: %s"):format(offer.m_Quantity), self.m_Tabs.m_Browser):setFontSize(0.8)
	elements.date = GUILabel:new(15, 200+20, self.m_Form.m_Width-20, 30, ("Eingestellt am: %s"):format(getOpticalTimestamp(offer.m_Date)), self.m_Tabs.m_Browser):setFontSize(0.8)
	local previewPath, isWeb = self:getPreview(offer.m_Item, offer.m_ItemName, offer.m_Value)
	if previewPath then
		if isWeb then 
			elements.preview = GUIWebView:new(self.m_Form.m_Width-74, 102+20, 64, 95, previewPath, true, self.m_Tabs.m_Browser)
			elements.preview:setRenderingEnabled(false)
		else 
			elements.preview = GUIImage:new(self.m_Form.m_Width-74, 120+20, 32, 32, previewPath, self.m_Tabs.m_Browser)
		end
	end
	elements.bg2 = GUIRectangle:new(10, 55+20+175, self.m_Form.m_Width-20, 30, Color.Background, self.m_Tabs.m_Browser)
	elements.visitorcount = GUILabel:new(15, 55+20+175, self.m_Form.m_Width-20, 30, ("Angebot wurde %s-Mal besucht!"):format(offer.m_VisitorCount), self.m_Tabs.m_Browser):setFontSize(0.8):setAlignY("center")
	elements.back = GUIButton:new(self.m_Form.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self.m_Tabs.m_Browser):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Accent):setHoverColor(Color.White):setFontSize(1)
	if self.m_SelectedMarket then
		elements.back.onLeftClick = function() triggerServerEvent("Marketplace:getMarket", localPlayer, self.m_SelectedMarket) end
	end
	self.m_Form.m_Elements = elements
end

function AppMarketPlace:getPreview(item, itemName, itemValue)
	local itemData = Inventory:getSingleton():getItemData()
	if item == toMarketPlaceItem(79, 1) then 
		local skin = tonumber(itemValue)
		if skin then
			return INGAME_WEB_PATH .. "/ingame/skinPreview/skinPreview.php?skin="..skin, true
		end
	else 
		return "files/images/Inventory/items/"..itemData[itemName]["Icon"]
	end
end

function AppMarketPlace:createDealTab()
	self.m_Form.m_DealTab = {}
	self.m_Form.m_DealTab.m_DealBackground = GUIRectangle:new(10,55+20, self.m_Form.m_Width-20, 170, Color.Background, self.m_Tabs.m_Deal)
	self.m_Form.m_DealTab.m_DealHeader = GUILabel:new(10, 10, self.m_Form.m_Width-20, 50, ("Abgeschlossene Aufträge"), self.m_Tabs.m_Deal)
	self.m_Form.m_DealTab.m_DealGrid = GUIGridList:new(10, 60, self.m_Form.m_Width-20, self.m_Form.m_Height-160, self.m_Tabs.m_Deal)
	self.m_Form.m_DealTab.m_DealGrid:addColumn(_"Markt", .3)
	self.m_Form.m_DealTab.m_DealGrid:addColumn(_"Geschäft", .7)
end

function AppMarketPlace:getDeals(data)
	if self.m_Form.m_DealTab.m_DealGrid then
		self.m_Form.m_DealTab.m_DealGrid:clear()
		for market, data in pairs(data) do
			local item = data.m_Sell.m_ItemName
			local price = deal.m_Sell.m_Price
			local quantity = deal.m_Sell.m_Quantity
			if data.type == "buy" then 
				self.m_Form.m_DealTab.m_DealGrid:addItem(market, ("[Gegenstand] %sx%s für $%s"):format(item, quantity, price*quantity))
			else 
				self.m_Form.m_DealTab.m_DealGrid:addItem(market, ("[Geld] $%s für %sx%s"):format(price*quantity, quantity, item))
			end
		end
	end
end

function AppMarketPlace:onOpen(form)
	self.m_Form = form
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs.m_Browser = self.m_TabPanel:addTab(_"Marktplätze", FontAwesomeSymbols.Info)
	self.m_Tabs.m_Deal = self.m_TabPanel:addTab(_"Angebot erstellen", FontAwesomeSymbols.Info)
	self.m_Tabs.m_Info = self.m_TabPanel:addTab(_"Informationen", FontAwesomeSymbols.Info)
	self:createDealTab()
	triggerServerEvent("Marketplace:getMarkets", localPlayer)
	triggerServerEvent("Marketplace:getDeals", localPlayer)
end

function AppMarketPlace:onClose() 
	triggerServerEvent("Marketplace:closeClient", localPlayer)
end

function AppMarketPlace:onMarketClick(id) 
	triggerServerEvent("Marketplace:getMarket", localPlayer, id)
end

function AppMarketPlace:onOfferClick(id) 
	triggerServerEvent("Marketplace:getOffer", localPlayer, id)
end

function AppMarketPlace:Event_onServerResponse(page, data)
	if page == 1 then 
		self:showMarkets(data)
	elseif page == 2 then 
		self:showMarket(data)
	elseif page == 3 then
		self:showOffer(data)
	else 
		self:getDeals(data)
	end
end

function AppMarketPlace:clear() 
	if self.m_Form and self.m_Form.m_Elements then 
		for k, p in pairs(self.m_Form.m_Elements)  do 
			p:delete()
		end
	end
end
