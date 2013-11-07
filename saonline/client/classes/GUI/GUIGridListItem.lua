-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIGridListItem.lua
-- *  PURPOSE:     GUI gridlist item class
-- *
-- ****************************************************************************
GUIGridListItem = inherit(GUIElement)

function GUIGridListItem:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_Columns = {}
end

function GUIGridListItem:setColumnText(columnIndex, value)
	self.m_Columns[columnIndex] = value
	self:anyChange()
end

function GUIGridListItem:drawThis()
	local currentXPos = 0
	for columnIndex, columnValue in ipairs(self.m_Columns) do
		local columnWidth = self.m_Parent:getColumnWidth(columnIndex)
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