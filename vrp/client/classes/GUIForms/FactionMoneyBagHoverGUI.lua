-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionMoneyBagHoverGUI.lua
-- *  PURPOSE:     FactionMoneyBagHoverGUI class
-- *
-- ****************************************************************************

FactionMoneyBagHoverGUI = inherit(GUIRectangle)
inherit(Singleton, FactionMoneyBagHoverGUI)

function FactionMoneyBagHoverGUI:constructor(bag)
	self.m_CurrentBag = bag
	GUIRectangle.constructor(self, screenWidth-200, screenHeight/2-60/2, 160, 60, false)
	self:setColor(tocolor(0,0,0,150))
	GUILabel:new(0, 0, self.m_Width, 30, "Geldsack Inhalt:", self):setAlignX("center"):setAlignY("center"):setColor(Color.LightBlue)
	self.m_ContentLabel = GUILabel:new(5, 30, self.m_Width, 25, getElementData(self.m_CurrentBag, "Money").."$", self):setAlignX("center")
end