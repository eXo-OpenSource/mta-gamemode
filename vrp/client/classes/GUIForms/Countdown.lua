-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Countdown.lua
-- *  PURPOSE:     Countdown class
-- *
-- ****************************************************************************
Countdown = inherit(GUIForm)
inherit(Singleton, Countdown)

function Countdown:constructor(seconds, text)
	GUIForm.constructor(self, screenWidth/2-187/2, 60, 187, 90, false)
	self.m_Seconds = 0
	self.m_Rect = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 125), self)
	self.m_Text = GUILabel:new(0, 0, self.m_Width, 30, text or "Countdown...", self):setColor(Color.Red):setFont(VRPFont(self.m_Height*0.4)):setAlignX("center")
	self.m_Background = GUIImage:new(10, 30, self.m_Width-20, 60, "files/images/Other/Countdown.png", self)
	self.m_MinutesLabel = GUILabel:new(14, 14, 60, 20, "", self.m_Background):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52))
	self.m_SecondLabel = GUILabel:new(95, 14, 60, 20, "", self.m_Background):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52))

	self.m_Seconds = seconds
	self:updateTime()
	self.m_Timer = setTimer(bind(self.updateTime, self), 1000, 0)
end

function Countdown:destructor()
	if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	GUIForm.destructor(self)
end

function Countdown:updateTime()
	self.m_Seconds = self.m_Seconds - 1

	local mins = string.format("%02.f", math.floor(self.m_Seconds/60)) or "0";
	local secs = string.format("%02.f", math.floor(self.m_Seconds - mins *60)) or "0";

	self.m_MinutesLabel:setText(mins)
	self.m_SecondLabel:setText(secs)

	if self.m_Seconds == 0 then
		delete(self)
	else
		if self.m_TickEvent then
			self.m_TickEvent()
		end
	end
end

function Countdown:addTickEvent(callBack)
	self.m_TickEvent = callBack
end

addEvent("Countdown", true)
addEventHandler("Countdown", root,
	function(seconds, text)
		Countdown:new(seconds, text)
	end
)

addEvent("CountdownStop", true)
addEventHandler("CountdownStop", root,
	function()
		if Countdown:isInstantiated() then
			delete(Countdown:getSingleton())
		end
	end
)
