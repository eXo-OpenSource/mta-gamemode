-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUILabel.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
GUILabel = inherit(GUIElement)
inherit(GUIFontContainer, GUILabel)
inherit(GUIColorable, GUILabel)

function GUILabel:constructor(posX, posY, width, height, text, size, parent)
	checkArgs("GUILabel:constructor", "number", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, size)
	GUIColorable.constructor(self)

	self.m_LineSpacing = 10
	self.m_Multiline = false
end

function GUILabel:drawThis(incache)
	if not self.m_Multiline then
		dxDrawText(self.m_Text, self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, self.m_Color, self:getFontSize(), self:getFont(), "left", "top", false, true, incache ~= true)
	else

		-- Split the text into lines (\n)
		local parts = split(self.m_Text, '\n')
		for lineNum, part in ipairs(parts) do
			
			dxDrawText(self.m_Text, self.m_AbsoluteX, self.m_AbsoluteY + lineNum * self.m_LineSpacing, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height)

		end

	end
end

function GUILabel:setLineSpacing(lineSpacing)
	self.m_LineSpacing = lineSpacing
end

function GUILabel:setMultiline(multilineEnabled)
	self.m_Multiline = multilineEnabled
end
