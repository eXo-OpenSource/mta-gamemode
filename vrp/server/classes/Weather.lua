-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Weather.lua
-- *  PURPOSE:     Weather managing class
-- *
-- ****************************************************************************
Weather = inherit(Singleton)

addRemoteEvents{"clientRequestWeatherList"}

setWeather = nil -- Completetly disallow this function @ serverside!

function Weather:constructor()
	self.m_Weather = {}
	self.ms_Random = Randomizer:new()

	-- Setup weather for all zones
	for zone, weatherIDs in pairs(WEATHER_ZONE_WEATHERS) do
		self:updateWeather(zone, self.ms_Random:getRandomTableValue(weatherIDs))
	end

	addEventHandler("clientRequestWeatherList", root, bind(Weather.onClientRequestWeatherList, self))
end

function Weather:getWeather(zone)
	return self.m_Weather[zone]
end

function Weather:getWeatherForPlayer(player)
	return self:getWeather(player:getZoneName(true))
end

function Weather:updateWeather(zone, weatherId)
	self.m_Weather[zone] = weatherId
	--triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "receiveWeather", resourceRoot, zone, weatherId)
end

function Weather:onClientRequestWeatherList()
	client:triggerEvent("receiveWeatherList", self.m_Weather)
end


--[[Weather = inherit(Singleton)
local WEATHER_CHANGE_INTERVAL = 120*60*1000 -- it will bug without this as setWeatherBlended will perform the interpolation for a 2 hours period ingame

Weather.Data = {
	{0, "Hitzewelle"},
	{1, "sonnig"},
	{2, "sehr sonnig, Smog"},
	{3, "sonnig, Smog"},
	{4, "bewölkt"},
	{5, "sonnig"},
	{6, "sehr sonnig"},
	{7, "stark bewölkt"},
	--{8, "Sturm"},
	--{9, "Neblig und Bewoelkt"},
	--{10, "Blauer Himmel"},
	--{11, "Hitzewelle"},
	--{12, "Grau und trist"},
	--{13, "Grau und trist"},
	--{14, "Grau und trist"},
	{15, "Grau und trist"},
	--{16, "Bewoelkt und verregnet"},
	{17, "Leichte Hitze"},
	{18, "Leichte Hitze"},
	--{19, "Sandsturm"},
	--{20, "Neblig und Bewoelkt"} <-- This is a buggy weather
}

-- TODO iterate this list randomly because you cannot iterate every weather in a 2 hours interval for a server that restarts every 24 hours

function Weather:constructor()
	self.m_CurrentWeather = Weather.Data[1]
	self:changeWeatherRandomly()

	setTimer(bind(self.changeWeatherRandomly, self), WEATHER_CHANGE_INTERVAL, 0)
end

function Weather:changeWeatherRandomly()
	self.m_NextWeather = Weather.Data[math.random(1, #Weather.Data)]
	CompanyManager:getSingleton():getFromId(CompanyStaticId.SANNEWS):sendShortMessage(("Wetterbericht: Das Wetter ändert sich in der nächsten Stunde von %s zu %s"):format(self.m_CurrentWeather[2], self.m_NextWeather[2]))
	self:setWeather()
end

function Weather:setWeather()
	if self.m_CurrentWeather[1] ~= self.m_NextWeather[1] then
		self.m_CurrentWeather = self.m_NextWeather
		setWeatherBlended(self.m_CurrentWeather[1])
	end
end]]
