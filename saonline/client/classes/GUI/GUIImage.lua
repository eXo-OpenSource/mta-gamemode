-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIImage.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************

GUIImage = inherit(GUIElement)

function GUIImage:constructor(posX, posY, width, height, path, parent)
	checkArgs("GUIImage:constructor", "number", "number", "number", "number", "string")

	self.m_Image = path

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)
end

function GUIImage:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_Image, self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0, self.m_RotationCenterOffsetY or 0, self.m_Color or 0)
	dxSetBlendMode("blend")
end

function GUIImage:setRotation(rotation, rotationCenterOffsetX, rotationCenterOffsetY)
	assert(type(rotation) == "number", "Bad argument #1 @ GUIImage.setRotation")

	self.m_Rotation = rotation
	self.m_RotationCenterOffsetX = rotationCenterOffsetX
	self.m_RotationCenterOffsetY = rotationCenterOffsetY
end

function GUIImage:setImage(path)
	assert(type(path) == "string", "Bad argument @ GUIImage.setImage")

	self.m_Image = path
	self:anyChange()
end

function GUIImage:setColor(color)
	assert(type(color) == "number", "Bad argument @ GUIImage.setColor")

	self.m_Color = color
end
