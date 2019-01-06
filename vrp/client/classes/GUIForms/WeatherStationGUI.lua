-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WeatherStationGUI.lua
-- *  PURPOSE:     Weather station GUIs
-- *
-- ****************************************************************************
WeatherStationGUI = inherit(GUIForm)
inherit(Singleton, WeatherStationGUI)

addRemoteEvents{"onMainWeatherStationClicked", "onWeatherStationClicked"}

function WeatherStationGUI:constructor(stationName, lastMaintenance, isConnected)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Wetterstation: %s", stationName), true, true, self)

	GUIGridLabel:new(1, 1, 5, 1, "Station:\nLetzte Wartung:\nVerbunden:\nFrequenz:", window):setAlign("left", "top")
	GUIGridLabel:new(4, 1, 5, 1, ("%s\n"):rep(4):format(stationName, getOpticalTimestamp(lastMaintenance), isConnected and "✔" or "✘", ("%s MHz"):format(math.random(30, 300))), window):setAlign("left", "top")
end

addEventHandler("onWeatherStationClicked", root,
	function(...)
		if not WeatherStationGUI:isInstantiated() then
			WeatherStationGUI:new(...)
		end
	end
)

addEventHandler("onMainWeatherStationClicked", root,
	function(weatherStations)
		--MainWeatherStationGUI:new()
	end
)
