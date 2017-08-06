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

	GUILabel:new(grid("x"), grid("y"), grid("d", 5), grid("d"), _"Zwischenüberschrift", self)
	GUILabel:new(grid("x"), grid("y", 2), grid("d", 5), grid("d"), _"Infotext / Label", self):setFont(VRPFont(25)):setAlignY("center")

	VRPButton:new(grid("x"), grid("y", 3), grid("d", 3), grid("d"), "1331", true, self)

	GUILabel:new(grid("x", 11), grid("y"), grid("d", 9), grid("d"), _"Eine tolle Liste", self)
	GUIGridList:new(grid("x", 11), grid("y", 2), grid("d", 9), grid("d", 10), self)
	:addColumn(_"Name", 0.4)
	:addColumn(_"Position", 0.6)
	:setColumnBackgroundColor(Color.Primary)
	self.m_ListRefreshButton = GUIButton:new(grid("x", 19), grid("y", 2), grid("d"), grid("d"), " "..FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1)
	self.m_ListRefreshButton:setBackgroundColor(Color.LightBlue)

	GUIGridButton:new(7, 2, 4, 1, _"Hinzufügen", self):setBackgroundColor(Color.Red)
	GUIGridButton:new(7, 3, 4, 1, _"Entfernen", self):setBackgroundColor(Color.Green)
	GUIGridButton:new(7, 4, 4, 1, _"Nach oben", self)
	GUIGridButton:new(7, 5, 4, 1, _"Nach unten", self)
	GUILabel:new(grid("x", 7), grid("y", 6), grid("d", 4), grid("d", 2), _"Mehrzeiliger\nInfotext", self):setFont(VRPFont(25)):setAlignY("center")


	GUIGridCheckbox:new(1, 4, 4, 1, "GUIGridCheckbox", self)
	GUIGridChanger:new(1, 5, 6, 1, self):addItem("GUIGridChanger")

	GUIGridButton:new(8, 14, 4, 1, "Übernehmen p.", self):setBarEnabled(false)
	GUIGridButton:new(12, 13, 4, 2, "Übernehmen\nZweizeiler", self)
	GUIGridButton:new(16, 14, 4, 1, "Übernehmen", self)

	GUIEdit:new(grid("x"), grid("y", 10), grid("d", 5), grid("d"), self):setText("Dies ist ein Edit!")
end

function StyleguideDemonstrationGUI:destructor()
	GUIForm.destructor(self)
end

addCommandHandler("styleguide", function(cmd)
	StyleguideDemonstrationGUI:getSingleton()
end)
