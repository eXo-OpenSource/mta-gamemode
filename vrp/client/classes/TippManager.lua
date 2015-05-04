-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HelpTextManager.lua
-- *  PURPOSE:     Responsible for managing random tipps
-- *
-- ****************************************************************************

TippManager = inherit(Singleton)

function TippManager:constructor ()
	self.m_LastTippId = core:get("Tipps", "lastTipp", 0)
	self.m_IntervallTime = 2 * 60 * 1000
	self.m_Tipps = Tipps;
	self.m_TimedPulse = TimedPulse:new(self.m_IntervallTime)
	self.m_TimedPulse:registerHandler(bind(self.createTipp, self))

	if self.m_LastTippId > #self.m_Tipps then
		delete(self)
	end
end

function TippManager:createTipp ()
	if not localPlayer.m_showTipps then
		delete(self)
		return
	end

	self.m_LastTippId = self.m_LastTippId + 1
	if self.m_Tipps[self.m_LastTippId] then
		core:set("Tipps", "lastTipp", self.m_LastTippId)

		ShortMessage:new(("Tipp: %s\n\n%s"):format(string.len(self.m_Tipps[self.m_LastTippId][1]) > 1 and self.m_Tipps[self.m_LastTippId][1].."?" or "", self.m_Tipps[self.m_LastTippId][2]), 12000)
	else
		delete(self)
	end
end

function TippManager:destructor ()
	if self.m_TimedPulse then
		delete(self.m_TimedPulse)
	end
end
