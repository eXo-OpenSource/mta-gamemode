-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Event/EventManager.lua
-- *  PURPOSE:     Event manager class
-- *
-- ****************************************************************************
EventManager = inherit(Singleton)
addEvent("eventStart", true)

function EventManager:constructor()
	self.m_RegisteredEvents = {}

	-- Add events
	self:addEvent(StreetRaceEvent)
	self:addEvent(DMRaceEvent)

	addEventHandler("eventStart", root,
		function(eventType, Id, players)
			local eventClass = self.m_RegisteredEvents[eventType]
			if not eventClass then return end

			local event = eventClass:new(Id, players)
			event:start()
		end
	)
end

function EventManager:addEvent(eventClass)
	eventClass = eventClass or false

	local typeId = #self.m_RegisteredEvents + 1
	self.m_RegisteredEvents[typeId] = eventClass

	-- We do not require a clientside class (but add something to get consecutive IDs)
	if eventClass then
		eventClass.m_EventType = typeId
	end
end
