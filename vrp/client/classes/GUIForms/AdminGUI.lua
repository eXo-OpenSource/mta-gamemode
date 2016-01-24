-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI class
-- *
-- ****************************************************************************

AdminGUI = inherit(GUIForm)
inherit(Singleton, AdminGUI)

addRemoteEvents{"showAdminMenu"}
function AdminGUI:constructor() 
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.5/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.5, screenHeight*0.4)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Admin-menu", true, true, self)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.2, self.m_Width*0.25, self.m_Height*0.07, _"Adminansage:", self.m_Window):setColor(Color.White)
	self.m_AdminAnnounceText = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.6, self.m_Height*0.09,self.m_Window)
	self.m_AnnounceButton = GUIButton:new(self.m_Width*0.68, self.m_Height*0.29, self.m_Width*0.2, self.m_Height*0.09, _"senden",  self.m_Window)
	self.m_AnnounceButton.onLeftClick = bind(self.AnnounceButton_Click, self)
	
end




function AdminGUI:AnnounceButton_Click()
	local announceString = self.m_AdminAnnounceText:getText()
	if announceString ~= "" and #announceString > 0 then 
		--triggerServerEvent("adminAnnounce", root, announceString)
		self:AnnounceText( announceString )
		self.m_AdminAnnounceText:setText(" ")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function AdminGUI:AnnounceText( message )
	if self.m_MoveText == nil then
		self.m_MoveText = GUIMovetext:new(0, 0, screenWidth, screenHeight*0.05,message,"",1,(screenWidth*0.1)*-1, self,"files/images/GUI/megafone.png",true)
	end
end



addEventHandler("showAdminMenu", root,
		function(...)
			AdminGUI:new( ) 
		end
	)