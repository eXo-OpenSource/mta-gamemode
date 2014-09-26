HouseGUI = inherit(GUIForm)
inherit(Singleton, HouseGUI)

addRemoteEvents{"showHouseMenu","hideHouseMenu","houseEnter","houseLeave"}

function HouseGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(500/2), 300, 500)
	self.m_Window = GUIWindow:new(0,0,300,500,_"Hausmenue",true,false,self)
	self.m_LabelOwner =     GUILabel:new(30,40,200,30,_"s", self.m_Window)
	self.m_LabelPrice =     GUILabel:new(30,70,200,30,_"s", self.m_Window)
	self.m_LabelRentPrice = GUILabel:new(30,100,200,30,_"s", self.m_Window)
	
	self.m_Rent = GUIButton:new(30, 135, self.m_Width-60, 35, _("Einmieten"), self)
	self.m_Rent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Rent.onLeftClick = bind(self.onRent,self)
	
	self.m_Unrent = GUIButton:new(30, 180, self.m_Width-60, 35, _("Ausmieten"), self)
	self.m_Unrent:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Unrent.onLeftClick = bind(self.onUnrent,self)
	
	self.m_Buy = GUIButton:new(30, 225, self.m_Width-60, 35, _("Haus kaufen"), self)
	self.m_Buy:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Buy.onLeftClick = bind(self.buyHouse,self)
	
	self.m_Enter = GUIButton:new(30, 325, self.m_Width-60, 35, _("Betreten"), self)
	self.m_Enter:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Enter.onLeftClick = bind(self.enterHouse,self)	
	
	self.m_Leave = GUIButton:new(30, 370, self.m_Width-60, 35, _("Verlassen"), self)
	self.m_Leave:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Leave.onLeftClick = bind(self.leaveHouse,self)		
	
	self.m_RentPrice = "/"
	self.m_Owner = "/"
	self.m_Price = "/"
	self.m_InHouse = false
	
	self:houseChange()
	
	self:hide()
	
	addEventHandler("showHouseMenu", root,
		function(...)
			self:show(...)
		end
	)
	
	addEventHandler("hideHouseMenu", root,
		function()
			self:hide()
		end
	)
	
	addEventHandler("houseEnter", root,
		function()
			self.m_InHouse = true
		end
	)
	
	addEventHandler("houseLeave", root,
		function()
			self.m_InHouse = false
		end
	)
end

function HouseGUI:InHouse()
	return self.m_InHouse
end

function HouseGUI:enterHouse()
	triggerServerEvent("enterHouse",root)
end

function HouseGUI:leaveHouse()
	triggerServerEvent("leaveHouse",root)
end


function HouseGUI:buyHouse()
	triggerServerEvent("buyHouse",root)
end

function HouseGUI:onRent()
	triggerServerEvent("rentHouse",root)
end

function HouseGUI:onUnrent()
	triggerServerEvent("unrentHouse",root)
end

function HouseGUI:houseChange()
	self.m_LabelOwner:setText(_("Besitzer: %s",self.m_Owner or "Keiner"))
	self.m_LabelPrice:setText(_("Preis: $ %s",self.m_Price))
	self.m_LabelRentPrice:setText(_("Mietpreis: $ %s",self.m_RentPrice))
end

function HouseGUI:show(owner,price,rentprice)
	self.m_RentPrice = rentprice
	self.m_Price = price
	self.m_Owner = owner
	self:houseChange()
	self:setVisible(true)
end

function HouseGUI:hide()
	self:setVisible(false)
end