-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/ShortMessagees/ShortMessage.lua
-- *  PURPOSE:     Short message box class
-- *
-- ****************************************************************************
ShortMessage = inherit(DxElement)
inherit(GUIFontContainer, ShortMessage)

ShortMessage.posOffSet = 35
ShortMessage.MessageQueue = {}

function ShortMessage:constructor(text)
    local x, y, w, h = 20, screenHeight - screenHeight*0.265 - ShortMessage.posOffSet, 340*screenWidth/1600+6, 30
    local lines = math.floor(dxGetTextWidth(text, 1.4, "default")/w) + 1

    -- Calculate heigth
    h = (h * lines) - (15 * math.floor(lines/2))

    -- Calculate y position
    y = y - h + 25

    -- Recalculate the position offset for new Boxes
    ShortMessage.posOffSet = ShortMessage.posOffSet + h + 5

    -- Create it
    DxElement.constructor(self, x, y, w, h)
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

	-- Draw background
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 200))

    -- Center the text
    x = x + 5
    w = w - 10

    -- Draw the text bounding box (DEBUG)
    --[[dxDrawLine(x, y, x + w, y, Color.White, 1)
    dxDrawLine(x, y, x, y + h, Color.White, 1)
    dxDrawLine(x, y + h, x + w, y + h, Color.White, 1)
    dxDrawLine(x + w, y, x + w, y + h, Color.White, 1)]]

	-- Draw message text
	dxDrawText(self.m_Text, x, y, x + w, y + h, Color.White, self.m_FontSize, self.m_Font, "left", "center", false, true)
end

ShortMessage.Timer = setTimer(
	function()		
		if #ShortMessage.MessageQueue > 0 then
            local lastSize = ShortMessage.MessageQueue[1].m_Height

            -- Recalculate the position offset for new Boxes
            ShortMessage.posOffSet = ShortMessage.posOffSet - 5 - lastSize
            
			delete(ShortMessage.MessageQueue[1])
            table.remove(ShortMessage.MessageQueue, 1)

            for k, v in ipairs(ShortMessage.MessageQueue) do
				local x, y = v:getPosition()
				v:setPosition(x, y + lastSize + 5)
			end
		end		
	end, 4000, 0
)

addEvent("shortMessageBox", true)
addEventHandler("shortMessageBox", root, function(...) ShortMessage:new(...) end)

