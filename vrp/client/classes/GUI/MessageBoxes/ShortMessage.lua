-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/ShortMessagees/ShortMessage.lua
-- *  PURPOSE:     Short message box class
-- *
-- ****************************************************************************
ShortMessage = inherit(DxElement)
inherit(GUIFontContainer, ShortMessage)

ShortMessage.compSize = 35
ShortMessage.MessageQueue = {}

function ShortMessage:constructor(text)
	--DxElement.constructor(self, 20, screenHeight - screenHeight*0.265 - 35 * (#ShortMessage.MessageQueue+1), 340*screenWidth/1600+6, 30)
    DxElement.constructor(self, 20, screenHeight - screenHeight*0.265 - ShortMessage.compSize, 340*screenWidth/1600+6, 30)
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
    local x, y, w, h = self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height


    self.m_Lines = math.floor(dxGetTextWidth(self.m_Text, self.m_FontSize, self.m_Font)/self.m_Width) + 1
    outputChatBox(self.m_Lines)

    -- Calculate heigth
    h = (h * self.m_Lines) - (15 * math.floor(self.m_Lines/2))

    if self.m_Lines > 1 then
        y = y - h + 25
    end

	-- Draw background
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 200))


    -- Center the text
    x = x + 5
    w = w - 10

    -- Draw the text bounding box (DEBUG)
    --[[
    dxDrawLine(x, y, x + w, y, Color.White, 1)
    dxDrawLine(x, y, x, y + h, Color.White, 1)
    dxDrawLine(x, y + h, x + w, y + h, Color.White, 1)
    dxDrawLine(x + w, y, x + w, y + h, Color.White, 1)
    --]]

	-- Draw message text
	dxDrawText(self.m_Text, x, y, x + w, y + h, Color.White, self.m_FontSize, self.m_Font, "left", "center", false, true)
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

