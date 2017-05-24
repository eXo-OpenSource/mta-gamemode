-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Weather.lua
-- *  PURPOSE:     Weather managing class
-- *
-- ****************************************************************************
Weather = inherit(Singleton)
local WEATHER_CHANGE_INTERVAL = 120*60*1000 -- it will bug without this as setWeatherBlended will perform the interpolation for a 2 hours period ingame

Weather.Names = {
	[0]="Sonnig, blauer Himmel",
	[1]="Bewoelkt",
	[2]="Bewoelkt",
	[3]="Bewoelkt",
	[4]="Bewoelkt",
	[5]="Bewoelkt",
	[6]="Bewoelkt",
	[7]="Bewoelkt",
	[8]="Sturm",
	[9]="Neblig und Bewoelkt",
	[10]="Blauer Himmel",
	[11]="Hitzewelle",
	[12]="Grau und trist",
	[13]="Grau und trist",
	[14]="Grau und trist",
	[15]="Grau und trist",
	[16]="Bewoelkt und verregnet",
	[17]="Leichte Hitze",
	[18]="Leichte Hitze",
	[19]="Sandsturm",
	--[20]="Neblig und Bewoelkt" <-- This is a buggy weather
}

-- TODO iterate this list randomly because you cannot iterate every weather in a 2 hours interval for a server that restarts every 24 hours

function Weather:constructor()
	self.m_CurrentWeather = 1
	setWeatherBlended(self.m_CurrentWeather)

	self.m_NextWeather = 1

	setTimer(bind(self.changeWeatherRandomly, self), WEATHER_CHANGE_INTERVAL, 0)
end

function Weather:changeWeatherRandomly()
	self.m_NextWeather = (self.m_CurrentWeather + 1) % 18
	CompanyManager:getSingleton():getFromId(CompanyStaticId.SANNEWS):sendMessage(("San News: Das Wetter ändert sich die nächsten 5 Minuten in: %s"):format(Weather.Names[self.m_NextWeather]), 255, 255, 0)

	setTimer(bind(self.setWeather, self), 5*60*100, 1)
end

function Weather:setWeather()
	if self.m_CurrentWeather ~= self.m_NextWeather then
		self.m_CurrentWeather = self.m_NextWeather
		setWeatherBlended(self.m_CurrentWeather)
		if self.m_CurrentWeather == 16 or self.m_CurrentWeather == 8 then 
			setRainLevel(0.2)
		end
	end
end
