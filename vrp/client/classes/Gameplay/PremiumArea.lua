PremiumArea = inherit(Singleton)

function PremiumArea:constructor()
	self.m_Ped = Ped.create(23, Vector3(1263.16, -2067.58, 59.29))
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setData("onClickEvent", function ()
		triggerServerEvent("premiumOpenVehiclesList", localPlayer)
	 end)
	self.m_Ped:setFrozen(true)
	self.m_Ped.SpeakBubble = SpeakBubble3D:new(self.m_Ped, "Premium-Fahrzeuge", "Hier kannst du gekaufte Fahrzeuge abholen!", 0, 1.3)
end
