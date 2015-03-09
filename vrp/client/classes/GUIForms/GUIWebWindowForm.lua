-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GUIWebWindowForm.lua
-- *  PURPOSE:     Base class for web __windows__
-- *
-- ****************************************************************************
GUIWebWindowForm = inherit(GUIWebForm)

function GUIWebWindowForm:constructor(posX, posY, width, height, title, url, hasTitlebar, hasCloseButton)
	GUIWebForm.constructor(self, posX or screenWidth/2-width/2, posY or screenHeight/2-height/2, width, height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, hasTitlebar, hasCloseButton, self)
    -- TODO: Fix and enable moving for not cached CacheAreas
    self.m_Window.startMoving = function() end

    self.m_WebView = GUIWebView:new(0, hasTitlebar and 30 or 0, self.m_Width, hasTitlebar and self.m_Height-30 or self.m_Height, url, false, self.m_Window)

end
