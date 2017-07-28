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
	self.m_Players = {}
	self.m_Ranks = {}
	self.m_State = "NoMap"
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
	for i, p in pairs(self.m_Players) do
		if p == player then
			table.remove(self.m_Players, i)
			self:sendShortMessage(_("%s leaved!", player, player:getName()))
			self:checkState()
			return true
		end
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

function Race:setState(newState)
	outputChatBox("Set State: " .. tostring(newState))

	self.m_State = newState
	if self.m_State == "LoadingMap" then
		if self.m_NextMap then
			self:loadMap()
		end
	end
end

function Race:checkState()
	if #self.m_Players == 0 then
		self:unloadMap()
		self:setState("NoMap")
	end
end

function Race:loadMap()
	self.m_CurrentMap = RaceManager:getSingleton():loadMap(self.m_NextMap, self.m_Dimension)
	self.m_Spawnpoints = self.m_CurrentMap.instance:getElementsByType("spawnpoint")
	self.m_NextMap = nil

	outputChatBox("Available spawnpoints: " .. tostring(#self.m_Spawnpoints))

	-- Set up players
	for _, player in pairs(self.m_Players) do
		local spawnpoint = self:getRandomSpawnpoint()
		local vehicle = TemporaryVehicle.create(spawnpoint.model, spawnpoint.x, spawnpoint.y, spawnpoint.z, spawnpoint.rz)
		player:warpIntoVehicle(vehicle)
		vehicle:setEngineState(true)
		vehicle:setDimension(self.m_Dimension)
		vehicle.m_DisableToggleEngine = true
		vehicle:setData("disableCollisionCheck", true, true)
		vehicle:setData("disableDamageCheck", true, true)
	end
end

function Race:unloadMap()
	delete(self.m_CurrentMap.instance)
	self.m_CurrentMap = nil
end

function Race:getRandomSpawnpoint()
	return self.m_Spawnpoints[math.random(1, #self.m_Spawnpoints)]
end
