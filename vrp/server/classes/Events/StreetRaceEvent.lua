-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/StreetRaceEvent.lua
-- *  PURPOSE:     Streetrace event class
-- *
-- ****************************************************************************
StreetRaceEvent = inherit(Event)

function StreetRaceEvent:constructor()
	-- Find a random start position
	local x, y, z, randomIndex = self.getRandomPosition()
	self.m_StartIndex = randomIndex
	
	self.m_EventBlip = Blip:new("Wheel.png", x, y)
	
	-- Create the start marker
	self.m_StartMarker = createMarker(x, y, z, "checkpoint", 10, 255, 0, 0, 100)
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

function StreetRaceEvent:start()
	-- Jusonex: A better place for the following might be the Event class --> we have to write something like "onStart" or - as bad alternative - we can call Event.start here
	if #self.m_Players == 0 then
		delete(self)
		return false
	end
	
	-- Start the countdown
	for k, player in ipairs(self.m_Players) do
		player:triggerEvent("countdownStart", 3)
	end
	
	setTimer(
		function()
			destroyElement(self.m_StartMarker)

			-- Find random position which is not equal to the start position
			local x, y, z, randomIndex
			repeat
				x, y, z, randomIndex = self.getRandomPosition()
			until randomIndex ~= self.m_StartIndex
			
			self.m_DestinationBlip = Blip:new("Waypoint.png", x, y)
			self.m_ColShape = createColSphere(x, y, z, 20)
			addEventHandler("onColShapeHit", self.m_ColShape, bind(self.colShapeHit, self))
			
			-- Start the GPS for each player
			for k, player in ipairs(self.m_Players) do
				player:startNavigationTo(x, y, z)
			end
			
			-- Tell player that we started the event
			self:sendMessage("Das Event wurde gestartet!", 255, 255, 0)
			
			-- Set time out after 10min
			self.m_TimeoutTimer = setTimer(function() delete(self) end, 10*60*1000, 1)
		end,
		3000,
		1
	)
end

function StreetRaceEvent:destructor()
	if self.m_DestinationBlip then
		delete(self.m_DestinationBlip)
	end
	if self.m_ColShape and isElement(self.m_ColShape) then
		destroyElement(self.m_ColShape)
	end
	if self.m_StartMarker and isElement(self.m_StartMarker) then
		destroyElement(self.m_StartMarker)
	end
	if self.m_TimeoutTimer and isTimer(self.m_TimeoutTimer) then
		killTimer(self.m_TimeoutTimer)
	end
	delete(self.m_EventBlip)
end

function StreetRaceEvent:colShapeHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and getPedOccupiedVehicleSeat(hitElement) == 0 then
		-- Add player to the winner list
		self.m_Ranks[#self.m_Ranks+1] = hitElement
		
		-- Tell all players that someone reached the destination
		self:sendMessage("%s hat das Ziel als %d. erreicht", 255, 255, 0, getPlayerName(hitElement), #self.m_Ranks)
		
		-- Give him some money
		local moneyAmount = 100 * #self.m_Players / #self.m_Ranks
		hitElement:giveMoney(moneyAmount)
		hitElement:sendMessage(_("[EVENT] Du hast %d$ gewonnen!", hitElement, moneyAmount), 0, 255, 0)
		
		-- Quit the hitting player
		self:quit(hitElement)
		
		-- Stop the event is all players reached the destination
		if #self.m_Players == 0 then
			delete(self)
		end
	end
end

function StreetRaceEvent.getRandomPosition()
	local randomIndex = math.random(1, #StreetRaceEvent.Positions)
	local x, y, z = unpack(StreetRaceEvent.Positions[randomIndex])
	return x, y, z, randomIndex
end

function StreetRaceEvent:getName()
	return "Straßenrennen"
end

StreetRaceEvent.Positions = {
	{0, 0, 4},
	{-1656.3, -539.8, 10.8}
}
