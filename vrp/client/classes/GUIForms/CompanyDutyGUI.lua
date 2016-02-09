-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CompanyDutyGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
CompanyDutyGUI = inherit(GUIForm)
inherit(Singleton, CompanyDutyGUI)

addRemoteEvents{"showCompanyDutyGUI","updateCompanyDutyGUI"}

function CompanyDutyGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(150/2), 300, 150)
	self.m_Window = GUIWindow:new(0,0,300,500,_"Unternehmen Dienst-Menü",true,true,self)

	self.m_Duty = GUIButton:new(30, 50, self.m_Width-60, 35,_"In den Dienst gehen", self)
	self.m_Duty:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_Duty.onLeftClick = bind(self.companyToggleDuty,self)

	self.m_SkinChange = GUIButton:new(30, 95, self.m_Width-60, 35,_"Skin wechseln", self)
	self.m_SkinChange:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_SkinChange.onLeftClick = bind(self.companyChangeSkin,self)

	addEventHandler("updateCompanyDutyGUI", root, bind(self.Event_updateCompanyDutyGUI, self))

	--self:refresh()
end

function CompanyDutyGUI:Event_updateCompanyDutyGUI(duty)


	if duty == true then
		self.m_SkinChange:setEnabled(true)
		self.m_Duty:setBackgroundColor(Color.Red)
		self.m_Duty:setText("Dienst beenden")
	else
		self.m_SkinChange:setEnabled(false)
		self.m_Duty:setBackgroundColor(Color.Green)
		self.m_Duty:setText("In den Dienst gehen")
	end
end

addEventHandler("showCompanyDutyGUI", root,
		function()
			if CompanyDutyGUI:getSingleton():isInstantiated() then
				CompanyDutyGUI:getSingleton():open()
			else
				CompanyDutyGUI:getSingleton():new()
			end
		end
	)


function CompanyDutyGUI:onShow()
end

function CompanyDutyGUI:onHide()
end


function CompanyDutyGUI:hide()
	GUIForm.hide(self)
	removeEventHandler("updateCompanyDutyGUI", root, bind(self.Event_updateCompanyDutyGUI, self))
end

function CompanyDutyGUI:companyToggleDuty()
	triggerServerEvent("companyToggleDuty", localPlayer)
end

function CompanyDutyGUI:companyChangeSkin()
	triggerServerEvent("companyChangeSkin", localPlayer)
end
