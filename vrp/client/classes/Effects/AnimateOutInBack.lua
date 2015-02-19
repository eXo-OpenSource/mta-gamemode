-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/AnimateOutInBack.lua
-- *  PURPOSE:     OutInBack animation wrapper class (originally created by Sam@ake)
-- *
-- ****************************************************************************
AnimateOutInBack = inherit(Object)

function AnimateOutInBack:constructor(time)
	self.m_EasingInfo = {}
	self.m_EasingTime = time or 0.5
	self.m_EasingInfo.startTime = getTickCount()
	self.m_EasingInfo.endTime = self.m_EasingInfo.startTime + self.m_EasingTime
	self.m_EasingInfo.easingFunction = "OutInBack"
	self.m_EasingValue = 0
	
	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function AnimateOutInBack:destructor()
	removeEventHandler("onClientPreRender", root, self.m_Update)
end

function AnimateOutInBack:update()
	if self.m_EasingInfo and self.m_EasingValue >= 0 and self.m_EasingValue < 1 then
		local elapsedTime = getTickCount() - self.m_EasingInfo.startTime
		local duration = self.m_EasingInfo.endTime - self.m_EasingInfo.startTime
		local progress = elapsedTime / duration
		self.m_EasingValue = getEasingValue(progress, self.m_EasingInfo.easingFunction, 0.5, 1, 1.7)
	end
end


function AnimateOutInBack:reset()
	self.m_EasingInfo.startTime = getTickCount()
	self.m_EasingInfo.endTime = self.m_EasingInfo.startTime + self.m_EasingTime
	self.m_EasingValue = 0
end

function AnimateOutInBack:getFactor()
	return self.m_EasingValue
end
