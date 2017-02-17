-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Weather.lua
-- *  PURPOSE:     Weather managing class
-- *
-- ****************************************************************************
Weather = inherit(Singleton)
local WEATHER_CHANGE_INTERVAL = 30*60*1000

Weather.Names = { [
	1]="Bewoelkt",
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
	[20]="Neblig und Bewoelkt"
}

function Weather:constructor()
	self.m_CurrentWeather = 0
	setWeatherBlended(self.m_CurrentWeather)

	self.m_NextWeather = 0

	setTimer(bind(self.changeWeatherRandomly, self), WEATHER_CHANGE_INTERVAL, 0)
end

function Weather:changeWeatherRandomly()
	self.m_NextWeather = (self.m_CurrentWeather + 1) % 19
	CompanyManager:getSingleton():getFromId(CompanyStaticId.SANNEWS):sendMessage(("San News: Das Wetter ändert sich die nächsten 5 Minuten in: %s"):format(Weather.Names[self.m_NextWeather]), 255, 255, 0)

	setTimer(bind(self.setWeather, self), 5*60*100, 1)
end

function Weather:setWeather()
	if self.m_CurrentWeather ~= self.m_NextWeather then
		self.m_CurrentWeather = self.m_NextWeather
		setWeatherBlended(self.m_CurrentWeather)
	end
end
