-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TourGUI.lua
-- *  PURPOSE:     ServerTour Client
-- *
-- ****************************************************************************
TourGUI = inherit(GUIForm)
inherit(Singleton, TourGUI)

function TourGUI:constructor(title, description)
	GUIForm.constructor(self, screenWidth/2-250, 0, 500, 170, false)
	GUIImage:new(0, 0, self.m_Width-24, self.m_Height, "files/images/Other/Tour.png", self):setAlpha(220)
	self.m_Title = GUILabel:new(15, 50, self.m_Width-15, 30, title, self):setColor(Color.Accent)
	self.m_Description = GUILabel:new(15, 80, 300, 125, description, self):setFont(VRPFont(20)):setFontSize(0.9):setMultiline(true)
	self:setVisible(false)
	GUIForm.fadeIn(self, 750)
end
