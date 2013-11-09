-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIButton.lua
-- *  PURPOSE:     GUI button class
-- *
-- ****************************************************************************

GUIButton = inherit(GUIElement)
inherit(GUIFontContainer, GUIButton)
inherit(GUIColorable, GUIButton)

local GUI_BUTTON_BORDER_MARGIN = 5

function GUIButton:constructor(posX, posY, width, height, text, parent)
	checkArgs("CGUIButton:constructor", "number", "number", "number", "number", "string")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1.5)
	GUIColorable.constructor(self, Color.White)

	self.m_Path = "files/images/GUI/Button.png"
	self.m_BackgroundColor = tocolor(0, 32, 63, 255)
	self.m_BackgroundHoverColor = Color.White
end

function GUIButton:drawThis()
	dxSetBlendMode("modulate_add")

	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, math.floor(self.m_Width), math.floor(self.m_Height), self.m_Path)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self:isHovered() and self.m_BackgroundHoverColor or self.m_BackgroundColor)
	dxDrawText(self:getText(), self.m_AbsoluteX + GUI_BUTTON_BORDER_MARGIN, self.m_AbsoluteY + GUI_BUTTON_BORDER_MARGIN,
		self.m_AbsoluteX + self.m_Width - GUI_BUTTON_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height - GUI_BUTTON_BORDER_MARGIN, self:getColor(), self:getFontSize(), self:getFont(), "center", "center", false, true)

	dxSetBlendMode("blend")
end

function GUIButton:onInternalHover()
	self.m_Path = "files/images/GUI/Button_hover.png"
	self:setColor(Color.Black)
	self:anyChange()
end

function GUIButton:onInternalUnhover()
	self.m_Path = "files/images/GUI/Button.png"
	self:setColor(Color.White)
	self:anyChange()
end

function GUIButton:setBackgroundHoverColor(color)
	self.m_BackgroundHoverColor = color
end

function GUIButton:setBackgroundColor(color)
	self.m_BackgroundColor = color
end
