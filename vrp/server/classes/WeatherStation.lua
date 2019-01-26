-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/WeatherStation.lua
-- *  PURPOSE:     Serverside weather stations
-- *
-- ****************************************************************************
WeatherStation = inherit(Object)

function WeatherStation:constructor(data)
	self.m_MainStation = data.MainStation
	self.m_Id = data.Id
	self.m_StationName = data.Name
	self.m_LastMaintenance = data.LastMaintenance
	self.m_Connected = data.Connected
	self.m_Frequency = math.random(30, 300) -- Useless but better then generate a random frequency everytime when the gui get opened
	self.m_Weather = false

	self:checkMaintenance()

	self.m_Station = createObject(1596, WEATHER_STATIONS[data.Name].position)
	self.m_Station:setData("clickable", true, true)

	addEventHandler("onElementClicked",self.m_Station, bind(self.onStationClicked, self))
end

function WeatherStation:update(updateMaintenance)
	sql:queryExec(("UPDATE ??_weather_stations SET %sConnected = ? WHERE Id = ?"):format(updateMaintenance and "LastMaintenance = NOW(), " or ""), sql:getPrefix(), self.m_Connected, self.m_Id)
end

function WeatherStation:setWeather(weatherId)
	self.m_Weather = weatherId
end

function WeatherStation:onStationClicked(button, state, player)
	-- Todo: Check San News

	if button =="left" and state == "down" then
		if self.m_MainStation then
			local weatherStations = Weather:getSingleton().m_WeatherStations
			player:triggerEvent("onMainWeatherStationClicked", weatherStations)
		else
			player:triggerEvent("onWeatherStationClicked", self.m_StationName, self.m_LastMaintenance, self.m_Connected, self.m_Frequency)
		end
	end
end

function WeatherStation:checkMaintenance()
	if not self.m_MainStation then
		local maintenanceAgo = getRealTime().timestamp - self.m_LastMaintenance

		local calcedInterval =  WEATHER_STATIONS_MAINTENANCE_INTEVAL + math.random(-WEATHER_STATIONS_MAINTENANCE_SPREAD, WEATHER_STATIONS_MAINTENANCE_SPREAD)
		if maintenanceAgo >= calcedInterval then
			self.m_Connected = false
			self:update()
		end
	end
end
