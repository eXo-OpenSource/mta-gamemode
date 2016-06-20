-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUICombobox.lua
-- *  PURPOSE:     GUI combobox class
-- *
-- ****************************************************************************

GUICombobox = inherit(GUIElement)
local ITEM_HEIGHT = 30

function GUICombobox:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_Button = GUIButton:new(0, 0, width, height, "Drop down", self)
	self.m_Button.onLeftClick = function() self.m_List:setVisible(not self.m_List:isVisible()) end
	
	self.m_List = GUIGridList:new(self.m_PosX, self.m_PosY, width, 200, self:getParent())
	self.m_List.onSelectItem = function(item)
		self.m_Button:setText(item:getColumnText(1))
		self.m_List:setVisible(false) 
		
		if self.onSelectItem then self.onSelectItem(item) end
	end
	self.m_List:addColumn("", 1)
	self.m_List:setVisible(false)
end

function GUICombobox:addItem(text)
	self.m_List:addItem(text)
	self.m_List:setSize(nil, #self.m_List:getItems()*ITEM_HEIGHT)
end

addCommandHandler("combo",
	function()
		combo = GUICombobox:new(200, 300, 230, ITEM_HEIGHT)
		combo:addItem("Test 1")
		combo:addItem("Test 2")
		combo:addItem("Test 3")
	end
)
