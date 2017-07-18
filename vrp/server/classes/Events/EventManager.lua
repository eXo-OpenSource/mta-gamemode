-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Event/EventManager.lua
-- *  PURPOSE:     Event manager class
-- *
-- ****************************************************************************
EventManager = inherit(Singleton)
local MAX_PLAYERS_PER_EVENT = 32
addEvent("eventJoin", true)

function EventManager:constructor()
	self.m_RunningEvents = {}
	self.m_RegisteredEvents = {}
	self.m_EventIdCounter = 0 -- We need a unique id which works for a long time (to avoid collisions if somebody forgets to close the GUI)

	-- Add events (do it on the client as well)
	self:addEvent(StreetRaceEvent)
	--self:addEvent(DMRaceEvent)

	-- Start timer that opens every 30min a random event
	--setTimer(bind(self.openRandomEvent, self), 30*60*1000, 0)

	addEventHandler("eventJoin", root, bind(self.Event_eventJoin, self))
	addEventHandler("onPlayerQuit", root, bind(self.Event_playerQuit, self))

	-- Register hooks
	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			local event = self:getPlayerEvent(player)
			if not event or not event:hasStarted() then
				return
			end

			if event.onPlayerWasted then event:onPlayerWasted(player) end

			if event:hasExit() then
				return true
			end
		end
	)

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

function EventManager:unlinkEvent(event)
	self.m_RunningEvents[event:getId()] = nil
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

	for k, player in pairs(getElementsByType("player")) do
		player:sendShortMessage(_("In 5min startet ein '%s'! Begib dich zum Reifen-Blip (bzw. zur Diskette), um teilzunehmen.", player, event:getName()), "San News - Event", {0, 32, 63}, 15000)
	end

	-- Start the event in 5min
	local startTime = getRealTime().timestamp + 5*60
	event:setStartTime(startTime)
	setTimer(bind(event.start, event), 5*60*1000, 1)
end

function EventManager:isPlayerInEvent(player, eventClass)
	for k, event in pairs(self.m_RunningEvents) do
		if event:hasStarted() then
			if event:isMember(player) then
				if instanceof(event, eventClass) then
					return true
				end
				return false
			end
		end
	end
	return false
end

function EventManager:getPlayerEvent(player)
	for k, event in pairs(self.m_RunningEvents) do
		if event:isMember(player) then
			return event
		end
	end
	return nil
end

function EventManager:addEvent(eventClass)
	local typeId = #self.m_RegisteredEvents + 1
	self.m_RegisteredEvents[typeId] = eventClass
	eventClass.m_EventType = typeId
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

	if #event:getPlayers() >= MAX_PLAYERS_PER_EVENT then
		client:sendError(_("Dieses Event ist schon voll!", client))
		return
	end

	event:join(client)
	client:sendShortMessage(_("Du hast dich erfolgreich für dieses Event eingetragen. Bleibe in der Nähe!", client))
	client:triggerEvent("Countdown", event:getStartTime() - getRealTime().timestamp, "Event")

end

function EventManager:Event_playerQuit()
	-- onPlayerQuit triggers __before__ Player:destructor (which is called by onElementDestroy @ classlib)
	local event = self:getPlayerEvent(source)
	if not event or not event:hasStarted() or not event:hasExit() then
		return
	end

	self:teleportToExit(source)
end
