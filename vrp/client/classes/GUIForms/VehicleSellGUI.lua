-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************
--[[
VehicleSellGUI = inherit(GUIForm)
inherit(Singleton, VehicleSellGUI)

addRemoteEvents{"vehicleConfirmSell","vehicleStartSell"}

function VehicleSellGUI:constructor()
	local width, height =  screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/4
	GUIForm.constructor(self, (screenWidth*0.5 - (screenWidth/5)) /ASPECT_RATIO_MULTIPLIER , screenHeight*0.5, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/4)

	self.m_Edit = GUIEdit:constructor(width*0.4, height*0.4, width*0.4, height*0.2, self.m_Window )
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	GUILabel:new(6, self.m_Height-self.m_Height/14, self.m_Width*0.5, self.m_Height/14, _"Doppelklick zum Kaufen", self.m_Window):setFont(VRPFont(self.m_Height*0.045)):setAlignY("center"):setColor(Color.Red)
	
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() delete( VehicleSellGUI:getSingleton()) end
	--self.m_VehicleBought = bind(self.Event_VehicleBought, self)
	--addEventHandler("vehicleBought", root, self.m_VehicleBought)

	showChat(true)
end

function VehicleShopGUI:destructor()
	removeEventHandler("vehicleConfirmSell", root, self.m_VehicleSell)
	GUIForm.destructor(self)
end

addEventHandler("vehicleStartSell",localPlayer, function()
	if not VehicleSellGUI:getSingleton() then 
		
	end
)
--]]
