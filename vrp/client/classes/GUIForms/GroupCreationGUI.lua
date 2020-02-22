-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupCreationGUI.lua
-- *  PURPOSE:     Group creation GUI class
-- *
-- ****************************************************************************
GroupCreationGUI = inherit(GUIForm)

function GroupCreationGUI:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.3/2, screenWidth*0.4, screenHeight*0.3)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Private Gang/Firma erstellen", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.16, self.m_Width*0.98, self.m_Height*0.04, _("Hier kannst du eine private Firma oder Gang gründen.\nEine Gründung kostet %s!", toMoneyString(GROUP_CREATE_COSTS)), self.m_Window):setFont(VRPFont(self.m_Height*0.11)):setMultiline(true)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.42, self.m_Width*0.65, self.m_Height*0.10, _"Name der Gang/Firma:", self.m_Window):setFont(VRPFont(self.m_Height*0.12))
	self.m_NameEdit = GUIEdit:new(self.m_Width*0.42, self.m_Height*0.42, self.m_Width*0.5, self.m_Height*0.10, self.m_Window)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.6, self.m_Width*0.4, self.m_Height*0.10, _"Typ auswählen:", self.m_Window):setFont(VRPFont(self.m_Height*0.12))
	self.m_Type = GUIChanger:new(self.m_Width*0.42, self.m_Height*0.6, self.m_Width*0.5, self.m_Height*0.10, self.m_Window)
	self.m_Type:addItem("Gang")
	self.m_Type:addItem("Firma")
	self.m_CreateButton = GUIButton:new(self.m_Width*0.33, self.m_Height*0.8, self.m_Width*0.33, self.m_Height*0.15, _"Erstellen", self.m_Window):setBackgroundColor(Color.Green)

	self.m_CreateButton.onLeftClick = bind(self.CreateButton_Click, self)
end

function GroupCreationGUI:CreateButton_Click()
	local text = self.m_NameEdit:getText()
	local typ = self.m_Type:getIndex()

	if text ~= "" then
		if string.len(text) <= GROUP_NAME_MAX then
			if text:match(GROUP_NAME_MATCH) then
				triggerServerEvent("groupCreate", root, text, typ)
				delete(self)
			else
				ErrorBox:new(_"Name enthält ungültige Zeichen!")
			end
		else
			ErrorBox:new(_"Name zu lang! Maximal 24 Zeichen!")
		end
	else
		ErrorBox:new(_"Bitte gib zuerst einen Namen ein!")
	end
end
