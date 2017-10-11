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

	-- Create a dummy gui element for animation
	self.m_CheckedButton = DxRectangle:new(0, 0, 0, 0, Color.Clear, self)

	self.m_Checked = false
	self.m_Enabled = true
end

function GUICheckbox:drawThis()
	dxSetBlendMode("modulate_add")

	local primaryNc = Color.changeAlpha(Color.PrimaryNoClick, self:getAlpha())
	local lightGrey = Color.changeAlpha(Color.LightGrey, self:getAlpha())
	local primary = Color.changeAlpha(Color.Primary, self:getAlpha())
	local accent = Color.changeAlpha(Color.Accent, self:getAlpha())

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Height, self.m_Height, self.m_Enabled and primary or primaryNc)

	local w, h = self.m_CheckedButton:getSize()
	dxDrawRectangle(self.m_AbsoluteX + self.m_Height/2 - w/2, self.m_AbsoluteY + self.m_Height/2 - h/2, w, h, self.m_Enabled and accent or lightGrey)

	dxDrawText(self:getText(), self.m_AbsoluteX + self.m_Height + GUI_CHECKBOX_TEXT_MARGIN, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - GUI_CHECKBOX_TEXT_MARGIN, self.m_AbsoluteY + self.m_Height, self:getColor(), self:getFontSize(), self:getFont(), "left", "center", false, true, false, false, true)
	dxSetBlendMode("blend")
end

function GUICheckbox:onInternalLeftClick()
	if self.m_Enabled then
		self:setChecked(not self:isChecked())

		if self.onChange then
			self.onChange(self:isChecked())
		end
	end
end

function GUICheckbox:isChecked()
	return self.m_Checked
end

function GUICheckbox:setChecked(checked)
	checkArgs("GUICheckbox:setChecked", "boolean")
	self.m_Checked = checked

	local size = self.m_Checked and self.m_Height - 4 or 0
	Animation.Size:new(self.m_CheckedButton, 150, size, size, "OutQuad")

	self:anyChange()
	return self
end

function GUICheckbox:setEnabled(state)
	self:setColor(state and Color.White or Color.LightGrey)
	self.m_Enabled = state
	self:anyChange()
end

function GUICheckbox:isEnabled()
	return self.m_Enabled
end
