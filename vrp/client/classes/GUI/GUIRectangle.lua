-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIRectangle.lua
-- *  PURPOSE:     GUIRectangle class
-- *
-- ****************************************************************************
GUIRectangle = inherit(GUIElement)
inherit(GUIColorable, GUIRectangle)

function GUIRectangle:constructor(posX, posY, width, height, color, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, color or Color.Black)
end

function GUIRectangle:drawThis()
	dxSetBlendMode("modulate_add")
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)
	dxSetBlendMode("blend")
end

GUIEmptyRectangle = inherit(GUIElement)
inherit(GUIColorable, GUIEmptyRectangle)

function GUIEmptyRectangle:constructor(posX, posY, width, height, linewidth, color, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, color or Color.Black)

	self.m_LineWidth = linewidth
end

function GUIEmptyRectangle:drawThis()
	dxSetBlendMode("modulate_add")
		if GUI_DEBUG then
			dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
		end

		dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY + self.m_LineWidth/2, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_LineWidth/2, self.m_Color, self.m_LineWidth)
		dxDrawLine(self.m_AbsoluteX + self.m_LineWidth/2, self.m_AbsoluteY, self.m_AbsoluteX + self.m_LineWidth/2, self.m_AbsoluteY + self.m_Height, self.m_Color, self.m_LineWidth)
		dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - self.m_LineWidth/2, self.m_AbsoluteX + self.m_Width - self.m_LineWidth/2, self.m_AbsoluteY + self.m_Height - self.m_LineWidth/2, self.m_Color, self.m_LineWidth)
		dxDrawLine(self.m_AbsoluteX + self.m_Width - self.m_LineWidth/2, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - self.m_LineWidth/2, self.m_AbsoluteY + self.m_Height, self.m_Color, self.m_LineWidth)
	dxSetBlendMode("blend")
end
