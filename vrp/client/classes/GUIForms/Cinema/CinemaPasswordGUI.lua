-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Cinema/CinemaPasswordGUI.lua
-- *  PURPOSE:     CinemaPasswordGUI class
-- *
-- ****************************************************************************

CinemaPasswordGUI = inherit(GUIForm)
inherit(Singleton, CinemaPasswordGUI)

function CinemaPasswordGUI:constructor(lobbyHost, position)
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 5)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, position)
	
	self.m_PasswordWindow = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Passwort eingeben", true, true, self)

    self.m_PasswordEdit  = GUIGridEdit:new(2, 2, 5, 1, self.m_PasswordWindow)
    self.m_PasswordEdit:setCaption(_"Passwort")
    self.m_PasswordEdit:setMasked(_"*")

    self.m_PasswordButton = GUIGridButton:new(2, 3, 5, 1, _"Beitreten", self.m_PasswordWindow)
    self.m_PasswordButton:setBackgroundColor(Color.Green)

    self.m_PasswordButton.onLeftClick = 
    function()
        local enteredPassword = self.m_PasswordEdit:getText()  
        CinemaManager:getSingleton():validatePassword(enteredPassword, lobbyHost)         
    end    
end    

function CinemaPasswordGUI:destructor()
    GUIForm.destructor(self)
end