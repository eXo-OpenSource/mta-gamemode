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

function GUIGridListItem:setColumnText(columnIndex, value, alignX)
	self.m_Columns[columnIndex] = {text = value, alignX = (alignX or "left")}
	self:anyChange()
	return self
end

function GUIGridListItem:getColumnText(columnIndex)
	return self.m_Columns[columnIndex].text
end

function GUIGridListItem:setColumnAlignX(columnIndex, alignX)
	self.m_Columns[columnIndex].alignX = alignX
	self:anyChange()
	return self
end

function GUIGridListItem:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

	local currentXPos = 0
	for columnIndex, columnValue in ipairs(self.m_Columns) do
		local columnWidth = self:getGridList():getColumnWidth(columnIndex)
		dxDrawText(self.m_Columns[columnIndex].text, self.m_AbsoluteX + currentXPos + 4, self.m_AbsoluteY + 1, self.m_AbsoluteX + currentXPos + columnWidth*self.m_Width - 4, self.m_Height, Color.White, 1, VRPFont(28), self.m_Columns[columnIndex].alignX)
		currentXPos = currentXPos + columnWidth*self.m_Width + 5
	end
	dxSetBlendMode("blend")
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