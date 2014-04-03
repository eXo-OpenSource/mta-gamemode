-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUILabel.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
GUILabel = inherit(GUIElement)
inherit(GUIFontContainer, GUILabel)
inherit(GUIColorable, GUILabel)

function GUILabel:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUILabel:constructor", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1)
	GUIColorable.constructor(self)

	self.m_LineSpacing = 10
	self.m_Multiline = false
	self.m_AlignX = "left"
	self.m_AlignY = "top"
	self:setFont(VRPFont(height))
end

function GUILabel:drawThis(incache)
	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end

	dxDrawText(self.m_Text, self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, self.m_Color, self:getFontSize(), self:getFont(), self.m_AlignX, self.m_AlignY, false, true, incache ~= true)
end

function GUILabel:setLineSpacing(lineSpacing)
	self.m_LineSpacing = lineSpacing
	return self
end

function GUILabel:setMultiline(multilineEnabled)
	self.m_Multiline = multilineEnabled
	return self
end

function GUILabel:setAlignX(alignX)
	self.m_AlignX = alignX
	return self
end

function GUILabel:setAlignY(alignY)
	self.m_AlignY = alignY
	return self
end

function GUILabel:setAlign(x, y)
	self.m_AlignX = x or self.m_AlignX
	self.m_AlignY = y or self.m_AlignY
	return self
end
