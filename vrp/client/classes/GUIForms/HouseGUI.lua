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

function HouseGUI:constructor(owner,price,rentprice,isValidRob)
	GUIForm.constructor(self, screenWidth/2-(400/2), screenHeight/2-(500/2), 400, 500)
	self.m_Window = GUIWindow:new(0, 0, 300, 500, _"Hausmenü", true, true, self)
	self.m_Window:setCloseOnClose( true )

	self.m_LabelOwner =     GUILabel:new(30, 40, self.m_Width-60, 30,_"s", self.m_Window)
	self.m_LabelPrice =     GUILabel:new(30, 70, self.m_Width-60, 30,_"s", self.m_Window)
	self.m_LabelRentPrice = GUILabel:new(30, 100,self.m_Width-60, 30,_"s", self.m_Window)

	self.m_Rent = GUIButton:new(30, 135, self.m_Width-60, 35, _("Einmieten"), self)
	self.m_Rent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Rent.onLeftClick = bind(self.onRent,self)

	self.m_Unrent = GUIButton:new(30, 180, self.m_Width-60, 35, _("Ausmieten"), self)
	self.m_Unrent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Unrent.onLeftClick = bind(self.onUnrent,self)

	self.m_Buy = GUIButton:new(30, 225, self.m_Width-60, 35, _("Haus kaufen"), self)
	self.m_Buy:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Buy.onLeftClick = bind(self.buyHouse,self)

	self.m_Sell = GUIButton:new(30, 225, self.m_Width-60, 35, _("Haus verkaufen"), self)
	self.m_Sell:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Sell.onLeftClick = bind(self.sellHouse,self)
	self.m_Sell:setVisible(false)

	self.m_Enter = GUIButton:new(30, 280, self.m_Width-60, 35, _("Betreten"), self)
	self.m_Enter:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Enter.onLeftClick = bind(self.enterHouse,self)

	self.m_Leave = GUIButton:new(30, 280, self.m_Width-60, 35, _("Verlassen"), self)
	self.m_Leave:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Leave.onLeftClick = bind(self.leaveHouse,self)

	self.m_Break = GUIButton:new(30, 325, self.m_Width-60, 35, _("Einbrechen"), self)
	self.m_Break:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Break.onLeftClick = bind(self.breakHouse,self)

	self.m_Close = GUIButton:new(30, 450, self.m_Width-60, 35, _("Schließen"), self)
	self.m_Close:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Close.onLeftClick = function () delete(self) end

	self.m_LabelOwner:setText(_("Besitzer: %s",owner or "-"))
	self.m_LabelPrice:setText(_("Preis: $%d",price))
	self.m_LabelRentPrice:setText(_("Mietpreis: $%d",rentprice))
	self.m_Break:setVisible(isValidRob)

	if owner == localPlayer:getName() then
		self.m_Buy:setVisible(false)
		self.m_Sell:setVisible(true)
		self.m_Rent:setVisible(false)
		self.m_Unrent:setVisible(false)
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

function HouseGUI:onUnrent()
	triggerServerEvent("unrentHouse",root)
end

function HouseGUI:breakHouse()
	triggerServerEvent("breakHouse",root)
	delete(self)
end

addEventHandler("showHouseMenu", root,
	function(owner,price,rentprice,isValidRob)
		HouseGUI:new(owner,price,rentprice,isValidRob)
	end
)

addEventHandler("hideHouseMenu", root,
	function()
		if HouseGUI:isInstantiated() then
			delete(HouseGUI:getSingleton())
		end
	end
)
