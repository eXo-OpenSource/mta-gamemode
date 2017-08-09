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

	GUIGridLabel:new(1, 1, 5, 1, _"Überschrift", self):setHeader()
	GUIGridLabel:new(1, 2, 5, 1, _"Zwischenüberschrift", self):setHeader("sub")
	GUIGridLabel:new(1, 3, 5, 1, _"Infotext / Label", self)


	GUIGridLabel:new(11, 1, 9, 1, "Eine super tolle Liste!", self):setHeader("sub")
	GUIGridGridList:new(11, 2, 9, 10, self):addColumn(_"Name", 0.4):addColumn(_"Position", 0.6):setColumnBackgroundColor(Color.PrimaryNoClick)

	self.m_ListRefreshButton = GUIGridButton:new(19, 2, 1, 1, FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1):setBarEnabled(false)
	self.m_ListRefreshButton:setBackgroundColor(Color.Accent)

	GUIGridButton:new(7, 2, 4, 1, _"Hinzufügen", self):setBackgroundColor(Color.Red)
	GUIGridButton:new(7, 3, 4, 1, _"Entfernen", self):setBackgroundColor(Color.Green)
	GUIGridButton:new(7, 4, 4, 1, _"Nach oben", self)
	GUIGridButton:new(7, 5, 4, 1, _"Nach unten", self)
	GUIGridLabel:new(7, 6, 4, 2, _"Mehrzeiliger\nInfotext", self)

	GUIGridCheckbox:new(1, 4, 4, 1, "GUIGridCheckbox", self)
	local changer = GUIGridChanger:new(1, 5, 6, 1, self)
	changer:addItem("No Pew")
	changer:addItem("Pew")
	changer:addItem("Pew Pew Pew")

	GUIGridButton:new(8, 14, 4, 1, "Übernehmen p.", self):setBarEnabled(false)
	GUIGridButton:new(12, 13, 4, 2, "Übernehmen\nZweizeiler", self)
	GUIGridButton:new(16, 14, 4, 1, "Übernehmen", self)

	GUIGridProgressBar:new(1, 9, 8, 1, self):setProgress(13.37):setText("für den Fortschritt!"):setProgressTextEnabled(true)
	GUIGridEdit:new(1, 10, 8, 1, self):setText("Dies sind die neuen Textboxen")
	GUIGridEdit:new(1, 11, 8, 1, self):setText("mit selektieren Funktion!")
end

function StyleguideDemonstrationGUI:destructor()
	GUIForm.destructor(self)
end

addCommandHandler("styleguide", function(cmd)
	StyleguideDemonstrationGUI:getSingleton()
end)
