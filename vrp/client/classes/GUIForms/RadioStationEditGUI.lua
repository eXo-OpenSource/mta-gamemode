RadioStationEditGUI = inherit(GUIForm)
inherit(Singleton, RadioStationEditGUI)

function RadioStationEditGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
    self.m_Height = grid("y", 12)
    self.m_PreListenState = false

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Radiosender", true, true, self)

	self.m_InfoLabel = GUIGridLabel:new(1, 1, 15, 1, "Die Sender kannst du im Auto oder mit dem platzierbaren Radio anhören.", self.m_Window)
	self.m_StreamGrid = GUIGridGridList:new(1, 2, 15, 7, self.m_Window)
	self.m_StreamGrid:addColumn("Senderliste", 0.4)
    self.m_StreamGrid:addColumn("", 1)
    self.m_StreamGrid.onLeftClick = bind(RadioStationEditGUI.Event_OnListItemClick, self)

	self.m_DeleteBtn = GUIGridIconButton:new(13, 2, FontAwesomeSymbols.Minus, self.m_Window):setBackgroundColor(Color.Red)
    self.m_DeleteBtn.onLeftClick = bind(RadioStationEditGUI.deleteStation, self)
	self.m_DownBtn = GUIGridIconButton:new(14, 2, FontAwesomeSymbols.Double_Down, self.m_Window)
    self.m_DownBtn.onLeftClick = bind(RadioStationEditGUI.moveStation, self)
	self.m_UpBtn = GUIGridIconButton:new(15, 2, FontAwesomeSymbols.Double_Up, self.m_Window)
    self.m_UpBtn.onLeftClick = bind(RadioStationEditGUI.moveStation, self, true)


	self.m_InfoLabel2 = GUIGridLabel:new(1, 9, 11, 1, "Füge hier einen neuen Sender mit einer Stream-URL hinzu.", self.m_Window)
	self.m_HelpLabel = GUIGridLabel:new(11, 9, 5, 1, "(Wo finde ich die URLs?)", self.m_Window):setAlignX("right"):setClickable(true)
	self.m_HelpLabel.onLeftClick = function()
        ShortMessage:new("Radiostationen besitzen heutzutage meistens Webstreams. Diese findest du auf der Web-Seite des Radios oder auch in sog. Stream-Listen im Internet. Wichtig ist, dass der Link möglichst direkt zu dem Audio-Player führt bzw die Musik direkt beginnt. Du kannst auch eine URL eines bestehenden Radiosenders in deinen Browser einfügen und dir somit ein Beispiel anzeigen lassen.", nil, nil, 20000)
        --GUIWebWindow:new(screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, "Das ist ganz einfach", "https://lmddgtfy.net/?q=radio%20stream%20liste", true, true)
	end


	self.m_NameEdit = GUIGridEdit:new(1, 10, 13, 1, self.m_Window):setCaption("Name des Senders")
	self.m_URLEdit = GUIGridEdit:new(1, 11, 14, 1, self.m_Window):setCaption("Stream-URL")
    self.m_SoundCheckBtn = GUIGridIconButton:new(15, 11, FontAwesomeSymbols.SoundOn, self.m_Window)
    self.m_SoundCheckBtn.onLeftClick = function()
        self:preListenStation(not self.m_PreListenState)
    end
    self.m_ListBtn = GUIGridIconButton:new(14, 10, FontAwesomeSymbols.List, self.m_Window):setTooltip("aus Standard-Liste auswählen")
    self.m_ListBtn.onLeftClick = function()
        RadioStationPreviewGUI:new(self)
    end
    self.m_AddBtn = GUIGridIconButton:new(15, 10, FontAwesomeSymbols.Plus, self.m_Window):setBackgroundColor(Color.Green)
    self.m_AddBtn.onLeftClick = bind(RadioStationEditGUI.addStation, self)

    self.m_NameEdit.onLeftClick = function() self:resetSelection() end
    self.m_URLEdit.onLeftClick = self.m_NameEdit.onLeftClick

    self:loadDefaultStations()
    self:loadList()
    self:updateEditButtons()
end

function RadioStationEditGUI:setMainWindow(windowInstance)
    self.m_MainWindow = windowInstance
    self.m_Window:addBackButton(function () delete(self) self.m_MainWindow:getSingleton():show() end)
end

function RadioStationEditGUI:loadDefaultStations()
    self.m_ModifiedStreams = RadioStationManager:getSingleton():getStations() -- just load the stations as they are
end

function RadioStationEditGUI:loadList()
    self.m_StreamGrid:clear()
	self.m_StreamIdToGridItem = {}
    for i,v in ipairs(self.m_ModifiedStreams) do
        local url = tonumber(v[2]) and ("GTA-Radiostation "..v[2]) or v[2]
        local item = self.m_StreamGrid:addItem(v[1], url)
        item.m_StationId = i
		self.m_StreamIdToGridItem[i] = item
    end
