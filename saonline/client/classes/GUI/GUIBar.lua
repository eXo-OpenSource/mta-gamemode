-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIBar.lua
-- *  PURPOSE:     Bar class
-- *
-- ****************************************************************************

GUIBar = inherit(GUIElement)

function GUIBar:constructor(posX, posY, width, height, color1, color2, progress, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	self.m_Progress = progress
	self.m_ForegroundColor = color1
	self.m_BackgroundColor = color2
end

function GUIBar:setColor(color1, color2)
	self.m_ForegroundColor = color1
	self.m_BackgroundColor = color2
	return self
end

function GUIBar:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width*self.m_Progress, self.m_Height, self.m_ForegroundColor)
	dxSetBlendMode("blend")
end
