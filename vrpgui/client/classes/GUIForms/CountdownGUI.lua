CountdownGUI = inherit(GUIForm)

function CountdownGUI:constructor(countFrom)
	local width, height = 0.05, 0.18
	GUIForm.constructor(self, screenWidth/2 - screenWidth*width/2, screenHeight/2 - screenHeight*height/2, screenWidth*width, screenHeight*height)
	
	self.m_DigitLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, tostring(countFrom), self)
	self.m_CurrentNumber = countFrom
	
	setTimer(
		function()
			if self.m_CurrentNumber == 1 then
				delete(self)
				return
			end
			
			self.m_CurrentNumber = self.m_CurrentNumber - 1
			self.m_DigitLabel:setText(tostring(self.m_CurrentNumber))
			-- Todo: Add an animation
			
		end,
		1000,
		countFrom
	)
end

addEvent("countdownStart", true)
addEventHandler("countdownStart", root, function(countFrom) CountdownGUI:new(countFrom) end)
