-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
TurtleRaceGUI = inherit(GUIForm)
TurtleRaceGUI.Bets = {100, 1000, 5000, 10000, 50000, 100000, 500000}
inherit(Singleton, TurtleRaceGUI)

function TurtleRaceGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schildkrötenrennen", true, true, self)

	GUILabel:new(5, 30, 540, 25, "Nicer dicer text @ here", self.m_Window):setMultiline(true)

	--[[GUILabel:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.28, self.m_Height*0.07, _"Dein Einsatz:", self.m_Window)
	self.m_Bet = GUIChanger:new(self.m_Width*0.3, self.m_Height*0.7, self.m_Width*0.4, self.m_Height*0.07, self.m_Window)
	for _, betAmount in ipairs(TurtleRaceGUI.Bets) do
		self.m_Bet:addItem(("%d$"):format(betAmount))
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.8, self.m_Height*0.06, "Möglicher Gewinn: 3-facher Einsatz!", self.m_Window)

	self.m_BetButton = VRPButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.078, self.m_Width*0.3, self.m_Height*0.07, "Wette platzieren", true, self.m_Window)
	self.m_BetButton.onLeftClick = bind(self.placeBet, self)]]
end

function TurtleRaceGUI:placeBet()
	local betText, betId = self.m_Bet:getSelectedItem()

	QuestionBox:new(("Möchtest du wirklich %s$ auf die Schildkröte %d setzen?"):format(betText, 1),
		function()
			delete(self)
			triggerServerEvent("TurtleRaceAddBet", root)
		end
	)
end
