-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Countdown.lua
-- *  PURPOSE:     Countdown class
-- *
-- ****************************************************************************
Countdown = inherit(GUIForm)
inherit(Singleton, Countdown)

function Countdown:constructor()
	GUIForm.constructor(self, screenWidth/2-187/2, 60, 187, 90, false)
	self.m_Seconds = 0
	self.m_Rect = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 125), self)
	self.m_Text = GUILabel:new(0, 0, self.m_Width, 30, "Countdown...", self):setColor(Color.Red):setFont(VRPFont(self.m_Height*0.4)):setAlignX("center")
	self.m_Background = GUIImage:new(10, 30, self.m_Width-20, 60, "files/images/Other/Countdown.png", self)
	self.m_MinutesLabel = GUILabel:new(14, 14, 60, 20, "", self.m_Background):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52))
	self.m_SecondLabel = GUILabel:new(95, 14, 60, 20, "", self.m_Background):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52))
end

function Countdown:startCountdown(seconds, text)
	self.m_Text:setText(text or "Countdown...")
	self.m_Seconds = seconds
	self:updateTime()
	self.m_Timer = setTimer(bind(self.updateTime, self), 1000, 0)
	return self
end

function Countdown:updateTime()
	self.m_Seconds = self.m_Seconds - 1
	if self.m_TickEvent then
		self.m_TickEvent()
	end
	local mins = string.format("%02.f", math.floor(self.m_Seconds/60)) or "0";
	local secs = string.format("%02.f", math.floor(self.m_Seconds - mins *60)) or "0";

	self.m_MinutesLabel:setText(mins)
	self.m_SecondLabel:setText(secs)

	if self.m_Seconds == 0 then
		self:stopCountdown()
	end

end

function Countdown:addTickEvent(callBack)
	self.m_TickEvent = callBack()
end

function Countdown:stopCountdown()
	if self.m_Timer and isTimer(self.m_Timer) then
		killTimer(self.m_Timer)
		self.m_Timer = nil
		delete(self)
	end
end

addEvent("Countdown", true)
addEventHandler("Countdown", root,
	function(seconds, text)
		Countdown:getSingleton():startCountdown(seconds, text)
	end
)

addEvent("CountdownStop", true)
addEventHandler("CountdownStop", root,
	function()
		if Countdown:isInstantiated() then
			Countdown:getSingleton():stopCountdown()
		end
	end
)
