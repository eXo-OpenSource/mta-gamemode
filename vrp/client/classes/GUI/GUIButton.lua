-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIButton.lua
-- *  PURPOSE:     GUI button class
-- *
-- ****************************************************************************
GUIButton = inherit(GUIElement)
inherit(GUIFontContainer, GUIButton)

local GUI_BUTTON_BORDER_MARGIN = 5

function GUIButton:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUIButton:constructor", "number", "number", "number", "number", "string")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1, VRPFont(math.floor(height*.9)))

	self.m_NormalColor = Color.White
	self.m_HoverColor = Color.Black
	self.m_BackgroundNormalColor = Color.Accent
	self.m_BackgroundHoverColor = Color.White
	self.m_Color = self.m_NormalColor
	self.m_BackgroundColor = self.m_BackgroundNormalColor
	self.m_Enabled = true
	self.m_BarActivated = true

	-- Create a dummy gui element for animation
	self.m_AnimatedBar = DxRectangle:new(0, 0, 0, 2, Color.White, self):setDrawingEnabled(true)
end

function GUIButton:drawThis()
	dxSetBlendMode("modulate_add")

	if self.m_BarActivated then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 2, self.m_Width, self.m_Height - 2, Color.Primary)
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, 2, self.m_BackgroundColor)
	else
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)
	end
	dxDrawText(self:getText(), self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height, self.m_Color, self:getFontSize(), self:getFont(), "center", "center", false, true)

	dxSetBlendMode("blend")
end

function GUIButton:performChecks(...)
	-- Only perform checks if enabled
	if self.m_Enabled then
		GUIElement.performChecks(self, ...)
	end
end

function GUIButton:onInternalHover(cx, cy)
	if self.m_Enabled then
		if not self.m_BarActivated then
			self.m_Color = self.m_HoverColor
			self.m_BackgroundColor = self.m_BackgroundHoverColor
			self:anyChange()
			return
		end

		local buttonX, buttonY = self:getPosition(true)
		self.m_HoverPosX = cx - buttonX

		self.m_AnimatedBar:setSize(0, 2)
		self.m_AnimatedBar:setPosition(self.m_HoverPosX, 0)
		Animation.Move:new(self.m_AnimatedBar, 150, 0, 0, "OutQuad")
		Animation.Size:new(self.m_AnimatedBar, 150, self.m_Width, 2, "OutQuad")
	end
end

function GUIButton:onInternalUnhover()
	if self.m_Enabled then
		if not self.m_BarActivated then
			self.m_Color = self.m_NormalColor
			self.m_BackgroundColor = self.m_BackgroundNormalColor
			self:anyChange()
			return
		end

		if self.m_HoverPosX then
			Animation.Move:new(self.m_AnimatedBar, 150, self.m_HoverPosX, 0, "OutQuad")
			Animation.Size:new(self.m_AnimatedBar, 150, 0, 2, "OutQuad")
		end
	end
end

function GUIButton:setColor(color)
	self.m_NormalColor = color
	if not self:isHovered() then
		self.m_Color = color
	end
	self:anyChange()
	return self
end

function GUIButton:setAlpha(alpha)
	self.m_Alpha = alpha
	self.m_Color = bitReplace(self.m_Color, alpha, 24, 8)
	self.m_BackgroundColor = bitReplace(self.m_BackgroundColor, alpha, 24, 8)

	self:anyChange()
	return self
end


function GUIButton:setHoverColor(color)
	self.m_HoverColor = color
	self:anyChange()
	return self
end

function GUIButton:setBackgroundHoverColor(color)
	self.m_BackgroundHoverColor = color
	self:anyChange()
	return self
end

function GUIButton:setBackgroundColor(color)
	self.m_BackgroundColor = color
	self.m_BackgroundNormalColor = color
	self:anyChange()
	return self
end

function GUIButton:setBarEnabled(activate)
	self.m_BarActivated = activate
	self:anyChange()
	return self
end


function GUIButton:setEnabled(state, tabButton)
	if state == true then
		self:setAlpha(255)
		if tabButton then
			self:setColor(Color.White)
		end
	else
		if not tabButton then
			self:setBackgroundColor(self.m_BackgroundNormalColor)
			self:setAlpha(100)
		else
			self:setBackgroundColor(self.m_BackgroundNormalColor)
			self:setColor(Color.LightGrey)
		end
	end
	self.m_Enabled = state
	self:anyChange()
	return self
end

function GUIButton:isEnabled()
	return self.m_Enabled
end
