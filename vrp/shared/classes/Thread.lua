-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Thread.lua
-- *  PURPOSE:     Skin shops singleton class
-- *
-- ****************************************************************************
Thread = inherit(Object)
Thread.Map = {}

function Thread:newPromise(func, priority, ...)
	local self = Thread:new(func, priority)
	self.ms_Promise = Promise:new(bind(self.start, self))
	return self.ms_Promise
end

function Thread:constructor(func, priority)
	Thread.Map[#Thread.Map+1] = self
	self.m_Id = #Thread.Map
	self.m_Func = func
	self.m_Priority = priority or THREAD_PRIORITY_LOW
	self.ms_Thread = false
	self.ms_Timer = false
	self.m_Yields = 0
	self.ms_StartTime = 0
end

function Thread:destructor()
	Thread.Map[self:getId()] = nil
	self.ms_Thread = nil

	if isTimer(self.ms_Timer) then
		killTimer(self.ms_Timer)
	end
end

function Thread:start(fulfill)
	self.ms_Thread = coroutine.create(self.m_Func)
	self.ms_StartTime = getTickCount()
	self:resume()

	self.ms_Timer = setTimer(
		function()
		  	if self:getStatus() == COROUTINE_STATUS_SUSPENDED then
				self:resume()
		  		self.m_Yields = self.m_Yields + 1
			elseif self:getStatus() == COROUTINE_STATUS_DEAD then
				if fulfill then fulfill() end
				delete(self)
			end
		end, self:getPriority(), 0
	)
end

function Thread:resume(...)
	return coroutine.resume(self:getThread(), ...)
end

function Thread.pause()
	return coroutine.yield()
end

function Thread:getStatus()
	return coroutine.status(self:getThread())
end

function Thread:getId()
	return self.m_Id
end

function Thread:getPriority()
	return self.m_Priority
end

function Thread:getThread()
	return self.ms_Thread
end

function Thread:setPriority(priority)
	self.m_Priority = priority
end
