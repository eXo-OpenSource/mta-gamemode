-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/ShortMessagees/ShortMessage.lua
-- *  PURPOSE:     Short message box class
-- *
-- ****************************************************************************
ShortMessage = inherit(DxElement)
inherit(GUIFontContainer, ShortMessage)

ShortMessage.MessageBoxes = {}

function ShortMessage:constructor(text, timeout)
	local x, y, w, h = 20, screenHeight - screenHeight*0.265, 340*screenWidth/1600+6, 30
	local lines = math.floor(dxGetTextWidth(text, 1.4, "default")/w) + 1
	if string.countChar(text, "\n") > 0 then
		local extra = string.countChar(text, "\n")
		lines = lines + extra -- Todo: improve
	end

	-- Calculate heigth
	h = (h * lines) - (15 * math.floor(lines/2))

	-- Calculate y position
	y = y - h - 20

	timeout = timeout and timeout >= 50 and timeout or 4000
	setTimer(function () delete(self) end, timeout + 500, 1)

	DxElement.constructor(self, x, y, w, h)
	GUIFontContainer.constructor(self, text, 1.4, "default")

	self:setAlpha(0)

	table.insert(ShortMessage.MessageBoxes, self)
	ShortMessage.resortPositions()
end

function ShortMessage:destructor()
	DxElement.destructor(self)
	table.removevalue(ShortMessage.MessageBoxes, self)
end

function ShortMessage:drawThis()
	local x, y, w, h = self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height

	-- Draw background
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, self.m_Alpha))

	-- Center the text
	x = x + 5
	w = w - 10

	-- Draw the text bounding box (DEBUG)
	--[[dxDrawLine(x, y, x + w, y, Color.White, 1)
	dxDrawLine(x, y, x, y + h, Color.White, 1)
	dxDrawLine(x, y + h, x + w, y + h, Color.White, 1)
	dxDrawLine(x + w, y, x + w, y + h, Color.White, 1)]]

	-- Draw message text
	dxDrawText(self.m_Text, x, y, x + w, y + h, tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_Font, "left", "top", false, true)
end

function ShortMessage.resortPositions ()
	for i = #ShortMessage.MessageBoxes, 1, -1 do
		local obj = ShortMessage.MessageBoxes[i]
		local prevObj = ShortMessage.MessageBoxes[i + 1]

		if obj.m_Animation then
			delete(obj.m_Animation)
		end

		if prevObj then
			local y
			if not prevObj.m_Animation then
				y = obj.m_AbsoluteY
			else
				y = prevObj.m_Animation.m_TY
			end
			obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, y - obj.m_Height - 5)
		else
			Animation.FadeAlpha:new(obj, 500, 0, 200)
		end
	end
end

-- Maybe required!
function ShortMessage.recalculatePositions () end

addEvent("shortMessageBox", true)
addEventHandler("shortMessageBox", root, function(...) ShortMessage:new(...) end)

