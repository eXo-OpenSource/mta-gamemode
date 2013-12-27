Animation.FadeIn = inherit(Animation)

-- Fade the gui element out and then hide it
function Animation.FadeIn:constructor(guielement, time)
	self.m_Element = guielement
	self.m_Time = time
	self.m_Start = getTickCount()
	self.m_fnPreRender = bind(Animation.FadeIn.preRender, self)
	self.m_Element:setAlpha(0)
	self.m_Element:show()
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeIn:destructor()
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeIn:preRender()
	local progress = (getTickCount() - self.m_Start) / self.m_Time
	if progress >= 1 then
		if self.onFinish then
			self.onFinish(self)
		end
		delete(self)
	else
		local alpha = 255 * progress
		self.m_Element:setAlpha(alpha)
	end
end