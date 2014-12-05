-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Event/EventManager.lua
-- *  PURPOSE:     Event manager class
-- *
-- ****************************************************************************
EventManager = inherit(Singleton)

function EventManager:constructor()
	self.m_RunningEvents = {}
	self.m_RegisteredEvents = {StreetRaceEvent, LasertagEvent} -- Add it on the client as well
	self.m_EventIdCounter = 0 -- We need a unique id which works a long time (to avoid collisions if somebody forgets to close the GUI)
	
	-- Start timer that opens every 30min a random event
	setTimer(bind(self.openRandomEvent, self), 30*60*1000, 0)
	
	addEvent("eventJoin", true)
	addEventHandler("eventJoin", root, bind(EventManager.Event_eventJoin, self))
	
	if DEBUG then
		addCommandHandler("startevent",
			function(player, cmd, event)
				if not tonumber(event) then
					self:openRandomEvent()
				else
					local eventClass = self.m_RegisteredEvents[tonumber(event)]
					if eventClass then
						self:openEvent(eventClass)
					end
				end
			end
		)
	end
end

function EventManager:openRandomEvent()
	-- Get a random event
	local eventClass = self.m_RegisteredEvents[math.random(1, #self.m_RegisteredEvents)]
	
	self:openEvent(eventClass)
end

function EventManager:openEvent(eventClass)
	-- Create the event
	self.m_EventIdCounter = self.m_EventIdCounter + 1
	local event = eventClass:new(self.m_EventIdCounter)
	self.m_RunningEvents[self.m_EventIdCounter] = event
	
	for k, player in ipairs(getElementsByType("player")) do
		player:sendMessage(_("In 5min startet das Event '%s'! Begib dich zum Reifen-Blip, um daran teilzunehmen", player, event:getName()), 255, 255, 0)
	end
	
	-- Start the event in 5min
	setTimer(function(e) e:start() end, 0.5*60*1000, 1, event)
end

function EventManager:Event_eventJoin(eventId)
	if not eventId then
		return
	end

	local event = self.m_RunningEvents[eventId]
	if not event then
		client:sendError(_"Dieses Event existiert nicht mehr!")
		return
	end
	
	event:join(client)
	client:sendShortMessage(_("Du hast dich erfolgreich für dieses Event eingetragen", client))
end
