-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareKeepMove.lua
-- *  PURPOSE:     WareKeepMove class
-- *
-- ****************************************************************************
WareKeepMove = inherit(Object)
WareKeepMove.modeDesc = "Bleib in Bewegung!"
WareKeepMove.timeScale = 0.4

addRemoteEvents{"Ware:clientStoppedMove"}
function WareKeepMove:constructor( super )
	self.m_Super = super
	for key, player in ipairs(self.m_Super.m_Players) do 
		player:setData("Ware:isMoving", true)
		player:triggerEvent("setWareKeepMoveListenerOn")
	end
	self.m_EventOnStopMove = bind(self.Event_onStopMove, self)
	addEventHandler("Ware:clientStoppedMove", root, self.m_EventOnStopMove)
end

function WareKeepMove:Event_onStopMove() 
	if source.bInWare then 
		if source.bInWare == self.m_Super then 
			source:setData("Ware:isMoving",false)
		end
	end
end

function WareKeepMove:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:triggerEvent("setWareKeepMoveListenerOff")
		if p:getData("Ware:isMoving") then 
			self.m_Super:addPlayerToWinners( p ) 
		end
	end
	removeEventHandler("Ware:clientStoppedMove", root, self.m_EventOnStopMove)
end