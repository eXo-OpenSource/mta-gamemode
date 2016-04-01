-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIEdit.lua
-- *  PURPOSE:     GUI edit class
-- *
-- ****************************************************************************

GUIEdit = inherit(GUIElement)
inherit(GUIFontContainer, GUIEdit)
inherit(GUIColorable, GUIEdit)

local GUI_EDITBOX_BORDER_MARGIN = 6

function GUIEdit:constructor(posX, posY, width, height, parent)
	checkArgs("GUIEdit:constructor", "number", "number", "number", "number")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "", 1, VRPFont(height))
	GUIColorable.constructor(self, Color.DarkBlue)

	self.m_Caret = 0
	self.m_DrawCursor = false
end

function GUIEdit:drawThis()
	dxSetBlendMode("modulate_add")

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.White)
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/Editbox.png")

	local text = self:getDrawnText()

	dxDrawText(text, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY,
				self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height,
				self:getColor(), self:getFontSize(), self:getFont(), "left", "center", true, false, false, false)

	if self.m_DrawCursor then
		local textBeforeCursor = utfSub(text, 0, self.m_Caret)
		dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN + dxGetTextWidth(textBeforeCursor, self:getFontSize(), self:getFont()), self.m_AbsoluteY + 6, 2, self.m_Height - 12, Color.Black)
	end

	dxSetBlendMode("blend")
end

function GUIEdit:getDrawnText()
	local text = #self.m_Text > 0 and self.m_Text or self.m_Caption or ""
	if text ~= self.m_Caption and self.m_MaskChar then
		text = self.m_MaskChar:rep(#text)
	end
	return text
end

function GUIEdit:onInternalEditInput(caret)
	-- Todo: Remove the following condition as soon as guiGetCaretIndex is backported
	if not caret then
		self.m_Caret = utfLen(self.m_Text)
		return
	end
	self.m_Caret = caret

	if self.onChange then
		self.onChange(self:getDrawnText())
	end

end

function GUIEdit:onInternalLeftClick(absoluteX, absoluteY)
	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	local index = self:getIndexFromPixel(relativeX, relativeY)
	self:setCaretPosition(index)

	GUIInputControl.setFocus(self, index)
end

function GUIEdit:onInternalFocus()
	self:setCursorDrawingEnabled(true)
end

function GUIEdit:onInternalLooseFocus()
	self:setCursorDrawingEnabled(false)
end

function GUIEdit:setCaretPosition(pos)
	self.m_Caret = math.min(math.max(pos, 0), utfLen(self:getDrawnText())+1)
	self:anyChange()
	return self
end

--[[function GUIEdit:getSelectionRange()
	return self.m_SelectionStart, self.m_Caret
end]]

function GUIEdit:getCaretPosition(pos)
	return self.m_Caret
end

function GUIEdit:setCaption(caption)
	assert(type(caption) == "string", "Bad argument @ GUIEdit.setCaption")

	self.m_Caption = caption
	self:anyChange()
	return self
end

function GUIEdit:setMasked(maskChar)
	self.m_MaskChar = maskChar or "*"
	return self
end

function GUIEdit:setCursorDrawingEnabled(state)
	self.m_DrawCursor = state
	self:anyChange()
	return self
end

function GUIEdit:getIndexFromPixel(posX, posY)
	local text = self:getDrawnText()
	local size = self:getFontSize()
	local font = self:getFont()

	for i = 0, utfLen(text) do
		local extent = dxGetTextWidth(utfSub(text, 0, i), size, font)
		if extent > posX then
			return i-1
		end
	end
	return utfLen(text)
end

function GUIEdit:isNumeric()
	return self.m_Numeric
end

function GUIEdit:setNumeric(numeric)
	self.m_Numeric = numeric
	return self
end
