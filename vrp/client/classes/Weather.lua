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
Weather._setWeatherBlended = setWeatherBlended
setWeather = nil -- Disallow this function @ clientside!
setWeatherBlended = nil -- Disallow this function @ clientside!

function Weather:constructor()
	self.m_CurrentZone = getZoneName(localPlayer.position, true)
	triggerServerEvent("clientRequestWeatherList", localPlayer)

	addEventHandler("receiveWeather", root, bind(Weather.onReceiveWeather, self))
	addEventHandler("receiveWeatherList", root, bind(Weather.onReceiveWeatherList, self))

	addEventHandler("onClientRender", root, bind(Weather.checkZone, self))

	--set every weather option to default (that it can be changed via weather id)
	resetFarClipDistance()
	resetNearClipDistance()
	resetFogDistance()
	resetSkyGradient()
	resetMoonSize()
	resetWaterColor()
	resetSunColor()
	resetSunSize()
	resetWindVelocity()
	-- Disable Heathaze-Effect (causes unsightly effects on 3D-GUIs e.g. SpeakBubble3D)
	setHeatHaze(0)
	--wave height does not seem to be affected by weather, so fix it to 1
	setWaveHeight(1)
	--disable rain effect only if the player wishes to
	if (core:get("Weather", "GTARainEnabled", true)) then
		resetRainLevel()
	else
		setRainLevel(0)
	end
end

function Weather:onReceiveWeather(zone, weatherId)
	self.m_Weather[zone] = {Id = weatherId}

	if self.m_CurrentZone == zone then
		self:checkZone(true)
	end
end

function Weather:getAllWeather()
	return self.m_Weather
end

function Weather:getWeatherInZone(zoneName)
	return self.m_Weather and self.m_Weather[zoneName]
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
		self:setWeather(WEATHER_ID_INTERIOR)
		return
	end

	local w1, w2 = getWeather()
	if self.m_BlendingWeatherId and not w2 then -- weather blending is finished
		self:finishBlending()
	end

	local zone = getZoneName(localPlayer.position, true)
	if not force and self.m_CurrentZone == zone then return end
	if not self:isValidZone(zone) then return end
	if not self.m_Weather then return end

	if (self.m_CurrentZone ~= zone) then
		self.m_CurrentZone = zone
		local weatherId = self.m_Weather[self.m_CurrentZone].Id
		if not weatherId then return end
		if getWeather() == WEATHER_ID_INTERIOR or force or (not core:get("Weather", "Blending", false)) then 
			self:setWeather(weatherId)
		else
			self:setWeatherBlended(weatherId)
		end
	end
end

function Weather:setWeather(weatherId)
	if getWeather() == weatherId then return end
	Weather._setWeather(weatherId)
end

function Weather:setWeatherBlended(weatherId)
	local w1, w2 = getWeather()
	if w1 == weatherId and (not w2 or w2 == weatherId) then return end
	if w2 then outputDebug "weather blending cancelled" Weather._setWeather(w2) end -- if there is a blending in progress, cancel it and set it to the new value immediately 
	setMinuteDuration(300)
	self.m_BlendingWeatherId = weatherId
	outputDebug "weather blending started"
	Weather._setWeatherBlended(weatherId)
end

function Weather:finishBlending()
	outputDebug "weather blending finished"
	Weather._setWeather(self.m_BlendingWeatherId)
	setMinuteDuration(3600000) --
	setTime(getRealTime().hour, getRealTime().minute) -- do not forget, reset time
	self.m_BlendingWeatherId = nil
end


--[[
	--test function to interpolate between two different weather ids, does not really work as you have to set the new weather in order to get its configuration
function Weather:interpolateBetween()
	local w = self.m_WeatherTransition
	if not w then return end
	
	local timeEnd = 10000
	if getTickCount() - w.startTime > timeEnd then
		self:setWeather(w.newWeatherId)
		resetSkyGradient()
		resetFogDistance()
		resetFarClipDistance()
		outputDebug(w.skyGradient)
		self.m_WeatherTransition = nil
		outputDebug("interpolation ended")
		return
	end

	local i = (getTickCount() - w.startTime)/timeEnd
	
	outputDebug("interpolation "..math.floor(i*100)/100)
	
	local r1s, g1s, b1s, r2s, g2s, b2s = unpack(w.skyGradient[1])
	local r1e, g1e, b1e, r2e, g2e, b2e = unpack(w.skyGradient[2])
	
	setSkyGradient(r1s*(1-i)+r1e*i, g1s*(1-i)+g1e*i, b1s*(1-i)+b1e*i, r2s*(1-i)+r2e*i, g2s*(1-i)+g2e*i, b2s*(1-i)+b2e*i)
	setFogDistance(w.fog[1]*(1-i) +w.fog[2]*i)
	setFarClipDistance(w.farClip[1]*(1-i) +w.farClip[2]*i)
end
]]