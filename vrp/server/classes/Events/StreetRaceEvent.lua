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
end

function StreetRaceEvent:onStart()
	-- Start the countdown
	self.m_onExitFunc = bind(StreetRaceEvent.onPlayerExit, self)
	for k, player in pairs(self.m_Players) do
		player:triggerEvent("countdownStart", 3)
		player:setData("inEvent", true)
		removeEventHandler("onPlayerVehicleExit", player, self.m_onExitFunc)
		addEventHandler("onPlayerVehicleExit", player, self.m_onExitFunc)
		player:setFrozen(true)
	end

	setTimer(
		function()
			if isElement(self.m_StartMarker) then destroyElement(self.m_StartMarker) end

			-- Find random position which is not equal to the start position
			local pos, randomIndex
			repeat
				pos, randomIndex = self.getRandomPosition()
			until randomIndex ~= self.m_StartIndex

			self.m_DestinationBlip = Blip:new("Waypoint.png", pos.x, pos.y,root,9999)
			self.m_ColShape = createColSphere(pos, 20)
			addEventHandler("onColShapeHit", self.m_ColShape, bind(self.colShapeHit, self))

			-- Start the GPS for each player
			for k, player in ipairs(self.m_Players) do
				player:startNavigationTo(pos)
				player:setFrozen(false)
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

function StreetRaceEvent:onPlayerExit()
	if source:getData("inEvent") then
		source:sendError("Du wurdest disqualifiziert!")
		self:quit(source)
		removeEventHandler("onPlayerVehicleExit",source,self.m_onExitFunc)
	end
end

function StreetRaceEvent:destructor()
	for k, player in pairs(self.m_Players) do
		player:setData("inEvent", false)
		removeEventHandler("onPlayerVehicleExit",player,self.m_onExitFunc)
	end

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
	if getElementType(hitElement) == "player" and matchingDimension and getPedOccupiedVehicleSeat(hitElement) == 0 and self:isMember(hitElement) then
		-- Add player to the winner list
		self.m_Ranks[#self.m_Ranks+1] = hitElement

		-- Tell all players that someone reached the destination
		self:sendMessage("%s hat das Ziel als %d. erreicht", 255, 255, 0, getPlayerName(hitElement), #self.m_Ranks)

		-- Give him some money
		local moneyAmount = 100 * #self.m_Players / #self.m_Ranks
		hitElement:giveMoney(math.ceil(moneyAmount), "Event")
		hitElement:sendSuccess(_("Du hast beim Straßenrennen %d$ gewonnen!", hitElement, moneyAmount))

		-- Quit the hitting player
		self:quit(hitElement)

		-- Start countdown when the first player has reached the destination
		if #self.m_Ranks == 1 then
			self:sendMessage("Der erste Spieler hat das Ziel erreicht. Du hast du noch 1 Minute Zeit, um das Ziel zu erreichen!", 255, 255, 0)

			-- Give him an Achievement
			hitElement:giveAchievement(16)

			-- Kill old timeout timer and restart
			self.m_TimeoutTimer:destroy()
			self.m_TimeoutTimer = setTimer(function() delete(self) end, 60*1000, 1)
		end

		-- Stop the event is all players reached the destination
		if #self.m_Players == 0 then
			delete(self)
		end
	end
end

function StreetRaceEvent.getRandomPosition()
	local randomIndex = math.random(1, #StreetRaceEvent.Positions)
	local pos = StreetRaceEvent.Positions[randomIndex]
	return pos, randomIndex
end

function StreetRaceEvent:getName()
	return "Straßenrennen"
end

function StreetRaceEvent:getDescription(player)
	return _([[Straßenrennen gegen andere Spieler
	]], player)
end

function StreetRaceEvent:getPositions()
	return StreetRaceEvent.Positions
end

StreetRaceEvent.Positions = {
	Vector3(-1656.3, -539.8, 10.8),
	Vector3(1824.1, -1576, 13),
	Vector3(1866.2, -1130.2, 23.5),
	Vector3(2286.4, -1152.1, 26.5),
	Vector3(2198, -1646.6, 15.1),
	Vector3(1949, -2353, 13.3),
	Vector3(1788.8, 833.3, 10.4),
	Vector3(1808.3, 2318.9, 6),
	Vector3(1087.2, 2499.9, 10.5),
	Vector3(1448.9, 2849.1, 10.6),
}
