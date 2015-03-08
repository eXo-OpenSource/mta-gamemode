-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/DMRaceEvent.lua
-- *  PURPOSE:     DM race event class
-- *
-- ****************************************************************************
DMRaceEvent = inherit(Event)
local EVENT_DIMENSION = 3

function DMRaceEvent:constructor()
	-- Initialise map
	self.m_Map = MapParser:new(self.getRandomMap())

	self.m_EnterHandler = bind(self.Event_PressedEnter, self)
end

function DMRaceEvent:destructor()
	delete(self.m_Map)
	self.m_Map = nil -- make sure the reference is removed so that the GC can collect it

	if self.m_AFKTimer then
		killTimer(self.m_AFKTimer)
		self.m_AFKTimer = nil
	end
end

function DMRaceEvent:onStart()
	-- Create map objects
	self.m_Map:create(EVENT_DIMENSION) -- TODO: Create the map only for contributing players

	self.m_AFKTimer = setTimer(bind(self.AFKTimer_Tick, self), 3000, 0)
	self.m_StartPlayerAmount = #self:getPlayers()

	-- Get a list of spawnpoints
	local spawnpoints = {}
	for k, element in pairs(self.m_Map:getElements()) do
		if not isElement(element) and element.type == "spawnpoint" then
			spawnpoints[#spawnpoints + 1] = {model = element.model, position = Vector3(element.x, element.y, element.z), rotation = element.rz}
		elseif isElement(element) and element:getType() == "pickup" and element.targetModel == 425 then -- is Hunter?
			addEventHandler("onPickupHit", element, bind(self.Event_PlayerReachedHunter, self))
		end
	end

	-- Spawn all players (the code below assumes that #spawnpoints >= #players; there is a general player limit for events)
	local spawnIndex = 1
	for k, player in pairs(self:getPlayers()) do
		-- Spawn the player
		local spawnInfo = spawnpoints[spawnIndex]
		player:setPosition(spawnInfo.position)
		player:setDimension(EVENT_DIMENSION)

		local vehicle = TemporaryVehicle.create(spawnInfo.model, spawnInfo.position.x, spawnInfo.position.y, spawnInfo.position.z, spawnInfo.rotation)
		vehicle:setDimension(EVENT_DIMENSION)
		warpPedIntoVehicle(player, vehicle)
		vehicle:setEngineState(true)

		-- Add binds
		bindKey(player, "enter_exit", "down", self.m_EnterHandler)

		-- Increment spawn index
		spawnIndex = spawnIndex + 1
	end
end

function DMRaceEvent:onPlayerWasted(player)
	-- Quit the player
	self:quit(player)

	local leftPlayers = #self:getPlayers()
	local money = self.m_StartPlayerAmount * (self.m_StartPlayerAmount-leftPlayers-1) * 40
	player:giveMoney(money)

	-- Output the winner if he was the last player
	if leftPlayers == 1 then
		local winningPlayer = self:getPlayers()[1]
		winningPlayer:sendSuccess(_("Du hast gewonnen und %d$ bekommen!", winningPlayer, money))

		-- Stop event
		delete(self)
	else
		player:sendInfo(_("Du hast den %d. Platz erreicht und %d$ bekommen!", player, leftPlayers+1, money))
	end
end

function DMRaceEvent:Event_PressedEnter(player)
	killPed(player)
end

function DMRaceEvent:Event_PlayerReachedHunter(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		-- Kill all players [except us]
		for k, player in pairs(self:getPlayers()) do
			--if hitElement ~= player then
				killPed(player)
			--end
		end
	end
end

function DMRaceEvent:AFKTimer_Tick()
	for k, player in pairs(self:getPlayers()) do
		-- Kick if position has not changed since 3000 seconds
		if player:getIdleTime() >= 3000 then
			killPed(player)
			outputDebug("Player is afk")
		end
	end
end

function DMRaceEvent:onQuit(player)
	-- Remove event handlers and binds
	unbindKey(player, "enter_exit", "down", self.m_EnterHandler)
end

function DMRaceEvent.getRandomMap()
	local maps = {
		"files/maps/DMRace/DM1.map",
	}

	return maps[math.random(1, #maps)]
end

function DMRaceEvent:getPositions()
	return {Vector3(2669.9, -1757.5, 10.8)}
end

function DMRaceEvent:getExitPosition()
	return Vector3(2669.9, -1760, 12)
end

function DMRaceEvent:getName()
	return "DM Race"
end

function DMRaceEvent:getDescription(player)
	return _([[Der von Race Servern bekannte Gamemode mit DM Maps.

		Ziel ist es, das Ziel vor allen anderen zu erreichen während sich auf dem Weg viele Hindernisse befinden.
		Einmal ein kaputtes Auto führt und du hast verloren.
	]], player)
end
