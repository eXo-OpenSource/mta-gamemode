-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/TicketGUI.lua
-- *  PURPOSE:     TicketGUI class
-- *
-- ****************************************************************************
TicketGUI = inherit(GUIWebForm)
inherit(Singleton, TicketGUI)

function TicketGUI:constructor()
	GUIWebForm.constructor(self, screenWidth/2-400, screenHeight/2-250, 800, 500)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Ticket-System", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "http://exo-reallife.de/ingame/ticketSystem/user.php", true, self.m_Window)
	Browser.requestDomains{"exo-reallife.de", "maxcdn.bootstrapcdn.com"}
end

function TicketGUI:destructor()
	GUIWebForm.destructor(self)
end

function TicketGUI:onShow()
	
end

function TicketGUI:onHide()
	
end
