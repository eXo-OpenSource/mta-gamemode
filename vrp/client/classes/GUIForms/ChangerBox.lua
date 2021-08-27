-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ChangerBox.lua
-- *  PURPOSE:     Generic ChangerBox class
-- *
-- ****************************************************************************
ChangerBox = inherit(GUIForm)

function ChangerBox:constructor(title, text, items, callback, value)
	local height = 4

	if not text or text == "" then
		height = 3
	end

	GUIWindow.updateGrid()	
	self.m_Width = grid("x", 21)
	self.m_Height = grid("y", height)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	
	if text and text ~= "" then
		GUIGridLabel:new(1, 1, 20, 1, text, self.m_Window)
	end

	self.m_Changer = GUIGridChanger:new(1, height - 2, 20, 1, self.m_Window)

	local item
	self.m_itemTable = {}
	for index, v in pairs(items) do
		item = self.m_Changer:addItem(v)
		self.m_itemTable[v] = index
	end

	if value ~= nil then
		self.m_Changer:setIndex(value)
	end

	self.m_SubmitButton = GUIGridButton:new(16, height - 1, 5, 1, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	self.m_SubmitButton.onLeftClick = function()
		if callback then

			callback(self:getSelectedIndex())
		end
		delete(self)
	end
end

function ChangerBox:getSelectedIndex()
	local name = self.m_Changer:getIndex()
	return self.m_itemTable[name]
end
