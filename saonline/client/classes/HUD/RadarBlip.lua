-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/RadarBlip.lua
-- *  PURPOSE:     HUD radar blip class
-- *
-- ****************************************************************************
RadarBlip = inherit(Object)

function RadarBlip:constructor(worldX, worldY, imagePath)
	self.m_ImagePath = imagePath
	self.m_WorldX = worldX
	self.m_WorldY = worldY
	self.m_Alpha = 255
	self.m_Size = 16
end

function RadarBlip:destructor()
end

function RadarBlip:getImagePath()
	return self.m_ImagePath
end

function RadarBlip:setImagePath(path)
	return self.m_ImagePath
end

function RadarBlip:getPosition()
	return self.m_WorldX, self.m_WorldY
end

function RadarBlip:setPosition(x, y)
	self.m_WorldX, self.m_WorldY = x, y
end

function RadarBlip:getAlpha()
	return self.m_Alpha
end

function RadarBlip:setAlpha(alpha)
	self.m_Alpha = alpha
end

function RadarBlip:getSize()
	return self.m_Size
end

function RadarBlip:setSize(size)
	self.m_Size = size
end
