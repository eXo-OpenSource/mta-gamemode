ToastMessage = inherit(DxElement)
inherit(GUIFontContainer, ToastMessage)
ToastMessage.Map = {}

function ToastMessage:constructor(text, timeout)
	GUIFontContainer.constructor(self, text, 1, VRPFont(23))

	local radar = HUDRadar:getSingleton()
	local x, y, w, h = radar.m_PosX + radar.m_Width + 20, screenHeight, 340, 41
	local textHeight = textHeight(self.m_Text, w - 70, self.m_Font, self.m_FontSize)
	h = h + textHeight

	DxElement.constructor(self, x, y, w, h)

	self.m_Title = self:getDefaultTitle()
	self.m_TitleFont = VRPFont(28, Fonts.EkMukta_Bold)
	self.m_TextHeight = textHeight

	playSound(self:getSoundPath())
	setTimer(function() delete(self) end, timeout or 5000, 1)
	table.insert(ToastMessage.Map, self)
	ToastMessage.resortPositions()
end

function ToastMessage:virtual_constructor(text, timeout)
	ToastMessage.constructor(self, text, timeout)
end

function ToastMessage:virtual_destructor()
	table.removevalue(ToastMessage.Map, self)
	ToastMessage.resortPositions()
end

function ToastMessage:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self:getColor())

	-- Draw image
	dxDrawImage(self.m_AbsoluteX + 20, self.m_AbsoluteY + self.m_Height/2 - 24/2, 24, 24, self:getImagePath())

	-- Draw title
	dxDrawText(self.m_Title, self.m_AbsoluteX + 60, self.m_AbsoluteY + 5, self.m_AbsoluteX + self.m_Width - 20, self.m_AbsoluteY + 15, Color.White, self.m_FontSize, self.m_TitleFont)

	-- Draw text
	dxDrawText(self.m_Text, self.m_AbsoluteX + 60, self.m_AbsoluteY + 30, self.m_AbsoluteX + self.m_Width - 20, self.m_AbsoluteY + self.m_Height - 30 - 10, Color.White, self.m_FontSize, self.m_Font, "left", "top", false, true)
end

function ToastMessage.resortPositions()
	local radar = HUDRadar:getSingleton()
	for i = #ToastMessage.Map, 1, -1 do
		local toast = ToastMessage.Map[i]
		local prevToast = ToastMessage.Map[i + 1]

		if toast.m_Animation then
			delete(toast.m_Animation)
		end

		if prevToast then
			toast.m_Animation = Animation.Move:new(toast, 1000, toast.m_AbsoluteX, prevToast.m_Animation.m_TY - toast.m_Height - 5)
		else
			toast.m_Animation = Animation.Move:new(toast, 1000, toast.m_AbsoluteX, radar.m_PosY + radar.m_Height + 18 - toast.m_Height)
		end
	end
end

ToastMessage.getImagePath    = pure_virtual
ToastMessage.getSoundPath    = pure_virtual
ToastMessage.getColor        = pure_virtual
ToastMessage.getDefaultTitle = pure_virtual

function testToast()
	ToastError:new("Hi im a error toast")
	ToastInfo:new("Hi im a  info toast")
	ToastSuccess:new("Hi im a success toast")
	ToastWarning:new("Hi im a warning toast")

	ToastInfo:new("Hi im a  info toast with\nmultiple\nlines!")
end
