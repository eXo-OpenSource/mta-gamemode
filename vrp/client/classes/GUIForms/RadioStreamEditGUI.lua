RadioStreamEditGUI = inherit(GUIForm)
inherit(Singleton, RadioStreamEditGUI)

function RadioStreamEditGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Radiosender", true, true, self)
    self.m_Window.onLeftClick = bind(RadioStreamEditGUI.Event_OnWindowClick, self)
	
	self.m_InfoLabel = GUIGridLabel:new(1, 1, 15, 1, "Die Sender kannst du im Auto oder mit dem platzierbaren Radio abspielen.", self.m_Window)
	self.m_StreamGrid = GUIGridGridList:new(1, 2, 15, 7, self.m_Window)
	self.m_StreamGrid:addColumn("Senderliste", 0.4)
    self.m_StreamGrid:addColumn("", 1)
    self.m_StreamGrid.onLeftClick = bind(RadioStreamEditGUI.Event_OnListItemClick, self)

	self.m_DeleteBtn = GUIGridIconButton:new(13, 2, FontAwesomeSymbols.Minus, self.m_Window):setBackgroundColor(Color.Red)
    self.m_DownBtn = GUIGridIconButton:new(14, 2, FontAwesomeSymbols.Double_Down, self.m_Window)
    self.m_DownBtn.onLeftClick = bind(RadioStreamEditGUI.moveStation, self)
	self.m_UpBtn = GUIGridIconButton:new(15, 2, FontAwesomeSymbols.Double_Up, self.m_Window)
    self.m_UpBtn.onLeftClick = bind(RadioStreamEditGUI.moveStation, self, true)
    
	self.m_ListBtn = GUIGridIconButton:new(14, 10, FontAwesomeSymbols.List, self.m_Window)
	
	self.m_InfoLabel2 = GUIGridLabel:new(1, 9, 11, 1, "Füge hier einen neuen Sender mit einer Stream-URL hinzu.", self.m_Window)
	self.m_HelpLabel = GUIGridLabel:new(11, 9, 5, 1, "(Was ist eine Stream-URL?)", self.m_Window):setAlignX("right"):setClickable(true)
	self.m_HelpLabel.onLeftClick = function()
		outputChatBox("the fuck is this search for yourself")
	end
	
	
	self.m_NameEdit = GUIGridEdit:new(1, 10, 13, 1, self.m_Window):setCaption("Name des Senders")
	self.m_NameEdit = GUIGridEdit:new(1, 11, 14, 1, self.m_Window):setCaption("Stream-URL")
	self.m_SoundCheckBtn = GUIGridIconButton:new(15, 11, FontAwesomeSymbols.SoundOn, self.m_Window)
    self.m_AddBtn = GUIGridIconButton:new(15, 10, FontAwesomeSymbols.Plus, self.m_Window):setBackgroundColor(Color.Green)
    
    self:loadDefaultStations()
    self:loadList()
    self:updateEditButtons()
end

function RadioStreamEditGUI:loadDefaultStations()
    self.m_ModifiedStreams = RadioStationManager:getSingleton():getStations() -- just load the stations as they are
end

function RadioStreamEditGUI:loadList()
    for i,v in ipairs(self.m_ModifiedStreams) do
        local url = tonumber(v[2]) and ("GTA-Radiostation "..v[2]) or v[2]
        self.m_StreamGrid:addItem(v[1], url)
    end
end

function RadioStreamEditGUI:Event_OnWindowClick()
    --self.m_StreamGrid:setSelectedItem()
    --outputChatBox("selected")
end

function RadioStreamEditGUI:Event_OnListItemClick()
    nextframe(function()
        self.m_SelectedListItem = self.m_StreamGrid:getSelectedItem()
        if self.m_SelectedListItem then
          --  outputChatBox(self.m_ModifiedStreams[self.m_SelectedListItem][1])
        end
        self:updateEditButtons(self.m_SelectedListItem)
	end)
end

function RadioStreamEditGUI:moveStation(moveUp)

end

function RadioStreamEditGUI:updateEditButtons(show)
    self.m_DeleteBtn:setVisible(show)
	self.m_DownBtn:setVisible(show)
	self.m_UpBtn:setVisible(show)
end

function RadioStreamEditGUI:destructor()
    outputDebug(self.m_ModifiedStreams)
   -- RadioStationManager:getSingleton():saveNewStations(self.m_ModifiedStreams)
	GUIForm.destructor(self)
end


addCommandHandler("radio", function()
    RadioStreamEditGUI:new()
end)