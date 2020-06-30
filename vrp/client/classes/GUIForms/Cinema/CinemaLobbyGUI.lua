-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Cinema/CinemaLobbyGUI.lua
-- *  PURPOSE:     CinemaLobbyGUI class
-- *
-- ****************************************************************************

CinemaLobbyGUI = inherit(GUIForm)
inherit(Singleton, CinemaLobbyGUI)

function CinemaLobbyGUI:constructor(position)
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 11)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, position)
    self.m_LobbyWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kino Lobbys", true, true, self)
    self.m_LobbyWindow:addHelpButton(LexiconPages.Cinema)
    self.m_LobbyGrid = GUIGridGridList:new(1, 2, 15, 7, self.m_LobbyWindow)
    self.m_LobbyGrid:addColumn(_"Lobby Name", 0.4)
    self.m_LobbyGrid:addColumn(_"Host", 0.4)
    self.m_LobbyGrid:addColumn(_"Passwort", 0.2)

    self.m_CreateLobbyButton = GUIGridButton:new(2, 9, 13, 1, _"Lobby erstellen", self.m_LobbyWindow)
    self.m_CreateLobbyButton:setBackgroundColor(Color.LightBlue)

    self.m_JoinLobbyButton = GUIGridButton:new(2, 10, 5, 1, _"Beitreten", self.m_LobbyWindow)
    self.m_JoinLobbyButton:setBackgroundColor(Color.Green)
	
	if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["cinemaRemoveLobby"] then
          self.m_AdminRemoveLobbyButton = GUIGridButton:new(12, 1, 4, 1, _"Lobby löschen",  self.m_LobbyWindow)
          self.m_AdminRemoveLobbyButton:setBackgroundColor(Color.Red)

          self.m_AdminRemoveLobbyButton.onLeftClick = 
          function()
              if self.m_LobbyGrid:getSelectedItem() then
                   local lobbyHost = self.m_LobbyGrid:getSelectedItem().Host
                   triggerServerEvent("Cinema_AdminRemoveLobby", resourceRoot, lobbyHost)
                   CinemaManager:getSingleton():lobbyGUI()
                   InfoBox:new(_"Lobby wurde gelöscht!")
               else
                   ErrorBox:new(_"Es ist keine Lobby ausgewählt!") 
            end
        end
    end
    
    self.m_CreateLobbyButton.onLeftClick = 
    function() 
        CinemaManager:getSingleton():createLobbyGUI() 
    end

    self.m_JoinLobbyButton.onLeftClick = 
    function() 
        if self.m_LobbyGrid:getSelectedItem() then
            local lobbyHost     = self.m_LobbyGrid:getSelectedItem().Host
            local lobbyPassword = self.m_LobbyGrid:getSelectedItem().Password

            if lobbyHost and not(lobbyPassword) then
                CinemaManager:getSingleton():closeGUI()
                CinemaManager:getSingleton():addPlayerToLobby(lobbyHost)

            elseif lobbyHost and lobbyPassword then
                CinemaManager:getSingleton():PasswordGUI(lobbyHost)
            end
                
        else
            ErrorBox:new(_"Es ist keine Lobby ausgewählt!")    
        end

    end
end   

function CinemaLobbyGUI:addItemToList(player, info)
    if self.m_LobbyGrid then
        lobby = self.m_LobbyGrid:addItem(info.lobbyName, player:getName(), info.lobbyPassword and _"Ja" or _"Nein")
        lobby.Host     = player
        lobby.Password = info.lobbyPassword  
    end
end

function CinemaLobbyGUI:destructor()
    GUIForm.destructor(self)
end