Animation.Move = inherit(Animation)

-- Move the gui element
function Animation.Move:constructor(guielement, time, tx, ty, easing)
	self.m_Element = guielement
	self.m_Time = time
	self.m_X, self.m_Y = guielement:getPosition()
	self.m_TX = tx
	self.m_TY = ty
	self.m_Start = getTickCount()
	self.m_Easing = easing or "Linear"
	self.m_fnPreRender = bind(Animation.Move.preRender, self)
	addEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.Move:destructor()
	removeEventHandler("onClientPreRender", root, self.m_fnPreRender)
end

function Animation.Move:preRender()
	local progress = (getTickCount() - self.m_Start) / self.m_Time
	if progress >= 1 then
		if self.onFinish then
			self.onFinish(self)
		end
		self.m_Element:setPosition(self.m_TX, self.m_TY)
		delete(self)
	else
		local x = self.m_X + (self.m_TX - self.m_X) * getEasingValue(progress, self.m_Easing)
		local y = self.m_Y + (self.m_TY - self.m_Y) * getEasingValue(progress, self.m_Easing)
		self.m_Element:setPosition(x, y)
	end
end

function Animation.Move:setTargetPosition (x, y)
	self.m_X, self.m_Y = x, y
end

function Animation.Move:setFinishTime (time)
	self.m_Time = self.m_Time + time
end