-- ****************************************************************************
-- *
-- *  PROJECT:     MTA:SA CEF utilities (https://github.com/Jusonex/mtasa_cef_tools)
-- *  FILE:        webui/src/WebWindow.lua
-- *  PURPOSE:     WebWindow class definition
-- *
-- ****************************************************************************
WebWindow = { new = function(self, ...) local o=setmetatable({},{__index=self}) o:constructor(...) return o end }
WebWindow.WindowType = {Normal = 0, Frame = 1};

--
-- WebWindow's constructor
-- Parameters:
--    pos: the position (Vector2)
--    size: the size (Vector2)
--    initialPage: path to the initial page (string)
--    transparent: does it support transparency or is it fully opaque? (bool)
--    browserPos: the browser size (default: pos)
--    browserSize: the browser size (default: size)
-- Returns: The WebWindow instance
--
function WebWindow:constructor(pos, size, initialPage, transparent, browserPos, browserSize)
	-- Read necessary information
	self.m_Position = pos
	self.m_Size = size
	self.m_BrowserPos = browserPos
	self.m_BrowserSize = browserSize or size
	self.m_Transparent = transparent
	self.m_IsLocal = initialPage:sub(0, 7) ~= "http://" and initialPage:sub(0, 8) ~= "https://"
	self.m_PostGUI = false

	-- Create the CEF browser in local mode
	self.m_Browser = Browser.create(self.m_BrowserSize, self.m_IsLocal, transparent)

	-- Use asynchronous API (onClientBrowserCreated is triggered right after the CEF webview has been created)
	addEventHandler("onClientBrowserCreated", self.m_Browser,
		function()
			-- Load the initial page
			self.m_Browser:loadURL(initialPage)
		end
	)

	-- Register the window
	WebUIManager:getInstance():registerWindow(self)
end

--
-- WebWindow's destructor
--
function WebWindow:destroy()
	-- Unlink from manager
	WebUIManager:getInstance():unregisterWindow(self)

	self.m_Browser:destroy()
end

--
-- Returns the drawing 2D position
-- Returns: A Vector2 containing the position
--
function WebWindow:getPosition()
	return self.m_Position
end

--
-- Sets the position of the window. Also adjusts the browsers position
-- Parameters:
--    pos: A Vector2 containing the position
--
function WebWindow:setPosition(pos)
	-- Adjust the browser's position
	local diff = self.m_Position - pos
	self.m_BrowserPos = self.m_BrowserPos - diff

	self.m_Position = pos
end

--
-- Returns the size
-- Returns: A Vector2 containing the size
--
function WebWindow:getSize()
	return self.m_Size
end

--
-- Returns the browser's position
-- Returns: A Vector2 containing the position
--
function WebWindow:getBrowserPosition()
	return self.m_BrowserPos
end

--
-- Returns the browser's size
-- Returns: A Vector2 containing the size
--
function WebWindow:getBrowserSize()
	return self.m_BrowserSize
end

--
-- Returns the transparency state
-- Returns: true if transparent, false if fully opaque
--
function WebWindow:isTransparent()
	return self.m_Transparent
end

--
-- Returns the mode the browser is running in
-- Returns: true for local mode, false for remote mode
--
function WebWindow:isLocal()
	return self.m_IsLocal
end
--
-- Sets the rendering state
-- Parameters:
--    state: false if you want to pause rendering, true if you want to continue rendering
--
function WebWindow:setRenderingPaused(state)
	return self.m_Browser:setRenderingPaused(state)
end

--
-- Returns the underlying Browser instance (for internal use only!)
-- Returns: The CEF browser (Browser, texture)
--
function WebWindow:getUnderlyingBrowser()
	return self.m_Browser
end

--
-- Returns the texture you can use to draw the webview into the 3d world
-- This method is technically the same as getUnderlyingBrowser, but use the function in the correct context
-- Returns: A DirectX texture (similar to the one returned by dxCreateTexture)
--
function WebWindow:getTexture()
	return self.m_Browser
end

--
-- Executes a piece of javascript code
-- Returns: true in case of success, false otherwise
--
function WebWindow:executeJavascript(code)
	return self.m_Browser:executeJavascript(code)
end

--
-- Draws the window (normally called by the ui manager)
--
function WebWindow:draw()
	dxDrawImage(self.m_BrowserPos, self.m_BrowserSize, self.m_Browser, 0, 0, 0, -1, self.m_PostGUI)
end

--
-- Returns the window type (supported types are Normal and Frame at the moment)
--
function WebWindow:getType()
	return WebWindow.WindowType.Normal
end

--
-- Adds an event handlers to the web window
-- Parameters:
--    eventName: the event name
--    func: the function you want to attach (the first parameter of the callback function is the WebWindow instance)
--
function WebWindow:addEvent(eventName, func)
	addEvent(eventName)
	addEventHandler(eventName, self.m_Browser, function(...) func(self, ...) end)
end

--
-- Calls a javascript event (this function should not be called to frequently as it is very inefficient (might be better to implement an event system in C++)
-- This method supports only numbers and strings
-- Parameters:
--    eventName: The event name
--    ...: The parameters you want to pass to the Javascript event handler
--
function WebWindow:callEvent(eventName, ...)
	local code = ("mtatools._callEvent('%s', '%s')"):format(eventName, toJSON({...}))
	return self.m_Browser:executeJavascript(code)
end
