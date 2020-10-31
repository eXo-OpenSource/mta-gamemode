-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Cinema/CinemaCreateLobbyGUI.lua
-- *  PURPOSE:     CinemaCreateLobbyGUI class
-- *
-- ****************************************************************************

CinemaCreateLobbyGUI = inherit(GUIForm)
inherit(Singleton, CinemaCreateLobbyGUI)

function CinemaCreateLobbyGUI:constructor(position)
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
    self.m_Height = grid("y", 12)
    
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, position)
	
	self.m_CreateLobbyWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kino Lobby erstellen", true, true, self)

    self.m_CreateLobbyNameLabel = GUIGridLabel:new(2, 1, 5, 1, _"Lobby Name:", self.m_CreateLobbyWindow)
    self.m_CreateLobbyNameEdit  = GUIGridEdit:new(2, 2, 5, 1, self.m_CreateLobbyWindow)
    self.m_CreateLobbyNameEdit:setCaption(_"Name")

    self.m_CreateLobbyPasswordLabel = GUIGridLabel:new(2, 3, 5, 1, _"Passwort:", self.m_CreateLobbyWindow)
    self.m_CreateLobbyPasswordEdit  = GUIGridEdit:new(2, 4, 5, 1, self.m_CreateLobbyWindow)
    self.m_CreateLobbyPasswordEdit:setCaption(_"Passwort")
    self.m_CreateLobbyPasswordEdit:setMasked(_"*")

    self.m_CreateLobbySetting1Label   = GUIGridLabel:new(2, 6, 5, 1, _"Videos hinzufügen:", self.m_CreateLobbyWindow)
	self.m_CreateLobbySetting1Changer = GUIGridChanger:new(2, 7, 5, 1, self.m_CreateLobbyWindow)
    self.m_CreateLobbySetting1Changer:addItem(_"Nur Host")
    self.m_CreateLobbySetting1Changer:addItem(_"Alle")

    self.m_CreateLobbySetting2Label   = GUIGridLabel:new(2, 8, 5, 1, _"Abspielen / Entfernen:", self.m_CreateLobbyWindow)
	self.m_CreateLobbySetting2Changer = GUIGridChanger:new(2, 9, 5, 1, self.m_CreateLobbyWindow)
    self.m_CreateLobbySetting2Changer:addItem(_"Nur Host")
    self.m_CreateLobbySetting2Changer:addItem(_"Alle")

    self.m_CreateLobbyButton = GUIGridButton:new(2, 11, 5, 1, _"Lobby erstellen", self.m_CreateLobbyWindow)
    self.m_CreateLobbyButton:setBackgroundColor(Color.Green)

    self.m_CreateLobbyButton.onLeftClick = 
    function() 
        local lobbyName     = self.m_CreateLobbyNameEdit:getText()
        local lobbyPassword = self.m_CreateLobbyPasswordEdit:getText()
        local settingVideoAddHostOnly = self.m_CreateLobbySetting1Changer:getIndex()
        local settingManageVideoHostOnly = self.m_CreateLobbySetting2Changer:getIndex()

        if #lobbyName > 20 then
            ErrorBox:new(_"Der Lobbyname ist zu lang!")
            return
        end

        if #lobbyPassword > 20 then    
            ErrorBox:new(_"Das Passwort ist zu lang!")
            return
        end

        if #lobbyName == 0 then
            lobbyName = _("%s's Raum", localPlayer:getName())
        end        
    
        local settingVideoAddHostOnly = (settingVideoAddHostOnly == _"Nur Host")
        local settingManageVideoHostOnly = (settingManageVideoHostOnly == _"Nur Host")
        
        CinemaManager:getSingleton():createLobby(lobbyName, lobbyPassword, settingVideoAddHostOnly, settingManageVideoHostOnly)    
        CinemaManager:getSingleton():closeGUI() 
    end
end    

function CinemaCreateLobbyGUI:destructor()
    GUIForm.destructor(self)
end