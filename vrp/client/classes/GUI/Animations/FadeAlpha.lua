Animation.FadeAlpha = inherit(Animation)

-- Fade the gui element out and then hide it
function Animation.FadeAlpha:constructor(guielement, time, starta, enda)
	self.m_Element = guielement
	self.m_Time = time
	self.m_Start = getTickCount()
	self.m_fnPreRender = bind(Animation.FadeAlpha.preRender, self)
	self.m_StartAlpha = starta
	self.m_EndAlpha = enda
	self:preRender()
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeAlpha:destructor()
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeAlpha:preRender()
	local progress = (getTickCount() - self.m_Start) / self.m_Time
	if progress >= 1 then
		if self.onFinish then
			self.onFinish(self)
		end
		delete(self)
	else
		local alpha = self.m_StartAlpha + ( self.m_EndAlpha - self.m_StartAlpha )*progress
		self.m_Element:setAlpha(alpha)
	end
end