-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Race = inherit(Object)

Race.STATES = {
	[1] = "NoMap",
	[2] = "LoadingMap",
	[3] = "PreGridCountdown",
	[4] = "GridCountdown",
	[5] = "Running",
	[6] = "SomeoneWon",
	[7] = "TimesUp",
	[8] = "EveryoneFinished",
	[9] = "PostFinish",
	[10] = "NextMapSelect",
	[11] = "NextMapVote",
}

function Race:virtual_constructor()
	self.m_Vehicles = {}
	self.m_Players = {}
	self.m_AlivePlayers = {}
	self.m_State = "NoMap"

	self.m_PlayersReadyTimer = bind(Race.checkPlayersReady, self)
end

function Race:virtual_destructor()
end

function Race:sendMessage(text, r, g, b, ...)
	for _, player in pairs(self.m_Players) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Race:sendShortMessage(text, ...)
	for _, player in pairs(self.m_Players) do
		player:sendShortMessage(text, self.m_ModeName, {255, 80, 0}, ...)
	end
end

function Race:join(player)
	table.insert(self.m_Players, player)
	self:sendShortMessage(_("%s joined!", player, player:getName()))

	player.race_ready = false

	player:setDimension(self.m_Dimension)

	if self.m_State == "NoMap" then
		self.m_NextMap = RaceManager:getSingleton():getRandomMap(self.m_Mode)
		self:setState("LoadingMap")
	end
end

function Race:quit(player)
	local key = self:isPlayer(player)
	if key then
		table.remove(self.m_Players, key)

		player:triggerEvent("RaceManager:destroyMap")
		self:sendShortMessage(_("%s leaved!", player, player:getName()))

		if #self.m_Players == 0 then
			self:unloadMap()
			self:setState("NoMap")
		end
		return true
	end

	return false
end

function Race:getPlayers()
	return self.m_Players
end

function Race:isPlayer(player)
	for key, value in pairs(self.m_Players) do
		if value == player then
			return key
		end
	end
end

function Race:checkPlayersReady()
	local playersReady = {}
	for _, player in pairs(self.m_Players) do
		if player.race_ready then
			table.insert(playersReady, player)
		end
	end

	if #self.m_Players == #playersReady then
		outputChatBox("All players are ready. goto pregridcountdown")
		return self:setState("GridCountdown")
	end

	outputChatBox("Waiting for players..")
	setTimer(self.m_PlayersReadyTimer, 2000, 1)
end

function Race:setState(newState)
	outputChatBox("Set State: " .. tostring(newState))

	self.m_State = newState
	if self.m_State == "LoadingMap" then
		if self.m_NextMap then
			self:loadMap()
		end
	elseif self.m_State == "PreGridCountdown" then
		setTimer(self.m_PlayersReadyTimer, 2000, 1)
	elseif self.m_State == "GridCountdown" then
		-- Todo: Countdown // Timer = Workaround
		setTimer(
			function()
				self:setState("Running")

				for _, player in pairs(self.m_Players) do
					self.m_AlivePlayers[player] = true
					player.raceVehicle:setFrozen(false)
				end
			end, 4000, 1
		)
	end
end


function Race:loadMap()
	local st = getTickCount()

	self.m_CurrentMap = RaceManager:getSingleton():loadMap(self.m_NextMap, self.m_Dimension)
	self.m_Spawnpoints = self.m_CurrentMap.instance:getElementsByTypeFromData("spawnpoint")
	self.m_NextMap = nil

	outputChatBox("Available spawnpoints: " .. tostring(#self.m_Spawnpoints))

	-- Set up players
	for _, player in pairs(self.m_Players) do
		--player:triggerEvent("RaceManager:sendMap", self.m_CurrentMap.instance.m_MapData, self.m_Dimension)
		triggerLatentClientEvent(player, "RaceManager:sendMap", 8388608, resourceRoot, self.m_CurrentMap.instance.m_MapData, self.m_Dimension)

		local spawnpoint = self:getRandomSpawnpoint()
		local vehicle = TemporaryVehicle.create(spawnpoint.model, spawnpoint.x, spawnpoint.y, spawnpoint.z, spawnpoint.rz)
		player:warpIntoVehicle(vehicle)
		vehicle:setEngineState(true)
		vehicle:setFrozen(true)
		vehicle:setDimension(self.m_Dimension)
		vehicle.m_DisableToggleEngine = true
		vehicle:setData("disableCollisionCheck", true, true)
		vehicle:setData("disableDamageCheck", true, true)

		vehicle.player = player
		player.raceVehicle = vehicle

		table.insert(self.m_Vehicles, vehicle)
	end

	outputChatBox("Race:loadMap() took " .. getTickCount() - st)

	self:setState("PreGridCountdown")
end

function Race:unloadMap()
	local st = getTickCount()

	delete(self.m_CurrentMap.instance)
	self.m_CurrentMap = nil

	for _, player in pairs(self.m_Players) do
		player:triggerEvent("RaceManager:destroyMap")
	end

	for _, vehicle in pairs(self.m_Vehicles) do
		vehicle:destroy()
	end
	self.m_Vehicles = {}

	outputChatBox("Race:unloadMap() took " .. getTickCount() - st)
end

function Race:getRandomSpawnpoint()
	return self.m_Spawnpoints[math.random(1, #self.m_Spawnpoints)]
end
