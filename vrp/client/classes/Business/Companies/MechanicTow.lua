MechanicTow = inherit(Singleton)

function MechanicTow:constructor()
	self.m_Ped = createPed(50, 913.83, -1232.65, 16.98)
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setFrozen(true)
	self.m_Ped:setData("onClickEvent", function ()
		triggerServerEvent("mechanicOpenTakeGUI", localPlayer)
	 end)

	SpeakBubble3D:new(self.m_Ped, _"Fahrzeug freikaufen", _"Klicke mich an!")

	NonCollidingArea:new(894.25, -1188.40, 16.98, 10)
	NonCollidingArea:new(924.76, -1192.84, 16.72, 10)
end
