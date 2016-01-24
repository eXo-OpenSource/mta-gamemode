-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/SkinPreview.lua
-- *  PURPOSE:     SkinPreview GUI class
-- *
-- ****************************************************************************
SkinPreview = inherit(GUIWebForm)
inherit(Singleton, SkinPreview)

function SkinPreview:constructor(skin)
	local width, height = 180,350
	GUIWebForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Skin Vorschau", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..skin, true, self.m_Window)
	Browser.requestDomains{"exo-reallife.de"}
end

function SkinPreview:destructor()
	GUIWebForm.destructor(self)
end

function SkinPreview:onShow()
	showChat(false)
end

function SkinPreview:onHide()
	showChat(true)
end
