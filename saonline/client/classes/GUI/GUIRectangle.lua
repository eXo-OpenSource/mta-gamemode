-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
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
