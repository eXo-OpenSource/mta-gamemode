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

	self.m_OnCursorMove = bind(GUIEdit.onCursorMove, self)
	self.m_MaxLength = math.huge
	self.m_MaxValue =  math.huge
	self.m_Caret = 0
	self.m_StartIndex = 0
	self.m_EndIndex = 0
	self.m_DrawCursor = false
end

function GUIEdit:drawThis()
	dxSetBlendMode("modulate_add")

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.White)
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/Editbox.png")

	local text = self:getDrawnText()
	local aliginX = "left"
	local textBeforeCursor = utfSub(text, 0, self.m_Caret)

	if dxGetTextWidth(textBeforeCursor, self:getFontSize(), self:getFont()) >= self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN - 2 then
		aliginX = "right"
	end

	if self.m_MarkedAll then
		local textWidth = dxGetTextWidth(text, self:getFontSize(), self:getFont())
		if textWidth > self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN then textWidth = self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN end
		dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + 6, textWidth, self.m_Height - 12, tocolor(0, 170, 255))
	end

	if self.m_Selection then
		dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN + self.m_SelectionOffset, self.m_AbsoluteY + 6, self.m_SelectionWidth, self.m_Height - 12, tocolor(0, 170, 255))
	end

	dxDrawText(text, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY,
				self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height,
				(self.m_MarkedAll) and Color.White or self:getColor(), self:getFontSize(), self:getFont(), aliginX, "center", true, false, false, false)

	if self.m_DrawCursor and not self.m_MarkedAll then
		if dxGetTextWidth(textBeforeCursor, self:getFontSize(), self:getFont()) < self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN then
			dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN + dxGetTextWidth(textBeforeCursor, self:getFontSize(), self:getFont()), self.m_AbsoluteY + 6, 2, self.m_Height - 12, Color.Black)
		end
	end

	dxSetBlendMode("blend")
end

function GUIEdit:getDrawnText()
	local text = #self.m_Text > 0 and self:getText() or self.m_Caption or ""
	if text ~= self.m_Caption and self.m_MaskChar then
		text = self.m_MaskChar:rep(#text)
	end
	return text
end

function GUIEdit:onInternalEditInput(caret)
	self.m_Caret = caret
	self.m_MarkedAll = false
	self.m_Selection = false

	if self.onChange then
		self.onChange(self:getDrawnText())
	end
end

function GUIEdit:onInternalLeftClickDown(absoluteX, absoluteY)
	if GUIEdit.SelectionInProgress then return end
	GUIEdit.SelectionInProgress = true

	if self.m_LastClick and getTickCount() - self.m_LastClick.tick < 500 and (self.m_LastClick.position - Vector2(absoluteX, absoluteY)).length < 5 then
		return self:onInternalLeftDoubleClick(absoluteX, absoluteY)
	end
	self.m_LastClick = {tick = getTickCount(), position = Vector2(absoluteX, absoluteY)}

	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	local index = self:getIndexFromPixel(relativeX, relativeY)

	self.m_StartIndex = index
	self.m_EndIndex = index

	GUIInputControl.setFocus(self, index)

	addEventHandler("onClientCursorMove", root, self.m_OnCursorMove)
end

function GUIEdit:onInternalLeftClick(absoluteX, absoluteY)
	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	local index = self:getIndexFromPixel(relativeX, relativeY)
	self:setCaretPosition(index)
	self.m_MarkedAll = false
	self.m_EndIndex = index

	GUIInputControl.setFocus(self, index)

	GUIEdit.SelectionInProgress = false
	removeEventHandler("onClientCursorMove", root, self.m_OnCursorMove)
end

function GUIEdit:onInternalLeftDoubleClick(absoluteX, absoluteY)
	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	local index = self:getIndexFromPixel(relativeX, relativeY)

	local selectionStart, selectionEnd = 0, 0
	for i = 0, #self.m_Text do
		local result = string.find(self.m_Text, "%s", i) or (#self.m_Text +1)
		if result > index then
			selectionEnd = result - 1
			break
		end
		selectionStart = result
	end

	self.m_SelectionStart = selectionStart
	self.m_SelectionEnd = selectionEnd
	self.m_Selection = self.m_SelectionStart ~= self.m_SelectionEnd

	if self.m_Selection then
		self.m_SelectedText = utfSub(self.m_Text, self.m_SelectionStart + 1, self.m_SelectionEnd)
		self.m_SelectionOffset = dxGetTextWidth(utfSub(self.m_Text, 0, self.m_SelectionStart), self:getFontSize(), self:getFont())
		self.m_SelectionWidth = dxGetTextWidth(self.m_SelectedText, self:getFontSize(), self:getFont())

		GUIInputControl.skipChangedEvent = true
		guiEditSetCaretIndex(GUIInputControl.ms_Edit, self.m_SelectionEnd)
		GUIInputControl.skipChangedEvent = false

		self:anyChange()
	end
end

function GUIEdit:onCursorMove(_, _, absoluteX, absoluteY)
	if not getKeyState("mouse1") then
		GUIEdit.SelectionInProgress = false
		removeEventHandler("onClientCursorMove", root, self.m_OnCursorMove)
		return
	end

	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	if relativeX < 0 then relativeX = 0 end

	self.m_EndIndex = self:getIndexFromPixel(relativeX, relativeY)

	self.m_Selection = self.m_StartIndex ~= self.m_EndIndex
	if self.m_Selection then
		local text = self:getDrawnText()
		self.m_SelectionStart = self.m_StartIndex
		self.m_SelectionEnd = self.m_EndIndex

		if self.m_StartIndex > self.m_EndIndex then
			self.m_SelectionStart = self.m_EndIndex
			self.m_SelectionEnd = self.m_StartIndex
		end

		self.m_SelectedText = utfSub(text, self.m_SelectionStart + 1, self.m_SelectionEnd)
		self.m_SelectionOffset = dxGetTextWidth(utfSub(text, 0, self.m_SelectionStart), self:getFontSize(), self:getFont())
		self.m_SelectionWidth = dxGetTextWidth(self.m_SelectedText, self:getFontSize(), self:getFont())
	end

	self:anyChange()
end

function GUIEdit:onInternalFocus()
	GUIInputControl.ms_RecentlyInFocus = self
	self:setCursorDrawingEnabled(true)
end

function GUIEdit:onInternalLooseFocus()
	self.m_Selection = false
	self.m_SelectedText = nil
	self.m_MarkedAll = false
	self:setCursorDrawingEnabled(false)
end

function GUIEdit:setCaretPosition(pos)
	self.m_Caret = math.min(math.max(pos, 0), utfLen(self:getDrawnText())+1)
	self:anyChange()
	return self
end

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

function GUIEdit:setNumeric(numeric, integerOnly)
	self.m_Numeric = numeric
	self.m_IntegerOnly = integerOnly or false
	return self
end

function GUIEdit:setMaxLength(length)
	self.m_MaxLength = length
	return self
end

function GUIEdit:setMaxValue(value)
	self.m_MaxValue = value
	return self
end

function GUIEdit:isNumeric()
	return self.m_Numeric
end

function GUIEdit:isIntegerOnly()
	return self.m_IntegerOnly
end
