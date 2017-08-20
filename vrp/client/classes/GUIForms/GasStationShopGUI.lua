-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GasStationShopGUI.lua
-- *  PURPOSE:     Gas Station Shop GUI class
-- *
-- ****************************************************************************
GasStationShopGUI = inherit(GUIForm)
inherit(Singleton, GasStationShopGUI)

addRemoteEvents{"showGasStationShopGUI", "refreshGasStationShopGUI"}

function GasStationShopGUI:constructor(callback, name)
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:delete() end

	local tabFuelStation = self.m_TabPanel:addTab(_("Tankstelle"))
	local tabItemShop = self.m_TabPanel:addTab(_("Shop"))

	GUILabel:new(5, 5, 200, 30, "Tankstelle:", tabFuelStation)
	GUILabel:new(5, 35, 200, 30, "Liter:", tabFuelStation)
	GUILabel:new(5, 65, 200, 30, "Preis:", tabFuelStation)

	GUILabel:new(150, 5, 200, 30, name, tabFuelStation)
	self.m_Fuel = GUILabel:new(150, 35, 200, 30, "-", tabFuelStation)
	self.m_Price = GUILabel:new(150, 65, 200, 30, "-", tabFuelStation)

	if GasStation.PendingTransaction and GasStation.PendingTransaction.station:getData("Name") == name then
		local vehicle = GasStation.PendingTransaction.vehicle
		local fuel = GasStation.PendingTransaction.fuel
		local station = GasStation.PendingTransaction.station

		self.m_Fuel:setText(fuel .. " L")
		self.m_Price:setText(fuel * 2 .. " $")

		self.m_Confirm = GUIButton:new(5, 120, 200, 25, "Bezahlen", tabFuelStation):setBackgroundColor(Color.Green)
		self.m_Cancel = GUIButton:new(210, 120, 200, 25, "Abbrechen", tabFuelStation):setBackgroundColor(Color.Red)

		self.m_Confirm.onLeftClick =
			function()
				triggerServerEvent("gasStationConfirmTransaction", localPlayer, vehicle, fuel, station)
			end

		self.m_Cancel.onLeftClick =
			function()
				self.m_Fuel:setText("-")
				self.m_Price:setText("-")
				self.m_Confirm:setVisible(false)
				self.m_Cancel:setVisible(false)
				GasStation.PendingTransaction = nil
			end
	end

	---

	self.m_Preview = GUIImage:new(280, 5, 150, 150, false, tabItemShop)
	self.m_LabelDescription = GUILabel:new(265, 160, 150, 20, "", tabItemShop)
	self.m_LabelDescription:setFont(VRPFont(self.m_Height*0.07)):setMultiline(true)

	self.m_Grid = GUIGridList:new(5, 5, 255, 420, tabItemShop)
	self.m_Grid:addColumn(_"Name", 0.7)
	self.m_Grid:addColumn(_"Preis", 0.3)

	addEventHandler("refreshGasStationShopGUI", root, bind(GasStationShopGUI.refreshItemShopGUI, self))

	--[[GUIForm.constructor(self, screenWidth/2-screenWidth*0.3*0.5, screenHeight/2-screenHeight*0.4*0.5, screenWidth*0.3, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Shop", true, true, self)
	self.m_Preview = GUIImage:new(self.m_Height*0.08, self.m_Height*0.12, self.m_Width*0.2, self.m_Width*0.2, false, self.m_Window)
	self.m_LabelDescription = GUILabel:new(self.m_Width*0.02, self.m_Width*0.3, self.m_Width*0.45, self.m_Height-self.m_Width*0.76, "", self.m_Window) -- use width to align correctly
	self.m_LabelDescription:setFont(VRPFont(self.m_Height*0.07)):setMultiline(true)

	self.m_Grid = GUIGridList:new(self.m_Width*0.5, self.m_Height*0.12, self.m_Width*0.48, self.m_Height*0.7, self.m_Window)
	self.m_Grid:addColumn(_"Name", 0.7)
	self.m_Grid:addColumn(_"Preis", 0.3)

	GUILabel:new(self.m_Width*0.08, self.m_Height*0.8, self.m_Width*0.2, self.m_Height*0.1, "Anzahl:", self.m_Window)
	self.m_EditAmount = GUIEdit:new(self.m_Width*0.26, self.m_Height*0.8, self.m_Width*0.1, self.m_Height*0.1, self.m_Window)
	self.m_EditAmount:setNumeric(true, true)
	self.m_EditAmount:setText("1")

	self.m_ButtonBuy = VRPButton:new(self.m_Width*0.65, self.m_Height*0.85, self.m_Width*0.33, self.m_Height*0.12, _"Kaufen", true, self.m_Window):setBarColor(Color.Green)
	self.m_ButtonBuy.onLeftClick = bind(self.ButtonBuy_Click, self)

	addEventHandler("refreshGasStationShopGUI", root, bind(GasStationShopGUI.refreshItemShopGUI, self))
	self.m_CallBack = callback]]
end

function GasStationShopGUI:refreshItemShopGUI(shopId, items)
	self.m_Shop = shopId or 0
	local item
	local itemData = Inventory:getSingleton():getItemData()
	if itemData then
		self.m_Grid:clear()
		for name, price in pairs(items) do
			item = self.m_Grid:addItem(name, tostring(price.."$"))
			item.Id = name
			item.onLeftClick = function()
				self.m_Preview:setImage("files/images/Inventory/items/"..itemData[name]["Icon"])
				self.m_LabelDescription:setText(itemData[name]["Info"])
			end
		end
	end
end

function GasStationShopGUI:ButtonBuy_Click()
	if not self.m_Grid:getSelectedItem() then
		ErrorBox:new(_"Bitte wähle zuerst ein Item aus")
		return
	end

	local itemName = self.m_Grid:getSelectedItem().Id
	if not itemName then
		core:throwInternalError("Unknown itemName @ GasStationShopGUI")
		return
	end
	local amount = tonumber(self.m_EditAmount:getText())
	if not amount then
		ErrorBox:new(_"Bitte gebe einen gültige Anzahl ein!")
		return
	end

	self.m_CallBack(self.m_Shop, itemName, amount)
end

addEventHandler("showGasStationShopGUI", root,
	function(name)
		if GasStationShopGUI:isInstantiated() then delete(GasStationShopGUI:getSingleton()) end
		local callback = function(shop, itemName, amount)
			triggerServerEvent("shopBuyItem", root, shop, itemName, amount)
		end
		GasStationShopGUI:new(callback, name)
	end
)
