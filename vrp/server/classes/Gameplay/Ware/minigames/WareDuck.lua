-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareDuck.lua
-- *  PURPOSE:     WareDuck class
-- *
-- ****************************************************************************
WareDuck = inherit(Object)
WareDuck.modeDesc = "Duck dich!"
WareDuck.timeScale = 0.4

addRemoteEvents{"Ware:clientDucked"}
function WareDuck:constructor( super )
	self.m_Super = super
	for key, player in ipairs(self.m_Super.m_Players) do 
		player:triggerEvent("setWareDuckListenerOn")
	end
	self.m_EventOnDuck = bind(self.Event_onDuck, self)
	addEventHandler("Ware:clientDucked", root, self.m_EventOnDuck)
end

function WareDuck:Event_onDuck() 
	if source.bInWare then 
		if source.bInWare == self.m_Super then 
			self.m_Super:addPlayerToWinners( source ) 
		end
	end
end

function WareDuck:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:triggerEvent("setWareDuckListenerOff")
	end
	removeEventHandler("Ware:clientDucked", root, self.m_EventOnDuck)
end