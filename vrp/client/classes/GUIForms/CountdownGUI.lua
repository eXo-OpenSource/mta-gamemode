-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CountdownGUI.lua
-- *  PURPOSE:     Displays a countdown e.g. for events - Todo: Update countdown style, change name to prevent mismatch with countdown.lua, its more like a HUD, no GUI.
-- *
-- ****************************************************************************
CountdownGUI = inherit(GUIForm)

function CountdownGUI:constructor(countFrom)
	local width, height = 0.05, 0.18
	GUIForm.constructor(self, screenWidth/2 - screenWidth*width/2, screenHeight/2 - screenHeight*height/2, screenWidth*width, screenHeight*height, false)

	self.m_DigitLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, tostring(countFrom), self):setColor(Color.Red)
	self.m_CurrentNumber = countFrom

	setTimer(
		function()
			if self.m_CurrentNumber == 1 then
				delete(self)
				return
			end

			self.m_CurrentNumber = self.m_CurrentNumber - 1
			self.m_DigitLabel:setText(tostring(self.m_CurrentNumber))
		end, 1000, countFrom
	)
end

addEvent("countdownStart", true)
addEventHandler("countdownStart", root, function(countFrom) CountdownGUI:new(countFrom) end)
