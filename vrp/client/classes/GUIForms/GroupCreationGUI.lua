-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupCreationGUI.lua
-- *  PURPOSE:     Group creation GUI class
-- *
-- ****************************************************************************
GroupCreationGUI = inherit(GUIForm)

function GroupCreationGUI:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Gruppe erstellen", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.14, _"Bitte gib einen Namen ein:", 1, self.m_Window):setFont(VRPFont(self.m_Height*0.13))
	self.m_NameEdit = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.38, self.m_Width*0.98, self.m_Height*0.18, self.m_Window)
	self.m_CreateButton = GUIButton:new(self.m_Width*0.3, self.m_Height*0.7, self.m_Width*0.4, self.m_Height*0.2, _"Erstellen", self.m_Window):setBackgroundColor(Color.Green)
	
	self.m_CreateButton.onLeftClick = bind(self.CreateButton_Click, self)
end

function GroupCreationGUI:CreateButton_Click()
	local text = self.m_NameEdit:getText()
	
	if text ~= "" then
		triggerServerEvent("groupCreate", root, text)
		delete(self)
	else
		ErrorBox:new(_"Bitte gib zuerst einen Namen ein!")
	end
end
