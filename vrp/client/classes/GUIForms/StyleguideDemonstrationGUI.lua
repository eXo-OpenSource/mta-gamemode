-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StyleguideDemonstrationGUI.lua
-- *  PURPOSE:     overview of world items of a specified owner
-- *
-- ****************************************************************************
StyleguideDemonstrationGUI = inherit(GUIForm)
inherit(Singleton, StyleguideDemonstrationGUI)
LoginDemonstrationGUI = inherit(GUIForm)
inherit(Singleton, LoginDemonstrationGUI)

function StyleguideDemonstrationGUI:constructor()
	--main
	grid("reset", true)
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 15)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"StyleguideDemonstrationGUI", true, true, self)
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Allgemein", "weiteres"})
	self.m_TabPanel:updateGrid()

	--Tab 1

	GUIGridLabel:new(1, 1, 5, 1, _"Überschrift", self.m_Tabs[1]):setHeader()
	GUIGridLabel:new(1, 2, 5, 1, _"Zwischenüberschrift", self.m_Tabs[1]):setHeader("sub")
	GUIGridLabel:new(1, 3, 5, 1, _"Infotext / Label", self.m_Tabs[1])


	GUIGridLabel:new(11, 1, 9, 1, "Eine super tolle Liste!", self.m_Tabs[1]):setHeader("sub")
	GUIGridGridList:new(11, 2, 9, 10, self.m_Tabs[1]):addColumn(_"Name", 0.4):addColumn(_"Position", 0.6):setColumnBackgroundColor(Color.PrimaryNoClick)

	GUIGridIconButton:new(19, 2, FontAwesomeSymbols.Refresh, self.m_Tabs[1])

	GUIGridButton:new(7, 2, 4, 1, _"Hinzufügen", self.m_Tabs[1]):setBackgroundColor(Color.Red)
	GUIGridButton:new(7, 3, 4, 1, _"Entfernen", self.m_Tabs[1]):setBackgroundColor(Color.Green)
	GUIGridButton:new(7, 4, 4, 1, _"Nach oben", self.m_Tabs[1])
	GUIGridButton:new(7, 5, 4, 1, _"Nach unten", self.m_Tabs[1])
	GUIGridLabel:new(7, 6, 4, 2, _"Mehrzeiliger\nInfotext\nundso", self.m_Tabs[1])

	GUIGridCheckbox:new(1, 4, 4, 1, "GUIGridCheckbox", self.m_Tabs[1])
	local changer = GUIGridChanger:new(1, 5, 6, 1, self.m_Tabs[1])
	changer:addItem("No Pew")
	changer:addItem("Pew")
	changer:addItem("Pew Pew Pew")

	GUIGridButton:new(8, 14, 4, 1, "Übernehmen p.", self.m_Tabs[1]):setBarEnabled(false)
	GUIGridButton:new(12, 13, 4, 2, "Übernehmen\nZweizeiler", self.m_Tabs[1])
	GUIGridButton:new(16, 14, 4, 1, "Übernehmen", self.m_Tabs[1])

	GUIGridProgressBar:new(1, 9, 8, 1, self.m_Tabs[1]):setProgress(13.37):setText("für den Fortschritt!"):setProgressTextEnabled(true)
	GUIGridEdit:new(1, 10, 8, 1, self.m_Tabs[1]):setText("Dies sind die neuen Textboxen")
	GUIGridEdit:new(1, 11, 8, 1, self.m_Tabs[1]):setText("mit selektieren Funktion!")
	GUIGridLabel:new(1, 12, 4, 1, "Slider von 30 zu 40", self.m_Tabs[1])
	local coolSlider = GUIGridSlider:new(1, 13, 8, 1, self.m_Tabs[1])
	local label = GUIGridLabel:new(5, 12, 4, 1, "Slider-Value", self.m_Tabs[1])
	local label2 = GUIGridLabel:new(9, 12, 4, 1, "Slider-Value", self.m_Tabs[1])

	GUIGridSlider:new(1, 14, 1, 1, self.m_Tabs[1])

	coolSlider:setRange(30, 40)
	coolSlider:setValue(35)
	coolSlider.onUpdated = function(newValue)
		label:setText("onUpdated: "..newValue)
	end
	coolSlider.onUpdate = function(newValue)
		label2:setText("onUpdate: "..newValue)
	end

	--Tab 2
	local labelToggle = GUIGridLabel:new(1, 1, 4, 1, "Switch..", self.m_Tabs[2])
	local geilerToggler = GUIGridSwitch:new(1, 2, 3, 1, self.m_Tabs[2])

	geilerToggler.onChange =
		function(state)
			labelToggle:setText("onChange: " .. tostring(state))
		end
	local scrollArea = GUIGridScrollableArea:new(10, 1, 10, 10, 10, 20, true, false, self.m_Tabs[2], 1)
	scrollArea:updateGrid()
	GUIGridLabel:new(1, 1, 10, 1, _"irgendwelche Settings", scrollArea):setHeader()
	for i = 1, 5 do
		GUIGridLabel:new(1, i+1, 8, 1, "Setting "..i, scrollArea)
		GUIGridSwitch:new(7, i+1, 3, 1, scrollArea)
	end

	GUIGridLabel:new(1, 7, 4, 1, "Setting 6", scrollArea)
	GUIGridChanger:new(5, 7, 5, 1, scrollArea)

	GUIGridLabel:new(1, 8, 4, 1, "Setting 7", scrollArea)
	GUIGridSlider:new(5, 8, 5, 1, scrollArea)
	GUIGridButton:new(5, 9, 5, 1, "hi", scrollArea)

	for i = 10, 15 do
		GUIGridLabel:new(1, i+1, 8, 1, "Setting "..i, scrollArea)
		GUIGridCheckbox:new(9, i+1, 5, 1, "", scrollArea)
	end
end

function StyleguideDemonstrationGUI:destructor()
	GUIForm.destructor(self)
end

function LoginDemonstrationGUI:constructor()
	grid("reset", true)
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 11)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"", false, false, self)

	img = GUIGridImage:new(1, 1, 9, 2, "files/images/LogoNoFont.png", self.m_Window):fitBySize(285, 123)
	GUIGridLabel:new(1, 3, 9, 2, _"Herzlich willkommen auf eXo Reallife, bitte logge dich mit deinen Accountdaten ein.", self.m_Window):setAlignX("center")
	GUIGridEdit:new(1, 5, 9, 1, self.m_Window):setCaption("Username")
	GUIGridEdit:new(1, 6, 9, 1, self.m_Window):setCaption("Passwort"):setMasked("•")
	GUIGridLabel:new(1, 7, 6, 1, _"Passwort speichern", self.m_Window)
	GUIGridSwitch:new(7, 7, 3, 1, self.m_Window)

	GUIGridButton:new(1, 8, 9, 1, "Einloggen", self.m_Window):setBarEnabled(false).onLeftClick = function()
		self:fadeOut(7500)
		setTimer(function()
			self:close()
		end, 7500, 1)
	end
	self.m_Label = GUIGridLabel:new(1, 10, 9, 1, _"(Kein Account? Registriere dich noch heute!)", self.m_Window)
	self.m_Label:setAlignX("center")
	self.m_Label:setColor(Color.Accent)
end

addCommandHandler("styleguide", function(cmd)
	StyleguideDemonstrationGUI:getSingleton()
end)

addCommandHandler("loginpreview", function(cmd)
	LoginDemonstrationGUI:getSingleton():open()
end)
