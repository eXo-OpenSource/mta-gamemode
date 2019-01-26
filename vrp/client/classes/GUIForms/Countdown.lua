-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Countdown.lua
-- *  PURPOSE:     Countdown class
-- *
-- ****************************************************************************
Countdown = inherit(GUIForm)
Countdown.Map = {}

function Countdown:constructor(seconds, title)
	if Countdown.Map[title] then
		outputDebugString("Countdown with title "..title.." already exists!")
		delete(self)
		return
	end

	local offset = Countdown.getCurrentCountdowns()*90
	GUIForm.constructor(self, screenWidth/2-187/2, 60+offset, 187, 90, false)
	self.m_Title = title
	self.m_StartTick = getTickCount()
	self.m_Rect = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 125), self)
	self.m_Text = GUILabel:new(0, 0, self.m_Width, 30, self.m_Title, self):setColor(Color.Red):setFont(VRPFont(self.m_Height*0.4)):setAlignX("center")
	self.m_Background = GUIImage:new(10, 30, self.m_Width-20, 60, "files/images/Other/Countdown.png", self)
	self.m_MinutesLabel = GUILabel:new(14, 14, 60, 20, "", self.m_Background):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52))
	self.m_SecondLabel = GUILabel:new(95, 14, 60, 20, "", self.m_Background):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52))

	self.m_Seconds = seconds
	self:updateTime()
	self.m_Timer = setTimer(bind(self.updateTime, self), 500, 0)
	Countdown.Map[title] = self
end

function Countdown:destructor()
	if Countdown.Map[self.m_Title] then
		Countdown.Map[self.m_Title] = nil
		if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
		GUIForm.destructor(self)
	end

end

function Countdown:updateTime()
	if localPlayer.m_PaydayShowing then
		self:setVisible(false)
	else
		self:setVisible(true)
	end

	local elapsedSecs = math.floor((getTickCount() - self.m_StartTick)/1000)
	local secsTotal = self.m_Seconds - elapsedSecs

	local mins = string.format("%02.f", math.floor(secsTotal/60)) or "0";
	local secs = string.format("%02.f", math.floor(secsTotal - mins *60)) or "0";

	self.m_MinutesLabel:setText(mins)
	self.m_SecondLabel:setText(secs)

	if secsTotal <= 0 then
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
	function(seconds, title)
		Countdown:new(seconds, title)
	end
)

addEvent("CountdownStop", true)
addEventHandler("CountdownStop", root,
	function(title)
		if Countdown.Map[title] then
			delete(Countdown.Map[title])
		end
	end
)

function Countdown.getCurrentCountdowns()
	local count = 0
	for index, countdown in pairs(Countdown.Map) do
		if countdown and countdown:isVisible() then
			count = count+1
		end
	end
	return count
end
