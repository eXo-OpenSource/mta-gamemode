-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JailCountdownGUI.lua
-- *  PURPOSE:     Jail countdown GUI class
-- *
-- ****************************************************************************
JailCountdownGUI = inherit(GUIForm)

function JailCountdownGUI:constructor(countFrom)
	local width, height = 0.16, 0.23
	GUIForm.constructor(self, screenWidth/2 - screenWidth*width/2, screenHeight/2 - screenHeight*height/2, screenWidth*width, screenHeight*height)
	
	self.m_Background = GUIRoundedRect:new(0, 0, self.m_Width, self.m_Height, self)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.02, self.m_Width*0.9, self.m_Height*0.2, _"Frei in...", self.m_Background)
	self.m_DigitLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.15, self.m_Width*0.9, self.m_Height*0.8, tostring(countFrom), self)
	self.m_DigitLabel:setColor(Color.Red)
	self.m_DigitLabel:setAlignX("right")

	self.m_CurrentNumber = countFrom
	setTimer(
		function()
			if self.m_CurrentNumber == 1 then
				delete(self)
				return
			end
			
			self.m_CurrentNumber = self.m_CurrentNumber - 1
			self.m_DigitLabel:setText(tostring(self.m_CurrentNumber))
		end,
		1000,
		countFrom
	)
end

addEvent("jailCountdownStart", true)
addEventHandler("jailCountdownStart", root, function(countFrom) JailCountdownGUI:new(countFrom) end)
