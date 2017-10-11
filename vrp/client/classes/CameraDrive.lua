cameraDrive = inherit(Object)

function cameraDrive:constructor ( startX,startY,startZ,startLookX,startLookY,startLookZ,endX,endY,endZ,endLookX,endLookY,endLookZ, needForFinish, effect )
	self.m_StartPositions = {startX,startY,startZ}
	self.m_StartLookPositions = {startLookX,startLookY,startLookZ}
	self.m_EndPositions = {endX,endY,endZ}
	self.m_EndLookPositions = {endLookX,endLookY,endLookZ}
	
	self.m_IsWorking = false
	self.m_UsedEffect = effect or "Linear"
	self.m_StartTick = getTickCount ()
	self.m_EndTick = self.m_StartTick + needForFinish
	self.m_FOV = 70
	
	self.m_RenderHandler = bind(self.onRender,self)
	
	addEventHandler ('onClientRender', root, self.m_RenderHandler )
end

function cameraDrive:setFOV(fov)
	self.m_FOV = tonumber(fov) or 70
end

function cameraDrive:destructor ()
	removeEventHandler ('onClientRender', root, self.m_RenderHandler)
end

function cameraDrive:onRender ()
	local progress = (getTickCount () - self.m_StartTick)/(self.m_EndTick - self.m_StartTick)
	
	local startX,startY,startZ = unpack (self.m_StartPositions)
	local startLookX,startLookY,startLookZ = unpack ( self.m_StartLookPositions )
	local endX,endY,endZ = unpack(self.m_EndPositions)
	local endLookX,endLookY,endLookZ = unpack (self.m_EndLookPositions)
	
	local positionX, positionY, positionZ = interpolateBetween (startX,startY,startZ,endX,endY,endZ,progress,self.m_UsedEffect)
	local lookAtX, lookAtY, lookAtZ = interpolateBetween (startLookX,startLookY,startLookZ,endLookX,endLookY,endLookZ,progress,self.m_UsedEffect)
	
	setCameraMatrix (positionX, positionY, positionZ,lookAtX, lookAtY, lookAtZ, 0, self.m_FOV)
	
	if getTickCount () >= self.m_EndTick then
		delete(self)
	end
end
