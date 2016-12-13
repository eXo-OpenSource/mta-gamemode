-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Stack.lua
-- *  PURPOSE:     Simple Stack class
-- *
-- ****************************************************************************
Stack = inherit(Object)

function Stack:constructor()
	self.m_Elements = {}
end

function Stack:push(element)
	table.insert(self.m_Elements, element)
end

function Stack:pop()
	local highestIndex = #self.m_Elements
	local element = self.m_Elements[highestIndex]
	table.remove(self.m_Elements, highestIndex)
	return element
end

function Stack:top()
	return self.m_Elements[#self.m_Elements]
end

function Stack:empty()
	return #self.m_Elements == 0
end

function Stack:clear()
	self.m_Elements = {}
end
