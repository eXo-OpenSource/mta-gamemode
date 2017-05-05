-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolInstructorGUI.lua
-- *  PURPOSE:     DrivingSchoolInstructorGUI
-- *
-- ****************************************************************************
DrivingSchoolInstructorGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolInstructorGUI)

addRemoteEvents{"showDrivingSchoolInstructorGUI", "hideDrivingSchoolInstructorGUI"}

function DrivingSchoolInstructorGUI:constructor(type, student)
	GUIForm.constructor(self, screenWidth-210, screenHeight-270, 200, 240, false)
	self.m_Student = student
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Fahrlehrer-Menü"), true, false, self)
	GUILabel:new(5, 35, self.m_Width-10, 25, _("Prüfung: %s", type), self.m_Window)
	GUILabel:new(5, 60, self.m_Width-10, 20, _("Schüler: %s", student.name), self.m_Window)
	self.m_SpeedLabel = GUILabel:new(5, 85, self.m_Width-10, 30, _("<< kein Fahrzeug >>"), self.m_Window)
	GUILabel:new(5, 118, self.m_Width, 30, _("Anweisungen geben:", student.name), self.m_Window):setFont("default-bold"):setFontSize(1.2)
	self.m_LeftButton = GUIButton:new(27, 145, 45, 40, "←", self):setBackgroundColor(Color.LightBlue)
	self.m_LeftButton.onLeftClick = bind(self.turnLeft, self)
	self.m_StraightButton = GUIButton:new(77, 145, 45, 40, "↑", self):setBackgroundColor(Color.LightBlue)
	self.m_StraightButton.onLeftClick = bind(self.turnStraight, self)
	self.m_RightButton = GUIButton:new(127, 145, 45, 40, "→", self):setBackgroundColor(Color.LightBlue)
	self.m_RightButton.onLeftClick = bind(self.turnRight, self)
	self.m_TurnButton = GUIButton:new(5, 195, 90, 40, "Umkehren ↶", self):setFontSize(1):setBackgroundColor(Color.Red)
	self.m_TurnButton.onLeftClick = bind(self.turnArround, self)
	self.m_DSButton = GUIButton:new(100, 195, 95, 40, "zur Fahrschule", self):setFontSize(1):setBackgroundColor(Color.Orange)
	self.m_DSButton.onLeftClick = bind(self.turnToDrivingSchool, self)

	self.m_SpeedUpdateTimer = setTimer(bind(self.updateSpeed, self), 50, 0)
end

function DrivingSchoolInstructorGUI:virtual_destructor()
	if isTimer(self.m_SpeedUpdateTimer) then killTimer(self.m_SpeedUpdateTimer) end
end

function DrivingSchoolInstructorGUI:turnLeft() 				triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "left") 			end
function DrivingSchoolInstructorGUI:turnStraight() 			triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "straight") 		end
function DrivingSchoolInstructorGUI:turnRight() 			triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "right") 		end
function DrivingSchoolInstructorGUI:turnArround() 			triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "turnarround")	end
function DrivingSchoolInstructorGUI:turnToDrivingSchool() 	triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "school") 		end

function DrivingSchoolInstructorGUI:updateSpeed()
	if self.m_Student.vehicle then
		local vx, vy, vz = getElementVelocity(self.m_Student.vehicle)
		local speed = math.floor((vx^2 + vy^2 + vz^2) ^ 0.5 * 161)
		self.m_SpeedLabel:setText(_("Tempo: %d km/H", speed))
		if speed > 85 then self.m_SpeedLabel:setColor(Color.Red) else self.m_SpeedLabel:setColor(Color.Green) end
		return
	end
	self.m_SpeedLabel:setText(_("<< kein Fahrzeug >>"))
	self.m_SpeedLabel:setColor(Color.White)
end

addEventHandler("showDrivingSchoolInstructorGUI", root,
	function(type, student)
		DrivingSchoolInstructorGUI:new(type, student)
	end
)

addEventHandler("hideDrivingSchoolInstructorGUI", root,
	function()
		DrivingSchoolInstructorGUI:getSingleton():delete()
	end
)
