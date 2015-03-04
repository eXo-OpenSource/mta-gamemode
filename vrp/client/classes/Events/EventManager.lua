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
	self.m_RegisteredEvents = {StreetRaceEvent, LasertagEvent, DMRaceEvent}


	addEventHandler("eventStart", root,
		function(eventType, Id, players)
			local eventClass = self.m_RegisteredEvents[eventType]
			if not eventClass then return end

			local event = eventClass:new(Id, players)
			event:start()
		end
	)
end
