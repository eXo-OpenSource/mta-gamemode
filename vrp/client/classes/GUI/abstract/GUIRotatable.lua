-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/abstract/GUIRotatable.lua
-- *  PURPOSE:     GUI rotatable abstract super class
-- *
-- ****************************************************************************
GUIRotatable = inherit(Object)

function GUIRotatable:constructor(rotation, rotationCenterOffsetX, rotationCenterOffsetY)
    self.m_Rotation = rotation or 0
	self.m_RotationCenterOffsetX = rotationCenterOffsetX or 0
	self.m_RotationCenterOffsetY = rotationCenterOffsetY or 0
end

function GUIRotatable:setRotation(rotation, rotationCenterOffsetX, rotationCenterOffsetY)
	assert(type(rotation) == "number", "Bad argument #1 @ GUIImage.setRotation")

	self.m_Rotation = rotation or 0
	self.m_RotationCenterOffsetX = rotationCenterOffsetX or 0
	self.m_RotationCenterOffsetY = rotationCenterOffsetY or 0

    self:anyChange()
	return self
end

function GUIRotatable:getRotation()
    return self.m_Rotation, self.m_RotationCenterOffsetX, self.m_RotationCenterOffsetY
end