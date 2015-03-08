-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIGridList.lua
-- *  PURPOSE:     GUI gridlist class
-- *
-- ****************************************************************************
GUIGridList = inherit(GUIElement)
inherit(GUIColorable, GUIGridList)
local ITEM_HEIGHT = 30

function GUIGridList:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, tocolor(0, 0, 0, 180))

	self.m_Columns = {}
	self.m_ScrollArea = GUIScrollableArea:new(0, ITEM_HEIGHT, self.m_Width, self.m_Height-ITEM_HEIGHT, self.m_Width, 1, true, false, self)
	self.m_SelectedItem = nil
end

function GUIGridList:addItem(...)
	local listItem = GUIGridListItem:new(0, #self:getItems() * ITEM_HEIGHT, self.m_Width, ITEM_HEIGHT, self.m_ScrollArea)
	for k, arg in ipairs({...}) do
		listItem:setColumnText(k, arg)
	end

	-- Resize the document
	self.m_ScrollArea:resize(self.m_Width, 60 + #self:getItems() * ITEM_HEIGHT)

	return listItem
end

function GUIGridList:addItemNoClick(...)
	local listItem = GUIGridListNoClickItem:new(0, #self:getItems() * ITEM_HEIGHT, self.m_Width, ITEM_HEIGHT, self.m_ScrollArea)
	for k, arg in ipairs({...}) do
		listItem:setColumnText(k, arg)
	end

	-- Resize the document
	self.m_ScrollArea:resize(self.m_Width, 60 + #self:getItems() * ITEM_HEIGHT)

	return listItem
end

function GUIGridList:removeItem(itemIndex)
	delete(self.m_ScrollArea.m_Children[itemIndex])
	self:anyChange()
end

function GUIGridList:removeItemByItem(item)
	local itemIndex = table.find(self.m_ScrollArea.m_Children, item)
	if itemIndex then
		self:removeItem(itemIndex)
	else
		delete(item)
	end
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
	return self
end

function GUIGridList:addColumn(text, width)
	table.insert(self.m_Columns, {text = text, width = width})
end

function GUIGridList:getSelectedItem()
	return self.m_SelectedItem
end

function GUIGridList:clear()
	delete(self.m_ScrollArea)
	self.m_ScrollArea = GUIScrollableArea:new(0, ITEM_HEIGHT, self.m_Width, self.m_Height-ITEM_HEIGHT, self.m_Width, 1, true, false, self)
end

function GUIGridList:onInternalSelectItem(item)
	self.m_SelectedItem = item

	for k, v in ipairs(self:getItems()) do
		v.m_Color = Color.Clear
	end

	item:setColor(Color.LightBlue)
	self:anyChange()
end

function GUIGridList:onInternalMouseWheelUp()
	self.m_ScrollArea:onInternalMouseWheelUp()
end

function GUIGridList:onInternalMouseWheelDown()
	self.m_ScrollArea:onInternalMouseWheelDown()
end

function GUIGridList:draw(incache) -- Swap render order
	if self.m_Visible then
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
	end
end

function GUIGridList:drawThis()
	-- Draw header line
	--dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, ITEM_HEIGHT, Color.Black)

	-- Draw column header
	local currentXPos = 0
	for k, column in ipairs(self.m_Columns) do
		dxDrawText(column.text, self.m_AbsoluteX + currentXPos + 4, self.m_AbsoluteY + 1, self.m_AbsoluteX + currentXPos + column.width*self.m_Width, self.m_AbsoluteY + 10, Color.White, 1, VRPFont(28))
		currentXPos = currentXPos + column.width*self.m_Width + 5
	end
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + ITEM_HEIGHT - 2, self.m_Width, 2, Color.LightBlue) -- tocolor(255, 255, 255, 150)
end
