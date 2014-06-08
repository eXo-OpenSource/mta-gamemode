-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIButton.lua
-- *  PURPOSE:     GUI button class
-- *
-- ****************************************************************************
GUIButton = inherit(GUIElement)
inherit(GUIFontContainer, GUIButton)

local GUI_BUTTON_BORDER_MARGIN = 5

function GUIButton:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUIButton:constructor", "number", "number", "number", "number", "string")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1.5)

	self.m_Path = "files/images/GUI/Button.png"
	self.m_NormalColor = Color.White
	self.m_HoverColor = Color.Black
	self.m_BackgroundColor = tocolor(0, 32, 63, 255)
	self.m_BackgroundHoverColor = Color.White
	self.m_Color = self.m_NormalColor
end

function GUIButton:drawThis()
	dxSetBlendMode("modulate_add")

	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, math.floor(self.m_Width), math.floor(self.m_Height), self.m_Path)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self:isHovered() and self.m_BackgroundHoverColor or self.m_BackgroundColor)
	dxDrawText(self:getText(), self.m_AbsoluteX, self.m_AbsoluteY,
		self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, self.m_Color, self:getFontSize(), self:getFont(), "center", "center", false, true)

	dxSetBlendMode("blend")
end

function GUIButton:onInternalHover()
	self.m_Path = "files/images/GUI/Button_hover.png"
	self.m_Color = self.m_HoverColor
	self:anyChange()
end

function GUIButton:onInternalUnhover()
	self.m_Path = "files/images/GUI/Button.png"
	self.m_Color = self.m_NormalColor
	self:anyChange()
end

function GUIButton:setColor(color)
	self.m_NormalColor = color
	if not self:isHovered() then
		self.m_Color = color
	end
	self:anyChange()
	return self
end

function GUIButton:setHoverColor(color)
	self.m_HoverColor = color
	self:anyChange()
	return self
end

function GUIButton:setBackgroundHoverColor(color)
	self.m_BackgroundHoverColor = color
	self:anyChange()
	return self
end

function GUIButton:setBackgroundColor(color)
	self.m_BackgroundColor = color
	self:anyChange()
	return self
end
