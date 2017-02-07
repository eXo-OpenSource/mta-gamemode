-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HorseBetGUI.lua
-- *  PURPOSE:     HorseBetGUI class
-- *
-- ****************************************************************************
HorseBetGUI = inherit(GUIForm)
inherit(Singleton, HorseBetGUI)

addRemoteEvents{"showHorseBetGUI", "receiveKartDatas"}

function HorseBetGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-270, screenHeight/2-230, 540, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Pferdewetten", true, true, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.96, self.m_Height*0.05, _"Das Pferderennen findet täglich um 19:30 Uhr statt, du kannst es dir Live ansehen. \nNatürlich bekommst du auch ohne Ansehen der Live-Übertragung deinen Gewinn, du musst nur zu dieser Zeit online sein!", self.m_Window):setMultiline(true)

	local imgX, imgY = self.m_Width*0.18, self.m_Width*0.146

	GUIImage:new(self.m_Width*0.02, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_1.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*1, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_2.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*2, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_3.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*3, self.m_Height*0.32, imgX, imgY, "files/images/HorseRace/Horse_4.png", self.m_Window)

	self.m_HorseBox = {}
	self.m_HorseBox[1] = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.35+imgY, imgX, self.m_Height*0.04, "Pferd 1", self.m_Window):setFontSize(1)
	self.m_HorseBox[2] = GUICheckbox:new(self.m_Width*0.25*1, self.m_Height*0.35+imgY, imgX, self.m_Height*0.04, "Pferd 2", self.m_Window):setFontSize(1)
	self.m_HorseBox[3] = GUICheckbox:new(self.m_Width*0.25*2, self.m_Height*0.35+imgY, imgX, self.m_Height*0.04, "Pferd 3", self.m_Window):setFontSize(1)
	self.m_HorseBox[4] = GUICheckbox:new(self.m_Width*0.25*3, self.m_Height*0.35+imgY, imgX, self.m_Height*0.04, "Pferd 4", self.m_Window):setFontSize(1)


	GUILabel:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.28, self.m_Height*0.07, _"Dein Einsatz:", self.m_Window)
	self.m_Bet = GUIChanger:new(self.m_Width*0.3, self.m_Height*0.7, self.m_Width*0.4, self.m_Height*0.07, self.m_Window)
	self.m_Bet:addItem(_("%d$", 10))
	self.m_Bet:addItem(_("%d$", 100))
	self.m_Bet:addItem(_("%d$", 1000))
	self.m_Bet:addItem(_("%d$", 5000))
	self.m_Bet:addItem(_("%d$", 10000))
	self.m_Bet:addItem(_("%d$", 50000))
	self.m_Bet:addItem(_("%d$", 100000))

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.8, self.m_Height*0.06, _"Möglicher Gewinn: 3-facher Einsatz!", self.m_Window)

	self.m_BetButton = VRPButton:new(self.m_Width-self.m_Width*0.32, self.m_Height-self.m_Height*0.078, self.m_Width*0.3, self.m_Height*0.07, _"Wette platzieren", true, self.m_Window)
	self.m_BetButton.onLeftClick = bind(self.PlaceBet, self)
end

function HorseBetGUI:PlaceBet()

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
