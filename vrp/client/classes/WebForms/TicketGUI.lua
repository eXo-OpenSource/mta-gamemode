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
	self.m_Window:addBackButton(function () SelfGUI:getSingleton():show() end)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, (INGAME_WEB_PATH .. "/ingame/ticketSystem/user.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, self.m_Window)
	addCommandHandler("report", bind(self.show, self))
	addCommandHandler("tickets", bind(self.show, self))
	addCommandHandler("bug", bind(self.show, self))
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
