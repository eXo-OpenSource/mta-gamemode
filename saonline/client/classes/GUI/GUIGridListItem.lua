-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIGridListItem.lua
-- *  PURPOSE:     GUI gridlist item class
-- *
-- ****************************************************************************
GUIGridListItem = inherit(GUIElement)
inherit(GUIColorable, GUIGridListItem)

function GUIGridListItem:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, tocolor(0, 0, 0, 0))
	
	self.m_Columns = {}
end

function GUIGridListItem:setColumnText(columnIndex, value)
	self.m_Columns[columnIndex] = value
	self:anyChange()
end

function GUIGridListItem:getColumnText(columnIndex)
	return self.m_Columns[columnIndex]
end

function GUIGridListItem:drawThis()
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

	local currentXPos = 0
	for columnIndex, columnValue in ipairs(self.m_Columns) do
		local columnWidth = self:getGridList():getColumnWidth(columnIndex)
		dxDrawText(self.m_Columns[columnIndex], self.m_AbsoluteX + currentXPos + 2, self.m_AbsoluteY, self.m_AbsoluteX + currentXPos + columnWidth*self.m_Width, self.m_Height, Color.White)
		currentXPos = currentXPos + columnWidth*self.m_Width + 5
	end
end

function GUIGridListItem:onInternalMouseWheelUp()
	self.m_Parent:onInternalMouseWheelUp()
end

function GUIGridListItem:onInternalMouseWheelDown()
	self.m_Parent:onInternalMouseWheelDown()
end

function GUIGridListItem:onInternalLeftClick()
	self:getGridList():onInternalSelectItem(self)
	if self:getGridList().onSelectItem then
		self:getGridList().onSelectItem(self)
	end
end

function GUIGridListItem:getGridList()
	return self.m_Parent.m_Parent
end