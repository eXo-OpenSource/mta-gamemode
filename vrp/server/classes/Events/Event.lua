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

function Event:start()
	triggerClientEvent(self.m_Players, "eventStart", root, self.m_Id, self.m_Players)

	if self.onStart() then
		self:onStart()
	end
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

Event.getName = pure_virtual
Event.onStart = pure_virtual
Event.getPositions = pure_virtual