-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ColorCars/ColorCarsLobbyGUI.lua
-- *  PURPOSE:     ColorCarsMatchGUI class
-- *
-- ****************************************************************************

ColorCarsMatchGUI = inherit(GUIForm)
inherit(Singleton, ColorCarsMatchGUI)

function ColorCarsMatchGUI:constructor()
    GUIForm.constructor(self, screenWidth*0.8, screenHeight - screenHeight*0.62, screenWidth*0.4, screenHeight*0.5, false)
    self.m_MatchWindow = GUIWindow:new(0, 0, 300, 300, "Match", true, false, self)
    
    self.m_MatchGridList = GUIGridList:new(self.m_PosX*0.004, self.m_PosY*0.1, 290, 220, self.m_MatchWindow)
    self.m_MatchGridList:addColumn(_"Spieler:", 0.5)
    self.m_MatchGridList:addColumn(_"Hat gefangen:", 0.5)


    self.m_LeaveButton = GUIButton:new(self.m_PosX*0, self.m_PosY*0.68, 300, 30, _"Lobby verlassen", self.m_MatchWindow)

    self.m_LeaveButton.onLeftClick =
    function()
        ColorCarsManager:getSingleton():removePlayer()
    end
end