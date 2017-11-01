-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareKeepMove.lua
-- *  PURPOSE:     WareKeepMove
-- *
-- ****************************************************************************
WareKeepMove = inherit(Singleton)

addRemoteEvents{"setWareKeepMoveListenerOn","setWareKeepMoveListenerOff"}
function WareKeepMove:constructor()
	addEventHandler("setWareKeepMoveListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareKeepMoveListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
	self.m_RenderBind = bind(self.Event_Render,self)
end

function WareKeepMove:Event_ListenerOn()
	self.m_HasStopped = false
	self.m_TickCount = getTickCount()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	addEventHandler("onClientRender", root, self.m_RenderBind)
end

function WareKeepMove:Event_ListenerOff()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	self.m_HasStopped = true
end

function WareKeepMove:Event_Render()
	local now = getTickCount()
	if not self.m_HasStopped and now - self.m_TickCount >= 500 then 
		if getPedMoveState(localPlayer) == "stand" then 
			removeEventHandler("onClientRender", root, self.m_RenderBind)
			triggerServerEvent("Ware:clientStoppedMove", localPlayer)
			self.m_HasStopped = true
			playSound("files/audio/Ware/fail.mp3")
		end
	end
end