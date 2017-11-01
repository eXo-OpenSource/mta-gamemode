-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplayer/Ware/minigames/WareSprint.lua
-- *  PURPOSE:     WareSprint
-- *
-- ****************************************************************************
WareSprint = inherit(Singleton)

addRemoteEvents{"setWareSprintListenerOn","setWareSprintListenerOff"}
function WareSprint:constructor()
	addEventHandler("setWareSprintListenerOn", localPlayer, bind(self.Event_ListenerOn,self))
	addEventHandler("setWareSprintListenerOff", localPlayer, bind(self.Event_ListenerOff,self))
end

function WareSprint:Event_ListenerOn()
	self.m_Form = WareSprintProgress:new()
end

function WareSprint:Event_ListenerOff()
	if self.m_Form then delete(self.m_Form) end
end

WareSprintProgress = inherit(GUIForm)
inherit(Singleton, WareSprintForm)

function WareSprintProgress:constructor()
	GUIForm.constructor(self, screenWidth/2-100, screenHeight*0.6, 200, 30, false)
	showCursor(true)
	self.m_Progress = GUIProgressBar:new(0, 0, self.m_Width, self.m_Height, self)

	self.m_KeyBind = bind(self.onClientKey, self)
	self.m_TimerBind = bind(self.onTimerExecute, self)

	self.m_ProgressTimer = setTimer(self.m_TimerBind, 250, 0)
	addEventHandler("onClientKey", root, self.m_KeyBind)
end

function WareSprintProgress:onClientKey(button, state)
	if button == "space" and state == true then
		local prog = self.m_Progress:getProgress()+2
		if prog >= 100 then
			prog = 100
			triggerServerEvent("Ware:clientSprintFinished", localPlayer, i)
			if isTimer(self.m_ProgressTimer) then killTimer(self.m_ProgressTimer) end
		end
		setPedAnimation(localPlayer, 'GYMNASIUM','gym_tread_sprint', 200, false)

		self.m_Progress:setProgress(prog)
	end
end

function WareSprintProgress:onTimerExecute()
	local prog = self.m_Progress:getProgress()-1
	if prog < 0 then prog = 0 end
	self.m_Progress:setProgress(prog)
end

function WareSprintProgress:destructor()
	GUIForm.destructor(self)
	if isTimer(self.m_ProgressTimer) then killTimer(self.m_ProgressTimer) end
	removeEventHandler("onClientKey", root, self.m_KeyBind)
	setPedAnimation(localPlayer)
end
