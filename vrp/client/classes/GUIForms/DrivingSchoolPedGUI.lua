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
	self:addItem(_"Theorietest", Color.Accent,
		function()
			triggerServerEvent("drivingSchoolStartTheory", localPlayer)
			self:delete()
		end
	)

	if automaticTestAvailable then
		self:addItem(_"Fahrprüfung (Auto)", Color.Accent,
			function()
				triggerServerEvent("drivingSchoolStartAutomaticTest", localPlayer, "car")
				self:delete()
			end
		)
		self:addItem(_"Fahrprüfung (Motorrad)", Color.Accent,
			function()
				triggerServerEvent("drivingSchoolStartAutomaticTest", localPlayer, "bike")
				self:delete()
			end
		)
	else
		self:addItem(_"Fahrlehrer rufen", Color.Accent,
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

	self:addItem(_"STVO-Punkte abbauen", Color.Accent,
		function()
			self:delete()
			ReduceSTVOBox:new(player, 1, 20, _"STVO-Punkte abbauen", function(category, amount) triggerServerEvent("drivingSchoolReduceSTVO", localPlayer, category, amount) end)
		end
	)
end


ReduceSTVOBox = inherit(GUIForm)
inherit(Singleton, ReduceSTVOBox)

addRemoteEvents{"hideDrivingSchoolReduceSTVO"}

function ReduceSTVOBox:constructor(player, min, max, title, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.4, screenHeight*0.2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.24, self.m_Width*0.5, self.m_Height*0.17, _"Kategorie:", self.m_Window)
	self.m_STVOCategories = GUIChanger:new(self.m_Width*0.5, self.m_Height*0.24, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_STVOCategories:addItem(_"Auto")
	self.m_STVOCategories:addItem(_"Motorrad")
	self.m_STVOCategories:addItem(_"Lastkraftwagen")
	self.m_STVOCategories:addItem(_"Pilot")
	self.m_STVOCategories.onChange = function (text, index)
		local category

		if index == 1 then
			category = "Driving"
		elseif index == 2 then
			category = "Bike"
		elseif index == 3 then
			category = "Truck"
		elseif index == 4 then
			category = "Pilot"
		end

		self.m_CurrentSTVO:setText(_("aktuell %s Punkte", localPlayer:getSTVO(category)))
	end

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.46, self.m_Width*0.5, self.m_Height*0.17, _"Anzahl:", self.m_Window)
	self.m_Changer = GUIChanger:new(self.m_Width*0.5, self.m_Height*0.46, self.m_Width*0.2, self.m_Height*0.2, self.m_Window)
	for i = min, max do
		self.m_Changer:addItem(tostring(i))
	end
	self.m_CurrentSTVO = GUILabel:new(self.m_Width*0.73, self.m_Height*0.47, self.m_Width*0.5, self.m_Height*0.17, _("aktuell %s Punkte", localPlayer:getSTVO("Driving")), self.m_Window)

	self.m_SubmitButton = GUIButton:new(self.m_Width*0.5, self.m_Height*0.75, self.m_Width*0.45, self.m_Height*0.2, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_SubmitButton.onLeftClick =
	function()
		local categoryName, categoryIndex = self.m_STVOCategories:getIndex()
		local category

		if categoryIndex == 1 then
			category = "Driving"
		elseif categoryIndex == 2 then
			category = "Bike"
		elseif categoryIndex == 3 then
			category = "Truck"
		elseif categoryIndex == 4 then
			category = "Pilot"
		end

		callback(category, self.m_Changer:getIndex())
	end
end

addEventHandler("hideDrivingSchoolReduceSTVO", root,
	function()
		ReduceSTVOBox:getSingleton():delete()
	end
)
