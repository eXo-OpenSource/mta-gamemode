-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/WebPanel.lua
-- *  PURPOSE:     Web panel GUI class
-- *
-- ****************************************************************************
WebPanel = inherit(GUIWebForm)
inherit(Singleton, WebPanel)

function WebPanel:constructor()
	GUIWebForm.constructor(self, 0, 0, screenWidth, screenHeight)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Webpanel", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "http://exo-reallife.de/dev", true, self.m_Window)
end

function WebPanel:destructor()
	GUIWebForm.destructor(self)
end

function WebPanel:onShow()
	showChat(false)
end

function WebPanel:onHide()
	showChat(true)
end
