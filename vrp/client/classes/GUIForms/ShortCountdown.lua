-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ShortCountdown.lua
-- *  PURPOSE:     SimpleCountdown class
-- *
-- ****************************************************************************
ShortCountdown = inherit(GUIForm)

function ShortCountdown:constructor(seconds, title, icon)
	if ShortCountdown.Map[title] then
		outputDebugString("Countdown with title "..title.." already exists! Destroying it")
		delete(ShortCountdown.Map[title])
	end

	local offset = screenHeight*0.95 - (ShortCountdown.getCurrentCountdowns()*screenHeight*0.035)

	GUIForm.constructor(self, screenWidth/2-(screenWidth*0.15/2), offset, screenWidth*0.15, screenHeight*0.03, false)
	self.m_Title = title
	self.m_StartTick = getTickCount()
	self.m_FontScale = screenHeight / 768
	self.m_Font = getVRPFont(VRPFont(self.m_Height)) or "sans"

	GUIRectangle:new(self.m_Width*.1, 0, self.m_Width*.6, self.m_Height, Color.PrimaryNoClick, self)
	if icon then
		GUIImage:new(0, self.m_Height/2 - self.m_Width*.05, self.m_Width*.1, self.m_Width*.1, icon, self)
	end
	GUIRectangle:new(((self.m_Width*.7)+self.m_Width*.05)-2, 0, (self.m_Width*.3-self.m_Width*.1)+4, self.m_Height, Color.PrimaryNoClick, self)
	GUIRectangle:new((self.m_Width*.7)+self.m_Width*.05, 2, self.m_Width*.3-self.m_Width*.1, self.m_Height-4, Color.LightGrey, self)

	self.m_TimeLabel = GUILabel:new((self.m_Width*.7)+self.m_Width*.05, 2, self.m_Width*.3-self.m_Width*.1, self.m_Height-4, self.m_Seconds, self):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.52)):setFont(VRPFont(18*self.m_FontScale))

	self.m_Seconds = seconds
	self.m_FrameBind = bind(self.Event_onFrame, self)
	addEventHandler("onClientRender", root, self.m_FrameBind)
	
	self:updateTime()
	self.m_Timer = setTimer(bind(self.updateTime, self), 250, 0)
	
	ShortCountdown.Map[title] = self
end

function ShortCountdown:destructor()
	if ShortCountdown.Map[self.m_Title] then
		ShortCountdown.Map[self.m_Title] = nil
		if self.m_Timer and isTimer(self.m_Timer) then killTimer(self.m_Timer) end
		removeEventHandler("onClientRender", root, self.m_FrameBind)
		GUIForm.destructor(self)
	end

end

function ShortCountdown:updateTime()
	local elapsedSecs = math.floor((getTickCount() - self.m_StartTick)/1000)
	local secsTotal = self.m_Seconds - elapsedSecs

	local mins = string.format("%02.f", math.floor(secsTotal/60)) or "0";
	local secs = string.format("%02.f", math.floor(secsTotal - mins *60)) or "0";

	self.m_TimeLabel:setText(("%s:%s"):format(mins, secs))

	if secsTotal <= 0 then
		delete(self)
	else
		if self.m_TickEvent then
			self.m_TickEvent()
		end
	end
end

function ShortCountdown:Event_onFrame() 
	local prog = (getTickCount() - self.m_StartTick) / (self.m_Seconds*1000)
	local width = (self.m_Width*.6 - 4) * prog
	dxDrawRectangle(self.m_AbsoluteX + (self.m_Width*.1 + 2), self.m_AbsoluteY + 2, width, self.m_Height-4, Color.Accent )
	dxDrawText(self.m_Title, self.m_AbsoluteX + (self.m_Width*.1 + 2), self.m_AbsoluteY + 2, self.m_AbsoluteX + (self.m_Width*.1 + 2) +  self.m_Width*.6, self.m_AbsoluteY + self.m_Height-4, Color.White, 1, self.m_Font, "center", "center")
end

function ShortCountdown.getCurrentCountdowns()
	local count = 0
	for index, countdown in pairs(ShortCountdown.Map) do
		if countdown and countdown:isVisible() then
			count = count+1
		end
	end
	return count
end

