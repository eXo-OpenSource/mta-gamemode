MechanicTow = inherit(Singleton)

function MechanicTow:constructor()
	self.m_Ped = createPed(50, 913.83, -1232.65, 16.98)
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setFrozen(true)
	self.m_Ped:setData("onClickEvent",
		function()
			local questionBox = QuestionBox:new("Welches Fahrzeug möchtest du freikaufen?",
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "permanentVehicle")
				end,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "groupVehicle")
				end
			)

			questionBox:setButtonText("Privat", "Firma/Gruppe")
		end
	)

	SpeakBubble3D:new(self.m_Ped, _"Fahrzeug freikaufen", _"Klicke mich an!")

	NonCollidingArea:new(894.25, -1188.40, 16.98, 10)
	NonCollidingArea:new(924.76, -1192.84, 16.72, 10)
	NonCollidingArea:new(908.032, -1259.658, 15, 15)
	NonCollidingArea:new(864.61, -1272.77, 15, 15)

	self.m_BugPed = createPed(50, 885.95, -1176.06, 16.98, 270)
	setElementData(self.m_BugPed, "clickable", true)
	self.m_BugPed:setData("BugChecker", true)
	self.m_BugPed:setData("NPC:Immortal", true)
	self.m_BugPed:setFrozen(true)

	SpeakBubble3D:new(self.m_BugPed, _"Ich kann Wanzen aufspüren", _"Klicke mich an!")
end
