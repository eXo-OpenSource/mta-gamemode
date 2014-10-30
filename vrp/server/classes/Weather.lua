-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Weather.lua
-- *  PURPOSE:     Weather managing class
-- *
-- ****************************************************************************
Weather = inherit(Singleton)
local WEATHER_CHANGE_INTERVAL = 5*60*1000

function Weather:constructor()
	self.m_CurrentWeather = 0
	setWeatherBlended(self.m_CurrentWeather)
	
	setTimer(bind(self.changeWeatherRandomly, self), WEATHER_CHANGE_INTERVAL, 0)
end

function Weather:changeWeatherRandomly()
	self.m_CurrentWeather = (self.m_CurrentWeather + 1) % 20
	setWeatherBlended(self.m_CurrentWeather)
end
