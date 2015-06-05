-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/WebForms/SkillTreeGUI.lua
-- *  PURPOSE:     Skill tree form class
-- *
-- ****************************************************************************
SkillTreeGUI = inherit(GUIWebForm)
inherit(Singleton, SkillTreeGUI)

function SkillTreeGUI:constructor()
	local width, height = screenWidth*0.6, screenHeight*0.6
	GUIWebForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Skill Baum", true, true, self)
	self.m_WebView = GUIWebView:new(0, 30, self.m_Width, self.m_Height-30, "files/html/Skilltree.html", true, self.m_Window)
end

function SkillTreeGUI:destructor()
	GUIWebForm.destructor(self)
end
