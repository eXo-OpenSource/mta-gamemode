-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIEdit.lua
-- *  PURPOSE:     GUI edit class
-- *
-- ****************************************************************************

GUIEdit = inherit(GUIElement)
inherit(GUIFontContainer, GUIEdit)
inherit(GUIColorable, GUIEdit)

local GUI_EDITBOX_BORDER_MARGIN = 6

function GUIEdit:constructor(posX, posY, width, height, parent)
	checkArgs("CGUIEdit:constructor", "number", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "", 1)
	GUIColorable.constructor(self, tocolor(0, 0, 0, 127))

	self.m_Caret = 1
end

function GUIEdit:drawThis()
	dxSetBlendMode("modulate_add")

	--dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 100))
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/Editbox.png")

	local text = #self.m_Text > 0 and self.m_Text or self.m_Caption or ""
	if text ~= self.m_Caption and self.m_MaskChar then
		text = self.m_MaskChar:rep(#text)
	end

	dxDrawText(text, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY, 
				self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height, 
				self:getColor(), self:getFontSize(), self:getFont(), "left", "center", true, false, false, false)

	dxSetBlendMode("blend")
end

function GUIEdit:setCaretPosition(pos)
	self.m_Caret = math.min(math.max(pos, 1), #self.m_Text+1)
	self:anyChange()
end

function GUIEdit:getSelectionRange()
	return self.m_SelectionStart, self.m_Caret
end

function GUIEdit:getCaretPosition(pos)
	return self.m_Caret
end

function GUIEdit:setCaption(caption)
	assert(type(caption) == "string", "Bad argument @ GUIEdit.setCaption")

	self.m_Caption = caption
	self:anyChange()
end

function GUIEdit:onInternalLeftClick()
	GUIInputControl.setFocus(self)
end

function GUIEdit:setMasked(maskChar)
	self.m_MaskChar = maskChar or "*"
end
