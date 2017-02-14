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
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Fahrschule", true, true, self):setCloseOnClose(true)

	GUILabel:new(10, 40, self.m_Width-20, 25, _("Es sind aktuell %d Fahrlehrer online!",self.m_InstructorCount), self):setAlignX("center")
	self.m_CallInstructorButton = GUIButton:new(30, 70, self.m_Width-60, 35,_"Fahrlehrer rufen", self)
	self.m_CallInstructorButton:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_CallInstructorButton.onLeftClick = bind(self.callInstructor,self)

	local instructorString = ""
	if self.m_InstructorCount > 0 then
		instructorString = _"Diese Fahrlehrer sind online:\n"
		for name, duty in pairs(instructors) do
			instructorString = instructorString..name.." "..duty.."\n"
		end
	end

	GUILabel:new(30, 115, self.m_Width-60, 20, instructorString, self):setMultiline(true)
end

addEventHandler("showDrivingSchoolMenu", root,
	function(count, instructors)
		DrivingSchoolMenuGUI:new(count, instructors)
	end
	)


function DrivingSchoolMenuGUI:callInstructor()
	if self.m_LastClick and getTickCount() - self.m_LastClick < 60000 then
		ErrorBox:new(_"Du hast bereits alle Fahrlerer gerufen. Bitte gedulde dich etwas.")
		return
	end

	self.m_LastClick = getTickCount()
	triggerServerEvent("drivingSchoolMenu", localPlayer, "callInstructor")
end

function DrivingSchoolMenuGUI:showInstructor()
	triggerServerEvent("drivingSchoolMenu", localPlayer, "showInstructor")
end
