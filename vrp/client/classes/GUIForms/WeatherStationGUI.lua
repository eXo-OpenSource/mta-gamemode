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

function WeatherStationGUI:constructor(stationName, lastMaintenance, isConnected, frequency)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Wetterstation: %s", stationName), true, true, self)

	GUIGridLabel:new(1, 1, 5, 1, "Station:\nLetzte Wartung:\nVerbunden:\nFrequenz:", window):setAlign("left", "top")
	GUIGridLabel:new(4, 1, 5, 1, ("%s\n"):rep(4):format(stationName, getOpticalTimestamp(lastMaintenance), isConnected and "✔" or "✘", ("%s MHz"):format(frequency)), window):setAlign("left", "top")
end

addEventHandler("onWeatherStationClicked", root,
	function(...)
		if not WeatherStationGUI:isInstantiated() then
			WeatherStationGUI:new(...)
		end
	end
)


---------------------------------------------------------------------------------------------
MainWeatherStationGUI = inherit(GUIForm)
inherit(Singleton, MainWeatherStationGUI)

function MainWeatherStationGUI:constructor(weatherStations)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 17)
	self.m_Height = grid("y", 13)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	local window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Wetterstation Verwaltung", true, true, self)

	local columns = 2
	local n, row  = 0, 0
	for _, weatherStation in pairs(weatherStations) do
		n = n + 1
		local i = n - columns*row

		local image = weatherStation.m_Connected and "files/images/Other/antenna_c.png" or  "files/images/Other/antenna_nc.png"
		local stationBackground = GUIGridRectangle:new(1 + 8*(i-1), row*3 + 1, 8, 3, Color.LightGrey, window)
		local background = GUIRectangle:new(2, 2, stationBackground.m_Height - 4, stationBackground.m_Height - 4, weatherStation.m_Connected and Color.Accent or Color.Grey, stationBackground)
		GUIImage:new(5, 5, background.m_Width - 10, background.m_Height - 10, image, background)
		--GUIRectangle:new(0, background.m_Height - 20, background.m_Width, 20, Color.Background, background)
		--GUILabel:new(0, background.m_Height - 20, background.m_Width, 20, weatherStation.m_StationName, background):setAlign("center", "center"):setFontSize(1):setFont(VRPFont(25)):setColor(weatherStation.m_Connected and Color.Green or Color.Red)

		GUIGridLabel:new(4 + 8*(i-1), row*3 + 1, 3, 1, "Station:\nStatus:\nFrequenz:\nWetter:", window):setAlign("left", "top")
		GUIGridLabel:new(6 + 8*(i-1), row*3 + 1, 3, 1, ("%s\n"):rep(4):format(weatherStation.m_StationName, weatherStation.m_Connected and "Verbunden" or "Außer Betrieb", weatherStation.m_Frequency .. " MHz", (weatherStation.m_Connected and weatherStation.m_Weather) and WEATHER_ID_DESCRIPTION[weatherStation.m_Weather].info or "-"), window):setAlign("left", "top")

		if i%columns == 0 then row = row + 1 end
	end
end


addEventHandler("onMainWeatherStationClicked", root,
	function(...)
		if not MainWeatherStationGUI:isInstantiated() then
			MainWeatherStationGUI:new(...)
		end
	end
)
