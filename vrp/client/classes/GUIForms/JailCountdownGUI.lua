-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JailCountdownGUI.lua
-- *  PURPOSE:     Jail countdown GUI class
-- *
-- ****************************************************************************
JailCountdownGUI = inherit(GUIForm)

function JailCountdownGUI:constructor(countFrom)
	local width, height = 0.16, 0.07
	GUIForm.constructor(self, screenWidth/2 - screenWidth*width/2, height + 10, screenWidth*width, screenHeight*height)

	self.m_Background = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0,0,0,180), self)
	GUILabel:new(0, -self.m_Height*0.2, self.m_Width, self.m_Height, _"Frei in", self.m_Background):setAlignX("center"):setAlignY("top")
	self.m_DigitLabel = GUILabel:new(0, self.m_Height*0.15, self.m_Width, self.m_Height, tostring(countFrom).." Minuten", self.m_Background):setAlignX("center"):setAlignY("bottom")
	self.m_DigitLabel:setColor(Color.Red)

	self.m_CurrentNumber = countFrom
	setTimer(
		function()
			if self.m_CurrentNumber == 0 then
				delete(self)
				return
			end

			self.m_CurrentNumber = self.m_CurrentNumber - 1
			self.m_DigitLabel:setText(tostring(self.m_CurrentNumber).." Minuten")
		end,
		1000*60,
		countFrom
	)
end
