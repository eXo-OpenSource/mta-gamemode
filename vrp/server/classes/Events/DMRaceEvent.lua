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

	self.m_WastedFunc = bind(self.Event_PlayerWasted, self)
	self.m_EnterHandler = bind(self.Event_PressedEnter, self)
end

function DMRaceEvent:destructor()
	delete(self.m_Map)
end

function DMRaceEvent:onStart()
	-- Create map objects
	self.m_Map:create(EVENT_DIMENSION) -- TODO: Create the map only for contributing players

	-- Get a list of spawnpoints
	local spawnpoints = {}
	for k, element in pairs(self.m_Map:getElements()) do
		if not isElement(element) and element.type == "spawnpoint" then
			spawnpoints[#spawnpoints + 1] = {model = element.model, position = Vector3(element.x, element.y, element.z), rotation = Vector3(element.rx, element.ry, element.rz)}
		end
	end

	-- Spawn all players (the code below assumes that #spawnpoints >= #players; there is a general player limit for events)
	local spawnIndex = 1
	for k, player in pairs(self:getPlayers()) do
		-- Spawn the player
		local spawnInfo = spawnpoints[spawnIndex]
		player:setPosition(spawnInfo.position)
		player:setDimension(EVENT_DIMENSION)

		local vehicle = TemporaryVehicle.create(spawnInfo.model, spawnInfo.position.x, spawnInfo.position.y, spawnInfo.position.z, spawnInfo.rotation.rz)
		vehicle:setDimension(EVENT_DIMENSION)
		warpPedIntoVehicle(player, vehicle)
		vehicle:setEngineState(true)

		-- Add event handlers
		addEventHandler("onPlayerWasted", player, self.m_WastedFunc)
		bindKey(player, "enter", "down", self.m_EnterHandler)

		-- Increment spawn index
		spawnIndex = spawnIndex + 1
	end
end

function DMRaceEvent:Event_PlayerWasted()
	-- Quit the player
	self:quit(source)

	-- Output the winner if he was the last player
	if #self:getPlayers() == 0 then
		source:sendSuccess(_("Du hast gewonnen!", source))

		-- Stop event
		delete(self)
	end
end

function DMRaceEvent:Event_PressedEnter(player)
	killPed(player)
end

function DMRaceEvent:onQuit(player)
	-- Remove event handlers and binds
	removeEventHandler("onPlayerWasted", player, self.m_WastedFunc)
	unbindKey(player, "enter", "down", self.m_EnterHandler)
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

function DMRaceEvent:getName()
	return "DM Race"
end


--[[
Things we've to talk about:
- What happens when the player quits? (where does he respawn?) - respawn at hospital?
- Do we want to use our own maps or convert/load public maps
- How to end the event (shall we use the standard way (=Hunter?))
]]
