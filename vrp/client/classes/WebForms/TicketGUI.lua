-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/TicketGUI.lua
-- *  PURPOSE:     TicketGUI class
-- *
-- ****************************************************************************
TicketGUI = inherit(GUIWebForm)
inherit(Singleton, TicketGUI)
HelpGUI.TicketBaseUrl = "https://cp.exo-reallife.de/tickets?minimal"

function TicketGUI:constructor()
	local width = screenWidth * 0.8
	local height = screenHeight * 0.8
	-- GUIWebForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height, true)

	GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height, true, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Ticket-System", true, true, self)
	self.m_Window:addBackButton(function () SelfGUI:getSingleton():show() end)
	self.m_Window:addTitlebarButton(FontAwesomeSymbols.Home, bind(self.internalBrowserNavigateHome, self))
	self.m_WebView = GUIWebView:new(0, 32, self.m_Width, self.m_Height-32, ("https://cp.exo-reallife.de/api/auth/?redirect=/tickets?minimal&token=%s"):format(localPlayer:getSessionId()), true, self.m_Window)
	self.m_WebView.onDocumentReady = bind(self.onBrowserReady, self)
	addCommandHandler("report", bind(self.show, self))
	addCommandHandler("tickets", bind(self.show, self))
	addCommandHandler("bug", bind(self.show, self))
end

function TicketGUI:internalBrowserNavigateHome()
	if not self.m_BrowserReady then return false end
	self.m_WebView:loadURL(HelpGUI.TicketBaseUrl)
end

function TicketGUI:onBrowserReady(url)
	self.m_BrowserReady = true
end

function TicketGUI:destructor()
	GUIWebForm.destructor(self)
end

function TicketGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
end

function TicketGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end
