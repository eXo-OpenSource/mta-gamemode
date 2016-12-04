-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/WebBrowser.lua
-- *  PURPOSE:     Web panel GUI class
-- *
-- ****************************************************************************
WebBrowser = inherit(GUIWebForm)

function WebBrowser:constructor(url)
	GUIWebForm.constructor(self, 0, 0, screenWidth, screenHeight)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Browser", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, url, true, self.m_Window)
	showChat(false)
end

function WebBrowser:destructor()
	showChat(true)
	GUIWebForm.destructor(self)
end

function WebBrowser:onShow()
	showChat(false)
end

function WebBrowser:onHide()
	showChat(true)
end
