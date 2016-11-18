-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupPropertyGUI.lua
-- *  PURPOSE:     GroupProperty GUI class
-- *
-- ****************************************************************************
GroupPropertyGUI = inherit(GUIForm)
inherit(Singleton, GroupPropertyGUI)

addRemoteEvents{"setGUIActive"}
function GroupPropertyGUI:constructor( tObj ) 
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.3/2, screenWidth*0.4, screenHeight*0.3)
	
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	local tabManage = self.m_TabPanel:addTab(_"Verwaltung")
	self.m_TabManage = tabManage
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.1, self.m_Width*0.65, self.m_Height*0.10, _"Verwaltung", tabAManage):setFont(VRPFont(self.m_Height*0.12))
	self.m_CreateButton = GUIButton:new(self.m_Width*0.33, self.m_Height*0.2, self.m_Width*0.33, self.m_Height*0.15, _"Auf-/Abschließen", tabManage):setBackgroundColor(Color.Orange)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.66, self.m_Height*0.2, self.m_Width*0.33, self.m_Height*0.15, _"Eingangsnachricht", tabManage):setBackgroundColor(Color.Orange
	
	local tabAccess = self.m_TabPanel:addTab(_"Berechtigung")
	self.m_TabAccess = tabAccess
	
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.1, self.m_Width*0.65, self.m_Height*0.10, _"Schlüssel-Berechtigung", tabAccess):setFont(VRPFont(self.m_Height*0.12))
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.2, self.m_Width*0.45, self.m_Height*0.10, _"Name des Spielers:", tabAccess)
	self.m_PlayerEdit = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.5, self.m_Height*0.10, tabAccess)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.33, self.m_Height*0.32, self.m_Width*0.33, self.m_Height*0.15, _"Vergeben", tabAccess):setBackgroundColor(Color.Green)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.66, self.m_Height*0.32, self.m_Width*0.33, self.m_Height*0.15, _"Abnehmen", tabAccess):setBackgroundColor(Color.Yellow)
	
	local tabInfo = self.m_TabPanel:addTab(_"Information")
	self.m_TabInfo = tabInfo
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.1, self.m_Width*0.65, self.m_Height*0.10, _"Information", tabInfo):setFont(VRPFont(self.m_Height*0.12))
end

addEventHandler("setGUIActive",localPlayer,function( tObj) 
	if GroupPropertyGUI:getSingleton() then 
		GroupPropertyGUI:getSingleton():delete()
	end
	GroupProperty:new( tObj )
end
)