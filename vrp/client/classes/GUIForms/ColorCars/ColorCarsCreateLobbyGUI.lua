-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ColorCars/ColorCarsCreateLobbyGUI.lua
-- *  PURPOSE:     ColorCarsCreateLobbyGUI class
-- *
-- ****************************************************************************

ColorCarsCreateLobbyGUI = inherit(GUIForm)
inherit(Singleton, ColorCarsCreateLobbyGUI)

function ColorCarsCreateLobbyGUI:constructor(marker)
    GUIForm.constructor(self, screenWidth/2 - screenWidth*0.175/2, screenHeight/2 - screenHeight*0.5/2, screenWidth*0.175, screenHeight*0.5, true, false, marker)
    self.m_CreateLobbyWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Lobby erstellen", true, true, self)

    self.m_NameLabel = GUILabel:new(self.m_PosX*0.07, self.m_PosY*0.3, 200, 30, _"Lobby Name:", self.m_CreateLobbyWindow)
    self.m_NameEdit = GUIEdit:new(self.m_PosX*0.07, self.m_PosY*0.4, 200, 30, self.m_CreateLobbyWindow)
    
    self.m_PasswordLabel = GUILabel:new(self.m_PosX*0.07, self.m_PosY*0.55, 200, 30, _"Lobby Passwort:", self.m_CreateLobbyWindow)
    self.m_PasswordEdit = GUIEdit:new(self.m_PosX*0.07, self.m_PosY*0.65, 200, 30, self.m_CreateLobbyWindow)

    self.m_MaxPlayerLabel = GUILabel:new(self.m_PosX*0.07, self.m_PosY*1, 200, 30, _"Maximale Spieler:", self.m_CreateLobbyWindow)
    self.m_MaxPlayerChanger = GUIChanger:new(self.m_PosX*0.07, self.m_PosY*1.1, 200, 40, self.m_CreateLobbyWindow)
    for i = 2, 10 do
        self.m_MaxPlayerChanger:addItem(i)
    end

    self.m_CreateButton = GUIButton:new(self.m_PosX*0.07, self.m_PosY*1.7, 200, 50, _"Lobby erstellen (1000$)", self.m_CreateLobbyWindow):setBackgroundColor(Color.Green):setFontSize(0.75)

    self.m_CreateButton.onLeftClick = 
    function()
        local name = self.m_NameEdit:getText()
        local password = self.m_PasswordEdit:getText()
        local maxPlayers = self.m_MaxPlayerChanger:getIndex()

        if localPlayer:isDead() then return ErrorBox:new(_"Tote Spieler können keine Lobbys erstellen!") end
        if #name > 20 then return ErrorBox:new(_"Der Name ist zu lang.") end
     
        if #name == 0 then
            name = localPlayer:getName()
        end

    ColorCarsManager:getSingleton():createLobby(name, password, maxPlayers)
    end
end