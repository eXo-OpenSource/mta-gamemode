-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareDontMove.lua
-- *  PURPOSE:     WareDontMove class
-- *
-- ****************************************************************************
WareDontMove = inherit(Object)
WareDontMove.modeDesc = "Beweg dich nicht!"
WareDontMove.timeScale = 0.4

addRemoteEvents{"Ware:clientMoved"}
function WareDontMove:constructor( super )
	self.m_Super = super
	for key, player in ipairs(self.m_Super.m_Players) do 
		player:setData("Ware:isStanding", true)
		player:triggerEvent("setWareDontMoveListenerOn")
	end
	self.m_EventOnMove = bind(self.Event_onMove, self)
	addEventHandler("Ware:clientMoved", root, self.m_EventOnMove)
end

function WareDontMove:Event_onMove() 
	if source.bInWare then 
		if source.bInWare == self.m_Super then 
			source:setData("Ware:isStanding",false)
		end
	end
end

function WareDontMove:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:triggerEvent("setWareDontMoveListenerOff")
		if p:getData("Ware:isStanding") then 
			self.m_Super:addPlayerToWinners( p ) 
		end
	end
	removeEventHandler("Ware:clientMoved", root, self.m_EventOnMove)
end