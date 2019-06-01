-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/DxRectangle.lua
-- *  PURPOSE:     Dx resctangle to provide animation dummies without mouse interaction
-- *
-- ****************************************************************************
DxRectangle = inherit(DxElement)
inherit(GUIColorable, DxRectangle)

function DxRectangle:constructor(posX, posY, width, height, color, parent, isRelative)
	DxElement.constructor(self, posX, posY, width, height, parent, isRelative)
	GUIColorable.constructor(self, color)
end

function DxRectangle:drawThis()
	if not self.m_Draw then return end

    dxSetBlendMode("modulate_add")

    if GUI_DEBUG then
        dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
    end

    dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

    dxSetBlendMode("blend")
end

function DxRectangle:setDrawingEnabled(bool)
	self.m_Draw = bool
	return self
end
