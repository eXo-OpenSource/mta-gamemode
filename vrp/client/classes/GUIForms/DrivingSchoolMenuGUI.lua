-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolMenuGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
DrivingSchoolMenuGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolMenuGUI)

addRemoteEvents{"showDrivingSchoolMenu"}

function DrivingSchoolMenuGUI:constructor()
	self.m_InstructorCount = 0

	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(160/2), 300, 160)
	self.m_Window = GUIWindow:new(0,0,300,500,_"eXo Fahrschule",true,true,self)
	GUILabel:new(10, 40, self.m_Width-20, 20, _("Es sind aktuell %d Fahrlehrer online!",self.m_InstructorCount), self)
	self.m_CallInstructorButton = GUIButton:new(30, 70, self.m_Width-60, 35,_"Fahrlehrer rufen", self)
	self.m_CallInstructorButton:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_CallInstructorButton.onLeftClick = bind(self.callInstructor,self)

	self.m_ShowInstructorButton = GUIButton:new(30, 115, self.m_Width-60, 35,_"Fahrlehrer anzeigen", self)
	self.m_ShowInstructorButton:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_ShowInstructorButton.onLeftClick = bind(self.showInstructor,self)

end

addEventHandler("showDrivingSchoolMenu", root,
		function()
			if DrivingSchoolMenuGUI:getSingleton():isInstantiated() then
				DrivingSchoolMenuGUI:getSingleton():open()
			else
				DrivingSchoolMenuGUI:getSingleton():new()
			end
		end
	)


function DrivingSchoolMenuGUI:callInstructor()
	triggerServerEvent("drivingSchoolMenu", localPlayer, "callInstructor")
end

function DrivingSchoolMenuGUI:showInstructor()
	triggerServerEvent("drivingSchoolMenu", localPlayer, "showInstructor")
end
