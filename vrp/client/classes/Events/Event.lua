-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Event.lua
-- *  PURPOSE:     Event base class
-- *
-- ****************************************************************************
Event = inherit(Object)

function Event:virtual_constructor(Id, players)
	self.m_Id = Id
	self.m_Players = players
end

function Event:isMember(player)
	return table.find(self.m_Players, player) ~= nil
end

function Event:start()
	if self.onStart then
		self:onStart()
	end
end
