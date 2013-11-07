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
	GUIColorable.constructor(self)

	self.m_Path = "files/images/GUI/Button.png"
	self.m_BackgroundColor = tocolor(255, 255, 255, 200)
	self:setColor(Color.Black)
end

function GUIButton:drawThis()
	dxSetBlendMode("modulate_add")

	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, math.floor(self.m_Width), math.floor(self.m_Height), self.m_Path)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)
	dxDrawText(self:getText(), self.m_AbsoluteX + GUI_BUTTON_BORDER_MARGIN, self.m_AbsoluteY + GUI_BUTTON_BORDER_MARGIN,
		self.m_AbsoluteX + self.m_Width - GUI_BUTTON_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height - GUI_BUTTON_BORDER_MARGIN, self:getColor(), self:getFontSize(), "default", "center", "center", false, true)

	dxSetBlendMode("blend")
end

function GUIButton:onInternalHover()
	self.m_Path = "files/images/GUI/Button_hover.png"
	self.m_BackgroundColor = tocolor(255, 255, 255, 170)
	self:anyChange()
end

function GUIButton:onInternalUnhover()
	self.m_Path = "files/images/GUI/Button.png"
	self.m_BackgroundColor = tocolor(255, 255, 255, 200)
	self:anyChange()
end
