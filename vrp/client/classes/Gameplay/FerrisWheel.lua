-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************

FerrisWheel = {}

function FerrisWheel.onClientClickedGond(ele)
    triggerServerEvent("onFerrisWheelGondClicked", ele)
end



FerrisWheelGUI = inherit(GUIForm)
inherit(Singleton, FerrisWheelGUI)

function FerrisWheelGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 10) 	-- width of the window
	self.m_Height = grid("y", 5) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Riesenrad", true, true, self)
	self.m_Label = GUIGridLabel:new(1,1,9,3, _"Mit einer Höhe von 32m und 10 Gondeln ist dieses Riesenrad das wohl spektakulärste in ganz San Andreas! Klicke auf eine Gondel, um für nur 10$ bis zu 2 Runden mitzufahren.", self.m_Window)
	self.m_Btn = GUIGridButton:new(3, 4, 5, 1, "Verstanden!", self.m_Window):setBarEnabled(false)
	self.m_Btn.onLeftClick = function ()
		self:delete()
	end
end

function FerrisWheelGUI:destructor()
	GUIForm.destructor(self)
end