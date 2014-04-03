-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************
VehicleShopGUI = inherit(GUIForm)
inherit(Singleton, VehicleShopGUI)

function VehicleShopGUI:constructor()
	GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Vehicle shop", false, true, self):setCloseOnClose(false)
	self.m_ShopImage = GUIImage:new(0, self.m_Height*0.01, self.m_Width, self.m_Height/7, "files/images/CouttSchutz.png", self.m_Window)
	self.m_VehicleList = GUIGridList:new(0, self.m_Height/7, self.m_Width, self.m_Height-self.m_Height/7-self.m_Height/14, self.m_Window)
	self.m_VehicleList:addColumn("", 0.57)
	self.m_VehicleList:addColumn("", 0.4)
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doubleclick to buy", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center"):setColor(Color.Red)
	self:setVisible(false)
	
	addEvent("vehicleBought", true)
	addEventHandler("vehicleBought", root, 
		function()
			self:close()
			SuccessBox:new(_"Congratulations! You are now owner of a brand new vehicle", 0, 255, 0)
		end
	)
end

function VehicleShopGUI:onShow()
	showChat(false)
end

function VehicleShopGUI:onHide()
	showChat(true)
end

function VehicleShopGUI:buyVehicle(item)
	if item.VehicleId then
		triggerServerEvent("vehicleBuy", root, item.VehicleId, self.m_ShopName)
	end
end

function VehicleShopGUI:setShopName(name)
	self.m_ShopName = name
end

function VehicleShopGUI:setShopLogoPath(path)
	return self.m_ShopImage:setImage(path)
end

function VehicleShopGUI:setVehicleList(list)
	-- Clear old data
	self.m_VehicleList:clear()
	
	for k, v in pairs(list) do
		local item = self.m_VehicleList:addItem(getVehicleNameFromModel(k), "$"..tostring(v)):setColumnAlignX(2, "right")
		item.VehicleId = k
		
		item.onLeftDoubleClick = bind(self.buyVehicle, self)
	end
end
