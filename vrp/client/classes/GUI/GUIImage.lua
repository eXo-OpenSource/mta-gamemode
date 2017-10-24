-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIImage.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************
GUIImage = inherit(GUIElement)
inherit(GUIColorable, GUIImage)

function GUIImage:constructor(posX, posY, width, height, path, parent)
	self.m_Image = path

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)
end

function GUIImage:drawThis()
	dxSetBlendMode("modulate_add")
	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end
	if self.m_Image then
		dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_Image, self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0, self.m_RotationCenterOffsetY or 0, self:getColor() or 0)
	end
	dxSetBlendMode("blend")
end

function GUIImage:setRotation(rotation, rotationCenterOffsetX, rotationCenterOffsetY)
	assert(type(rotation) == "number", "Bad argument #1 @ GUIImage.setRotation")

	self.m_Rotation = rotation
	self.m_RotationCenterOffsetX = rotationCenterOffsetX
	self.m_RotationCenterOffsetY = rotationCenterOffsetY

	return self
end

function GUIImage:setImage(path)
	assert(type(path) == "string", "Bad argument @ GUIImage.setImage")

	self.m_Image = path
	self:anyChange()
	return self
end

function GUIImage:fitBySize(width, height)
    local origW, origH = self:getSize()
    local origPx, origPy = self:getPosition()
    local origAs = origW/origH
    local as = width/height
    if as > origAs then --fit image to left/right of grid
        self:setPosition(origPx, origPy + (origH/2 - (origW/as)/2))
        self:setSize(origW, origW/as)
    elseif as < origAs then --fit image to top/bottom of grid
        self:setPosition(origPx + (origW/2 - (origH*as)/2), origPy)
        self:setSize(origH*as, origH)
    --else do not fit as the aspect ratio fits
    end
    return self
end