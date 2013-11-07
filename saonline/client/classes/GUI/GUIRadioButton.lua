-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIRadioButton.lua
-- *  PURPOSE:     GUI radio button class
-- *
-- ****************************************************************************
GUIRadioButton = inherit(GUIElement)
inherit(GUIColorable, GUIRadioButton)
inherit(GUIFontContainer, GUIRadioButton)

local GUI_RADIO_TEXT_MARGIN = 5

function GUIRadioButton:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUIRadioButton.constructor", "number", "number", "number", "number")
	
	if not instanceof(parent, GUIRadioButtonGroup) then
		error("GUIRadioButton's parent should be a GUIRadioButtonGroup")
	end

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1.5)
	GUIColorable.constructor(self)
	
	self.m_Checked = false

	-- Mark first item in radio button group as checked
	if self.m_Parent and not self.m_Parent.m_pCheckedRadio then
		self:setChecked(true)
	end
end

function GUIRadioButton:onInternalLeftClick()
	if self.m_Parent then -- Should always exist
		self:setChecked(not self:isChecked())
	end
end

function GUIRadioButton:setChecked(bChecked)
	if bChecked then
		self.m_Parent:setCheckedRadioButton(self)
	end

	self.m_Checked = bChecked
	self:anyChange()
end

function GUIRadioButton:isChecked()
	return self.m_Checked
end

function GUIRadioButton:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Height, self.m_Height, "files/images/GUI/radiobutton.png")
	dxDrawText(self:getText(), self.m_AbsoluteX + self.m_Height + GUI_RADIO_TEXT_MARGIN, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - GUI_RADIO_TEXT_MARGIN, self.m_AbsoluteY + self.m_Height, self:getColor(), self:getFontSize(), self:getFont(), "left", "center", false, true)

	if self.m_Checked then
		dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Height, self.m_Height, "files/images/GUI/radiobutton_check.png")
	end
	dxSetBlendMode("blend")
end
