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
	local x = HUDRadar:getSingleton():getPosition()
	DxElement.constructor(self, x, screenHeight, HUDRadar:getSingleton():getWidth(), 110)
	GUIFontContainer.constructor(self, text, 1, VRPFont(28))

	if timeout and type(timeout) == "number" then
		if timeout > 50 then
			timeout = timeout
		else
			timeout = #text*100 > 5000 and #text*100 or 5000
		end
	else
		timeout = #text*100 > 5000 and #text*100 or 5000
	end
	setTimer(function() delete(self) end, timeout, 1)
	playSound(self:getSoundPath())

	table.insert(MessageBox.MessageBoxes, self)
	MessageBox.resortPositions()
end

function MessageBox:virtual_constructor(text, timeout)
	MessageBox.constructor(self, text, timeout)
end

function MessageBox:virtual_destructor ()
	table.removevalue(MessageBox.MessageBoxes, self)
	MessageBox.resortPositions()
end

function MessageBox:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150))
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, 5, Color.DarkLightBlue)

	-- Draw icon
	dxDrawImage(self.m_AbsoluteX + 10, self.m_AbsoluteY + self.m_Height/2 - 80/2, 85, 85, self:getImagePath())

	-- Draw message text
	dxDrawText(self.m_Text, self.m_AbsoluteX + 120, self.m_AbsoluteY + 20, self.m_AbsoluteX + self.m_Width - 5, self.m_AbsoluteY + self.m_Height - 10, Color.White, self.m_FontSize, self.m_Font, "left", "top", false, true)
end

function MessageBox.resortPositions ()
	for i = #MessageBox.MessageBoxes, 1, -1 do
		local obj = MessageBox.MessageBoxes[i]
		local prevObj = MessageBox.MessageBoxes[i + 1]
		local x, y = HUDRadar:getSingleton():getPosition()

		if obj.m_Animation then
			delete(obj.m_Animation)
		end

		if prevObj then
			obj.m_Animation = Animation.Move:new(obj, 1000, obj.m_AbsoluteX, prevObj.m_Animation.m_TY - obj.m_Height - 5)
		else
			obj.m_Animation = Animation.Move:new(obj, 1000, obj.m_AbsoluteX, y - x)
		end
	end
end

MessageBox.getImagePath = pure_virtual
MessageBox.getSoundPath = pure_virtual
