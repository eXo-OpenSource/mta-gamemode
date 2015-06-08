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
	local width, height = screenWidth*0.6, screenHeight*0.6
	GUIWebForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, 1000, 560)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Webpanel", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "http://v-roleplay.net:3001", true, self.m_Window)
	Browser.requestDomains{"v-roleplay.net", "maxcdn.bootstrapcdn.com"}
end

function WebPanel:destructor()
	GUIWebForm.destructor(self)
end
