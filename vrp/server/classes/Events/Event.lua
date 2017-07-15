-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Event.lua
-- *  PURPOSE:     Event base class
-- *
-- ****************************************************************************
Event = inherit(Object)
local EVENT_RANGE = 40 -- Radius

function Event:virtual_constructor(Id)
	self.m_Id = Id
	self.m_Players = {}
	self.m_Ranks = {}
	self.m_Started = false

	self.m_StartTime = 0

	local positions = self:getPositions()
	local position = positions[math.random(1, #positions)]
	self.m_EventBlip = Blip:new("Kart.png", position.x, position.y)

	-- Create the start marker
	self.m_StartMarker = Marker(position, "checkpoint", 10, 255, 0, 0, 100)
	addEventHandler("onMarkerHit", self.m_StartMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				if not self:isMember(hitElement) then
					self:openGUI(hitElement)
				else
					hitElement:sendWarning(_("Du nimmst bereits an diesem Event teil!", hitElement))
				end
			end
		end
	)

	self.m_EventRangeShape = createColSphere(position, EVENT_RANGE)
	addEventHandler("onColShapeLeave", self.m_EventRangeShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				if self:isMember(hitElement) then
					-- Quit the player if he leaves the zone
					self:quit(hitElement, true)

					hitElement:sendWarning(_("Du hast die Eventzone verlassen und nimmst deshalb nicht mehr am Event teil!", hitElement))
					hitElement:triggerEvent("CountdownStop", "Event")
				end
			end
		end
	)
end

function Event:virtual_destructor()
	-- Quit all remaining players
	for k, player in pairs(self.m_Players) do
		self:quit(player)
	end

	-- Unlink from event manager
	EventManager:getSingleton():unlinkEvent(self)

	if self.m_EventBlip then
		delete(self.m_EventBlip)
	end
	if isElement(self.m_StartMarker) then
		self.m_StartMarker:destroy()
	end
	if isElement(self.m_EventRangeShape) then
		self.m_EventRangeShape:destroy()
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

function Event:quit(player, withoutRespawn)
	local idx = table.find(self.m_Players, player)
	if not idx then
		return false
	end

	table.remove(self.m_Players, idx)

	if self.onQuit then	self:onQuit(player) end

	if self:hasExit() and not withoutRespawn then
		player:respawn(self:getExitPosition())
		return true
	end
end

function Event:start()
	if #self.m_Players == 0 then
		delete(self)
		return
	end
	if #self.m_Players <= 2 then
		for k, player in pairs(self.m_Players) do
			player:sendShortMessage(_("Das Event wurde wegen zu weniger Spieler abgesagt!", player))
		end

		delete(self)
		return
	end

	self.m_StartMarker:destroy()
	self.m_EventRangeShape:destroy()
	delete(self.m_EventBlip)
	self.m_EventBlip = nil

	self.m_Started = true
	triggerClientEvent(self.m_Players, "eventStart", root, self.m_EventType, self.m_Id, self.m_Players)
	self:onStart()
end

function Event:sendMessage(text, r, g, b, ...)
	for k, player in pairs(self.m_Players) do
		player:sendMessage("[EVENT] ".._(text, player, ...), r, g, b)
	end
end

function Event:openGUI(player)
	player:triggerEvent("eventGUI", self.m_Id, self:getName(player), self:getDescription(player))
end

function Event:isMember(player)
	return table.find(self.m_Players, player) ~= nil
end

function Event:getPlayers()
	return self.m_Players
end

function Event:hasExit()
	return self.getExitPosition ~= nil
end

function Event:teleportToExit(player)
	if not self:hasExit() then
		return false
	end

	player:setPosition(self:getExitPosition() + Vector3(math.random(-5, 5), math.random(-5, 5), 0))
	return true
end

function Event:hasStarted()
	return self.m_Started
end

function Event:setStartTime(timestamp)
	self.m_StartTime = timestamp
end

function Event:getStartTime()
	return self.m_StartTime
end

Event.getName = pure_virtual
Event.getDescription = pure_virtual
Event.getPositions = pure_virtual
