-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolChooseLicenseGUI.lua
-- *  PURPOSE:     House GUI class
-- *
-- ****************************************************************************
DrivingSchoolChooseLicenseGUI = inherit(GUIButtonMenu)

function DrivingSchoolChooseLicenseGUI:constructor(target)
	self.m_Target = target
	GUIButtonMenu.constructor(self, "Führerschein auswählen")

	self:addItem(_"Auto-Führerschein",Color.Green ,
		function()
			triggerServerEvent("drivingSchoolstartLessionQuestion", localPlayer, self.m_Target, "car")
			self:delete()
		end
	)
	self:addItem(_"Motorradschein",Color.Blue ,
		function()
			triggerServerEvent("drivingSchoolstartLessionQuestion", localPlayer, self.m_Target, "bike")
			self:delete()
		end
	)
	self:addItem(_"LKW-Schein",Color.LightRed ,
		function()
			triggerServerEvent("drivingSchoolstartLessionQuestion", localPlayer, self.m_Target, "truck")
			self:delete()
		end
	)
	self:addItem(_"Helikopter-Schein",Color.Orange ,
		function()
			triggerServerEvent("drivingSchoolstartLessionQuestion", localPlayer, self.m_Target, "heli")
			self:delete()
		end
	)
	self:addItem(_"Flug-Schein",Color.LightBlue ,
		function()
			triggerServerEvent("drivingSchoolstartLessionQuestion", localPlayer, self.m_Target, "plane")
			self:delete()
		end
	)
end
