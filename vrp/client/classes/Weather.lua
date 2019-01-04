-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Weather.lua
-- *  PURPOSE:     Clientside weather class
-- *
-- ****************************************************************************
Weather = inherit(Singleton)

addRemoteEvents{"receiveWeather", "receiveWeatherList"}

Weather._setWeather = setWeather
setWeather = nil -- Disallow this function @ clientside!

function Weather:constructor()
	self.m_CurrentZone = getZoneName(localPlayer.position, true)
	triggerServerEvent("clientRequestWeatherList", localPlayer)

	addEventHandler("receiveWeather", root, bind(Weather.onReceiveWeather, self))
	addEventHandler("receiveWeatherList", root, bind(Weather.onReceiveWeatherList, self))

	addEventHandler("onClientRender", root, bind(Weather.checkZone, self))
end

function Weather:onReceiveWeather(zone, weatherId)
	self.m_Weather[zone] = {Id = weatherId}

	if self.m_CurrentZone == zone then
		self:checkZone(true)
	end
end

function Weather:onReceiveWeatherList(weatherList)
	self.m_Weather = weatherList
end

function Weather:isValidZone(zone)
	return WEATHER_ZONE_WEATHERS[zone] ~= nil
end

function Weather:checkZone(force)
	-- Check for interior, to perform the interior weather
	if localPlayer:getInterior() ~= 0 then
		self:setWeather(22)
		return
	end

	local zone = getZoneName(localPlayer.position, true)
	if not force and self.m_CurrentZone == zone then return end
	if not self:isValidZone(zone) then return end
	if not self.m_Weather then return end

	self.m_CurrentZone = zone

	local weatherId = self.m_Weather[self.m_CurrentZone].Id
	if not weatherId then return end
	self:setWeather(weatherId)
end

function Weather:setWeather(weatherId)
	if getWeather() == weatherId then return end
	Weather._setWeather(weatherId)
end
