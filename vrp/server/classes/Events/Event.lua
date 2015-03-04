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

	local positions = self:getPositions()
	local position = positions[math.random(1, #positions)]
	self.m_EventBlip = Blip:new("Wheel.png", position.x, position.y)

	-- Create the start marker
	self.m_StartMarker = Marker(position, "checkpoint", 10, 255, 0, 0, 100)
	addEventHandler("onMarkerHit", self.m_StartMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				if not self:isMember(hitElement) then
					self:openGUI(hitElement)
				else
					hitElement:sendWarning(_("Du nimmst bereits an diesem Event Teil!", hitElement))
				end
			end
		end
	)
end

function Event:virtual_destructor()
	-- Unlink from event manager
	EventManager:getSingleton():unlinkEvent(self)

	delete(self.m_EventBlip)
	if isElement(self.m_StartMarker) then
		destroyElement(self.m_StartMarker)
	end
end

function Event:getId()
	return self.m_Id
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

	if self.onQuit then	self:onQuit(player) end
end

function Event:start()
	if #self.m_Players == 0 then
		delete(self)
		return
	end

	triggerClientEvent(self.m_Players, "eventStart", root, self.m_Id, self.m_Players)
	self:onStart()
end

function Event:sendMessage(text, r, g, b, ...)
	for k, player in pairs(self.m_Players) do
		player:sendMessage("[EVENT] ".._(text, player, ...), r, g, b)
	end
end

function Event:openGUI(player)
	player:triggerEvent("eventGUI", self.m_Id)
end

function Event:isMember(player)
	return table.find(self.m_Players, player) ~= nil
end

function Event:getPlayers()
	return self.m_Players
end

Event.getName = pure_virtual
Event.onStart = pure_virtual
Event.getPositions = pure_virtual
