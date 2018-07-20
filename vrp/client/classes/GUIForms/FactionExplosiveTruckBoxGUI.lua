-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionExplosiveTruckBoxGUI.lua
-- *  PURPOSE:     FactionExplosiveTruckBoxGUI class
-- *
-- ****************************************************************************

FactionExplosiveTruckBoxGUI = inherit(GUIRectangle)
inherit(Singleton, FactionExplosiveTruckBoxGUI)

function FactionExplosiveTruckBoxGUI:constructor()
	GUIRectangle.constructor(self, screenWidth-200, screenHeight/2-60/2, 160, 60, false)
	self:setColor(tocolor(0, 0, 0, 150))
	GUILabel:new(0, 0, self.m_Width, 30, "Kisteninhalt:", self):setAlignX("center"):setAlignY("center"):setColor(Color.LightBlue)
	self.m_ContentLabel = GUILabel:new(5, 30, self.m_Width, 25, "Sprengstoff", self):setAlignX("center")
end
