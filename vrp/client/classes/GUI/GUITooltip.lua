-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUITooltip.lua
-- *  PURPOSE:     GUI Tooltip class
-- *
-- ****************************************************************************
GUITooltip = inherit(GUIElement)
inherit(GUIColorable, GUITooltip)

GUITooltip.MaxWidth = 400
GUITooltip.StandartSize = 20

function GUITooltip.create(text, element, pos, lineColor)
	local tooltipPosX, tooltipPosY, tooltipWidth, tooltipHeight = GUITooltip.calculatePosition(text, element, pos)

	return GUITooltip:new(tooltipPosX, tooltipPosY, tooltipWidth, tooltipHeight, text, element, pos, lineColor)
end

function GUITooltip.calculatePosition(textLines, element, pos) -- Please dont judge me for that messy "code". Please.
	if type(textLines) == "string" then textLines = {{text=textLines, size=1}} end
	
	local tooltipPosX = 0
	local tooltipPosY = 0
	local tooltipWidth = 0
	local tooltipHeight = 0
	for index, line in pairs(textLines) do
		local text = line.text
		local textFont = getVRPFont(VRPFont(line.size))
		local textWidth = fontWidth(text, textFont, 1)
		if textWidth > tooltipWidth then
			tooltipWidth = textWidth
		end
		tooltipHeight = tooltipHeight + textHeight(text, GUITooltip.MaxWidth, textFont, 1)
	end
	
    tooltipWidth = (tooltipWidth > GUITooltip.MaxWidth and GUITooltip.MaxWidth or tooltipWidth) + 14
	tooltipHeight = tooltipHeight + 14

	local positionFound = false
	if element then
		local gap = 10
		local posX, posY = element:getPosition(true)
		local width, height = element:getSize()

		function getRelativePosition(p)
			if p == "left" then
				x = posX - gap - tooltipWidth
				y = posY + (height/2) - (tooltipHeight/2)
			elseif p == "right" then
				x = posX + width + gap
				y = posY + (height/2) - (tooltipHeight/2)
			elseif p == "bottom" then
				x = posX + (width/2) - (tooltipWidth/2)
				y = posY + height + gap
			else
				x = posX + (width/2) - (tooltipWidth/2)
				y = posY - gap - tooltipHeight
			end

			if x < 0 then x = 0 end
			if y < 0 then y = 0 end
			if x + tooltipWidth > screenWidth then x = x - (x + tooltipWidth - screenWidth) end
			if y + tooltipHeight > screenHeight then y = y - (y + tooltipHeight - screenHeight) end

			return x, y
		end

		function isCursorWithin(x, y, width, height)
			local relCursorX, relCursorY = getCursorPosition()
			if not relCursorX then
				return false
			end
		
			local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight
		
			return cursorX >= x and cursorY >= y and cursorX < x + width and cursorY < y + height
		end

		tooltipPosX, tooltipPosY = getRelativePosition(pos)
		if isCursorWithin(tooltipPosX, tooltipPosY, tooltipWidth, tooltipHeight) then
			for k, position in pairs({"left", "right", "bottom", "up"}) do
				local x, y = getRelativePosition(position)
				if not isCursorWithin(x, y, tooltipWidth, tooltipHeight) then
					tooltipPosX, tooltipPosY = x, y
					positionFound = true
					break
				end
			end
		else
			positionFound = true
		end	
	end

	if not element or not positionFound then
		tooltipPosX = screenWidth - 25 - tooltipWidth
		tooltipPosY = screenHeight - 25 - tooltipHeight
	end

	return math.floor(tooltipPosX), math.floor(tooltipPosY), math.floor(tooltipWidth), math.floor(tooltipHeight)
end


function GUITooltip:constructor(posX, posY, width, height, text, attachedTo, position, lineColor)
	checkArgs("GUITooltip:constructor", "number", "number", "number", "number")

	GUIElement.constructor(self, posX, posY, width, height)
	GUIColorable.constructor(self)

	self.m_AttachedTo = attachedTo
	self.m_Position = position

    self.m_BackgroundColor = tocolor(0, 0, 0, 225)

    self.m_LineColor = type(lineColor) == "number" and lineColor or Color.Accent
	self.m_LineWidth = 2
	self.m_LineOffsetTop = 1
	self.m_LineOffsetLeft = 1
	self.m_LineOffsetRight = -1
	self.m_LineOffsetBottom = -1

	self.m_TextLines = {}
	if type(text) == "string" then
		self:addTextLine(text)
	else
		self.m_TextLines = text
	end

	self:anyChange()
end

function GUITooltip:drawThis(incache)
	dxSetBlendMode("modulate_add")

	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end

    dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor, incache ~= true)
    
    dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY + self.m_LineOffsetTop, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_LineOffsetTop, self.m_LineColor, self.m_LineWidth, incache ~= true)
    dxDrawLine(self.m_AbsoluteX + self.m_LineOffsetLeft, self.m_AbsoluteY, self.m_AbsoluteX + self.m_LineOffsetLeft, self.m_AbsoluteY + self.m_Height, self.m_LineColor, self.m_LineWidth, incache ~= true)
    dxDrawLine(self.m_AbsoluteX + self.m_Width + self.m_LineOffsetRight, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width + self.m_LineOffsetRight, self.m_AbsoluteY + self.m_Height, self.m_LineColor, self.m_LineWidth, incache ~= true)
    dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height + self.m_LineOffsetBottom, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height + self.m_LineOffsetBottom, self.m_LineColor, self.m_LineWidth, incache ~= true)

	local height = 0
	for index, line in pairs(self.m_TextLines) do
		local textFont = getVRPFont(VRPFont(line.size))
		local currentHeight = height
		height = height + textHeight(line.text, GUITooltip.MaxWidth, textFont, 1)

		dxDrawText(line.text, self.m_AbsoluteX + 7, self.m_AbsoluteY + 7 + currentHeight, self.m_AbsoluteX + self.m_Width - 7, self.m_AbsoluteY + 7 + height, line.color, 1, textFont, "left", "top", true, true, incache ~= true, false, false)
	end

	dxSetBlendMode("blend")
end

function GUITooltip:update(elapsedTime)
	GUIElement.update(self, elapsedTime)
	self:getParent():bringToFront()
end

function GUITooltip:resize()
	local posX, posY, width, height = GUITooltip.calculatePosition(self.m_TextLines, self.m_AttachedTo, self.m_Position)

	self:setAbsolutePosition(posX, posY)
	self:setSize(width, height)
end

function GUITooltip:setBackgroundColor(color)
	self.m_BackgroundColor = color
	self:anyChange()
	return self
end

function GUITooltip:setOutlineColor(color)
	self.m_LineColor = color
	self:anyChange()
	return self
end

function GUITooltip:addTextLine(text, color, size)
	if not color then color = Color.White end
	if not size then size = 20 end

	table.insert(self.m_TextLines, {text=text, color=color, size=size})
	self:resize()

	self:anyChange()
	return self
end