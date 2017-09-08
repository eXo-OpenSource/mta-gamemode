-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRaceGUI = inherit(GUIForm)
TurtleRaceGUI.Bets = {100, 1000, 5000, 10000, 50000, 100000}
inherit(Singleton, TurtleRaceGUI)

function TurtleRaceGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schildkrötenrennen", true, true, self)

	GUILabel:new(5, 30, 540, 25, "Nicer dicer text @ here", self.m_Window):setMultiline(true)

	self.m_Turtles = {}
	self.m_Turtles[1] = GUIRectangle:new(5, self.m_Height*0.32, 85, 85, Color.Red, self.m_Window)
	self.m_Turtles[2] = GUIRectangle:new(95, self.m_Height*0.32, 85, 85, Color.Blue, self.m_Window)
	self.m_Turtles[3] = GUIRectangle:new(185, self.m_Height*0.32, 85, 85, Color.Green, self.m_Window)
	self.m_Turtles[4] = GUIRectangle:new(275, self.m_Height*0.32, 85, 85, Color.Orange, self.m_Window)
	self.m_Turtles[5] = GUIRectangle:new(365, self.m_Height*0.32, 85, 85, Color.LightRed, self.m_Window)
	self.m_Turtles[6] = GUIRectangle:new(455, self.m_Height*0.32, 85, 85, Color.LightBlue, self.m_Window)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.6, self.m_Height*0.07, _"Ausgewählte Schildkröte:", self.m_Window)
	self.m_SelectedTurtleLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.6, self.m_Width*0.28, self.m_Height*0.07, "-", self.m_Window)

	for id, turtle in pairs(self.m_Turtles) do
		turtle.onLeftClick =
			function()
				self.m_SelectedTurtle = id
				self.m_SelectedTurtleLabel:setText(id)
			end
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.28, self.m_Height*0.07, _"Dein Einsatz:", self.m_Window)
	self.m_Bet = GUIChanger:new(self.m_Width*0.3, self.m_Height*0.7, self.m_Width*0.4, self.m_Height*0.07, self.m_Window)
	for _, betAmount in ipairs(TurtleRaceGUI.Bets) do
		self.m_Bet:addItem(("%d$"):format(betAmount))
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.8, self.m_Height*0.06, "Möglicher Gewinn: 6-facher Einsatz!", self.m_Window)

	self.m_BetButton = VRPButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.078, self.m_Width*0.3, self.m_Height*0.07, "Wette platzieren", true, self.m_Window)
	self.m_BetButton.onLeftClick = bind(self.placeBet, self)
end

function TurtleRaceGUI:placeBet()
	local text, id = self.m_Bet:getSelectedItem()
	local betMoney = TurtleRaceGUI.Bets[id]
	local selectedTurtle = self.m_SelectedTurtle

	QuestionBox:new(("Möchtest du wirklich %s$ auf die Schildkröte %d setzen?"):format(betMoney, selectedTurtle),
		function()
			triggerServerEvent("TurtleRaceAddBet", localPlayer, selectedTurtle, betMoney)
		end
	)

	delete(self)
end
