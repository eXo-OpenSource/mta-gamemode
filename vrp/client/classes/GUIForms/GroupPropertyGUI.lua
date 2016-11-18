-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupPropertyGUI.lua
-- *  PURPOSE:     GroupProperty GUI class
-- *
-- ****************************************************************************
GroupPropertyGUI = inherit(GUIForm)
inherit(Singleton, GroupPropertyGUI)

function GroupPropertyGUI:constructor() 
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.3/2, screenWidth*0.4, screenHeight*0.3)
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	local tabAccess = self.m_TabPanel:addTab(_"Berechtigung")
	self.m_TabAccess = tabAccess
	
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.1, self.m_Width*0.65, self.m_Height*0.10, _"Schlüssel:", tabAccess):setFont(VRPFont(self.m_Height*0.12))
	self.m_PlayerEdit = GUIEdit:new(self.m_Width*0.42, self.m_Height*0.42, self.m_Width*0.5, self.m_Height*0.10, tabAccess)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.33, self.m_Height*0.8, self.m_Width*0.33, self.m_Height*0.15, _"Vergeben", tabAccess):setBackgroundColor(Color.Green)
end