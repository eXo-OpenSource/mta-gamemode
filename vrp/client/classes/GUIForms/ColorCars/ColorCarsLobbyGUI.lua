-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ColorCars/ColorCarsLobbyGUI.lua
-- *  PURPOSE:     ColorCarsLobbyGUI class
-- *
-- ****************************************************************************

ColorCarsLobbyGUI = inherit(GUIForm)
inherit(Singleton, ColorCarsLobbyGUI)

function ColorCarsLobbyGUI:constructor(marker)
    GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.5/2, screenWidth*0.4, screenHeight*0.5, true, false, marker)
    self.m_LobbyWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"ColorCars Lobbys", true, true, self)

    self.m_JoinLobbyButton = GUIButton:new(self.m_PosX*0.9, self.m_PosY*0.3, 200, 50, _"Lobby beitreten", self.m_LobbyWindow):setBackgroundColor(Color.Green)

    self.m_CreateLobbyButton = GUIButton:new(self.m_PosX*0.9, self.m_PosY*0.6, 200, 50, _"Lobby erstellen", self.m_LobbyWindow)

    self.m_InfoLabel = GUILabel:new(self.m_PosX*0.05, self.m_PosY*0.175, 600, 20, _"INFO: Beim betreten der Lobby, verlierst du deine Waffen.", self.m_LobbyWindow)
    self.m_InfoLabel:setColorRGB(192, 7, 7)

    self.m_LobbyGridList = GUIGridList:new(self.m_PosX*0.05, self.m_PosY*0.3, 350, 430, self.m_LobbyWindow)
    self.m_LobbyGridList:addColumn(_"Name", 0.5)
    self.m_LobbyGridList:addColumn(_"Spieler", 0.25)
    self.m_LobbyGridList:addColumn(_"Passwort", 0.2)

    self.m_JoinLobbyButton.onLeftClick =
    function()
        if localPlayer:isDead() then return ErrorBox:new(_"Tote Spieler können keine Lobbys erstellen!") end
        
        if self.m_LobbyGridList:getSelectedItem() then
            local lobby = self.m_LobbyGridList:getSelectedItem().m_Lobby
            if self.m_LobbyGridList:getSelectedItem().m_HasPassword then
                ColorCarsManager:getSingleton():openPasswordGUI(lobby, marker)
            else
                ColorCarsManager:getSingleton():requestMaxPlayersCheck(lobby)
            end
        end
    end

    self.m_CreateLobbyButton.onLeftClick =
    function()
        if localPlayer:isDead() then return ErrorBox:new(_"Tote Spieler können keine Lobbys erstellen!") end
        
        ColorCarsManager:getSingleton():openCreateLobbyGUI(marker)
    end
end