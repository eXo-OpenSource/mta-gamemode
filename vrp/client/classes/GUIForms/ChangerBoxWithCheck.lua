-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ChangerBoxWithCheck.lua
-- *  PURPOSE:     Changerbox for faction/company class
-- *
-- ****************************************************************************
ChangerBoxWithCheck = inherit(GUIForm)

function ChangerBoxWithCheck:constructor(title, text, items, items2, checkBoxText, callback)
	GUIForm.constructor(self, screenWidth/2 - 707/2, screenHeight/2 - 218/2, 707, 218)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(14, 39, 692, 30, text, self.m_Window)
	GUILabel:new(14, 39, 692, 30, text, self.m_Window)
	self.m_Changer = GUIChanger:new(7, 71, 692, 35, self.m_Window)
	self.m_Changer2 = GUIChanger:new(7, 111, 692, 35, self.m_Window)
	local item
	self.m_itemTable = {}
	for index, v in pairs(items) do
		item = self.m_Changer:addItem(v)
		self.m_itemTable[v] = index
	end
	local item2
	self.m_itemTable2 = {}
	for index, v in pairs(items2) do
		item2 = self.m_Changer2:addItem(v)
		self.m_itemTable2[v] = index
	end
	self.m_SubmitButton = VRPButton:new(7, 164, 247, 35, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)
	self.m_CheckBox = GUICheckbox:new(282, 168, 247, 17, checkBoxText, self.m_Window):setFont(VRPFont(25)):setFontSize(1)
	
	self.m_SubmitButton.onLeftClick = function()
		if callback then

			callback(self:getSelectedIndex(), self:getSelectedIndex2(), self.m_CheckBox:isChecked())
		end
		delete(self)
	end
end

function ChangerBoxWithCheck:getSelectedIndex()
	local name = self.m_Changer:getIndex()
	return self.m_itemTable[name]
end

function ChangerBoxWithCheck:getSelectedIndex2()
	local name = self.m_Changer2:getIndex()
	return tonumber(name)
end
