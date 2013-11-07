-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIGridList.lua
-- *  PURPOSE:     GUI gridlist class
-- *
-- ****************************************************************************
GUIGridList = inherit(GUIScrollableArea)

function GUIGridList:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIScrollableArea.constructor(self, self.m_Width, math.max(#self.m_Children, 1)*20+100, true, false)
	
	self.m_Columns = {}
end

function GUIGridList:addItem(...)
	local listItem = GUIGridListItem:new(2, 60 + #self.m_Children * 20, self.m_Width - 4, 20, self)
	for k, arg in ipairs({...}) do
		listItem:setColumnText(k, arg)
	end
	
	-- Resize the document
	self:resize(self.m_Width, 60 + #self.m_Children * 20)
end

function GUIGridList:removeItem(columnIndex)
	delete(self.m_Children[columnIndex])
	self:anyChange()
end

function GUIGridList:getColumnWidth(columnIndex)
	return self.m_Columns[columnIndex].width
end

function GUIGridList:getColumnText(columnIndex)
	return self.m_Columns[columnIndex].text
end

function GUIGridList:setColumnText(columnIndex, text)
	self.m_Columns[columnIndex].text = text
end

function GUIGridList:addColumn(text, width)
	table.insert(self.m_Columns, {text = text, width = width})
end

function GUIGridList:drawThis()
	-- Draw column header
	local currentXPos = 0
	for k, column in ipairs(self.m_Columns) do
		dxDrawText(column.text, self.m_AbsoluteX + currentXPos, self.m_AbsoluteY + 2, self.m_AbsoluteX + currentXPos + column.width*self.m_Width, self.m_AbsoluteY + 10, Color.White, 1)
		currentXPos = currentXPos + column.width*self.m_Width + 5
	end
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 18, self.m_Width - 4, 2, Color.White)
end
