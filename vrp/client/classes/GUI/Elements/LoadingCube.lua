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

	self.m_CubeTop = GUIImage:new(posX, posY, width, height, "files/images/GUI/Loading/cube-top.png", parent)
	self.m_CubeTop.m_Direction = "up"
	self.m_CubeTop.m_Start = getTickCount()
	self.m_CubeTop.m_Pause = self:getSpeed()*.25

	self.m_CubeLeft = GUIImage:new(posX, posY, width, height, "files/images/GUI/Loading/cube-left.png", parent)
	self.m_CubeLeft.m_Direction = "left"
	self.m_CubeLeft.m_Start = getTickCount()
	self.m_CubeLeft.m_Pause = self:getSpeed()*.25

	self.m_CubeRight = GUIImage:new(posX, posY, width, height, "files/images/GUI/Loading/cube-right.png", parent)
	self.m_CubeRight.m_Direction = "right"
	self.m_CubeRight.m_Start = getTickCount()
	self.m_CubeRight.m_Pause = self:getSpeed()*.25

	
	self.m_AnimationFrame = bind(self.update, self)
	addEventHandler("onClientRender", root, self.m_AnimationFrame)
end


function LoadingCube:update() 
	self:move(self.m_CubeTop)
	self:move(self.m_CubeLeft)
	self:move(self.m_CubeRight)
end

function LoadingCube:move(element) 
	local now = getTickCount()
	if element.m_Start <= now then
		if element.m_Paused then 
			element.m_Start = now
			element.m_Paused = false
		end
		local progress = (getTickCount() - element.m_Start) / self:getSpeed()
		local x, y = self.m_StartX, self.m_StartY
		local width, height = element:getSize() 
		width, height = width*.5, height*.5
		local ease = getEasingValue(progress, "SineCurve")
		if element.m_Direction == "up" then 
			element:setPosition(x, y - height * ease)
		elseif element.m_Direction == "right" then 
			element:setPosition(x + width * ease, y)
		elseif element.m_Direction == "left" then 
			element:setPosition(x - width * ease, y)
		end
		element:setColor(tocolor(255, 255, 255, (1-ease)*255))
		if progress >= 1 then
			element.m_Start = now + element.m_Pause
			element.m_Paused = true
		end
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
