VehicleModelSelectionGUI = inherit(GUIForm)
inherit(Singleton, VehicleModelSelectionGUI)

function VehicleModelSelectionGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 7) 	-- width of the window
	self.m_Height = grid("y", 9) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeugauswahl", true, true, self)

	self.m_Combo = GUIGridCombobox:new(1, 1, 6, 1, "Sortierung...", self.m_Window)
	self.m_Combo:addItem("A-Z")
	self.m_Combo:addItem("ID")
	self.m_Combo:addItem("Kategorie")

	self.m_Grid = GUIGridGridList:new(1, 2, 6, 6, self.m_Window)
	self.m_Grid:addColumn("verfügbare Modelle", 1)

	self.m_Btn = GUIGridButton:new(1, 8, 6, 1, "Auswählen", self.m_Window):setBarEnabled(false)
end
