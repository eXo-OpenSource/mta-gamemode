﻿-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleShopGUI.lua
-- *  PURPOSE:     VehicleShopGUI class
-- *
-- ****************************************************************************
VehicleShopGUI = inherit(GUIForm)
local ASPECT_RATIO_MULTIPLIER = (screenWidth/screenHeight)/1.8

function VehicleShopGUI:constructor(name, imagePath, vehicles)
	GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Vehicle shop", false, false, self)
	GUIImage:new(0, 0, self.m_Width, self.m_Height/7, imagePath, self.m_Window)
	self.m_VehicleList = GUIGridList:new(0, self.m_Height/7, self.m_Width, self.m_Height-self.m_Height/7-self.m_Height/14, self.m_Window)
	self.m_VehicleList:addColumn("", 0.57)
	self.m_VehicleList:addColumn("", 0.4)
	GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", 2, self.m_Window):setAlignX("center")
	
	for k, v in pairs(vehicles) do
		local item = self.m_VehicleList:addItem(k, "$"..tostring(v)):setColumnAlignX(2, "right")
		item.onLeftDoubleClick = function() outputDebug(item:getColumnText(1)) end
	end
end
