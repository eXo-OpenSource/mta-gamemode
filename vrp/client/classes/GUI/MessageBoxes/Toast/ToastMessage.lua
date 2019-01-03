ToastMessage = inherit(DxElement)
inherit(GUIFontContainer, ToastMessage)

function ToastMessage:constructor(text, timeout, title)
	GUIFontContainer.constructor(self, text, 1, VRPFont(23))
	local x, y = HUDRadar:getSingleton():getPosition()
	local w = HUDRadar:getSingleton():getWidth()
	local h = 41
	local textHeight = textHeight(self.m_Text, w - 70, self:getFont(), self:getFontSize())
	h = h + textHeight
	y = y - h - x

	DxElement.constructor(self, x, y, w, h)

	self.m_Title = title or self:getDefaultTitle()
	self.m_TitleFont = VRPFont(28, Fonts.EkMukta_Bold)
	self.m_TextHeight = textHeight

	-- Alpha
	self:setAlpha(0)
	self.m_AlphaFaded = false

	playSound(self:getSoundPath())
	setTimer(function() delete(self) end, timeout or (#text*100 > 5000 and #text*100 or 5000), 1)

	table.insert(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()
end

function ToastMessage:virtual_constructor(text, timeout, title)
	ToastMessage.constructor(self, text, timeout, title)
end

function ToastMessage:virtual_destructor()
	table.removevalue(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()
end

function ToastMessage:drawThis()
	-- get color
	local color = self:getColor()

	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(color[1], color[2], color[3], self.m_Alpha))

	-- Draw image
	dxDrawImage(self.m_AbsoluteX + 20, self.m_AbsoluteY + self.m_Height/2 - 24/2, 24, 24, self:getImagePath(), 0, 0, 0, tocolor(255, 255, 255, self.m_Alpha))

	-- Draw title
	dxDrawText(self.m_Title, self.m_AbsoluteX + 60, self.m_AbsoluteY + 5, self.m_AbsoluteX + self.m_Width - 20, self.m_AbsoluteY + 15, tocolor(255, 255, 255, self.m_Alpha), self:getFontSize(), getVRPFont(self.m_TitleFont))

	-- Draw text
	dxDrawText(self.m_Text, self.m_AbsoluteX + 60, self.m_AbsoluteY + 30, self.m_AbsoluteX + self.m_Width - 20, self.m_AbsoluteY + self.m_Height - 30 - 10, tocolor(255, 255, 255, self.m_Alpha), self:getFontSize(), self:getFont(), "left", "top", false, true)
end

ToastMessage.getImagePath    = pure_virtual
ToastMessage.getSoundPath    = pure_virtual
ToastMessage.getColor        = pure_virtual
ToastMessage.getDefaultTitle = pure_virtual
