cameraDrive = inherit(Object)

function cameraDrive:construcotr ( startX,startY,startZ,startLookX,startLookY,startLookZ,endX,endY,endZ,endLookX,endLookY,endLookZ, needForFinish, effect )
	self.m_StartPositions = {startX,startY,startZ}
	self.m_StartLookPositions = {startLookX,startLookY,startLookZ}
	self.m_EndPositions = {endX,endY,endZ}
	self.m_EndLookPositions = {endLookX,endLookY,endLookZ}
	
	self.m_IsWorking = false
	self.m_UsedEffect = effect or "Linear"
	self.m_StartTick = getTickCount ()
	self.m_EndTick = self.startTick + needForFinish
	
	addEventHandler ('onClientRender', root, bind(self.onRender,self) )
end

function cameraDrive:destructor ()
	removeEventHandler ('onClientRender', root, bind(self.onRender,self))
end

function cameraDrive:onRender ()
	local progress = (getTickCount () - self.startTick)/(self.endTick - self.startTick)
	
	local startX,startY,startZ = unpack (self.startPositions)
	local startLookX,startLookY,startLookZ = unpack ( self.startLookPositions )
	local endX,endY,endZ = unpack(self.endPositions)
	local endLookX,endLookY,endLookZ = unpack (self.endLookPositions)
	
	local positionX, positionY, positionZ = interpolateBetween (startX,startY,startZ,endX,endY,endZ,progress,self.usedEffect)
	local lookAtX, lookAtY, lookAtZ = interpolateBetween (startLookX,startLookY,startLookZ,endLookX,endLookY,endLookZ,progress,self.usedEffect)
	
	setCameraMatrix (positionX, positionY, positionZ,lookAtX, lookAtY, lookAtZ)
	
	if getTickCount () >= self.endTick then
		cameraDrive:destructor ()
	end
end
