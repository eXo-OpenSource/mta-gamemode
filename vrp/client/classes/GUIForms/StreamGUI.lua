-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StreamGUI.lua
-- *  PURPOSE:     Stream GUI class
-- *
-- ****************************************************************************
StreamGUI = inherit(GUIForm)
inherit(Singleton, StreamGUI)

function StreamGUI:constructor(title, playCallback, stopCallback, stream)
	GUIForm.constructor(self, screenWidth/2 - 400/2, screenHeight/2 - 240/2, 400, 240)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(10, 40, 380, 25, "Wähle einen Stream aus der Liste aus, oder gib deine eigene Stream-URL ein.", self.m_Window)

	self.m_StreamList = GUIChanger:new(10, 100, 240, 30, self.m_Window)
	self.m_AddButton = GUIButton:new(260, 100, 130, 30, _"Auswählen", self.m_Window)
	GUILabel:new(10, 150, 90, 25, _"Stream-URL:", self.m_Window)
	self.m_StreamUrl = GUIEdit:new(110, 150, 280, 25, self.m_Window)
	self.m_StreamUrl:setText(stream or "")

	self.m_PlayButton = GUIButton:new(100, 200, 140, 30, _"Abspielen", self.m_Window):setBackgroundColor(Color.Green)
	self.m_StopButton = GUIButton:new(250, 200, 140, 30, _"Stoppen", self.m_Window):setBackgroundColor(Color.Red)

	local item, selectedItem

	self.m_AddButton.onLeftClick =
	function()
		if self.m_StreamList:getIndex() then
			selectedItem = self.m_StreamList:getIndex()
			self.m_StreamUrl:setText(self.m_Streams[selectedItem])
		end
	end

	self.m_PlayButton.onLeftClick = function() if playCallback then playCallback(self.m_StreamUrl:getText()) end end
	self.m_StopButton.onLeftClick = function() if stopCallback then stopCallback() end end

	self.m_Streams = {}

	for index, radio in pairs(RadioStationManager:getSingleton():getStations()) do
		local name, url = unpack(radio)
		if type(url) == "string" then
			self.m_StreamList:addItem(name)
			self.m_Streams[name] = url
		end
	end
end
