-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIGridList.lua
-- *  PURPOSE:     GUI gridlist class
-- *
-- ****************************************************************************
GUIGridList = inherit(GUIElement)
inherit(GUIColorable, GUIGridList)
inherit(GUIFontContainer, GUIGridList)

function GUIGridList:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, tocolor(0, 0, 0, 180))
	GUIFontContainer.constructor(self, "", 1, VRPFont(28))

	self.m_ItemHeight = 30
	self.m_Columns = {}
	self.m_ScrollArea = GUIScrollableArea:new(0, self.m_ItemHeight, self.m_Width, self.m_Height-self.m_ItemHeight, self.m_Width, 1, true, false, self, self.m_ItemHeight)
	self.m_SelectedItem = nil
end

function GUIGridList:addItem(...)
	local listItem = GUIGridListItem:new(0, #self:getItems() * self.m_ItemHeight, self.m_Width, self.m_ItemHeight, self.m_ScrollArea)
	for k, arg in ipairs({...}) do
		listItem:setColumnText(k, arg)
	end

	-- Resize the document
	self.m_ScrollArea:resize(self.m_Width, #self:getItems() * self.m_ItemHeight)

	return listItem
end

function GUIGridList:addItemNoClick(...)
	local listItem = GUIGridListItem:new(0, #self:getItems() * self.m_ItemHeight, self.m_Width, self.m_ItemHeight, self.m_ScrollArea):setClickable(false)
	for k, arg in ipairs({...}) do
		listItem:setColumnText(k, arg)
	end

	-- Resize the document
	self.m_ScrollArea:resize(self.m_Width, #self:getItems() * self.m_ItemHeight)

	return listItem
end

function GUIGridList:removeItem(itemIndex)
	local item = self.m_ScrollArea.m_Children[itemIndex]

	-- Move all following items 1 item higher
	local itemX, itemY = item:getPosition()
	for k, v in pairs(self:getItems()) do
		-- Since we do not have proper item rows, we've to check each height
		local x, y = v:getPosition()
		if y > itemY then
			v:setPosition(x, y - self.m_ItemHeight)
		end
	end

	delete(item)
	self:anyChange()
end

function GUIGridList:removeItemByItem(item)
	local itemIndex = table.find(self.m_ScrollArea.m_Children, item)
	if itemIndex then
		self:removeItem(itemIndex)
	else
		delete(item)
	end

	if item == self.m_SelectedItem then
		self.m_SelectedItem = nil
	end
end

function GUIGridList:getItems()
	return self.m_ScrollArea.m_Children
end

function GUIGridList:setItemHeight(height)
	self.m_ItemHeight = height

	-- Update position of the underlying scroll area
	self.m_ScrollArea:setPosition(0, self.m_ItemHeight)
end

function GUIGridList:getColumnWidth(columnIndex)
	return self.m_Columns[columnIndex].width
end

function GUIGridList:getColumnText(columnIndex)
	return self.m_Columns[columnIndex].text
end

function GUIGridList:setColumnText(columnIndex, text)
	self.m_Columns[columnIndex].text = text
	return self
end

function GUIGridList:setColumnBackgroundColor(color)
	if color == Color.Clear then color = false end
	self.m_ColumnBGColor = color
	return self
end

function GUIGridList:addColumn(text, width)
	table.insert(self.m_Columns, {text = text, width = width})
	return self
end

function GUIGridList:getSelectedItem()
	return self.m_SelectedItem
end

function GUIGridList:clear()
	self.m_SelectedItem = nil

	self.m_ScrollArea:clear()
	self.m_ScrollArea:resize(self.m_Width, 1)
end

function GUIGridList:onInternalSelectItem(item)
	self.m_SelectedItem = item

	for k, item in ipairs(self:getItems()) do
		item:setBackgroundColor(Color.Clear)
	end

	item:setBackgroundColor(Color.LightBlue)
	self:anyChange()
end

function GUIGridList:draw(incache) -- Swap render order
	if self.m_Visible then
		dxSetBlendMode("modulate_add")

		-- Draw background
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

		-- Draw items
		for k, v in ipairs(self.m_Children) do
			if v.m_Visible and v.draw then
				v:draw(incache)
			end
		end

		-- Draw i.a. the header line
		self:drawThis()

		dxSetBlendMode("blend")
	end
end

function GUIGridList:drawThis()
	-- Draw column header
	if self.m_ColumnBGColor then
		dxSetBlendMode("add")
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_ItemHeight, self.m_ColumnBGColor)
		dxSetBlendMode("blend")
	end
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_ItemHeight - 2, self.m_Width, 2, Color.LightBlue)
	local currentXPos = 0
	for k, column in ipairs(self.m_Columns) do
		dxDrawText(column.text, self.m_AbsoluteX + currentXPos + 4, self.m_AbsoluteY + 1, self.m_AbsoluteX + currentXPos + column.width*self.m_Width, self.m_AbsoluteY + 10, Color.White, self.m_FontSize, self.m_Font)
		currentXPos = currentXPos + column.width*self.m_Width + 5
	end
end
