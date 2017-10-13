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
	GUIFontContainer.constructor(self, "", 1, VRPFont(height*.9))
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

	local white = tocolor(255, 255, 255, self:getAlpha())
	if self.m_Icon then
		dxDrawRectangle(self.m_AbsoluteX - 30, self.m_AbsoluteY, 30, self.m_Height, white)
		dxDrawText(self.m_Icon, self.m_AbsoluteX - 30, self.m_AbsoluteY, self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height, self:getColor(), self:getFontSize(), FontAwesome(self.m_Height*.9), "center", "center")
	end

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, white)
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
		dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + 6, textWidth, self.m_Height - 12, tocolor(0, 170, self:getAlpha()))
	end

	if self.m_Selection then
		dxDrawText(text, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY, self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height, (self.m_MarkedAll) and white or self:getColor(), self:getFontSize(), self:getFont(), aliginX, "center", true, false, false, false)
		dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN + self.m_SelectionOffset, self.m_AbsoluteY + 6, self.m_SelectionWidth, self.m_Height - 12, tocolor(0, 170, self:getAlpha()))

		local textWidth = dxGetTextWidth(self.m_SelectedFirst, self:getFontSize(), self:getFont())
		dxDrawText(self.m_SelectedText, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN + textWidth, self.m_AbsoluteY, self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height, white, self:getFontSize(), self:getFont(), aliginX, "center", true, false, false, false)
	else
		dxDrawText(text, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY, self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height, (self.m_MarkedAll) and white or self:getColor(), self:getFontSize(), self:getFont(), aliginX, "center", true, false, false, false)
	end

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
	self.m_SelectionRenderOnly = false

	if self.onChange then
		self.onChange(self:getDrawnText())
	end
end

function GUIEdit:onInternalLeftClickDown(absoluteX, absoluteY)
	if self.m_Caption and self:getDrawnText() == self.m_Caption then
		GUIInputControl.setFocus(self, 0)
		return
	end

	if GUIInputControl.SelectionInProgress then return end
	GUIInputControl.SelectionInProgress = true

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
	if self.m_Caption and self:getDrawnText() == self.m_Caption then
		GUIInputControl.setFocus(self, 0)
		return
	end

	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	local index = self:getIndexFromPixel(relativeX, relativeY)

	if self.m_Selection then
		index = self.m_SelectionEnd
	end

	self:setCaretPosition(index)
	self.m_MarkedAll = false
	self.m_EndIndex = index

	GUIInputControl.setFocus(self, index)

	GUIInputControl.SelectionInProgress = false
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

	self:onInternalUpdateSelection()
end

function GUIEdit:onCursorMove(_, _, absoluteX, absoluteY)
	if not getKeyState("mouse1") then
		GUIInputControl.SelectionInProgress = false
		removeEventHandler("onClientCursorMove", root, self.m_OnCursorMove)
		return
	end

	local posX, posY = self:getPosition(true) -- DxElement:getPosition is necessary as m_Absolute_ depends on the position of the cache area
	local relativeX, relativeY = absoluteX - posX, absoluteY - posY
	if relativeX < 0 then relativeX = 0 end

	self.m_EndIndex = self:getIndexFromPixel(relativeX, relativeY)
	self:onInternalUpdateSelection(true)
end

function GUIEdit:onInternalFocus()
	GUIInputControl.ms_RecentlyInFocus = self
	self:setCursorDrawingEnabled(true)
end

function GUIEdit:onInternalLooseFocus()
	self.m_Selection = false
	self.m_SelectionRenderOnly = false
	self.m_SelectedText = nil
	self.m_MarkedAll = false
	self:setCursorDrawingEnabled(false)
end

function GUIEdit:onInternalUpdateSelection(checkIndex)
	if checkIndex then
		self.m_SelectionStart = self.m_StartIndex
		self.m_SelectionEnd = self.m_EndIndex

		if self.m_StartIndex > self.m_EndIndex then
			self.m_SelectionStart = self.m_EndIndex
			self.m_SelectionEnd = self.m_StartIndex
		end
	end

	self.m_Selection = self.m_SelectionStart ~= self.m_SelectionEnd
	if self.m_Selection then
		self.m_SelectedFirst = utfSub(self:getDrawnText(), 0, self.m_SelectionStart)
		self.m_SelectedText = utfSub(self:getDrawnText(), self.m_SelectionStart + 1, self.m_SelectionEnd)
		self.m_SelectionOffset = dxGetTextWidth(utfSub(self:getDrawnText(), 0, self.m_SelectionStart), self:getFontSize(), self:getFont())
		self.m_SelectionWidth = dxGetTextWidth(self.m_SelectedText, self:getFontSize(), self:getFont())
	end

	self:anyChange()
end

function GUIEdit:setCaretPosition(pos)
	if getKeyState("lshift") or getKeyState("rshift") then
		self.m_StartIndex = pos
		self.m_EndIndex = self.m_Caret
		self.m_SelectionRenderOnly = true
		self:onInternalUpdateSelection(true)
	end

	self.m_Caret = math.min(math.max(pos, 0), utfLen(self:getDrawnText())+1)
	self:anyChange()
	return self
end

function GUIEdit:getCaretPosition()
	return self.m_Caret
end

function GUIEdit:setCaption(caption)
	assert(type(caption) == "string", "Bad argument @ GUIEdit.setCaption")

	self.m_Caption = caption
	self:anyChange()
	return self
end

function GUIEdit:setMasked(maskChar)
	self.m_MaskChar = maskChar or "•"
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

function GUIEdit:setIcon(icon)
	self.m_Icon = icon

	local posX, posY = self:getPosition()
	local width, height = self:getSize()

	self:setSize(width - 30, height)
	self:setPosition(posX + 30, posY)
	return self
end
