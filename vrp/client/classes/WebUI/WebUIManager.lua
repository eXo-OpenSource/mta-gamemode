-- ****************************************************************************
-- *
-- *  PROJECT:     MTA:SA CEF utilities (https://github.com/Jusonex/mtasa_cef_tools)
-- *  FILE:        webui/src/WebUIManager.lua
-- *  PURPOSE:     WebUIManager class definition
-- *
-- ****************************************************************************
WebUIManager = {
	new = function(self, ...) if self.Instance then return false end local o=setmetatable({},{__index=self}) o:constructor(...) self.Instance = o return o end;
	getInstance = function() assert(WebUIManager.Instance, "WebUIManager has not been initialised yet") return WebUIManager.Instance end;
	
	Settings = {
		ScrollSpeed = 50;
		TitleBarHeight = 25;
		UseInternalClickMechanism = true;
	};
}

--
-- WebUIManager's constructor
-- Returns: The WebUIManager instance
--
function WebUIManager:constructor()
	self.m_Stack = {}
	
	addEventHandler("onClientRender", root,
		function()
			-- Draw from bottom to top
			for k, ui in ipairs(self.m_Stack) do
				ui:draw()
			end
		end
	)
	
	addEventHandler("onClientCursorMove", root,
		function(relX, relY, absX, absY)
			if not isCursorShowing() then
				return
			end
		
			for k, ui in pairs(self.m_Stack) do
				local browser = ui:getUnderlyingBrowser()
				local pos = ui:getBrowserPosition()
				browser:injectMouseMove(absX - pos.x, absY - pos.y)
			end
		end
	)
	
	local function onMouseWheel(button, state)
		if button == "mouse_wheel_down" or button == "mouse_wheel_up" then
			local browser = WebUIManager.getFocusedBrowser()
			if browser then
				local direction = button == "mouse_wheel_up" and 1 or -1
				browser:injectMouseWheel(direction*WebUIManager.Settings.ScrollSpeed, 0)
			end
		end
	end
	addEventHandler("onClientKey", root, onMouseWheel)
	
	addEventHandler("onClientBrowserInputFocusChanged", resourceRoot,
		function(gainedFocus)
			if gainedFocus then
				-- Set focus if it has not been done yet
				--source:focus()
			
				-- Enable input mode
				--guiSetInputEnabled(true)
			else
				-- Disabled input mode
				guiSetInputEnabled(false)
			end
		end
	)
	
	if self.Settings.UseInternalClickMechanism then
		addEventHandler("onClientClick", root, function(...) self:invokeClick(...) end)
	end
	addEventHandler("onClientResourceStop", resourceRoot, function() self:destroy() end)
end

--
-- WebUIManager's destructor
--
function WebUIManager:destroy()
	guiSetInputEnabled(false)
	
	for k, v in pairs(self.m_Stack) do
		v:destroy()
	end
end

--
-- Registers a window at the manager
-- Parameters:
--    window: The web UI window (WebWindow)
--
function WebUIManager:registerWindow(window)
	table.insert(self.m_Stack, window)
end

--
-- Unlinks a window from the manager
-- Parameters:
--     window: The web UI window (WebWindow)
--
function WebUIManager:unregisterWindow(window)
	-- Disable input if the browser we're about to destroy is focused
	if window:getUnderlyingBrowser():isFocused() then
		guiSetInputEnabled(false)
	end

	for k, v in pairs(self.m_Stack) do
		if v == window then
			table.remove(self.m_Stack, k)
			return true
		end
	end
	return false
end

--
-- Moves the specified window to the front (by WebWindow instance)
-- Parameters:
--     window: The web UI window you want to move to the front (WebWindow)
--
function WebUIManager:moveWindowToFront(window)
	-- TODO
end

--
-- Moves a window to the front by index (fast internal use)
-- Parameters:
--      index: The index the window has on the drawing stack
--
function WebUIManager:moveWindowToFrontByIndex(index)
	-- Make a backup of the window at the specified index
	local ui = self.m_Stack[index]
	
	-- Remove it from the list temporally
	table.remove(self.m_Stack, index)
	
	-- Append it to the end
	table.insert(self.m_Stack, ui)
end

--
-- Static function that returns the currently focussed browser
-- Returns: The focussed browser element
--
function WebUIManager.getFocusedBrowser()
	for k, browser in pairs(getElementsByType("webbrowser")) do
		if browser:isFocused() then
			return browser
		end
	end
	return false
end

--
-- Sets a web property (list of available settings below the file info header)
-- Parameters:
--     name: The property name
--     value: The property value
--
function WebUIManager:setProperty(name, value)
	self.Settings[name] = value
end

--
-- Sends a click message (call this in your own click handler implementation, example on GitHub)
-- Parameters:
--    button: The button (possible values: left, right, middle)
--    state: The button's state (possible values: down, up)
--    absX, absY: The click position
--
function WebUIManager:invokeClick(button, state, absX, absY)
	local topIndex = #self.m_Stack
		
	-- Process from top to bottom
	for i = topIndex, 1, -1 do
		local ui = self.m_Stack[i]
		local pos, size = ui:getPosition(), ui:getSize()
		local browser = ui:getUnderlyingBrowser()
		
		if state == "up" and ui.movefunc then
			removeEventHandler("onClientCursorMove", root, ui.movefunc)
			ui.movefunc = nil
		end
		
		-- Are we within the browser rect?
		if absX >= pos.x and absY >= pos.y and absX < pos.x + size.x and absY < pos.y + size.y then
			if ui:getType() == WebWindow.WindowType.Frame and state == "down" then
				local diff = Vector2(absX-pos.x, absY-pos.y)
				ui.movefunc = function(relX, relY, absX, absY) ui:setPosition(Vector2(absX, absY) - diff) end
				
				if diff.y <= WebUIManager.Settings.TitleBarHeight then
					addEventHandler("onClientCursorMove", root, ui.movefunc)
					
					-- Move to front if the current browser isn't the currently focused one
					if i ~= topIndex then
						self:moveWindowToFrontByIndex(i)
					end
					
					if ui.processTitleBarClick then
						ui:processTitleBarClick(diff)
					end
					
					break
				end
			end
		
			if state == "down" then
				browser:injectMouseDown(button)
			else
				browser:injectMouseUp(button)
			end
			
			-- Move to front if the current browser isn't the currently focused one
			if i ~= topIndex then
				self:moveWindowToFrontByIndex(i)
			end
			browser:focus()
			
			-- Stop here (the click has been processed!)
			return true
		end
	end
	
	-- Unfocus and disable input
	Browser.focus(nil)
	guiSetInputEnabled(false)
	return false
end

--
-- Checks whether a specified position is within any window
-- Parameters:
--    x: The x coordinate
--    y: The y coordinate
-- Returns:
--    true if within any window, false otherwise
--
function WebUIManager:isPositionWithinWindow(x, y)
	for i = #self.m_Stack, 1, -1 do
		local ui = self.m_Stack[i]
		local pos, size = ui:getPosition(), ui:getSize()
		
		if x >= pos.x and y >= pos.y and x < pos.x + size.x and y < pos.y + size.y then
			return true
		end
	end
	
	return false
end
