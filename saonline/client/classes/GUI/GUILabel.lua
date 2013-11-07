-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUI/GUILabel.lua
-- *  PURPOSE:     GUI label wrapper
-- *
-- ****************************************************************************
GUILabel = inherit(Object)

function GUILabel:constructor(posX, posY, width, height, text, relative, parent)
	self.m_Element = guiCreateLabel(posX, posY, width, height, text, relative, parent)
end

function GUILabel:getFontHeight()
	return guiLabelGetFontHeight(self.m_Element)
end

function GUILabel:getTextExtent()
	return guiLabelGetTextExtent(self.m_Element)
end

function GUILabel:setColor(r, g, b)
	return guiLabelSetColor(self.m_Element, r, g, b)
end

function GUILabel:getColor()
	return guiLabelGetColor(self.m_Element)
end

function GUILabel:setHorizontalAlign(align, wordwrap)
	return guiLabelSetHorizontalAlign(align, wordwrap)
end

function GUILabel:setVerticalAlign(align)
	return guiLabelSetVerticalAlign(align)
end
