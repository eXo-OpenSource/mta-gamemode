-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRaceGUI = inherit(GUIForm)
inherit(Singleton, TurtleRaceGUI)

function TurtleRaceGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 395)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schildkrötenrennen", true, true, self)

	GUILabel:new(5, 30, 540, 25, "Schildkröten sind perfekte Tiere, wenn es um Rennveranstaltungen und Kohle geht. Mit einer Geschwindigkeit von 1,8 bis 10 km/h sind sie schneller als Seesterne! Ihr Panzer macht etwa 30% ihres Gewichts aus und umschließt alle wichtigen Organe und Körperregionen. Unsere 6 Profis, die uns von Krötenprofi Diana freundlicherweiße zu Verfügung gestellt wurden, sind bereit für ein spannendes Rennen.\nPs. Am 23. Mai ist World Turtle Day (Welt-Schildkröten-Tag)!", self.m_Window):setMultiline(true)

	self.m_Turtles = {}
	self.m_Turtles[1] = GUIImage:new(5, 200, 85, 85, "files/images/TurtleRace/Turtle.png", self.m_Window):setColor(Color.Red)
	self.m_Turtles[2] = GUIImage:new(95, 200, 85, 85, "files/images/TurtleRace/Turtle.png", self.m_Window):setColor(Color.Blue)
	self.m_Turtles[3] = GUIImage:new(185, 200, 85, 85, "files/images/TurtleRace/Turtle.png", self.m_Window):setColor(Color.Green)
	self.m_Turtles[4] = GUIImage:new(275, 200, 85, 85, "files/images/TurtleRace/Turtle.png", self.m_Window):setColor(Color.Orange)
	self.m_Turtles[5] = GUIImage:new(365, 200, 85, 85, "files/images/TurtleRace/Turtle.png", self.m_Window):setColor(Color.LightRed)
	self.m_Turtles[6] = GUIImage:new(455, 200, 85, 85, "files/images/TurtleRace/Turtle.png", self.m_Window):setColor(Color.LightBlue)

	GUIImage:new(5, 200, 85, 85, "files/images/TurtleRace/Turtle-body.png", self.m_Window)
	GUIImage:new(95, 200, 85, 85, "files/images/TurtleRace/Turtle-body.png", self.m_Window)
	GUIImage:new(185, 200, 85, 85, "files/images/TurtleRace/Turtle-body.png", self.m_Window)
	GUIImage:new(275, 200, 85, 85, "files/images/TurtleRace/Turtle-body.png", self.m_Window)
	GUIImage:new(365, 200, 85, 85, "files/images/TurtleRace/Turtle-body.png", self.m_Window)
	GUIImage:new(455, 200, 85, 85, "files/images/TurtleRace/Turtle-body.png", self.m_Window)

	GUILabel:new(0, 275, 540, 20, _"(Klicke auf eine Schildkröte um sie auszuwählen)", self.m_Window):setAlignX("center")

	GUILabel:new(5, 300, 230, 30, _"Ausgewählte Schildkröte:", self.m_Window)
	self.m_SelectedTurtleLabel = GUILabel:new(235, 300, 50, 30, "-", self.m_Window)

	GUILabel:new(5, 330, 230, 30, _"Dein Einsatz:", self.m_Window)
	self.m_Bet = GUIEdit:new(235, 330, 100, 25, self.m_Window):setNumeric(true, true):setMaxValue(100000)

	for id, turtle in pairs(self.m_Turtles) do
		turtle.onLeftClick =
			function()
				self.m_SelectedTurtle = id
				self.m_SelectedTurtleLabel:setText(id)
			end
	end

	GUILabel:new(5, 360, 400, 30, "Möglicher Gewinn: 6-facher Einsatz!", self.m_Window)
	self.m_BetButton = GUIButton:new(self.m_Width - 155, 360, 150, 30, "Wette platzieren", self.m_Window):setFontSize(1)
	self.m_BetButton.onLeftClick = bind(self.placeBet, self)
end

function TurtleRaceGUI:placeBet()
	local betMoney = self.m_Bet:getText(true)
	local selectedTurtle = self.m_SelectedTurtle

	if not betMoney then WarningBox:new("Ungültige Eingabe!") return end
	if not selectedTurtle then WarningBox:new("Du hast keine Schildkröte ausgewählt!") return end

	QuestionBox:new(("Möchtest du wirklich %s$ auf die Schildkröte %d setzen?"):format(betMoney, selectedTurtle),
		function()
			triggerServerEvent("TurtleRaceAddBet", localPlayer, selectedTurtle, betMoney)
		end
	)

	delete(self)
end
