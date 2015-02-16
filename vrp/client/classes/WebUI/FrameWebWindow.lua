-- ****************************************************************************
-- *
-- *  PROJECT:     MTA:SA CEF utilities (https://github.com/Jusonex/mtasa_cef_tools)
-- *  FILE:        webui/src/FrameWebWindow.lua
-- *  PURPOSE:     FrameWebWindow class definition (inherits WebWindow)
-- *
-- ****************************************************************************
FrameWebWindow = setmetatable({ new = function(self, ...) local o=setmetatable({},{__index=self}) o:constructor(...) return o end },{__index=WebWindow})

--
-- FrameWebWindow's constructor
-- Parameters:
--    pos: the position (Vector2)
--    size: the size (Vector2)
--    initialPage: path to the initial page (string)
--    transparent: does it support transparency or is it fully opaque? (bool)
-- Returns: The FrameWebWindow instance
--
function FrameWebWindow:constructor(...)
	WebWindow.constructor(self, ...)
	
	self.m_Title = ""
end

--
-- Sets the window title
-- Parameters:
--    title: the new title
--
function FrameWebWindow:setTitle(title)
	self.m_Title = title
end

--
-- Returns the window title
-- Returns: The window title (string)
--
function FrameWebWindow:getTitle()
	return self.m_Title
end

--
-- Draws the window (normally called by the ui manager) [OVERRIDDEN]
--
function FrameWebWindow:draw()
	local pos, size = self.m_Position, self.m_Size
	local titleBarHeight = WebUIManager.Settings.TitleBarHeight
	
	-- Draw a border around the window
	dxDrawRectangle(pos.x, pos.y, size.x, size.y, -1)
	
	-- Draw title bar
	dxDrawRectangle(pos.x+2, pos.y+2, size.x-4, titleBarHeight, tocolor(200, 200, 200))
	dxDrawText(self.m_Title, pos.x+2, pos.y+2, pos.x+size.x-4, pos.y+titleBarHeight, -1, 1.5, "arial", "center", "center", true, false, self.m_PostGUI)
	
	-- Draw browser
	dxDrawImage(pos.x+2, pos.y+2+titleBarHeight, size.x-4, size.y-4-titleBarHeight, self.m_Browser, 0, 0, 0, -1, self.m_PostGUI)
end

--
-- Returns the window type [OVERRIDDEN]
-- Returns: the window type (WebWindow.WindowType enumeration)
--
function FrameWebWindow:getType()
	return WebWindow.WindowType.Frame
end
