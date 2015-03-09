-- ****************************************************************************
-- *
-- *  PROJECT:	 vRoleplay
-- *  FILE:      shared/classes/TimedPulse.lua
-- *  PURPOSE:	 Timed pulse class
-- *
-- ****************************************************************************
TimedPulse = inherit(Object)

function TimedPulse:constructor(time)
	self.m_Timer = setTimer(bind(self.doPulse, self), time, 0)
	self.m_Handlers = {}
end

function TimedPulse:destructor()
	if self.m_Timer and isTimer(self.m_Timer) then
		killTimer(self.m_Timer)
	end
end

function TimedPulse:doPulse()
	for k, v in ipairs(self.m_Handlers) do
		v()
	end
end

function TimedPulse:registerHandler(callbackFunc)
	table.insert(self.m_Handlers, callbackFunc)
end

function TimedPulse:removeHandler(callbackFunc)
	local idx = table.find(self.m_Handlers, callbackFunc)
	if not idx then
		return false
	end
	
	table.remove(self.m_Handlers, idx)
	return true
end
