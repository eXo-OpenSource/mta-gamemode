-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUICheckbox.lua
-- *  PURPOSE:     GUI checkbox class
-- *
-- ****************************************************************************
GUICheckbox = inherit(GUIElement)
inherit(GUIFontContainer, GUICheckbox)
inherit(GUIColorable, GUICheckbox)

local GUI_CHECKBOX_TEXT_MARGIN = 5

function GUICheckbox:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUICheckbox:constructor", "number", "number", "number", "number", "string")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1.5)
	GUIColorable.constructor(self)

	self.m_Checked = false
end

function GUICheckbox:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Height, self.m_Height, "files/images/GUI/Checkbox.png")
	dxDrawText(self:getText(), self.m_AbsoluteX + self.m_Height + GUI_CHECKBOX_TEXT_MARGIN, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - GUI_CHECKBOX_TEXT_MARGIN, self.m_AbsoluteY + self.m_Height, self:getColor(), self:getFontSize(), self:getFont(), "left", "center", false, true, false, false, true)

	if self.m_Checked then
		dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Height, self.m_Height, "files/images/GUI/Checkbox_checked.png")
	end
	dxSetBlendMode("blend")
end

function GUICheckbox:onInternalLeftClick()
	self:setChecked(not self:isChecked())

	if self.onChange then
		self.onChange(self:isChecked())
	end
end

function GUICheckbox:isChecked()
	return self.m_Checked
end

function GUICheckbox:setChecked(checked)
	checkArgs("GUICheckbox:setChecked", "boolean")
	self.m_Checked = checked

	self:anyChange()
	return self
end
