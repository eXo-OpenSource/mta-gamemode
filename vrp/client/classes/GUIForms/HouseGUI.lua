-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HouseGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
HouseGUI = inherit(GUIForm)
HouseGUI.Blips = {}
inherit(Singleton, HouseGUI)

addRemoteEvents{"showHouseMenu","hideHouseMenu", "addHouseBlip", "removeHouseBlip"}

function HouseGUI:constructor(owner, price, rentprice, isValidRob, isClosed, tenants, money, bRobPrompt, houseId)
	local columnWidth
	if owner == localPlayer:getName() then
		GUIForm.constructor(self, screenWidth/2-(screenWidth*0.35/2), screenHeight/2-(370/2), screenWidth*0.35, 370)
		columnWidth = self.m_Width*0.5

	else
		GUIForm.constructor(self, screenWidth/2-(screenWidth*0.2/2), screenHeight/2-(370/2), screenWidth*0.2, 370)
		columnWidth = self.m_Width
	end

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Hausmenü", true, true, self)
	self.m_Window:deleteOnClose( true )


	self.m_LabelOwner =     GUILabel:new(10, 40, self.m_Width-20, 30,_"s", self.m_Window)
	self.m_LabelPrice =     GUILabel:new(10, 70, self.m_Width-20, 30,_"s", self.m_Window)

	self.m_Rent = GUIButton:new(10, 135, columnWidth/2-15, 35, _("Einmieten"), self)
	self.m_Rent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Rent.onLeftClick = bind(self.onRent,self)

	self.m_Unrent = GUIButton:new(columnWidth/2+5, 135, columnWidth/2-15, 35, _("Ausmieten"), self)
	self.m_Unrent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Unrent.onLeftClick = bind(self.onUnrent,self)

	self.m_Buy = GUIButton:new(10, 180, columnWidth-20, 35, _("Haus kaufen"), self)
	self.m_Buy:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Buy.onLeftClick = bind(self.buyHouse,self)

	self.m_Sell = GUIButton:new(10, 180, columnWidth-20, 35, _("Haus verkaufen"), self)
	self.m_Sell:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Sell.onLeftClick = bind(self.sellHouse,self)
	self.m_Sell:setVisible(false)

	self.m_Enter = GUIButton:new(10, 225, columnWidth-20, 35, _("Betreten"), self)
	self.m_Enter:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Enter.onLeftClick = bind(self.enterHouse,self)

	self.m_Leave = GUIButton:new(10, 225, columnWidth-20, 35, _("Verlassen"), self)
	self.m_Leave:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Leave.onLeftClick = bind(self.leaveHouse,self)

	self.m_Lock = GUIButton:new(10, 280, columnWidth-20, 35, _("Abschließen"), self)
	self.m_Lock:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Lock.onLeftClick = bind(self.lockHouse,self)
	self.m_Lock:setVisible(false)

	self.m_Rob = GUIButton:new(10, 280, columnWidth-20, 35, _("Raub starten"), self)
	self.m_Rob:setBackgroundColor(Color.Orange):setFont(VRPFont(28)):setFontSize(1)
	self.m_Rob.onLeftClick = bind(self.tryRob,self)
	if bRobPrompt then
		self.m_Rob:setVisible(true)
	end

	if houseId then
		self.m_UpdateSpawnpoint = GUIButton:new(10, 325, columnWidth-20, 35, _("Als Spawnpunkt festlegen"), self)
		self.m_UpdateSpawnpoint:setFont(VRPFont(28)):setFontSize(1)
		self.m_UpdateSpawnpoint.onLeftClick = function() triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.HOUSE, houseId) end
	end

	self.m_LabelOwner:setText(_("Besitzer: %s",owner or "-"))
	self.m_LabelPrice:setText(_("Preis: $%d",price))


	--self.m_Break:setVisible(isValidRob)

	if owner == localPlayer:getName() then
		GUILabel:new(10, 100, self.m_Width/2-30, 30, _"Mietpreis:" , self.m_Window)
		self.m_RentPrice = GUIChanger:new(100, 100, self.m_Width*0.4-90, 30, self.m_Window)
		self.m_SaveRent = GUIButton:new(105+self.m_Width*0.4-90, 100, 30, 30, FontAwesomeSymbols.Save, self.m_Window):setFont(FontAwesome(15))
		self.m_SaveRent.onLeftClick = bind(self.saveRent,self)

		columnWidth = self.m_Width*0.45
		local left = self.m_Width-columnWidth+10
		self.m_Money = GUILabel:new(left, 40, columnWidth-20, 30, _"Kasse:", self)
		self.m_MoneyEdit = GUIEdit:new(left, 70, columnWidth-20, 25, self)
		self.m_MoneyEdit:setNumeric(true, true)
		self.m_MoneyDeposit = GUIButton:new(left, 100, (columnWidth-20)/2-5, 25, _"Einzahlen", self)
		self.m_MoneyDeposit:setFont(VRPFont(22)):setFontSize(1)
		self.m_MoneyDeposit.onLeftClick = bind(self.deposit, self)
		self.m_MoneyWithdraw = GUIButton:new(left + (columnWidth-20)/2+5, 100, (columnWidth-20)/2-5, 25, _"Auszahlen", self)
		self.m_MoneyWithdraw:setFont(VRPFont(22)):setFontSize(1)
		self.m_MoneyWithdraw.onLeftClick = bind(self.withdraw, self)

		self.m_Tenants = GUIGridList:new(left, 165, columnWidth-20, 150, self)
		self.m_Tenants:addColumn(_"Mieter", 1)
		self.m_RemoveTenant = GUIButton:new(left, 320, columnWidth-20, 35, _("Mieter entfernen"), self)
		self.m_RemoveTenant:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
		self.m_RemoveTenant.onLeftClick = bind(self.removeTenant, self)

		local item
		for id, tenant in pairs(tenants) do
			item = self.m_Tenants:addItem(tenant)
			item.Id = id
		end


		local item
		self.m_RentTable = {}
		for i = 0, 500, 50 do
			item = self.m_RentPrice:addItem(i.."$")
			self.m_RentTable[item] = i
			if rentprice == i then
				self.m_RentPrice:setIndex(item)
			end
		end

		self.m_Money:setText(_("Kasse: %d$", money or 0))

		self.m_Buy:setVisible(false)
		self.m_Sell:setVisible(true)
		self.m_Rent:setVisible(false)
		self.m_Unrent:setVisible(false)
		self.m_Lock:setVisible(true)

		if isClosed then
			self.m_Lock:setText(_"Aufschließen")
		else
			self.m_Lock:setText(_"Abschließen")
		end
	else
		GUILabel:new(10, 100,self.m_Width-20, 30, _("Mietpreis: $%d", rentprice) , self.m_Window)
	end

	if localPlayer:getDimension() > 0 or localPlayer:getInterior() > 0 then
		self.m_Leave:setVisible(true)
		self.m_Enter:setVisible(false)
	else
		self.m_Leave:setVisible(false)
		self.m_Enter:setVisible(true)
	end