end

function RadioStationEditGUI:resetSelection()
    self.m_StreamGrid:setSelectedItem()
    self:updateEditButtons(false)
    self.m_SelectedListItem = nil
end

function RadioStationEditGUI:Event_OnListItemClick()
    nextframe(function()
        self.m_SelectedListItem = self.m_StreamGrid:getSelectedItem()
        if self.m_SelectedListItem then
            self:updateEditButtons(self.m_SelectedListItem, self.m_SelectedListItem.m_StationId > 1, self.m_SelectedListItem.m_StationId < #self.m_ModifiedStreams)
        else
            self:updateEditButtons(false)
        end
	end)
end

function RadioStationEditGUI:setSelectedItemById(i)
	self.m_StreamGrid:setSelectedItem(i)
	self:Event_OnListItemClick()
end

function RadioStationEditGUI:deleteStation()
    if self.m_SelectedListItem then
        local id = self.m_SelectedListItem.m_StationId
        if id then
        	table.remove(self.m_ModifiedStreams, id)
            self:loadList()
            self.m_StreamGrid:scrollToItem(id)
        end
    end
end

function RadioStationEditGUI:moveStation(moveUp)
    if self.m_SelectedListItem then
        local id = self.m_SelectedListItem.m_StationId
        if id then
            if moveUp == true and id-1 > 0  then
                local d = table.remove(self.m_ModifiedStreams, id)
                table.insert(self.m_ModifiedStreams, id-1, d)
                self:loadList()
				self:setSelectedItemById(id-1)
            elseif id < #self.m_ModifiedStreams then
				local d = table.remove(self.m_ModifiedStreams, id)
                table.insert(self.m_ModifiedStreams, id+1, d)
                self:loadList()
				self:setSelectedItemById(id+1)
            end
        end
    end
end

function RadioStationEditGUI:addStation()
    local name = self.m_NameEdit:getText()
    local url = self.m_URLEdit:getText()
    if url:find("http://") or url:find("https://") or tonumber(url) then
        table.insert(self.m_ModifiedStreams, {name, tonumber(url) or url})
        self:loadList()
        self:setSelectedItemById(#self.m_ModifiedStreams)
    else
        ErrorBox:new("Ungültige URL (diese muss http oder https beinhalten)")
    end
end

function RadioStationEditGUI:setStationEditText(name, url)
    self.m_NameEdit:setText(name)
    self.m_URLEdit:setText(url)
end

function RadioStationEditGUI:updateEditButtons(show, moveUp, moveDown)
    self.m_DeleteBtn:setVisible(show)
	self.m_DownBtn:setVisible(show):setEnabled(moveDown)
    self.m_UpBtn:setVisible(show):setEnabled(moveUp)
end

function RadioStationEditGUI:preListenStation(state)
    if state == self.m_PreListenState then return end
    if state then
        local url = self.m_URLEdit:getText()
        if url:find("http://") or url:find("https://") then -- you cannot preview gta channels
            self.m_PreviewSound = playSound(url)
            self.m_PreListenState = true
        else
            ErrorBox:new("Ungültige URL (diese muss http oder https beinhalten)")
        end
    else
        setRadioChannel(0)
        if isElement(self.m_PreviewSound) then destroyElement(self.m_PreviewSound) end
        self.m_PreListenState = false
    end

end


function RadioStationEditGUI:destructor()
    self:preListenStation(false)
    RadioStationManager:getSingleton():saveStations(self.m_ModifiedStreams)
	GUIForm.destructor(self)
end


RadioStationPreviewGUI = inherit(GUIForm)
inherit(Singleton, RadioStationPreviewGUI)

function RadioStationPreviewGUI:constructor(radioEditInstance)
    local radioEditInstance = radioEditInstance
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 7)
	self.m_Height = grid("y", 9)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Standard-Stationen", true, true, self)
	self.m_Grid = GUIGridGridList:new(1, 1, 6, 7, self.m_Window)
	self.m_Grid:addColumn("Name", 1)
    self.m_Btn = GUIGridButton:new(1, 8, 6, 1, "Auswählen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(false)
    self.m_Btn.onLeftClick = function()
        local selected = self.m_Grid:getSelectedItem()
        if selected then
            radioEditInstance:setStationEditText(selected.m_StationData[1], selected.m_StationData[2])
            self:delete()
        end
    end

    for i,v in ipairs(RadioStationManager.Presets) do
        local item = self.m_Grid:addItem(v[1]..(tonumber(v[2]) and " [GTA-Radio] " or ""))
        item.m_StationData = {v[1], v[2]}
    end
end

function RadioStationPreviewGUI:destructor()
	GUIForm.destructor(self)
end

addCommandHandler("radio", function()
    RadioStationEditGUI:new()
end)
