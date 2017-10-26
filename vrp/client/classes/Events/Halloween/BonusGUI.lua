-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/BonusGUI.lua
-- *  PURPOSE:     Halloween Bonus GUI
-- *
-- ****************************************************************************

BonusGUI = inherit(GUIForm)
inherit(Singleton, BonusGUI)

function BonusGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 12) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Halloween Bonus GUI", true, true, self)
	GUIGridLabel:new(1, 1, 15, 1, "Herzlich Willkommen beim Halloween Premium Shop!\nHier kannst du deine Kürbisse und Süßigkeiten in wertvolle Prämien umwandeln!", self.m_Window)
	self.m_ScrollArea =	GUIGridScrollableArea:new(1, 3, 15, 9, 10, 20, true, false, self.m_Window, 3)
	self.m_ScrollArea:updateGrid()
	self.m_BonusAmount = 0

	self.m_Column, self.m_Row = 1, 1

	self.m_BonusBG = {}

	self:addBonus()
	self:addBonus()
	self:addBonus()
	self:addBonus()
end

function BonusGUI:addBonus()
	self.m_Column = (self.m_BonusAmount*5)+1

	if self.m_BonusAmount > 0 and self.m_BonusAmount % 3 == 0 then self.m_Row = self.m_Row + 6 self.m_Column = 1 end

	local id = #self.m_BonusBG+1
	self.m_BonusBG[id] = GUIGridRectangle:new(self.m_Column, self.m_Row, 4, 5, Color.White, self.m_ScrollArea)
	GUIGridWebView:new(1, 2, 4, 3, "https://exo-reallife.de/images/veh/Vehicle_573.jpg", true, self.m_BonusBG[id])
	GUIGridRectangle:new(1, 1, 4, 1, Color.LightBlue, self.m_BonusBG[id])
	GUIGridLabel:new(1, 1, 4, 1, "Fahrzeug", self.m_BonusBG[id]):setAlignX("center")
	GUIGridButton:new(1, 5, 4, 1, "Kaufen", self.m_BonusBG[id])

	self.m_BonusAmount = self.m_BonusAmount + 1
end

function BonusGUI:destructor()
	GUIForm.destructor(self)
end
