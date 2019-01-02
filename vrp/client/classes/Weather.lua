-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Weather = inherit(Singleton)

addRemoteEvents{"receiveWeatherList"}

Weather._setWeather = setWeather
setWeather = nil -- Disallow this function @ clientside!

function Weather:constructor()
	self.m_CurrentZone = getZoneName(localPlayer.position, true)
	triggerServerEvent("clientRequestWeatherList", localPlayer)


	addEventHandler("receiveWeatherList", root, bind(Weather.onReceiveWeatherList, self))
	addEventHandler("onClientRender", root, bind(Weather.checkZone, self)) -- Todo: Replace with timer
end

function Weather:destructor()
end

function Weather:onReceiveWeatherList(weatherList)
	self.m_Weather = weatherList
end

function Weather:isValidZone(zone)
	return WEATHER_ZONE_WEATHERS[zone] ~= nil
end

function Weather:checkZone()
	dxDrawText(self.m_CurrentZone, 500, 10)

	-- Todo: Check for interior, to perform the interior weather
	local zone = getZoneName(localPlayer.position, true)
	if self.m_CurrentZone == zone then return end
	if not self:isValidZone(zone) then return end
	if not self.m_Weather then return end

	self.m_CurrentZone = zone

	local weatherId = self.m_Weather[self.m_CurrentZone]
	if not weatherId then outputDebugString("Invalid zone") return end
	outputChatBox("Changed weather to: " .. weatherId)
	self:setWeather(weatherId)
end

function Weather:setWeather(weatherId)
	Weather._setWeather(weatherId)
end
