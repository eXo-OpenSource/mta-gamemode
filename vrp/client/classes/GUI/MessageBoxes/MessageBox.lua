-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MessageBoxs/MessageBox.lua
-- *  PURPOSE:     Message box class
-- *
-- ****************************************************************************
MessageBox = inherit(DxElement)
inherit(GUIFontContainer, MessageBox)
MessageBox.MessageBoxes = {}

function MessageBox:constructor(text, timeout)
	DxElement.constructor(self, screenWidth/2-360/2, screenHeight, 360, 140)
	GUIFontContainer.constructor(self, text, 1.4, "default")
	timeout = timeout and timeout >= 50 and timeout or 3000
	setTimer(function() delete(self) end, timeout, 1)
	playSound(self:getSoundPath())

	table.insert(MessageBox.MessageBoxes, self)

	for i = #MessageBox.MessageBoxes, 1, -1 do
		local obj = MessageBox.MessageBoxes[i]
		local prevObj = MessageBox.MessageBoxes[i + 1]

		if prevObj then
			obj.m_Animation = Animation.Move:new(obj, 1000, obj.m_AbsoluteX, prevObj.m_Animation.m_TY - obj.m_Height - 5)
		else
			obj.m_Animation = Animation.Move:new(obj, 1000, obj.m_AbsoluteX, obj.m_AbsoluteY - obj.m_Height - 5)
		end
	end
end

function MessageBox:virtual_constructor(text, timeout)
	MessageBox.constructor(self, text, timeout)
end

function MessageBox:virtual_destructor ()
	table.removevalue(MessageBox.MessageBoxes, self)
end

function MessageBox:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150))
	
	-- Draw icon
	dxDrawImage(self.m_AbsoluteX + 10, self.m_AbsoluteY + self.m_Height/2 - 100/2, 100, 100, self:getImagePath())
	
	-- Draw message text
	dxDrawText(self.m_Text, self.m_AbsoluteX + 120, self.m_AbsoluteY + 10, self.m_AbsoluteX + self.m_Width - 5, self.m_AbsoluteY + self.m_Height - 10, Color.White, self.m_FontSize, self.m_Font, "left", "top", false, true)
end

MessageBox.getImagePath = pure_virtual
MessageBox.getSoundPath = pure_virtual