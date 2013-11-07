-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
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
	GUIFontContainer.constructor(self, text, 1.5, "arial")
	GUIColorable.constructor(self, Color.Black)
	
	self.onInternalHover = function() self:setColor(Color.White) self:setTextColor(Color.Black) end
	self.onInternalUnhover = function() self:setColor(Color.Black) self:setTextColor(Color.White) end
end

function GUIMouseMenuItem:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)
	
	-- Draw item text
	dxDrawText(self.m_Text, self.m_AbsoluteX + 5, self.m_AbsoluteY + 3, self.m_Width - 10, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_Font)
end

function GUIMouseMenuItem:getTextColor()
	return self.m_TextColor
end

function GUIMouseMenuItem:setTextColor(color)
	self.m_TextColor = color
	self:anyChange()
end
