-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Cinema/CinemaVideoGUI.lua
-- *  PURPOSE:     CinemaVideoGUI class
-- *
-- ****************************************************************************

CinemaVideoGUI = inherit(GUIForm)
inherit(Singleton, CinemaVideoGUI)

function CinemaVideoGUI:constructor()
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	
	self.m_VideoWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Videoverwaltung", true, true, self)

    self.m_VideoLabel = GUIGridLabel:new(1, 1, 5, 1, _"Videoliste:", self.m_VideoWindow)
    self.m_VideoGrid = GUIGridGridList:new(1, 2, 15, 8, self.m_VideoWindow)
    self.m_VideoGrid:addColumn(_"Videotitel", 0.75)
    self.m_VideoGrid:addColumn(_"Hinzugefügt von", 0.25)

    self.m_VideoLabel2 = GUIGridLabel:new(1, 10, 5, 1, _"YouTube URL eingeben:", self.m_VideoWindow)
    self.m_VideoEdit  = GUIGridEdit:new(1, 11, 15, 1, self.m_VideoWindow)
    self.m_VideoEdit:setCaption(_"YouTube URL")

    self.m_VideoAddButton = GUIGridButton:new(10, 10, 6, 1, _"Hinzufügen", self.m_VideoWindow)
    self.m_VideoAddButton:setBackgroundColor(Color.Green)

    self.m_VideoPlayButton = GUIGridButton:new(6, 1, 5, 1, _"Abspielen", self.m_VideoWindow)
    self.m_VideoPlayButton:setBackgroundColor(Color.Green)

    self.m_VideoRemoveButton = GUIGridButton:new(11, 1 , 5, 1, _"Entfernen", self.m_VideoWindow)
    self.m_VideoRemoveButton:setBackgroundColor(Color.Red)

    self.m_VideoVolumeIcon = GUIGridLabel:new(6, 10, 1, 1, CinemaLobby:getSingleton().m_Browser:getVolume() ~= 0 and FontAwesomeSymbols.SoundOn or FontAwesomeSymbols.SoundOff, self.m_VideoWindow)
    self.m_VideoVolumeIcon:setFont(FontAwesome(22))

    self.m_VideoVolumeSlider = GUIGridSlider:new(7, 10, 3, 1, self.m_VideoWindow)
    self.m_VideoVolumeSlider:setRange(0, 100)
    self.m_VideoVolumeSlider:setValue(CinemaLobby:getSingleton().m_Browser:getVolume()*100)

    self.m_VideoVolumeSlider.onUpdate = 
    function(volume) 
        self.m_VideoVolumeIcon:setText(volume ~= 0 and FontAwesomeSymbols.SoundOn or FontAwesomeSymbols.SoundOff)
        CinemaLobby:getSingleton().m_Browser:setVolume(volume/100)
    end

    self.m_VideoAddButton.onLeftClick = 
    function()
        local URL = self.m_VideoEdit:getText()
        if string.find(URL, "https://www.youtube.com/watch?v=", 1, true) then
            CinemaLobby:getSingleton():queueAdd(URL)
        else
            ErrorBox:new(_"Dies ist kein gültiges YouTube Video!")
        end    
    end    

    self.m_VideoPlayButton.onLeftClick = 
    function()
        if self.m_VideoGrid:getSelectedItem() then
            local URL = self.m_VideoGrid:getSelectedItem().URL
            CinemaLobby:getSingleton():playVideo(URL)
        else
            ErrorBox:new(_"Bitte wähle ein Video aus!")
        end    
    end    

    self.m_VideoRemoveButton.onLeftClick = 
    function()
        if self.m_VideoGrid:getSelectedItem() then
            local URL = self.m_VideoGrid:getSelectedItem().URL
            CinemaLobby:getSingleton():removeVideo(URL)
        else
            ErrorBox:new(_"Bitte wähle ein Video aus!")
        end    
    end    
end  

function CinemaVideoGUI:addItemToList(title, playerName, URL)
    if self.m_VideoGrid then
        video = self.m_VideoGrid:addItem(title, playerName)
        video.URL = URL
    end
end

function CinemaVideoGUI:destructor()
    GUIForm.destructor(self)
end