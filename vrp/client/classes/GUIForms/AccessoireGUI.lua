-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AccesoireGUI.lua
-- *  PURPOSE:     AccesoireGUI
-- *
-- ****************************************************************************
AccessoireGUI = inherit(GUIForm)

function AccessoireGUI:constructor()
	GUIForm.constructor(self, screenWidth*0.1, screenHeight*0.3, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4)
	do
		self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kleidungszubehör", false, true, self)
		GUILabel:new(6, self.m_Height*0.05, self.m_Width-12, self.m_Height*0.15, _"Wählen Sie einen Gegenstand", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("top"):setColor(Color.White)
		self.m_AccessoireList = GUIGridList:new(0, self.m_Height*0.11, self.m_Width, self.m_Height*0.72, self.m_Window)
        self.m_AccessoireList:addColumn(_"Name", 1)
		GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
	end
end
