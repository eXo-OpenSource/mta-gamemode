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
	self.m_Window:addBackButton(function () SelfGUI:getSingleton():show() end)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, (INGAME_WEB_PATH .. "/ingame/migrator/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, self.m_Window)
end

function MigratorPanel:destructor()
	GUIWebForm.destructor(self)
end

function MigratorPanel:onShow()
	SelfGUI:getSingleton():addWindow(self)
end

function MigratorPanel:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end
