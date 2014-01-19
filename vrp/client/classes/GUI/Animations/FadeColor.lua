Animation.FadeColor = inherit(Animation)

-- Fade the gui element out and then hide it
function Animation.FadeColor:constructor(guielement, time, startcolor, targetcolor)
	self.m_Element = guielement
	self.m_Time = time
	self.m_Start = getTickCount()
	self.m_fnPreRender = bind(Animation.FadeColor.preRender, self)
	self.m_Startcolor = startcolor
	self.m_Targetcolor = targetcolor
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeColor:destructor()
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeColor:preRender()
	local progress = (getTickCount() - self.m_Start) / self.m_Time
	if progress >= 1 then
		if self.onFinish then
			self.onFinish(self)
		end
		delete(self)
	else
		local r = self.m_Startcolor[1] + (self.m_Targetcolor[1] - self.m_Startcolor[1]) * progress
		local g = self.m_Startcolor[2] + (self.m_Targetcolor[2] - self.m_Startcolor[2]) * progress
		local b = self.m_Startcolor[3] + (self.m_Targetcolor[3] - self.m_Startcolor[3]) * progress
		local a = self.m_Startcolor[4] + (self.m_Targetcolor[4] - self.m_Startcolor[4]) * progress
		
		self.m_Element:setColor(tocolor(r, g, b, a))
		self.m_Element:anyChange()
	end
end