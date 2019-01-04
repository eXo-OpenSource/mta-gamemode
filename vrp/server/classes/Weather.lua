-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Weather.lua
-- *  PURPOSE:     Serverside zone dependend weather managing class
-- *
-- ****************************************************************************
Weather = inherit(Singleton)

addRemoteEvents{"clientRequestWeatherList"}

setWeather = nil -- Completetly disallow this function @ serverside!

function Weather:constructor()
	self.m_Weather = {}
	self.ms_Random = Randomizer:new()

	-- Setup weather for all zones
	for zone in pairs(WEATHER_ZONE_WEATHERS) do
		self:updateWeather(zone)
	end

	addEventHandler("clientRequestWeatherList", root, bind(Weather.onClientRequestWeatherList, self))
	setTimer(bind(Weather.checkWeatherChange, self), 300000, 0)
end

function Weather:setWeather(zone, weatherId)
	self.m_Weather[zone] = {Id = weatherId, performed = getTickCount()}
	PlayerManager:getSingleton():triggerEvent("receiveWeather", zone, weatherId)
end

function Weather:getWeather(zone)
	return self.m_Weather[zone].Id
end

function Weather:getWeatherForPlayer(player)
	return self:getWeather(player:getZoneName(true)).Id
end

function Weather:updateWeather(zone)
	local weatherIds = WEATHER_ZONE_WEATHERS[zone]

	local weatherIdTable = {}
	for _, weatherId in pairs(weatherIds) do
		local chanceCount = WEATHER_ID_DESCRIPTION[weatherId].chance
		for i = 1, chanceCount do
			table.insert(weatherIdTable, weatherId)
		end
	end

	local weatherId = self.ms_Random:getRandomTableValue(weatherIdTable)
	self:setWeather(zone, weatherId)
end

function Weather:checkWeatherChange()
	for zone, weather in pairs(self.m_Weather) do
		local minDuration = WEATHER_ID_DESCRIPTION[weather.Id].minimumDuration*1000*60
		local changeChance = WEATHER_ID_DESCRIPTION[weather.Id].changeChance/100
		if getTickCount() - weather.performed >= minDuration and self.ms_Random:nextDouble() < changeChance then
			self:updateWeather(zone)
		end
	end
end

function Weather:onClientRequestWeatherList()
	client:triggerEvent("receiveWeatherList", self.m_Weather)
end
