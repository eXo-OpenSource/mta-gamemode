-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ChangerBoxWithCheck.lua
-- *  PURPOSE:     Generic ChangerBoxWithCheck class
-- *
-- ****************************************************************************
ChangerBoxWithCheck = inherit(GUIForm)

function ChangerBoxWithCheck:constructor(title, text, items, checkBoxText, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.17, text, self.m_Window)
	self.m_Changer = GUIChanger:new(self.m_Width*0.01, self.m_Height*0.4, self.m_Width*0.98, self.m_Height*0.2, self.m_Window)
	local item
	self.m_itemTable = {}
	for index, v in pairs(items) do
		item = self.m_Changer:addItem(v)
		self.m_itemTable[v] = index
	end
	self.m_SubmitButton = VRPButton:new(self.m_Width*0.01, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)
	self.m_CheckBox = GUICheckbox:new(self.m_Width*0.40, self.m_Height*0.72, self.m_Width*0.35, self.m_Height*0.10, checkBoxText, self.m_Window):setFont(VRPFont(25)):setFontSize(1)
	
	self.m_SubmitButton.onLeftClick = function()
		if callback then

			callback(self:getSelectedIndex(), self.m_CheckBox:isChecked())
		end
		delete(self)
	end
end

function ChangerBoxWithCheck:getSelectedIndex()
	local name = self.m_Changer:getIndex()
	return self.m_itemTable[name]
end
