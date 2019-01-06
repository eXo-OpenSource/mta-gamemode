-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIForm.lua
-- *  PURPOSE:     GUI form class (base class)
-- *
-- ****************************************************************************
GUIForm = inherit(CacheArea)
GUIForm.Map = {}
GUIForm.BlurCounter = 0

function GUIForm:constructor(posX, posY, width, height, incrementCursorCounter, postGUI)
	CacheArea.constructor(self, posX or 0, posY or 0, width or screenWidth, height or screenHeight, true, true, postGUI)
	self.m_KeyBinds = {}
	if incrementCursorCounter ~= false then
		Cursor:show()
		self:toggleKeys(false)
	end

	self.m_Id = #GUIForm.Map+1
	GUIForm.Map[self.m_Id] = self

	-- Enable blur shader maybe
	if self:isBackgroundBlurred() then
		GUIForm.BlurCounter = GUIForm.BlurCounter + 1
		RadialShader:getSingleton():setEnabled(true)
	end
end

function GUIForm:destructor()
	if self.m_Id and GUIForm.Map[self.m_Id] then
		GUIForm.Map[self.m_Id] = nil
	end

	if self.m_KeyBinds then
		for k, v in pairs(self.m_KeyBinds) do
			unbindKey(k, "down", v)
		end
	end
	self.m_KeyBinds = {}

	self:close(false)

	-- Todo: Replace this by virtual_destructor
	CacheArea.destructor(self)
end

function GUIForm:open(hiddenCursor)
	if not hiddenCursor and not self:isVisible() then
		Cursor:show()
	end

	-- Enable blur shader maybe
	if self:isBackgroundBlurred() then
		GUIForm.BlurCounter = GUIForm.BlurCounter + 1
		RadialShader:getSingleton():setEnabled(true)
	end

	return self:setVisible(true)
end

function GUIForm:close(decrementedCursorCounter)
    guiSetInputEnabled(false)
	focusBrowser()
	if not decrementedCursorCounter and self:isVisible() then
		Cursor:hide()
		self:toggleKeys(true)
	end

	-- Disable blur shader if it has been enabled before
	if self:isBackgroundBlurred() then
		GUIForm.BlurCounter = GUIForm.BlurCounter - 1

		if GUIForm.BlurCounter <= 0 then
			RadialShader:getSingleton():setEnabled(false)
		end
	end
	return self:setVisible(false)
end

function GUIForm:toggle(cursor)
	if self:isVisible() then
		self:close(cursor)
	else
		self:open(cursor)
	end
end

function GUIForm:toggleKeys(state)
	if state then
		removeEventHandler("onClientKey", root, GUIForm.onClientKey)
		GUIForm.keysEnabled = true
	elseif GUIForm.keysEnabled then
		addEventHandler("onClientKey", root, GUIForm.onClientKey)
		GUIForm.keysEnabled = false
	end
end

function GUIForm:fadeIn(time)
	if not time then time = 1000 end
	self:setVisible(true)
	for _, v in pairs(self:getChildrenRecursive()) do
		if v:isVisible() then
			if instanceof(v, GUIColorable) then
				Animation.FadeAlpha:new(v, 750, 0, 255)
			end
		end
	end
end

function GUIForm:fadeOut(time)
	if not time then time = 1000 end
	for _, v in pairs(self:getChildrenRecursive()) do
		if v:isVisible() then
			if instanceof(v, GUIColorable) then
				Animation.FadeAlpha:new(v, 750, v:getAlpha() or 255, 0)
			end
		end
	end
	setTimer(function() self:setVisible(false) end, time, 1)
end

function GUIForm:bind(key, fn)
	if self.m_KeyBinds[key] then
		unbindKey(key, "down", self.m_KeyBinds[key])
	end

	local handler = bind(fn, self)
	self.m_KeyBinds[key] = handler
	bindKey(key, "down", handler)
end

function GUIForm:unbind(key)
	if not self.m_KeyBinds[key] then
		return
	end

	unbindKey(key, "down", self.m_KeyBinds[key])
end

function GUIForm.closeAll()
	for _, form in pairs(GUIForm.Map) do
		if form then
			form:close(false)
		end
	end
end

--- Return true to show a blurry background
-- This enables the Radialshader internally
-- Override this in derived classes
-- @return true to enable blur, false otherwise
function GUIForm:isBackgroundBlurred()
	return false
end

GUIForm.AllowedKeys = {
	["^[F0-9]*$"] = true, 	-- F1 - F12
	["tab"] = true, 		-- kwt
	["enter"] = true, 		-- kwt
	["b"] = true, 			-- Toggle cursor on/off
	["m"] = true, 			-- Turn music on/off in download screen
	["pgup"] = true, 		-- scroll chatbox/debugscript
	["pgdn"] = true,		-- scroll chatbox/debugscript
	["t"] = true,
	["r"] = true, 			-- reload Police Panel
}

GUIForm.keysEnabled = true
GUIForm.onClientKey =
	function(button)
		for keys in pairs(GUIForm.AllowedKeys) do
			if button:match(keys) then return end
		end

		cancelEvent()
	end
