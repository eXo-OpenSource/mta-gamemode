-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/ShortMessagees/ShortMessage.lua
-- *  PURPOSE:     Short message box class
-- *
-- ****************************************************************************
ShortMessage = inherit(GUIElement)
inherit(GUIFontContainer, ShortMessage)

ShortMessage.MessageBoxes = {}
local TIMEOUT_LIMIT = 20
function ShortMessage:new(text, title, tcolor, timeout, callback, timeoutFunc)
	if type(title) == "number" then
		return new(ShortMessage, text, nil, nil, title)
	else
		return new(ShortMessage, text, title, tcolor, timeout, callback, timeoutFunc)
	end
	if ShortMessageLogGUI.m_Log then 
		table.insert(ShortMessageLogGUI.m_Log, title.." - "..text)
	end
end

function ShortMessage:constructor(text, title, tcolor, timeout, callback, timeoutFunc)
	local x, y, w
	x, y, w = 20, screenHeight - screenHeight*0.265, 340*screenWidth/1600+6
	if HUDRadar:getSingleton().m_DesignSet == RadarDesign.Default then
		y = screenHeight - screenHeight*0.365
	end
	--else
	--	x, y, w = 20, screenHeight - 5, 340*screenWidth/1600+6
	--end

	-- Title Bar
	self.m_HasTitleBar = title ~= nil
	self.m_Title = title
	self.m_TitleColor = (type(tcolor) == "table" and tcolor) or (type(tcolor) == "number" and {fromcolor(tcolor)}) or {125, 0, 0}

	self.m_Callback = callback or nil
	self.m_TimeoutFunc = timeoutFunc or nil

	-- Font
	GUIFontContainer.constructor(self, text, 1, VRPFont(24))
	local h = textHeight(self.m_Text, w - 8, self.m_Font, self.m_FontSize) + (self.m_HasTitleBar and 24 or 4)

	-- Calculate y position
	y = y - h - 20

	-- Instantiate GUIElement
	GUIElement.constructor(self, x, y, w, h)
	self.onLeftClick = function ()
		if self.m_Callback then
			self:m_Callback()
		end
		if core:get("HUD", "shortMessageCTC", false) then
			delete(self)
		end
	end

	-- Calculate timeout
	if timeout ~= -1 then
		self.m_Timeout = setTimer(
		function ()
			if self.m_TimeoutFunc then
				self:m_TimeoutFunc()
			end
			delete(self)
		end, ((type(timeout) == "number" and timeout > 50 and timeout) or 5000) + 500, 1)
	end

	-- Alpha
	self:setAlpha(0)
	self.m_AlphaFaded = false

	table.insert(ShortMessage.MessageBoxes, self)
	ShortMessage.resortPositions()
end

function ShortMessage:destructor()
	if self.m_Timeout and isTimer(self.m_Timeout) then
		killTimer(self.m_Timeout)
	end
	if not self.m_ForceDestroy then
		Animation.FadeAlpha:new(self, 200, 200, 0).onFinish = function ()
			GUIElement.destructor(self)
			table.removevalue(ShortMessage.MessageBoxes, self)
			ShortMessage.resortPositions()
			end
	end
end

function ShortMessage:drawThis()
	local x, y, w, h = self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height

	-- Draw background
	if self.m_HasTitleBar then
		dxDrawRectangle(x, y, w, 20, tocolor(self.m_TitleColor[1], self.m_TitleColor[2], self.m_TitleColor[3], self.m_Alpha))
		dxDrawRectangle(x, y + 20, w, h - 20, tocolor(0, 0, 0, self.m_Alpha))
	else
		dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, self.m_Alpha))
	end

	-- Center the text
	x = x + 4
	w = w - 8

	-- Draw message text
	if self.m_HasTitleBar then
		dxDrawText(self.m_Title, x, y - 2, x + w, y + 16, tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_Font, "left", "top", true, false)
		dxDrawText(self.m_Text, x, y + 20, x + w, y + (h - 20), tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_Font, "left", "top", false, true)
	else
		dxDrawText(self.m_Text, x, y, x + w, y + h, tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_Font, "left", "top", false, true)
	end
end

function ShortMessage.resortPositions ()
	if #ShortMessage.MessageBoxes <= TIMEOUT_LIMIT then
		for i = #ShortMessage.MessageBoxes, 1, -1 do
			local obj = ShortMessage.MessageBoxes[i]
			local prevObj = ShortMessage.MessageBoxes[i + 1]

			if obj.m_Animation then
				delete(obj.m_Animation)
			end

			if prevObj then
				local y
				if not prevObj.m_Animation then
					y = prevObj.m_AbsoluteY
				else
					y = prevObj.m_Animation.m_TY
				end
				obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, y - obj.m_Height - 5)
			elseif not obj.m_AlphaFaded then
				Animation.FadeAlpha:new(obj, 500, 0, 200)
				obj.m_AlphaFaded = true
			else
				--if HUDRadar:getSingleton().m_Visible then
					obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, (screenHeight - screenHeight*0.265) - 20 - obj.m_Height)
				--else
					--obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, screenHeight - 25 - obj.m_Height)
				--end
			end
		end
	else 
		for i = 1, #ShortMessage.MessageBoxes do 
			if ShortMessage.MessageBoxes[i].m_Animation then 
				delete(ShortMessage.MessageBoxes[i].m_Animation)
			end
			ShortMessage.MessageBoxes[i].m_ForceDestroy = true
			delete(ShortMessage.MessageBoxes[i])
		end
		outputDebugString("Forced destroy of MessageBoxe!",0, 255,0,150)
	end
end

function ShortMessage.recalculatePositions ()
	for i = #ShortMessage.MessageBoxes, 1, -1 do
		local obj = ShortMessage.MessageBoxes[i]
		local prevObj = ShortMessage.MessageBoxes[i + 1]

		if obj.m_Amination then
			delete(obj.m_Amination)
		end

		if prevObj then
			obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, prevObj.m_Animation.m_TY - obj.m_Height - 5)
		else
			--if HUDRadar:getSingleton().m_Visible then
				obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, (screenHeight - screenHeight*0.265) - 20 - obj.m_Height)
			--else
			--	obj.m_Animation = Animation.Move:new(obj, 250, obj.m_AbsoluteX, screenHeight - 5 - obj.m_Height)
			--end
		end
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
