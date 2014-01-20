-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIWindow.lua
-- *  PURPOSE:     GUI window class
-- *
-- ****************************************************************************
GUIWindow = inherit(GUIElement)
inherit(GUIFontContainer, GUIWindow)
inherit(GUIColorable, GUIWindow)
--inherit(GUIMoveable, GUIWindow)

function GUIWindow:constructor(posX, posY, width, height, title, hasTitlebar, hasCloseButton, parent)
	checkArgs("GUIWindow:constructor", "number", "number", "number", "number", "string")

	-- float -> int (prevent blurring)
	width = math.floor(width)
	height = math.floor(height)	

	-- Call base class ctors
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, title, 1)
	GUIColorable.constructor(self, Color.White)
	--GUIMoveable.constructor(self, self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + 20) -- ToDo: Const for title bar height

	self:setAlpha(200)
	self.m_HasTitlebar = hasTitlebar
	self.m_HasCloseButton = hasCloseButton
	self.m_CloseOnClose = true
	
	self:setFont(VRPFont(24))

	if self.m_HasCloseButton then
		self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", 1, self):setFont(VRPFont(28)) --GUIImage(self.m_Width - 40, 4, 35, 27, "files/images/GUI/close_button.png", self)
		self.m_CloseButton.onLeftClick = bind(GUIWindow.CloseButton_Click, self)
	end
end

function GUIWindow:drawThis()
	-- Moving test
	--[[if self:isMoving() then
		self:updateMoveArea()
	end]]

	dxSetBlendMode("modulate_add")

	-- Draw window
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/Window.png")
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, self.m_Alpha))

	-- Draw logo
	if false then -- Should the logo be optional? | Todo: Since we haven't got a logo, disable that
		dxDrawImage(self.m_AbsoluteX + 10, self.m_AbsoluteY + self.m_Height - 29 - 10, 62, 29, "files/images/GUI/logo.png")
	end
	
	if self.m_HasTitlebar then
		-- Draw line under title bar
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 30, self.m_Width, 2, Color.White)

		-- Draw title
		dxDrawText(self.m_Text, self.m_AbsoluteX, self.m_AbsoluteY+7, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + 25, self.m_Color, self.m_FontSize, self.m_Font, "center", "center")
	end
	
	dxSetBlendMode("blend")
end

function GUIWindow:CloseButton_Click()
	if self.m_CloseOnClose then
		self:close()
	else
		(self.m_Parent or self):setVisible(false) -- Todo: if self.m_Parent == cacheroot then problem() end
	end
end

--- Closes the window
function GUIWindow:close()
	-- Jusonex: Destroy or close, I dunno what's better
	delete(self.m_Parent or self)
end

function GUIWindow:setCloseOnClose(close) -- Todo: Find a better name
	self.m_CloseOnClose = close
	return self
end
