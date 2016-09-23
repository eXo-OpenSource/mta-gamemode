-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupCreationGUI.lua
-- *  PURPOSE:     Group creation GUI class
-- *
-- ****************************************************************************
GroupCreationGUI = inherit(GUIForm)

function GroupCreationGUI:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.25/2, screenWidth*0.4, screenHeight*0.25)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"private Gang/Firma erstellen", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.18, self.m_Width*0.98, self.m_Height*0.10, _"Hier kannst du eine private Firma oder Gang gründen. Eine Gründung kostet 20.000$!", self.m_Window):setFont(VRPFont(self.m_Height*0.13))
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.32, self.m_Width*0.65, self.m_Height*0.14, _"Name der Gang/Firma:", self.m_Window):setFont(VRPFont(self.m_Height*0.13))
	self.m_NameEdit = GUIEdit:new(self.m_Width*0.35, self.m_Height*0.32, self.m_Width*0.5, self.m_Height*0.14, self.m_Window)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.52, self.m_Width*0.4, self.m_Height*0.14, _"Typ auswählen:", self.m_Window):setFont(VRPFont(self.m_Height*0.14))
	self.m_Type = GUIChanger:new(self.m_Width*0.35, self.m_Height*0.52, self.m_Width*0.5, self.m_Height*0.14, self.m_Window)
	self.m_Type:addItem("Gang")
	self.m_Type:addItem("Firma")
	self.m_CreateButton = GUIButton:new(self.m_Width*0.33, self.m_Height*0.76, self.m_Width*0.33, self.m_Height*0.16, _"Erstellen", self.m_Window):setBackgroundColor(Color.Green)

	self.m_CreateButton.onLeftClick = bind(self.CreateButton_Click, self)
end

function GroupCreationGUI:CreateButton_Click()
	local text = self.m_NameEdit:getText()
	local typ = self.m_Type:getIndex()
	if text ~= "" then
		triggerServerEvent("groupCreate", root, text,typ)
		delete(self)
	else
		ErrorBox:new(_"Bitte gib zuerst einen Namen ein!")
	end
end
