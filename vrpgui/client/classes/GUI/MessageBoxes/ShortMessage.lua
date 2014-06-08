-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/ShortMessagees/ShortMessage.lua
-- *  PURPOSE:     Short message box class
-- *
-- ****************************************************************************
ShortMessage = inherit(DxElement)
inherit(GUIFontContainer, ShortMessage)

ShortMessage.MessageQueue = {}

function ShortMessage:constructor(text)
	DxElement.constructor(self, 20, screenHeight - screenHeight*0.265 - 35 * (#ShortMessage.MessageQueue+1), 340*screenWidth/1600+6, 30)
	GUIFontContainer.constructor(self, text, 1.4, "default")
	
	table.insert(ShortMessage.MessageQueue, self)
	
	if #ShortMessage.MessageQueue == 1 then
		resetTimer(ShortMessage.Timer)
	end
end

function ShortMessage:destructor()
	DxElement.destructor(self)
end

function ShortMessage:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200))
	
	-- Draw message text
	dxDrawText(self.m_Text, self.m_AbsoluteX + self.m_Width * 0.01, self.m_AbsoluteY + self.m_Width * 0.01, self.m_AbsoluteX - self.m_Width * 0.01, self.m_AbsoluteY - self.m_Height * 0.01, Color.White, self.m_FontSize, self.m_Font, "left", "top", false, true)
end

ShortMessage.Timer = setTimer(
	function()		
		if #ShortMessage.MessageQueue > 0 then			
			delete(ShortMessage.MessageQueue[1])
			table.remove(ShortMessage.MessageQueue, 1)
			
			for k, v in ipairs(ShortMessage.MessageQueue) do
				local x, y = v:getPosition()
				v:setPosition(x, y + 35)
			end
		end		
	end, 4000, 0
)

addEvent("shortMessageBox", true)
addEventHandler("shortMessageBox", root, function(...) ShortMessage:new(...) end)

