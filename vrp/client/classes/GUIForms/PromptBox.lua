-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PromptBox.lua
-- *  PURPOSE:     Prompt box
-- *
-- ****************************************************************************
PromptBox = inherit(GUIForm)

function PromptBox:constructor(question, callbackYes, callbackNo)
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.4/ASPECT_RATIO_MULTIPLIER/2, screenHeight/2-screenHeight*0.2/2, screenWidth*0.4/ASPECT_RATIO_MULTIPLIER, screenHeight*0.2)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Prompt", true, false, self)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.2, self.m_Width*0.9, self.m_Height*0.4, question, 1, self.m_Window):setFont(VRPFont(self.m_Height*0.15))
	
	self.m_ButtonYes = GUIButton:new(self.m_Width*0.05, self.m_Height*0.7, self.m_Width*0.3, self.m_Height*0.15, _"Yes", self.m_Window):setBackgroundColor(Color.Green)
	self.m_ButtonNo = GUIButton:new(self.m_Width*0.65, self.m_Height*0.7, self.m_Width*0.3, self.m_Height*0.15, _"No", self.m_Window):setBackgroundColor(Color.Red)
	
	self.m_ButtonYes.onLeftClick = function() callbackYes() delete(self) end
	self.m_ButtonNo.onLeftClick = function() callbackNo() delete(self) end
end
