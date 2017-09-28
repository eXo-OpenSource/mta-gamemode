Animation.Size = inherit(Animation)

-- Resize the gui element
function Animation.Size:constructor(guielement, time, tx, ty, easing)
	self.m_Element = guielement
	self.m_Time = time
	self.m_X, self.m_Y = guielement:getSize()
	self.m_TX = tx
	self.m_TY = ty
	self.m_Start = getTickCount()
	self.m_Easing = easing or "Linear"
	self.m_fnPreRender = bind(Animation.Size.preRender, self)
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.Size:destructor()
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.Size:preRender()
	local progress = (getTickCount() - self.m_Start) / self.m_Time
	if progress >= 1 then
		if self.onFinish then
			self.onFinish(self)
		end
		self.m_Element:setSize(self.m_TX, self.m_TY)
		delete(self)
	else
		local x = self.m_X + (self.m_TX - self.m_X) * getEasingValue(progress, self.m_Easing)
		local y = self.m_Y + (self.m_TY - self.m_Y) * getEasingValue(progress, self.m_Easing)
		self.m_Element:setSize(x, y)
	end
end

function Animation.Size:setTargetSize(x, y)
	self.m_X, self.m_Y = x, y
end

function Animation.Size:setFinishTime(time)
	self.m_Time = self.m_Time + time
end
