-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppCEF.lua
-- *  PURPOSE:     Base class for CEF based apps
-- *
-- ****************************************************************************
AppCEF = inherit(PhoneApp)

function AppCEF:constructor(title, icon, url, destroyOnClose)
	PhoneApp.constructor(self, title, icon)

	self.m_StartURL = url
	self.m_Browser = false
	self:setDestroyOnCloseEnabled(destroyOnClose)
end

function AppCEF:onOpen(form)
	if self:isDestroyOnCloseEnabled() or not self.m_Browser then
		local width, height = form:getSize()
		self.m_WebView = GUIWebView:new(0, 0, width, height, self.m_StartURL, true, form)
		self.m_WebView:setPausingOnHide(false)

		-- Set mobile property
		local browser = self.m_WebView:getUnderlyingBrowser()
		if browser.setProperty then -- backwards compatibility
			browser:setProperty("mobile", "1")
		end
	else
		self.m_WebView:setVisible(true)
	end
end

function AppCEF:onClose()
	if self:isDestroyOnCloseEnabled() then
		delete(self.m_WebView)
	end
end
