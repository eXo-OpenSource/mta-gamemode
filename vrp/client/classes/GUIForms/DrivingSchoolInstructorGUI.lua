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
	GUILabel:new(5, 55, self.m_Width-10, 25, _("Schüler: %s", student.name), self.m_Window)

	GUILabel:new(5, 75, self.m_Width-10, 25, "Geschwindigkeit:", self.m_Window)
	self.m_SpeedLabel = GUILabel:new(130, 75, self.m_Width-10, 25, "", self.m_Window)

	GUILabel:new(5, 95, self.m_Width-10, 25, "Distanz:", self.m_Window)
	self.m_DistanceLabel = GUILabel:new(130, 95, self.m_Width-10, 25, "", self.m_Window)

	GUILabel:new(5, 118, self.m_Width, 30, _("Anweisungen geben:", student.name), self.m_Window)
	self.m_LeftButton = GUIButton:new(27, 145, 45, 40, "←", self):setBackgroundColor(Color.LightBlue)
	self.m_LeftButton.onLeftClick = bind(self.turnLeft, self)
	self.m_StraightButton = GUIButton:new(77, 145, 45, 40, "↑", self):setBackgroundColor(Color.LightBlue)
	self.m_StraightButton.onLeftClick = bind(self.turnStraight, self)
	self.m_RightButton = GUIButton:new(127, 145, 45, 40, "→", self):setBackgroundColor(Color.LightBlue)
	self.m_RightButton.onLeftClick = bind(self.turnRight, self)
	self.m_TurnButton = GUIButton:new(5, 195, 90, 40, "Umkehren ↶", self):setBackgroundColor(Color.Red):setFont(VRPFont(20))
	self.m_TurnButton.onLeftClick = bind(self.turnArround, self)
	self.m_DSButton = GUIButton:new(100, 195, 95, 40, "zur Fahrschule", self):setBackgroundColor(Color.Orange):setFont(VRPFont(20))
	self.m_DSButton.onLeftClick = bind(self.turnToDrivingSchool, self)

	self.m_SpeedUpdateTimer = setTimer(bind(self.updateSpeed, self), 50, 0)

	self.m_InstructorBreak = bind(DrivingSchoolInstructorGUI.instructorBreak, self)
	bindKey("space", "both", self.m_InstructorBreak)
end

function DrivingSchoolInstructorGUI:virtual_destructor()
	unbindKey("space", "both", self.m_InstructorBreak)
	if isTimer(self.m_SpeedUpdateTimer) then killTimer(self.m_SpeedUpdateTimer) end
end

function DrivingSchoolInstructorGUI:turnLeft() 				triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "left") 			end
function DrivingSchoolInstructorGUI:turnStraight() 			triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "straight") 		end
function DrivingSchoolInstructorGUI:turnRight() 			triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "right") 		end
function DrivingSchoolInstructorGUI:turnArround() 			triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "turnarround")	end
function DrivingSchoolInstructorGUI:turnToDrivingSchool() 	triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "school") 		end
function DrivingSchoolInstructorGUI:instructorBreak(_, state) triggerServerEvent("drivingSchoolReceiveTurnCommand", localPlayer, "break", state) end

function DrivingSchoolInstructorGUI:updateSpeed()
	local instructorData = localPlayer:getPrivateSync("instructorData")
	if instructorData and localPlayer.vehicle and self.m_Student.vehicle and instructorData.vehicle == self.m_Student.vehicle then
		local speed = localPlayer.vehicle:getSpeed()
		self.m_SpeedLabel:setText(_("%d km/h", speed))
		self.m_SpeedLabel:setColor(speed > 85 and Color.Red or Color.Green)

		local mileageDiff = (localPlayer.vehicle:getMileage()-instructorData.startMileage)/1000
		self.m_DistanceLabel:setText(_("%.1f km", mileageDiff))
		self.m_DistanceLabel:setColor(mileageDiff < 5 and Color.Red or Color.Green)
	end
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
