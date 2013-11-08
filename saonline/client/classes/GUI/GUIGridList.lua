-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIGridList.lua
-- *  PURPOSE:     GUI gridlist class
-- *
-- ****************************************************************************
GUIGridList = inherit(GUIElement)

function GUIGridList:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_Columns = {}
	self.m_ScrollArea = GUIScrollableArea:new(0, 6, self.m_Width, self.m_Height - 40, self.m_Width, 1, true, false, self)
	self.m_SelectedItem = nil
end

function GUIGridList:addItem(...)
	local listItem = GUIGridListItem:new(2, #self:getItems() * 20, self.m_Width - 4, 20, self.m_ScrollArea)
	for k, arg in ipairs({...}) do
		listItem:setColumnText(k, arg)
	end
	
	-- Resize the document
	self.m_ScrollArea:resize(self.m_Width, 60 + #self:getItems() * 20)
	
	return listItem
end

function GUIGridList:removeItem(columnIndex)
	delete(self.m_ScrollArea.m_Children[columnIndex])
	self:anyChange()
end

function GUIGridList:getItems()
	return self.m_ScrollArea.m_Children
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

function GUIGridList:getSelectedItem()
	return self.m_SelectedItem
end

function GUIGridList:onInternalSelectItem(item)
	self.m_SelectedItem = item

	for k, v in ipairs(self:getItems()) do
		v.m_Color = tocolor(0, 0, 0, 0)
	end
	
	item:setColorRGB(200, 200, 200, 200)
	self:anyChange()
end

function GUIGridList:draw() -- Swap render order
	if self.m_Visible then
		for k, v in ipairs(self.m_Children) do
			if v.m_Visible and v.draw then
				v:draw(incache)
			end
		end
		self:drawThis()
	end
end

function GUIGridList:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(255, 255, 0, 50))
	
	-- Draw header line
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, 20, Color.Red)
	
	-- Draw column header
	local currentXPos = 0
	for k, column in ipairs(self.m_Columns) do
		dxDrawText(column.text, self.m_AbsoluteX + currentXPos, self.m_AbsoluteY + 2, self.m_AbsoluteX + currentXPos + column.width*self.m_Width, self.m_AbsoluteY + 10, Color.White, 1)
		currentXPos = currentXPos + column.width*self.m_Width + 5
	end
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 18, self.m_Width, 2, Color.White)
end
