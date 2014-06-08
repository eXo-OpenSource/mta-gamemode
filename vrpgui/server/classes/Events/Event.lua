-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Event.lua
-- *  PURPOSE:     Event base class
-- *
-- ****************************************************************************
Event = inherit(Object)

function Event:virtual_constructor(Id)
	self.m_Id = Id
	self.m_Players = {}
	self.m_Ranks = {}
end

function Event:join(player)
	self:sendMessage("%s ist dem Event beigetreten!", 255, 255, 0, getPlayerName(player))
	table.insert(self.m_Players, player)
	
	if self.onJoin then self:onJoin(player) end
end

function Event:quit(player)
	local idx = table.find(self.m_Players, player)
	if not idx then
		return false
	end
	
	table.remove(self.m_Players, idx)
end

function Event:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self.m_Players) do
		player:sendMessage("[EVENT] ".._(text, player, ...), r, g, b)
	end
end

function Event:openGUI(player)
	player:triggerEvent("eventGUI", self.m_Id)
end

function Event:isMember(player)
	return table.find(self.m_Players, player) ~= nil
end

Event.start = pure_virtual
Event.getName = pure_virtual