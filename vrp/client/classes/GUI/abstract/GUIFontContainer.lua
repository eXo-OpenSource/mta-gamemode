-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIFontContainer.lua
-- *  PURPOSE:     GUI font container super class
-- *
-- ****************************************************************************
GUIFontContainer = inherit(Object)

function GUIFontContainer:constructor(text, size, font)
	self.m_Text		= text or ""
	self.m_FontSize = size or 1
	self.m_Font		= font or "default-bold"
end

function GUIFontContainer:getText(toNumber)
	if not toNumber then
		return self.m_Text
	else
		return self:isIntegerOnly() and (tonumber(self.m_Text) and math.round(tonumber(self.m_Text)) or false) or tonumber(self.m_Text)
	end
end

function GUIFontContainer:setText(text)
	assert(type(text) == "string" or type(text) == "number", "Bad argument @ GUIFontContainer.setText")
	self.m_Text = tostring(text)
	self:anyChange()
	return self
end

function GUIFontContainer:isEmpty()
	return self.m_Text == ""
end

function GUIFontContainer:getFont()
	if type(self.m_Font) == "table" then
		return getVRPFont(self.m_Font)
	end

	return self.m_Font
end

function GUIFontContainer:setFont(font, size)
	--assert(type(font) == "string" or (type(font) == "userdata" and getElementType(font) == "dx-font"), "Bad argument @ GUIFontContainer.setFont")

	self.m_Font = font
	if size then
		assert(type(size) == "number", "Bad argument @ GUIFontContainer.setFont")
		self.m_FontSize = size
	end
	self:anyChange()
	return self
end

function GUIFontContainer:getFontSize()
	return self.m_FontSize
end

function GUIFontContainer:setFontSize(size)
	assert(type(size) == "number", "Bad argument @ GUIFontContainer.setFontSize")

	self.m_FontSize = size
	self:anyChange()
	return self
end

function GUIFontContainer:getFontHeight()
	return dxGetFontHeight(self.m_FontSize, self.m_Font) / 1.75
end
