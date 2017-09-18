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

function DrivingSchoolMenuGUI:constructor(count, instructors)
	self.m_InstructorCount = count

	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(160/2), 300, 250)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Fahrschule", true, true, self):deleteOnClose(true)

	GUILabel:new(10, 40, self.m_Width-20, 25, _("Es %s aktuell %s Fahrlehrer online!", self.m_InstructorCount > 1 and "sind" or "ist", self.m_InstructorCount == 0 and "kein" or self.m_InstructorCount), self):setAlignX("center")
	self.m_CallInstructorButton = GUIButton:new(30, 70, self.m_Width-60, 35,_"Fahrlehrer rufen", self)
	self.m_CallInstructorButton:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_CallInstructorButton.onLeftClick = bind(self.callInstructor,self)

	local instructorsGrid = GUIGridList:new(10, 115, 280, 125, self.m_Window)
	instructorsGrid:addColumn(_"Spieler", .6)
	instructorsGrid:addColumn(_"Im Dienst", .4)

	if self.m_InstructorCount > 0 then
		for name, duty in pairs(instructors) do
			instructorsGrid:addItem(name, duty)
		end
	end
end

addEventHandler("showDrivingSchoolMenu", root,
	function(count, instructors)
		DrivingSchoolMenuGUI:new(count, instructors)
	end
	)


function DrivingSchoolMenuGUI:callInstructor()
	if localPlayer.callInstructorCooldown and getTickCount() - localPlayer.callInstructorCooldown < 60000 then
		ErrorBox:new(_"Du hast bereits alle Fahrlerer gerufen. Bitte gedulde dich etwas.")
		return
	end

	localPlayer.callInstructorCooldown = getTickCount()
	triggerServerEvent("drivingSchoolMenu", localPlayer, "callInstructor")
end

function DrivingSchoolMenuGUI:showInstructor()
	triggerServerEvent("drivingSchoolMenu", localPlayer, "showInstructor")
end
