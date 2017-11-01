-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUISwitch.lua
-- *  PURPOSE:     GUI toggle class
-- *
-- ****************************************************************************
GUISwitch = inherit(GUIElement)
inherit(GUIFontContainer, GUISwitch)

function GUISwitch:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "", 1, VRPFont(height))

	-- Create a dummy button for animation
	self.m_Button = DxRectangle:new(0, 0, self.m_Width/2 - 4, self.m_Height - 4, Color.Clear, self)
	self.m_State = true
end

function GUISwitch:onInternalLeftClick()
	self:setState(not self.m_State)
end

function GUISwitch:onInternalHover()
	Animation.Size:new(self.m_Button, 150, self.m_Width/2, self.m_Height, "OutQuad")
	self.m_Hovered = true
end

function GUISwitch:onInternalUnhover()
	Animation.Size:new(self.m_Button, 150, self.m_Width/2 - 4, self.m_Height - 4, "OutQuad")
	self.m_Hovered = false
end

function GUISwitch:setState(state)
	self.m_State = state
	Animation.Move:new(self.m_Button, 150, self.m_State and 0 or self.m_Width/2, 0, "OutQuad")

	if self.onChange then
		self.onChange(self.m_State)
	end
	return self
end

function GUISwitch:getState()
	return self.m_State
end

function GUISwitch:isChecked() -- make it like GUICheckBox
	return self.m_State
end

function GUISwitch:drawThis()
	dxSetBlendMode("modulate_add")
	local white = Color.changeAlpha(Color.White, self:getAlpha())
	local black = Color.changeAlpha(Color.Black, self:getAlpha())
	local primary = Color.changeAlpha(Color.Primary, self:getAlpha())
	local accent = Color.changeAlpha(Color.Accent, self:getAlpha())

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, primary)

	local x, y = self.m_Button:getPosition()
	local w, h = self.m_Button:getSize()
	dxDrawRectangle(self.m_AbsoluteX + x + self.m_Width/4 - w/2, self.m_AbsoluteY + y + self.m_Height/2 - h/2, w, h, self.m_Hovered and white or accent)

	dxDrawText("An", self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width/2, self.m_AbsoluteY + self.m_Height, (self.m_Hovered and self.m_State) and black or white, self:getFontSize(), self:getFont(), "center", "center")
	dxDrawText("Aus", self.m_AbsoluteX + self.m_Width/2, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, (self.m_Hovered and not self.m_State) and black or white, self:getFontSize(), self:getFont(), "center", "center")

	dxSetBlendMode("blend")
end
