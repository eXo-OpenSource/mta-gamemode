-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HighscoreGUI.lua
-- *  PURPOSE:     HighscoreGUI class
-- *
-- ****************************************************************************
HighscoreGUI = inherit(GUIForm)
inherit(Singleton, HighscoreGUI)

HighscoreGUI.Scores = {
	[1] = {["name"] = "Global", ["data"] = "global"},
	[2] = {["name"] = "Monatlich", ["data"] = "monthly"},
	[3] = {["name"] = "Wöchentlich", ["data"] = "weekly"},
	[4] = {["name"] = "Täglich", ["data"] = "dayly"},
}

function HighscoreGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-440/2, screenHeight/2-230, 440, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Game-Name Highscore", true, true, self)

	self.m_TabPanel = GUITabPanel:new(0, 40, self.m_Width, self.m_Height-50, self)
	self.m_Tabs = {}
	self.m_GridList = {}

	for index, score in pairs(HighscoreGUI.Scores) do
		self.m_Tabs[score["data"]] = self.m_TabPanel:addTab(_("%s", score["name"]))
		self.m_GridList[score["data"]] = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-30, self.m_Tabs[score["data"]])
		self.m_GridList[score["data"]]:addColumn(_"Spieler", 0.7)
		self.m_GridList[score["data"]]:addColumn(_"Score", 0.3)
	end
end
