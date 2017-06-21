-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Queue.lua
-- *  PURPOSE:     Queues
-- *
-- ****************************************************************************
Queue = inherit(Object)

function Queue:constructor()
	self.m_Queue = {}
	self.m_Locked = false
end

function Queue:push_back(element)
	table.insert(self.m_Queue, element)
end

function Queue:pop_back(index)
	local element = self.m_Queue[index]
	table.remove(self.m_Queue, index)
	return element
end

function Queue:empty()
	return self:size() == 0
end

function Queue:lock()
	self.m_Locked = true
end

function Queue:unlock()
	self.m_Locked = false
end

function Queue:locked()
	return self.m_Locked
end

function Queue:size()
	return #self.m_Queue
end
