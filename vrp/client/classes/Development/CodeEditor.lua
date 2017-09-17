-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Development/CodeEditor.lua
-- *  PURPOSE:     Faction State Class
-- *
-- ****************************************************************************


CodeEditorGUI = inherit(GUIForm)
inherit(Singleton, CodeEditorGUI)


function CodeEditorGUI:constructor()
    grid("reset", true)
	grid("offset", 30)
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Code Editor", true, true, self)

	GUIGridLabel:new(1, 1, 19, 1, _"Editor", self.m_Window):setHeader("sub")
    BRO = GUIGridWebView:new(1, 2, 19, 10, "http://mta/local/files/html/editor.htm", false, self.m_Window)
	GUIGridLabel:new(1, 12, 5, 1, _"Optionen", self.m_Window):setHeader("sub")
    GUIGridButton:new(1, 13, 5, 1, "Option 1", self.m_Window)
    GUIGridButton:new(1, 14, 5, 1, "Option 2", self.m_Window)
    GUIGridButton:new(1, 15, 5, 1, "Option 3", self.m_Window)
end