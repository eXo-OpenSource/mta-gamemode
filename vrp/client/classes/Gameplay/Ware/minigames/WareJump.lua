-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareJump.lua
-- *  PURPOSE:     WareJump
-- *
-- ****************************************************************************
WareJump = inherit(Singleton)

addRemoteEvents{"setWareJumpListenerOn","setWareJumpListenerOff"}
function WareJump:constructor()
	addEventHandler("setWareJumpListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareJumpListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
	self.m_RenderBind = bind(self.Event_Render,self)
end

function WareJump:Event_ListenerOn()
	self.m_HasJumped = false
	removeEventHandler("onClientRender", root, self.m_RenderBind)
	addEventHandler("onClientRender", root, self.m_RenderBind)
end

function WareJump:Event_ListenerOff()
	removeEventHandler("onClientRender", root, self.m_RenderBind)
end

function WareJump:Event_Render()
	if not self.m_HasJumped then 
		if getPedMoveState(localPlayer) == "jump" then 
			removeEventHandler("onClientRender", root, self.m_RenderBind)
			triggerServerEvent("Ware:clientJumped", localPlayer)
			self.m_HasJumped = true
		end
	end
end