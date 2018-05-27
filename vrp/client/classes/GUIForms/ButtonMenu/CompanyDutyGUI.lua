-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CompanyDutyGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
--[[CompanyDutyGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showCompanyDutyGUI","updateCompanyDutyGUI"}

function CompanyDutyGUI:constructor()
	GUIButtonMenu.constructor(self, "Unternehmen Dienst-Menü")

	self.m_Duty = self:addItem(_"In den Dienst gehen",Color.Green ,
		function()
			triggerServerEvent("companyToggleDuty", localPlayer)
		end
	)

	addEventHandler("updateCompanyDutyGUI", root, bind(self.Event_updateCompanyDutyGUI, self))
end

function CompanyDutyGUI:Event_updateCompanyDutyGUI(duty)
	if duty == true then
		self.m_Duty:setBackgroundColor(Color.Red)
		self.m_Duty:setText("Dienst beenden")
	else
		self.m_Duty:setBackgroundColor(Color.Green)
		self.m_Duty:setText("In den Dienst gehen")
	end
end

addEventHandler("showCompanyDutyGUI", root,
		function()
			CompanyDutyGUI:new()
		end
	)
]]