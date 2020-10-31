-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HouseRobSellGUI.lua
-- *  PURPOSE:     HouseRob GUI class
-- *
-- ****************************************************************************
HouseRobSellGUI = inherit(GUIForm)
inherit(Singleton, HouseRobSellGUI)

addRemoteEvents{"showHouseRobSellGUI"}

function HouseRobSellGUI:constructor(ped)
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(150/2), 300, 200, true, false, ped)
	self.m_Window = GUIWindow:new(0,0,300,500,_"Diebesgut verkaufen",true,true,self)

	self.m_Accept = GUIButton:new(30, 50, self.m_Width-60, 40,_"Verkaufen", self)
	self.m_Accept:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Accept.onLeftClick = bind(self.acceptSell,self)

	self.m_Decline = GUIButton:new(30, 110, self.m_Width-60, 40,_"Ablehnen", self)
	self.m_Decline:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_Decline.onLeftClick = function () self:close() end
end

function HouseRobSellGUI:acceptSell() 
	triggerServerEvent("GroupRob:SellRobItems", localPlayer)
	self:close()
end

addEventHandler("showHouseRobSellGUI", root,
		function(ped)
			HouseRobSellGUI:new(ped)
		end
	)


function HouseRobSellGUI:onShow()
	Cursor:show()
end

function HouseRobSellGUI:onHide()
	Cursor:hide()
end


function HouseRobSellGUI:hide()
	GUIForm.hide(self)
end
