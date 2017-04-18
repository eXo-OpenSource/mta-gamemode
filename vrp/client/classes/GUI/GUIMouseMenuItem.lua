-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMouseMenuItem.lua
-- *  PURPOSE:     GUI mouse menu item class
-- *
-- ****************************************************************************
GUIMouseMenuItem = inherit(GUIElement)
inherit(GUIFontContainer, GUIMouseMenuItem)
inherit(GUIColorable, GUIMouseMenuItem)

function GUIMouseMenuItem:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUIMouseMenuItem:constructor", "number", "number", "number", "number")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1, VRPFont(self.m_Height))
	GUIColorable.constructor(self, tocolor(0, 0, 0, 220))

	self.m_IconFont = FontAwesome(self.m_Height*0.75)
	self.onInternalHover = function() self:setColor(Color.White) self:setTextColor(Color.Black) end
	self.onInternalUnhover = function() self:setColor(tocolor(0, 0, 0, 220)) self:setTextColor(Color.White) end
end

function GUIMouseMenuItem:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

	-- Draw line on the left
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, 2, self.m_Height,	Color.LightBlue) -- tocolor(0x3F, 0x7F, 0xBF, 255))

	-- Draw item text
	if self.m_Icon then
		dxDrawText(self.m_Icon, self.m_AbsoluteX + 10, self.m_AbsoluteY + 8, self.m_AbsoluteX + 5 + self.m_Height, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_IconFont)
		dxDrawText(self.m_Text, self.m_AbsoluteX + 5 + self.m_Height, self.m_AbsoluteY + 3, self.m_Width - 10 - self.m_Width/10, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_Font)
	else
		dxDrawText(self.m_Text, self.m_AbsoluteX + 5, self.m_AbsoluteY + 3, self.m_Width - 10, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_Font)
	end
end

function GUIMouseMenuItem:getTextColor()
	return self.m_TextColor
end

function GUIMouseMenuItem:setTextColor(color)
	self.m_TextColor = color
	self:anyChange()

	return self
end

function GUIMouseMenuItem:setIcon(icon)
	self.m_Icon = icon
end
