-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareDuck.lua
-- *  PURPOSE:     WareDuck
-- *
-- ****************************************************************************
WareDuck = inherit(Singleton)

addRemoteEvents{"setWareDuckListenerOn","setWareDuckListenerOff"}
function WareDuck:constructor()
	addEventHandler("setWareDuckListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareDuckListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
	self.m_RenderBind = bind(self.Event_Render,self)
end

function WareDuck:Event_ListenerOn()
	self.m_HasDucked = false
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	addEventHandler("onClientRender", root, self.m_RenderBind)
end

function WareDuck:Event_ListenerOff()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
end

function WareDuck:Event_Render()
	if not self.m_HasDucked then 
		if getPedMoveState(localPlayer) == "crouch" then 
			removeEventHandler("onClientRender", root, self.m_RenderBind)
			triggerServerEvent("Ware:clientDucked", localPlayer)
			self.m_HasDucked = true
		end
	end
end