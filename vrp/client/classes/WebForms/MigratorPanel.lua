-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/MigratorPanel.lua
-- *  PURPOSE:     MigratorPanel class
-- *
-- ****************************************************************************
MigratorPanel = inherit(GUIWebForm)
inherit(Singleton, MigratorPanel)

function MigratorPanel:constructor()
	GUIWebForm.constructor(self, screenWidth/2-310, screenHeight/2-230, 620, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"eXo Account-Migrator", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "http://exo-reallife.de/ingame/migrator/index.php?player="..getPlayerName(getLocalPlayer()).."&sessionID="..self:generateSessionId(), true, self.m_Window)
	Browser.requestDomains{"exo-reallife.de", "maxcdn.bootstrapcdn.com"}
end

function MigratorPanel:destructor()
	GUIWebForm.destructor(self)
end

function MigratorPanel:onShow()
	
end

function MigratorPanel:onHide()
	
end

function MigratorPanel:generateSessionId()
	return md5(localPlayer:getName()..localPlayer:getSerial()) -- ToDo: generate serverside with lastlogin timestamp for more security
end
