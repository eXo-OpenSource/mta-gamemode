-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ScoreboardGUI.lua
-- *  PURPOSE:     Scoreboard class
-- *
-- ****************************************************************************
ScoreboardGUI = inherit(GUIForm)
inherit(Singleton, ScoreboardGUI)

function ScoreboardGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.25 / ASPECT_RATIO_MULTIPLIER, screenHeight/2-screenHeight*0.3, screenWidth*0.5, screenHeight*0.6)
	
	self.m_Rect = GUIRoundedRect:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_Logo = GUIImage:new(math.floor(self.m_Width/2-self.m_Width*0.25*0.5), -20, math.floor(self.m_Width*0.25), math.floor(self.m_Height*0.33), "files/images/Logo.png", self.m_Rect)
	
end