end

function HouseGUI:deposit()
	local amount = self.m_MoneyEdit:getText()
	if amount and tonumber(amount) and tonumber(amount) > 0 then
		triggerServerEvent("houseDeposit", root, amount)
	else
		ErrorBox:new(_"Ungültiger Betrag!")
	end
end

function HouseGUI:withdraw()
	local amount = self.m_MoneyEdit:getText()
	if amount and tonumber(amount) and tonumber(amount) > 0 then
		triggerServerEvent("houseWithdraw", root, amount)
	else
		ErrorBox:new(_"Ungültiger Betrag!")
	end
end

function HouseGUI:removeTenant()
	local tenant = self.m_Tenants:getSelectedItem()
	if tenant and tenant.Id then
		triggerServerEvent("houseRemoveTenant", root, tenant.Id)
	else
		WarningBox:new(_"Bitte wähle einen Mieter aus!")
		return
	end

end

function HouseGUI:enterHouse()
	triggerServerEvent("enterHouse",root)
	delete(self)
end

function HouseGUI:leaveHouse()
	triggerServerEvent("leaveHouse",root)
	delete(self)
end

function HouseGUI:buyHouse()
	QuestionBox:new(_"Möchtest du wirklich dieses Haus kaufen?",
	function() triggerServerEvent("buyHouse",root) end
	)

end

function HouseGUI:sellHouse()
	QuestionBox:new("Möchtest du wirklich dein Haus verkaufen? Du erhälst 75% des Preises zurück!",
	function() triggerServerEvent("sellHouse",root) end
	)

end

function HouseGUI:onRent()
	triggerServerEvent("rentHouse",root)
end

function HouseGUI:saveRent()
	local _, id = self.m_RentPrice:getIndex()
	local rent = self.m_RentTable[id]
	if rent then
		triggerServerEvent("houseSetRent",root, rent)
	else
		ErrorBox:new("Ungültige Auswahl!")
	end
end

function HouseGUI:onUnrent()
	triggerServerEvent("unrentHouse",root)
end

function HouseGUI:lockHouse()
	triggerServerEvent("lockHouse",root)
end

function HouseGUI:tryRob()
	triggerServerEvent("tryRobHouse", localPlayer)
end

addEventHandler("showHouseMenu", root,
	function(...)
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
		HouseGUI:new(...)
	end
)

addEventHandler("hideHouseMenu", root,
	function()
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
	end
)

addEventHandler("addHouseBlip", root,
	function(id, x, y)
		if not HouseGUI.Blips[id] then
			HouseGUI.Blips[id] = Blip:new("House.png", x, y, 2000)
		end
	end
)

addEventHandler("removeHouseBlip", root,
	function(id)
		 if HouseGUI.Blips[id] then
		 	delete(HouseGUI.Blips[id])
			HouseGUI.Blips[id] = nil
		end
	end
)
