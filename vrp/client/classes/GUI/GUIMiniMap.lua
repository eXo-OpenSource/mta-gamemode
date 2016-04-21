-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMiniMap.lua
-- *  PURPOSE:     MiniMap class
-- *
-- ****************************************************************************
GUIMiniMap = inherit(GUIElement)

function GUIMiniMap:constructor(posX, posY, width, height, mapType, parent)
	self.m_MapType = mapType
	self.m_PosX = 0
	self.m_PosY = 0
	self.m_ImageSize = 500, 500 --3072, 3072
	self.m_Image = "files/images/"..mapType.."/Radar.jpg"
	self:worldToMapPosition()
	GUIElement.constructor(self, posX, posY, width, height, parent)

end

function GUIMiniMap:drawThis()
	dxSetBlendMode("modulate_add")
	if self.m_Image then
		dxDrawImageSection(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY),
		self.m_Width, self.m_Height,
		self.m_MapX, self.m_MapY,
		self.m_ImageSize, self.m_ImageSize,
		self.m_Image,
		self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0,
		self.m_RotationCenterOffsetY or 0)
	end
	dxSetBlendMode("blend")
end

function GUIMiniMap:worldToMapPosition()
	self.m_MapX = self.m_PosX / ( 6000/self.m_ImageSize) + self.m_ImageSize/2
	self.m_MapY = self.m_PosY / (-6000/self.m_ImageSize) + self.m_ImageSize/2
	self:anyChange()
end

function GUIMiniMap:setPosition(posX, posY)
	self.m_PosX = posX
	self.m_PosY = posY
	self:worldToMapPosition()
	self:anyChange()
	return self
end
