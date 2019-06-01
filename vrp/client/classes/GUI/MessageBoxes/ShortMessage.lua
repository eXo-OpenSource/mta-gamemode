-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/ShortMessagees/ShortMessage.lua
-- *  PURPOSE:     Short message box class
-- *
-- ****************************************************************************
ShortMessage = inherit(GUIElement)
inherit(GUIFontContainer, ShortMessage)

local MAX_BOX_LIMIT = 20
local TEXTURE_SIZE_X = (340*screenWidth/1600+6)
local TEXTURE_SIZE_Y = 250
function ShortMessage:new(text, title, tcolor, timeout, callback, timeoutFunc, minimapPos, minimapBlips, notClose)
	if type(title) == "number" then
		return new(ShortMessage, text, nil, nil, title)
	else
		return new(ShortMessage, text, title, tcolor, timeout, callback, timeoutFunc, minimapPos, minimapBlips, notClose)
	end
end

function ShortMessage:constructor(text, title, tcolor, timeout, callback, timeoutFunc, minimapPos, minimapBlips, notClose)
	local x, y = HUDRadar:getSingleton():getPosition()
	local w = HUDRadar:getSingleton():getWidth()

	-- Title Bar
	local hasTitleBar = title ~= nil
	self.m_Title = title
	self.m_TitleColor = (type(tcolor) == "table" and tcolor) or (type(tcolor) == "number" and {fromcolor(tcolor)}) or {125, 0, 0}

	self.m_Callback = callback or nil
	self.m_TimeoutFunc = timeoutFunc or nil

	self.m_CloseOnClick = not notClose
	if ShortMessageLogGUI.m_Log then
		ShortMessageLogGUI.insertLog(self.m_Title or "", text, self.m_TitleColor)
	end

	-- Font and height calc
	GUIFontContainer.constructor(self, text, 1, VRPFont(24))
	local h = textHeight(self.m_Text, w - 8, self:getFont(), self:getFontSize())
	if hasTitleBar then
		self.m_TitleHeight = textHeight(self.m_Title, w - 8, self:getFont(), self:getFontSize())
		h = h + self.m_TitleHeight
	end
	if true then -- option to disable this?
		if minimapPos then
			h = h + TEXTURE_SIZE_Y
		end
	end
	h = h + 4

	-- Calculate y position
	y = y - h - x

	-- Instantiate GUIElement
	GUIElement.constructor(self, x, y, w, h)
	self.onLeftClick = function ()
		if self.m_Callback then
			if self:m_Callback() == "forceOpen" then -- return to force it open
				return
			end
		end
		if self.m_CloseOnClick then
			delete(self)
		end
	end

	-- Instantiate custom GUIMiniMap
	if true then
		if minimapPos then
			self.m_Texture = GUIMiniMap:new(4, (self.m_TitleHeight or 0) + 4, TEXTURE_SIZE_X - 8, TEXTURE_SIZE_Y - 8, self)
			self.m_Texture:setMapPosition(minimapPos.x, minimapPos.y)
			for i, v in pairs(minimapBlips or {}) do
				self.m_Texture:addBlip(v.path, v.pos.x, v.pos.y)
			end
		end
	end

	-- Calculate timeout
	self:setTimeout(timeout)

	-- Alpha
	self:setAlpha(0)
	self.m_AlphaFaded = false

	table.insert(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()
end

function ShortMessage:virtual_destructor(force)
	if self.m_Timeout and isTimer(self.m_Timeout) then
		killTimer(self.m_Timeout)
	end
	if not force then
		Animation.FadeAlpha:new(self, 200, 200, 0).onFinish = function ()
			if self.m_Texture then
				delete(self.m_Texture)
			end

			table.removevalue(MessageBoxManager.Map, self)
			MessageBoxManager.resortPositions()
		end
		if self.m_Texture then
			Animation.FadeAlpha:new(self.m_Texture, 200, 200, 0)
		end
	else
		if self.m_Texture then
			delete(self.m_Texture)
		end

		table.removevalue(MessageBoxManager.Map, self)
		MessageBoxManager.resortPositions()
	end
end

function ShortMessage:setText(text)
	local success = GUIFontContainer.setText(self, text)
	if success then
		local h = textHeight(self.m_Text, self.m_Width - 8, self:getFont(), self:getFontSize()) + (self.m_TitleHeight or 0) + 4
		GUIElement.setSize(self, self.m_Width, h)
		MessageBoxManager.resortPositions()
	end
end

function ShortMessage:drawThis()
	local x, y, w, h = self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height
	local hasTitleBar = self.m_TitleHeight ~= nil
	local hasTexture = self.m_Texture ~= nil

	-- Draw background
	if hasTitleBar then
		dxDrawRectangle(x, y, w, self.m_TitleHeight, tocolor(self.m_TitleColor[1], self.m_TitleColor[2], self.m_TitleColor[3], self.m_Alpha))
	end
	dxDrawRectangle(x, y + (hasTitleBar and self.m_TitleHeight or 0), w, h - (hasTitleBar and self.m_TitleHeight or 0), tocolor(0, 0, 0, self.m_Alpha))

	-- Center the text
	x = x + 4
	w = w - 8

	-- Draw message text
	if hasTitleBar then
		dxDrawText(self.m_Title, x, y - 2, x + w, y + 16, tocolor(255, 255, 255, self.m_Alpha), self:getFontSize(), self:getFont(), "left", "top", false, true)
	end
	dxDrawText(self.m_Text, x, y + (hasTitleBar and self.m_TitleHeight or 0) + (hasTexture and TEXTURE_SIZE_Y or 0), x + w, y + (h - (hasTitleBar and self.m_TitleHeight or 0) - (hasTexture and TEXTURE_SIZE_Y or 0)), tocolor(255, 255, 255, self.m_Alpha), self:getFontSize(), self:getFont(), "left", "top", false, true)
end

function ShortMessage:setTimeout(timeoutMs)
	if timeoutMs ~= -1 then
		if self.m_Timeout and isTimer(self.m_Timeout) then killTimer(self.m_Timeout) end
		self.m_Timeout = setTimer(
		function ()
			if self.m_TimeoutFunc then
				self:m_TimeoutFunc()
			end
			delete(self)
		end, ((type(timeoutMs) == "number" and timeoutMs > 50 and timeoutMs) or 5000) + 500, 1)
	else
		if self.m_Timeout and isTimer(self.m_Timeout) then killTimer(self.m_Timeout) end
	end
end

function ShortMessage:resetTimeout()
	if self.m_Timeout and isTimer(self.m_Timeout) then
		resetTimer(self.m_Timeout)
	end
end

addEvent("shortMessageBox", true)
addEventHandler("shortMessageBox", root,
	function(text, title, tcolor, timeout, callback, onTimeout, ...)
		local additionalParameters = {...}
		ShortMessage:new(text, title, tcolor, timeout,
		function()
			if callback then
				triggerServerEvent(callback, root, unpack(additionalParameters))
			end
		end,
		function()
			if onTimeout then
				triggerServerEvent(onTimeout, root, unpack(additionalParameters))
			end
		end)
	end
)
