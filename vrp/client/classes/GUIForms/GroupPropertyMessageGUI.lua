-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupPropertyMessageGUI.lua
-- *  PURPOSE:     GroupPropertyMessageGUI class
-- *
-- ****************************************************************************

GroupPropertyMessageGUI = inherit(GUIForm)
inherit(Object, GroupPropertyMessageGUI)

function GroupPropertyMessageGUI:constructor( superClass )
	local width, height = ( screenWidth*0.4)/ASPECT_RATIO_MULTIPLIER, (screenHeight*0.2)/ASPECT_RATIO_MULTIPLIER
	GUIForm.constructor(self, (screenWidth*0.5 - width/2) /ASPECT_RATIO_MULTIPLIER , screenHeight*0, width, height,true)
	self.m_Window = GUIWindow:new(0,0,width,height,_"Eingangsnachricht",true,true,self)
	self.m_Edit = GUIEdit:new(width*0.1, height*0.25, width*0.8, height*0.4, self.m_Window )
	if superClass.m_Message then
		self.m_Edit:setCaption(superClass.m_Message or "")
	end
	self.m_AcceptButton = GUIButton:new(width*0.3, height*0.7, width*0.4, height*0.25, "Weiter", self.m_Window)
	self.m_AcceptButton.onLeftClick = bind(GroupPropertyMessageGUI.AcceptButton_message, self)
	self.m_Window:deleteOnClose(true)
	self.m_Super = superClass
end

function GroupPropertyMessageGUI:destructor()
	GUIForm.destructor(self)
end

function GroupPropertyMessageGUI:AcceptButton_message()
	if self.m_Super then
		self.m_Super:setMessage( self.m_Edit:getDrawnText())
		self:delete()
	else
		self:delete()
	end
end


