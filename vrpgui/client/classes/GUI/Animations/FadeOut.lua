Animation.FadeOut = inherit(Animation)

-- Fade the gui element out and then hide it
function Animation.FadeOut:constructor(guielement, time)
	self.m_Element = guielement
	self.m_Time = time
	self.m_Start = getTickCount()
	self.m_fnPreRender = bind(Animation.FadeOut.preRender, self)
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeOut:destructor()
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.FadeOut:preRender()
	local progress = (getTickCount() - self.m_Start) / self.m_Time
	if progress >= 1 then
		self.m_Element:hide()
		if self.onFinish then
			self.onFinish(self)
		end
		delete(self)
	else
		local alpha = 255 * (1-progress)
		self.m_Element:setAlpha(alpha)
	end
end