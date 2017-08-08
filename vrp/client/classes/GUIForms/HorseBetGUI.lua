-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HorseBetGUI.lua
-- *  PURPOSE:     HorseBetGUI class
-- *
-- ****************************************************************************
HorseBetGUI = inherit(GUIForm)
HorseBetGUI.Bets = {10, 100, 1000, 5000, 10000, 50000, 100000}
inherit(Singleton, HorseBetGUI)

addRemoteEvents{"showHorseBetGUI", "receiveKartDatas"}

function HorseBetGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Pferdewetten", true, true, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.96, self.m_Height*0.05, _"Das Pferderennen findet täglich um 20:00 Uhr statt, du kannst es dir Live ansehen. \nNatürlich bekommst du auch ohne Ansehen der Live-Übertragung deinen Gewinn, und ebenso wenn du offline bist!", self.m_Window):setMultiline(true)

	local imgX, imgY = self.m_Width*0.18, self.m_Width*0.146

	GUIImage:new(self.m_Width*0.02, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_1.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*1, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_2.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*2, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_3.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*3, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_4.png", self.m_Window)

	self.m_HorseGroup = GUIRadioButtonGroup:new(0, self.m_Height*0.35+imgY, self.m_Width, self.m_Height*0.04, self.m_Window)

	self.m_HorseBox = {}
	self.m_HorseBox[1] = GUIRadioButton:new(self.m_Width*0.02, 0, imgX, self.m_Height*0.04, "Pferd 1", self.m_HorseGroup):setFontSize(1)
	self.m_HorseBox[2] = GUIRadioButton:new(self.m_Width*0.25*1, 0, imgX, self.m_Height*0.04, "Pferd 2", self.m_HorseGroup):setFontSize(1)
	self.m_HorseBox[3] = GUIRadioButton:new(self.m_Width*0.25*2, 0, imgX, self.m_Height*0.04, "Pferd 3", self.m_HorseGroup):setFontSize(1)
	self.m_HorseBox[4] = GUIRadioButton:new(self.m_Width*0.25*3, 0, imgX, self.m_Height*0.04, "Pferd 4", self.m_HorseGroup):setFontSize(1)


	GUILabel:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.28, self.m_Height*0.07, _"Dein Einsatz:", self.m_Window)
	self.m_Bet = GUIChanger:new(self.m_Width*0.3, self.m_Height*0.7, self.m_Width*0.4, self.m_Height*0.07, self.m_Window)
	for index, betAmount in ipairs(HorseBetGUI.Bets) do
		self.m_Bet:addItem(_("%d$", betAmount))
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.8, self.m_Height*0.06, _"Möglicher Gewinn: 3-facher Einsatz!", self.m_Window)

	self.m_BetButton = GUIButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.078, self.m_Width*0.3, self.m_Height*0.07, _"Wette platzieren", self.m_Window):setBarEnabled(true)
	self.m_BetButton.onLeftClick = bind(self.PlaceBet, self)
end

function HorseBetGUI:PlaceBet()
	local horse = 0
	for i = 1,4 do
		if self.m_HorseBox[i]:isChecked() then
			horse = i
		end
	end

	local betText, betId = self.m_Bet:getSelectedItem()
	local bet = HorseBetGUI.Bets[betId]

	if horse > 0 and bet > 0 then
		QuestionBox:new(_("Möchtest du wirklich %d$ auf Pferd %d setzen?", bet, horse),
			function() 	triggerServerEvent("horseRaceAddBet", root, horse, bet) end
			)
		delete(self)
	else
		ErrorBox:new(_"Ungültige Auswahl!")
	end

end

addEventHandler("showHorseBetGUI", root,
	function()
		if HorseBetGUI:isInstantiated() then
			delete(HorseBetGUI:getSingleton())
		else
			HorseBetGUI:new()
		end
	end
)
