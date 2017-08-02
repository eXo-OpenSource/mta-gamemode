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
end

function Queue:push(element)
	table.insert(self.m_Queue, element)
end

function Queue:pop(index)
	index = index or 1

	local element = self.m_Queue[index]
	table.remove(self.m_Queue, index)
	return element
end

function Queue:empty()
	return self:size() == 0
end

function Queue:size()
	return #self.m_Queue
end

function Queue:clear()
	self.m_Queue = {}
end
