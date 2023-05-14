-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolStudentGUI.lua
-- *  PURPOSE:     DrivingSchoolStudentGUI
-- *
-- ****************************************************************************
DrivingSchoolStudentGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolStudentGUI)

addRemoteEvents{"showDrivingSchoolStudentGUI", "hideDrivingSchoolStudentGUI"}

function DrivingSchoolStudentGUI:constructor(type)
	GUIForm.constructor(self, screenWidth/2-(110/2), 10, 110, 135, false)
	GUIRectangle:new(0, 0, self.m_Width, 20, Color.Black, self)
	self.m_TypeLabel= GUILabel:new(0, 1, self.m_Width-4, 18, type, self):setAlignX("center")
	self.m_Rectangle = GUIRectangle:new(0, 20, self.m_Width, self.m_Height-20, Color.Orange, self)
	self.m_Image =  GUIImage:new(10, 25, 90, 90, "files/images/Other/trans.png", self)
	self.m_InstructionLabel = GUILabel:new(5, 25, 100, 90, "Bitte steige in\nein Fahrschul\nFahrzeug ein!", self)
	self.m_InstructionLabel:setColor(Color.Black):setAlignX("center"):setFont(VRPFont(25)):setMultiline(true)
	self.m_DirectionLabel = GUILabel:new(0, self.m_Height-20, self.m_Width, 20, "", self):setColor(Color.Black):setAlignX("center")

	if localPlayer.vehicle then
		self:setInVehicle()
	end

	addRemoteEvents{"drivingSchoolChangeDirection"}
	addEventHandler("drivingSchoolChangeDirection", root , bind(self.changeDirection, self))
	addEventHandler("onClientPlayerVehicleEnter", root, bind(self.setInVehicle, self))

end

function DrivingSchoolStudentGUI:setInVehicle()
	self.m_Image:setImage("files/images/Other/trans.png")
	self.m_InstructionLabel:setText("Folge den\nAnweisungen\ndes\nFahrlehrers!")
	self.m_DirectionLabel:setText("")
end

function DrivingSchoolStudentGUI:changeDirection(direction, arg)
	if direction == "straight" then
		self.m_Image:setImage("files/images/Other/arrow.png")
		self.m_Image:setRotation(0)
		self.m_InstructionLabel:setText("")
		self.m_DirectionLabel:setText("Gerade aus")
	elseif direction == "right" then
		self.m_Image:setImage("files/images/Other/arrow.png")
		self.m_Image:setRotation(90)
		self.m_InstructionLabel:setText("")
		self.m_DirectionLabel:setText("nach Rechts")
	elseif direction == "left" then
		self.m_Image:setImage("files/images/Other/arrow.png")
		self.m_Image:setRotation(270)
		self.m_InstructionLabel:setText("")
		self.m_DirectionLabel:setText("nach Links")
	elseif direction == "turnarround" then
		self.m_Image:setImage("files/images/Other/arrow_ta.png")
		self.m_Image:setRotation(0)
		self.m_InstructionLabel:setText("")
		self.m_DirectionLabel:setText("umdrehen")
	elseif direction == "school" then
		self.m_Image:setImage("files/images/Other/trans.png")
		self.m_InstructionLabel:setText("Fahre nun\nzurück zur\nFahrschule!")
		self.m_DirectionLabel:setText("")
	elseif direction == "break" then
		if arg == "down" then
			toggleControl("accelerate", false)
			toggleControl("brake_reverse", false)
			setPedControlState("brake_reverse", true)
		else
			setPedControlState("brake_reverse", false)
			toggleControl("brake_reverse", true)
			toggleControl("accelerate", true)
		end
	end
end

addEventHandler("showDrivingSchoolStudentGUI", root,
	function(type)
		DrivingSchoolStudentGUI:new(type)
	end
)

addEventHandler("hideDrivingSchoolStudentGUI", root,
	function()
		DrivingSchoolStudentGUI:getSingleton():delete()
	end
)
