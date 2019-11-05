-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/LoadingCube.lua
-- *  PURPOSE:     Loading animation with three cubes
-- *
-- ****************************************************************************
LoadingCube = inherit(GUIElement)

function LoadingCube:constructor(posX, posY, width, height, parent) 
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self:setPaused(false)
	self:setSpeed(1000)

	self.m_StartX = posX
	self.m_StartY = posY

	self.m_Start = getTickCount()
	

	self.m_CubeTop = GUIImage:new(posX, posY, width, height, "files/images/GUI/Loading/cube-top.png", parent)
	self.m_CubeLeft = GUIImage:new(posX, posY, width, height, "files/images/GUI/Loading/cube-left.png", parent)
	self.m_CubeRight = GUIImage:new(posX, posY, width, height, "files/images/GUI/Loading/cube-right.png", parent)

	self.m_AnimationFrame = bind(self.onFrame, self)
	addEventHandler("onClientRender", root, self.m_AnimationFrame)
end


function LoadingCube:onFrame() 
	if not self:isPaused() then
		local progress = (getTickCount() - self.m_Start) / self:getSpeed() 

		local width, height = self:getSize() 
		width, height = width*.5, height*.5


		local ease = getEasingValue(progress, "SineCurve")
		self:setPosition(self.m_StartX, self.m_StartY - height *ease)
		local x, y = self:getPosition()

		self.m_CubeTop:setPosition(x, y - height*ease)
		self.m_CubeTop:setColor(tocolor(255, 255, 255, (1-ease)*255))

		self.m_CubeLeft:setPosition(x - width * ease, y)
		self.m_CubeLeft:setColor(tocolor(255, 255, 255, (1-ease)*255))

		self.m_CubeRight:setPosition(x + width * ease, y)
		self.m_CubeRight:setColor(tocolor(255, 255, 255, (1-ease)*255))

		if progress >= 1 then 
			self:setPaused(true)
			self.m_CubeTop:setColor(Color.White)
			self.m_CubeLeft:setColor(Color.White)
			self.m_CubeRight:setColor(Color.White)
			setTimer(function() 
				self:setPaused(false)
				self.m_Start = getTickCount()
			end, self:getSpeed()/4, 1)
		end
		self:anyChange() 
	end
end

function LoadingCube:setSpeed(speed) 
	assert(tonumber(speed), "Bad argument #1 @ LoadingCube.setSpeed")
	self.m_Speed = speed
end

function LoadingCube:setPaused(bool) 
	self.m_Paused = bool
end

function LoadingCube:isPaused() 
	return self.m_Paused
end

function LoadingCube:getSpeed() return self.m_Speed end

function LoadingCube:destructor() 
	removeEventHandler("onClientRender", root, self.m_AnimationFrame)
end
