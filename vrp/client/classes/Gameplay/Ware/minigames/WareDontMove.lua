-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareDontMove.lua
-- *  PURPOSE:     WareDontMove
-- *
-- ****************************************************************************
WareDontMove = inherit(Singleton)

addRemoteEvents{"setWareDontMoveListenerOn","setWareDontMoveListenerOff"}
function WareDontMove:constructor()
	addEventHandler("setWareDontMoveListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareDontMoveListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
	self.m_RenderBind = bind(self.Event_Render,self)
end

function WareDontMove:Event_ListenerOn()
	self.m_HasMoved = false
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	addEventHandler("onClientRender", root, self.m_RenderBind)
end

function WareDontMove:Event_ListenerOff()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	self.m_HasMoved = true
end

function WareDontMove:Event_Render()
	if not self.m_HasStopped then 
		if getPedMoveState(localPlayer) ~= "stand" then 
			removeEventHandler("onClientRender", root, self.m_RenderBind)
			triggerServerEvent("Ware:clientMoved", localPlayer)
			self.m_HasMoved = true
			playSound("files/audio/Ware/fail.mp3")
		end
	end
end