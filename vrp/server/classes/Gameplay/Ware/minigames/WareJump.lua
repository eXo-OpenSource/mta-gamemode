-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareJump.lua
-- *  PURPOSE:     WareJump class
-- *
-- ****************************************************************************
WareJump = inherit(Object)
WareJump.modeDesc = "Springe!"
WareJump.timeScale = 0.4

addRemoteEvents{"Ware:clientJumped"}
function WareJump:constructor( super )
	self.m_Super = super
	for key, player in ipairs(self.m_Super.m_Players) do 
		player:triggerEvent("setWareJumpListenerOn")
	end
	self.m_EventOnJump = bind(self.Event_onJump, self)
	addEventHandler("Ware:clientJumped", root, self.m_EventOnJump)
end

function WareJump:Event_onJump() 
	if source.bInWare then 
		if source.bInWare == self.m_Super then 
			self.m_Super:addPlayerToWinners( source ) 
		end
	end
end

function WareJump:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:triggerEvent("setWareJumpListenerOff")
	end
	removeEventHandler("Ware:clientJumped", root, self.m_EventOnJump)
end