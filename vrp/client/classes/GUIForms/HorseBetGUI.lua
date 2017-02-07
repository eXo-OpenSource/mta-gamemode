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

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.96, self.m_Height*0.06, _"Das Pferderennen findet täglich um 19:30 Uhr statt, du kannst es dir Live ansehen. \nNatürlich bekommst du auch ohne Ansehen der Live-Übertragung deinen Gewinn, du musst nur zu dieser Zeit online sein!", self.m_Window):setMultiline(true)

	GUIImage:new(self.m_Width*0.02, self.m_Height*0.3, self.m_Width*0.24, self.m_Width*0.2, "files/images/HorseRace/Horse_1.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*1, self.m_Height*0.3, self.m_Width*0.22, self.m_Width*0.18, "files/images/HorseRace/Horse_2.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*2, self.m_Height*0.3, self.m_Width*0.22, self.m_Width*0.18, "files/images/HorseRace/Horse_3.png", self.m_Window)
	GUIImage:new(self.m_Width*0.25*3, self.m_Height*0.3, self.m_Width*0.22, self.m_Width*0.18, "files/images/HorseRace/Horse_4.png", self.m_Window)


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
