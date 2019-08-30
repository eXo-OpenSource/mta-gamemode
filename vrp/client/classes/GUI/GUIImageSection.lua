-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIImageSection.lua
-- *  PURPOSE:     GUI image-section class
-- *
-- ****************************************************************************
GUIImageSection = inherit(GUIElement)
inherit(GUIColorable, GUIImageSection)
inherit(GUIRotatable, GUIImageSection)

function GUIImageSection:constructor(posX, posY, width, height, startX, startY, endX, endY, path, parent)
	self.m_Image = path

	self.m_StartX = startX
	self.m_StartY = startY 
	self.m_SizeX = endX
	self.m_SizeY = endY 

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self)
	GUIRotatable.constructor(self)
end

function GUIImageSection:drawThis()
	dxSetBlendMode("modulate_add")
	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end
	if self.m_Image then
		dxDrawImageSection(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_StartX, self.m_StartY, self.m_SizeX, self.m_SizeY, self.m_Image, self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0, self.m_RotationCenterOffsetY or 0, self:getColor() or 0)
	end
	dxSetBlendMode("blend")
end

function GUIImageSection:setImage(path)
	assert(type(path) == "string", "Bad argument @ GUIImageSection.setImage")

	self.m_Image = path
	self:anyChange()
	return self
end

function GUIImageSection:fitBySize(width, height)
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
