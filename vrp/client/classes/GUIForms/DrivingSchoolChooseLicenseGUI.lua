-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolChooseLicenseGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
DrivingSchoolChooseLicenseGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolChooseLicenseGUI)

addRemoteEvents{"showDrivingSchoolMenu"}

function DrivingSchoolChooseLicenseGUI:constructor(target)
	self.m_Target = target

	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(280/2), 300, 280)
	self.m_Window = GUIWindow:new(0,0,300,500,_"Führerschein auswählen",true,true,self)
	self.m_LicenseButton_Car = GUIButton:new(30, 50, self.m_Width-60, 35,_"Auto-Führerschein", self)
	self.m_LicenseButton_Car:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_LicenseButton_Car.onLeftClick = bind(self.startLession_Car,self)

	self.m_LicenseButton_Bike = GUIButton:new(30, 95, self.m_Width-60, 35,_"Motorradschein", self)
	self.m_LicenseButton_Bike:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_LicenseButton_Bike.onLeftClick = bind(self.startLession_Bike,self)

	self.m_LicenseButton_Truck = GUIButton:new(30, 140, self.m_Width-60, 35,_"LKW-Schein", self)
	self.m_LicenseButton_Truck:setBackgroundColor(Color.LightRed):setFont(VRPFont(28)):setFontSize(1)
	self.m_LicenseButton_Truck.onLeftClick = bind(self.startLession_Truck,self)

	self.m_LicenseButton_Heli = GUIButton:new(30, 185, self.m_Width-60, 35,_"Helikopter-Schein", self)
	self.m_LicenseButton_Heli:setBackgroundColor(Color.Orange):setFont(VRPFont(28)):setFontSize(1)
	self.m_LicenseButton_Heli.onLeftClick = bind(self.startLession_Heli,self)

	self.m_LicenseButton_Plane = GUIButton:new(30, 230, self.m_Width-60, 35,_"Flug-Schein", self)
	self.m_LicenseButton_Plane:setBackgroundColor(Color.LightBlue):setFont(VRPFont(28)):setFontSize(1)
	self.m_LicenseButton_Plane.onLeftClick = bind(self.startLession_Plane,self)

end

function DrivingSchoolChooseLicenseGUI:startLession_Car()
	triggerServerEvent("drivingSchoolStartLession", localPlayer, self.m_Target, "car")
	self:delete()
end

function DrivingSchoolChooseLicenseGUI:startLession_Bike()
	triggerServerEvent("drivingSchoolStartLession", localPlayer, self.m_Target, "bike")
	self:delete()
end

function DrivingSchoolChooseLicenseGUI:startLession_Truck()
	triggerServerEvent("drivingSchoolStartLession", localPlayer, self.m_Target, "truck")
	self:delete()
end

function DrivingSchoolChooseLicenseGUI:startLession_Heli()
	triggerServerEvent("drivingSchoolStartLession", localPlayer, self.m_Target, "heli")
	self:delete()
end

function DrivingSchoolChooseLicenseGUI:startLession_Plane()
	triggerServerEvent("drivingSchoolStartLession", localPlayer, self.m_Target, "plane")
	self:delete()
end
