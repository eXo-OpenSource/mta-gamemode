-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionSelectionGUI.lua
-- *  PURPOSE:     Faction selection GUI
-- *
-- ****************************************************************************
FactionSelectionGUI = inherit(GUIForm)
inherit(Singleton, FactionSelectionGUI)

function FactionSelectionGUI:constructor()
	local screenWidth, screenHeight = guiGetScreenSize()
	GUIForm.constructor(self, screenWidth*0.5-screenWidth/2*0.5, screenHeight/2-screenHeight*0.25, screenWidth/2, screenHeight*0.5)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Wähle deinen Pfad", true, false, self)
	--self.m_LoginButton = GUIButton:new(0, 0, screenWidth/2, screenHeight*0.075, "Wähle deinen Pfad", self.m_Window):setBarEnabled(true)

	GUILabel:new(screenWidth/4*0.05, screenHeight/30*1.6, (screenWidth/2-screenWidth/4*0.1), screenHeight*0.01, [[
	Wähle nun zunächst den Pfad, den dein Charakter beschreiten wird. Du hast die Wahl zwischen dem Leben eines ehrlichen Staatsbürgers und dem Leben eines Kriminellens.

	Solange du noch nicht viel negatives Karma gesammelt hast, kannst du noch relativ schnell zum ehrlichen Weg wechseln. Bei viel negativem Karma musst du viele gute Taten vollbringen.

	Als Alternative kannst du im Einstellungsmenü dein Karma für 1.000.000$ auf 0 setzen. Deine Erfahrungspunkte und Level behälst du jedoch.

	]], self.m_Window):setAlign("left", "top"):setFont(VRPFont(screenHeight*0.04))

	self.m_GoodButton = GUIButton:new(self.m_Width*0.05, self.m_Height*0.85, self.m_Width*0.3, self.m_Height*0.1, "Ehrlich", self.m_Window):setBackground(Color.Green):setBarEnabled(true)
	self.m_BadButton = GUIButton:new(self.m_Width*0.65, self.m_Height*0.85, self.m_Width*0.3, self.m_Height*0.1, "Kriminell", true, self.m_Window):setBackground(Color.Red):setBarEnabled(true)
end

function FactionSelectionGUI:destructor()
	GUIForm.destructor(self)
end
