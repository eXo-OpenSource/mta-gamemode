Animation.Move = inherit(Animation)

-- Move the gui element
function Animation.Move:constructor(guielement, time, tx, ty)
	self.m_Element = guielement
	self.m_Time = time
	self.m_X, self.m_Y = guielement:getPosition()
	self.m_TX = tx
	self.m_TY = ty
	self.m_Start = getTickCount()
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
		local x = self.m_X + (self.m_TX - self.m_X) * progress
		local y = self.m_Y + (self.m_TY - self.m_Y) * progress
		self.m_Element:setPosition(x, y)
	end
end