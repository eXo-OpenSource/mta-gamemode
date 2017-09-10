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
	self.m_Button = GUIRectangle:new(2, 2, self.m_Width/2 - 4, self.m_Height -4, Color.Clear, self)
	--self.m_Button.onHover = function() self.m_Hovered = true self:anyChange() end -- Alternate hover style
	--self.m_Button.onUnhover = function() self.m_Hovered = false self:anyChange() end -- Alternate hover style

	self.m_State = true
end

function GUISwitch:onInternalLeftClick()
	self:setState(not self.m_State)
end

function GUISwitch:onInternalHover()
	self.m_Hovered = true
	self:anyChange()
end

function GUISwitch:onInternalUnhover()
	self.m_Hovered = false
	self:anyChange()
end

function GUISwitch:setState(state)
	self.m_State = state

	local targetPosition = self.m_State and 2 or self.m_Width/2 + 2
	self.m_Animation = Animation.Move:new(self.m_Button, 150, targetPosition, 2, "OutQuad")

	if self.onChange then
		self.onChange(self.m_State)
	end
end

function GUISwitch:getState()
	return self.m_State
end

function GUISwitch:drawThis()
	dxSetBlendMode("modulate_add")

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.Primary)


	local x, y = self.m_Button:getPosition()
	local w, h = self.m_Button:getSize()
	--dxDrawRectangle(self.m_AbsoluteX + x, self.m_AbsoluteY + y, w, h, self.m_Hovered and Color.LightGrey or Color.Accent) -- Alternate hover style
	dxDrawRectangle(self.m_AbsoluteX + x, self.m_AbsoluteY + y, w, h, Color.Accent)

	dxDrawText("An", self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width/2, self.m_AbsoluteY + self.m_Height, Color.White, self:getFontSize(), self:getFont(), "center", "center")
	dxDrawText("Aus", self.m_AbsoluteX + self.m_Width/2, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, Color.White, self:getFontSize(), self:getFont(), "center", "center")

	dxSetBlendMode("blend")
end
