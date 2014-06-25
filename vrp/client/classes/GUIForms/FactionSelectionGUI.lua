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
	local sw, sh = guiGetScreenSize()
	GUIForm.constructor(self, 0, 0, sw, sh)
	
	self.m_Center = GUIRectangle:new(sw*0.5-sw/2*0.5, sh*0.1, sw/2, sh/1.25, tocolor(0, 0, 0, 128), self)
	self.m_LoginButton = VRPButton:new(0, 0, sw/2, sh*0.075, "Wähle deinen Pfad", false, self.m_Center)
	
	GUILabel:new(sw/4*0.05, sh/30*2.5, (sw/2-sw/4*0.1), sh*0.01, [[
	Wähle nun zunächst hier den Pfad, den dein Charakter beschreiten wird. Du hast die Wahl zwischen dem Leben eines ehrlichen Staatsbürgers und dem Leben eines Kriminellens.
	
	Hier evtl. später noch etwas mehr Text dazu schreiben...?
	
	]], self.m_Center):setAlign("left", "top"):setFont(VRPFont(sh*0.04))
	
	self.m_GoodButton = VRPButton:new(sw/4*0.05, sh/1.25*0.9, sw/4-sw/16, sh*0.06, "Ehrlich", true, self.m_Center)
	self.m_BadButton = VRPButton:new(sw/4*0.05+sw/4, sh/1.25*0.9, sw/4-sw/16, sh*0.06, "Kriminell", true, self.m_Center)
end

function FactionSelectionGUI:destructor()
	GUIForm.destructor(self)
end






















