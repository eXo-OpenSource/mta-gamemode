-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobberyCountdown = inherit(GUIForm)
inherit(Singleton, BankRobberyCountdown)

function BankRobberyCountdown:constructor()
	GUIForm.constructor(self, screenWidth/2-200/2, 10, 200, 50, false)
	self.m_Seconds = 0

	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Other/BankRobberyCountdown.png", self)
	self.m_CountdownLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, tostring(self.m_Seconds), self):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.75))
end

function BankRobberyCountdown:startCountdown(seconds)
	self.m_Seconds = seconds
	self.m_CountdownLabel:setText(tostring(self.m_Seconds))

	self.m_Timer = setTimer(
		function()
			self.m_Seconds = self.m_Seconds - 1
			self.m_CountdownLabel:setText(tostring(self.m_Seconds))

			if self.m_Seconds == 0 then
				delete(self)
			end
		end,
		1000,
		self.m_Seconds
	)
end

function BankRobberyCountdown:stopCountdown()
	if self.m_Timer and isTimer(self.m_Timer) then
		killTimer(self.m_Timer)
		self.m_Timer = nil
		delete(self)
	end
end

addEvent("bankRobberyCountdown", true)
addEventHandler("bankRobberyCountdown", root,
	function(seconds)
		BankRobberyCountdown:getSingleton():startCountdown(seconds)
	end
)

addEvent("bankRobberyCountdownStop", true)
addEventHandler("bankRobberyCountdownStop", root,
	function(seconds)
		BankRobberyCountdown:getSingleton():stopCountdown()
	end
)
