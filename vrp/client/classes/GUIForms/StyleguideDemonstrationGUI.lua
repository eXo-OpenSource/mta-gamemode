-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StyleguideDemonstrationGUI.lua
-- *  PURPOSE:     overview of world items of a specified owner
-- *
-- ****************************************************************************
StyleguideDemonstrationGUI = inherit(GUIForm)
inherit(Singleton, StyleguideDemonstrationGUI)

function StyleguideDemonstrationGUI:constructor()
	--main
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 15)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"StyleguideDemonstrationGUI", true, true, self)

	GUIGridLabel:new(1, 1, 5, 1, _"Zwischenüberschrift", self)
	GUIGridLabel:new(1, 2, 5, 1, _"Infotext / Label", self):setFont(VRPFont(25)):setAlignY("center")

	VRPButton:new(grid("x"), grid("y", 3), grid("d", 3), grid("d"), "1331", true, self)

	GUIGridLabel:new(11, 1, 9, 1, "Eine super tolle Liste!", self)
	GUIGridGridList:new(11, 2, 9, 10, self):addColumn(_"Name", 0.4):addColumn(_"Position", 0.6):setColumnBackgroundColor(Color.Primary)

	self.m_ListRefreshButton = GUIGridButton:new(19, 2, 1, 1, FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
	self.m_ListRefreshButton:setBackgroundColor(Color.LightBlue)

	GUIGridButton:new(7, 2, 4, 1, _"Hinzufügen", self):setBackgroundColor(Color.Red)
	GUIGridButton:new(7, 3, 4, 1, _"Entfernen", self):setBackgroundColor(Color.Green)
	GUIGridButton:new(7, 4, 4, 1, _"Nach oben", self)
	GUIGridButton:new(7, 5, 4, 1, _"Nach unten", self)
	GUIGridLabel:new(7, 6, 4, 2, _"Mehrzeiliger\nInfotext", self):setFont(VRPFont(25)):setAlignY("center")

	GUIGridCheckbox:new(1, 4, 4, 1, "GUIGridCheckbox", self)
	GUIGridChanger:new(1, 5, 6, 1, self):addItem("GUIGridChanger")

	GUIGridButton:new(8, 14, 4, 1, "Übernehmen p.", self):setBarEnabled(false)
	GUIGridButton:new(12, 13, 4, 2, "Übernehmen\nZweizeiler", self)
	GUIGridButton:new(16, 14, 4, 1, "Übernehmen", self)

	GUIGridEdit:new(1, 10, 8, 1, self):setText("Dies sind die neuen Textboxen")
	GUIGridEdit:new(1, 11, 8, 1, self):setText("mit selektieren Funktion!")
end

function StyleguideDemonstrationGUI:destructor()
	GUIForm.destructor(self)
end

addCommandHandler("styleguide", function(cmd)
	StyleguideDemonstrationGUI:getSingleton()
end)
