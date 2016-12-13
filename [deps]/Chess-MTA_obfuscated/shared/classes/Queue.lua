-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Queue.lua
-- *  PURPOSE:     Queues
-- *
-- ****************************************************************************
Queue = inherit(Object)

function Queue:constructor(interval, refillFunc, callbackFunc)
	self.m_Interval = interval
	self.m_RefillFunc = refillFunc
	self.m_CallbackFunc = callbackFunc
	self.m_Queue = refillFunc()
	
	self:checkState()
end

function Queue:processNext()
	if #self.m_Queue == 0 then
		self.m_Queue = self.m_RefillFunc()
	end

	local currentInstance = self:pop_back(1)
	if currentInstance then
		self.m_CallbackFunc(currentInstance)
	end
	
	self:checkState()
end

function Queue:checkState()
	-- Restart the timer if necessary
	setTimer(bind(Queue.processNext, self), #self.m_Queue > 0 and self.m_Interval/#self.m_Queue or self.m_Interval, 1)
end

function Queue:push_back(callback)
	table.insert(self.m_Queue, callback)
	
	self:checkState()
end

function Queue:pop_back(index)
	local temp = self.m_Queue[index]
	table.remove(self.m_Queue, index)
	return temp
end
