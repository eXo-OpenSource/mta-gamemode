-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ColorCars/ColorCarsPasswordGUI.lua
-- *  PURPOSE:     ColorCarsPasswordGUI class
-- *
-- ****************************************************************************

ColorCarsPasswordGUI = inherit(GUIForm)
inherit(Singleton, ColorCarsPasswordGUI)

function ColorCarsPasswordGUI:constructor(marker)
    GUIForm.constructor(self, screenWidth/2 - screenWidth*0.175/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.175, screenHeight*0.2, true, false, marker)
    self.m_PasswordWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Lobby beitreten", true, true, self)
    
    self.m_PasswordLabel = GUILabel:new(self.m_PosX*0.07, self.m_PosY*0.1, 200, 30, _"Lobby Passwort:", self.m_PasswordWindow)
    self.m_PasswordEdit = GUIEdit:new(self.m_PosX*0.07, self.m_PosY*0.2, 200, 30, self.m_PasswordWindow)

    self.m_JoinLobbyButton = GUIButton:new(self.m_PosX*0.07, self.m_PosY*0.375, 200, 50, _"Lobby beitreten", self.m_PasswordWindow):setBackgroundColor(Color.Green)
    
    self.m_JoinLobbyButton.onLeftClick =
    function()
        local password = self.m_PasswordEdit:getText()
        if password == nil then
            return ErrorBox:new(_"Kein Passwort eingegeben.")
        end
        ColorCarsManager:getSingleton():requestPasswordCheck(password)
    end
end
