-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HouseGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
HouseGUI = inherit(GUIForm)
inherit(Singleton, HouseGUI)

addRemoteEvents{"showHouseMenu","hideHouseMenu"}

function HouseGUI:constructor(owner, price, rentprice, isValidRob, isOpen)
	GUIForm.constructor(self, screenWidth/2-(400/2), screenHeight/2-(500/2), screenWidth*0.4, 500)
	self.m_Window = GUIWindow:new(0, 0, screenWidth*0.25, 500, _"Hausmenü", true, true, self)
	self.m_Window:setCloseOnClose( true )

	local columnWidth = self.m_Width*0.5

	self.m_LabelOwner =     GUILabel:new(30, 40, columnWidth-60, 30,_"s", self.m_Window)
	self.m_LabelPrice =     GUILabel:new(30, 70, columnWidth-60, 30,_"s", self.m_Window)

	self.m_Rent = GUIButton:new(30, 135, columnWidth/2-35, 35, _("Einmieten"), self)
	self.m_Rent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Rent.onLeftClick = bind(self.onRent,self)

	self.m_Unrent = GUIButton:new(columnWidth/2+5, 135, columnWidth/2-35, 35, _("Ausmieten"), self)
	self.m_Unrent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Unrent.onLeftClick = bind(self.onUnrent,self)

	self.m_Buy = GUIButton:new(30, 180, columnWidth-60, 35, _("Haus kaufen"), self)
	self.m_Buy:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Buy.onLeftClick = bind(self.buyHouse,self)

	self.m_Sell = GUIButton:new(30, 180, columnWidth-60, 35, _("Haus verkaufen"), self)
	self.m_Sell:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Sell.onLeftClick = bind(self.sellHouse,self)
	self.m_Sell:setVisible(false)

	self.m_Enter = GUIButton:new(30, 225, columnWidth-60, 35, _("Betreten"), self)
	self.m_Enter:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Enter.onLeftClick = bind(self.enterHouse,self)

	self.m_Leave = GUIButton:new(30, 225, columnWidth-60, 35, _("Verlassen"), self)
	self.m_Leave:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Leave.onLeftClick = bind(self.leaveHouse,self)

	self.m_Lock = GUIButton:new(30, 280, columnWidth-60, 35, _("Abschließen"), self)
	self.m_Lock:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Lock.onLeftClick = bind(self.lockHouse,self)
	self.m_Lock:setVisible(false)

	self.m_Tenants = GUIButton:new(30, 325, columnWidth-60, 35, _("Mieter anzeigen"), self)
	self.m_Tenants:setBackgroundColor(Color.LightBlue):setFont(VRPFont(28)):setFontSize(1)
	self.m_Tenants.onLeftClick = bind(self.lockHouse,self)
	self.m_Tenants:setVisible(false)

	self.m_Close = GUIButton:new(30, 450, columnWidth-60, 35, _("Schließen"), self)
	self.m_Close:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Close.onLeftClick = function () delete(self) end

	self.m_LabelOwner:setText(_("Besitzer: %s",owner or "-"))
	self.m_LabelPrice:setText(_("Preis: $%d",price))

	--self.m_Break:setVisible(isValidRob)

	if owner == localPlayer:getName() then
		GUILabel:new(30, 100, self.m_Width/2-30, 30, _"Mietpreis:" , self.m_Window)
		self.m_RentPrice = GUIChanger:new(self.m_Width/2-30, 100, self.m_Width/2-35, 30, self.m_Window)
		self.m_SaveRent = GUIButton:new(self.m_Width-60, 100, 30, 30, FontAwesomeSymbols.Save, self.m_Window):setFont(FontAwesome(15))
		self.m_SaveRent.onLeftClick = bind(self.saveRent,self)

		local item
		self.m_RentTable = {}
		for i = 0, 500, 50 do
			item = self.m_RentPrice:addItem(i.."$")
			self.m_RentTable[item] = i
			if rentprice == i then
				self.m_RentPrice:setIndex(item)
			end
		end

		self.m_Buy:setVisible(false)
		self.m_Sell:setVisible(true)
		self.m_Rent:setVisible(false)
		self.m_Unrent:setVisible(false)
		self.m_Lock:setVisible(true)
		if isOpen then
			self.m_Lock:setText(_"Abschließen")
		else
			self.m_Lock:setText(_"Aufschließen")
		end
	else
		GUILabel:new(30, 100,self.m_Width-60, 30, _("Mietpreis: $%d",rentprice) , self.m_Window)
	end

	if localPlayer:getDimension() > 0 or localPlayer:getInterior() > 0 then
		self.m_Leave:setVisible(true)
		self.m_Enter:setVisible(false)
	else
		self.m_Leave:setVisible(false)
		self.m_Enter:setVisible(true)
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

addEventHandler("showHouseMenu", root,
	function(owner, price, rentprice, isValidRob, isOpen)
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
		HouseGUI:new(owner, price, rentprice, isValidRob, isOpen)
	end
)

addEventHandler("hideHouseMenu", root,
	function()
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
	end
)
