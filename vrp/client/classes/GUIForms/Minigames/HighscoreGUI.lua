-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HighscoreGUI.lua
-- *  PURPOSE:     HighscoreGUI class
-- *
-- ****************************************************************************
HighscoreGUI = inherit(GUIForm)
inherit(Singleton, HighscoreGUI)

addRemoteEvents{"showHighscoreGUI", "highscoreReceiveData"}


function HighscoreGUI:constructor(game)
	HighscoreGUI.Scores = { -- because translation is not loaded if table is outside of class
		[1] = {["name"] = _"Global", ["data"] = "Global"},
		[2] = {["name"] = _"Jährlich", ["data"] = "Yearly"},
		[3] = {["name"] = _"Monatlich", ["data"] = "Monthly"},
		[4] = {["name"] = _"Wöchentlich", ["data"] = "Weekly"},
		[5] = {["name"] = _"Täglich", ["data"] = "Daily"}
	}

	GUIForm.constructor(self, screenWidth/2-540/2, screenHeight/2-230, 540, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, MinigameGUI.Data[game]["title"].." Highscore", true, true, self)

	self.m_TabPanel = GUITabPanel:new(0, 40, self.m_Width, self.m_Height-50, self)
	self.m_Tabs = {}
	self.m_GridList = {}

	for index, score in ipairs(HighscoreGUI.Scores) do
		self.m_Tabs[score["data"]] = self.m_TabPanel:addTab(score["name"])
		self.m_GridList[score["data"]] = GUIGridList:new(10, 10, self.m_Width-20, self.m_Height-50, self.m_Tabs[score["data"]])
		self.m_GridList[score["data"]]:addColumn(_"Spieler", 0.7)
		self.m_GridList[score["data"]]:addColumn(_"Score", 0.3)
	end

	self.m_fnReceiveHighscores = bind(self.receiveScores, self)
	addEventHandler("highscoreReceiveData", root, self.m_fnReceiveHighscores)

	triggerServerEvent("highscoreRequestData", localPlayer, game)
end

function HighscoreGUI:virtual_destructor()
	removeEventHandler("highscoreReceiveData", root, self.m_fnReceiveHighscores)
end

function HighscoreGUI:receiveScores(tbl)
	for index, score in pairs(HighscoreGUI.Scores) do
		self.m_GridList[score["data"]]:clear()
		if tbl[score["data"]] then
			for index2, score2 in ipairs(tbl[score["data"]]) do
				self.m_GridList[score["data"]]:addItem(score2.name, score2.score)
			end
		end
	end
end

addEventHandler("showHighscoreGUI", root,
	function(game)
		HighscoreGUI:new(game)
	end
)
