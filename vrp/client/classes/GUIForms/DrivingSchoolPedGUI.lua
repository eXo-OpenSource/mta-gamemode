-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:         client/classes/GUIForms/DrivingSchoolPedGUI.lua
-- *  PURPOSE:     DrivingSchoolPedGUI
-- *
-- ****************************************************************************
DrivingSchoolPedGUI = inherit(GUIButtonMenu)
inherit(Singleton, DrivingSchoolPedGUI)

function DrivingSchoolPedGUI:constructor(automaticTestAvailable)
	GUIButtonMenu.constructor(self, "Fahrschule")
	self:addItem(_"Theorietest", Color.LightBlue,
		function()
			triggerServerEvent("drivingSchoolStartTheory", localPlayer)
			self:delete()
		end
	)

	if automaticTestAvailable then
		self:addItem(_"Fahrprüfung (Auto)", Color.LightBlue,
			function()
				triggerServerEvent("drivingSchoolStartAutomaticTest", localPlayer, "car")
				self:delete()
			end
		)
		self:addItem(_"Fahrprüfung (Motorrad)", Color.LightBlue,
			function()
				triggerServerEvent("drivingSchoolStartAutomaticTest", localPlayer, "bike")
				self:delete()
			end
		)
	else
		self:addItem(_"Fahrlehrer rufen", Color.LightBlue,
			function()
				self:delete()

				if localPlayer.callInstructorCooldown and getTickCount() - localPlayer.callInstructorCooldown < 60000 then
					ErrorBox:new(_"Du hast die Fahrschule bereits kontaktiert!")
					return
				end

				localPlayer.callInstructorCooldown = getTickCount()
				triggerServerEvent("drivingSchoolCallInstructor", localPlayer)
			end
		)
	end
end
