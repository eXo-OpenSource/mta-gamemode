-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIGridListItem.lua
-- *  PURPOSE:     GUI gridlist item class
-- *
-- ****************************************************************************
GUIGridListItem = inherit(GUIElement)
inherit(GUIColorable, GUIGridListItem)
inherit(GUIFontContainer, GUIGridListItem)

function GUIGridListItem:constructor(posX, posY, width, height, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.White)
	GUIFontContainer.constructor(self, "", 1, VRPFont(28))

	self.m_Columns = {}
	self.m_BackgroundColor = Color.Clear
	self.m_Clickable = true
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

function GUIGridListItem:setColumnColor(columnIndex, color)
	self.m_Columns[columnIndex].color = color
	self:anyChange()
	return self
end

function GUIGridListItem:setColumnToImage(columnIndex, state, width)
	self.m_Columns[columnIndex].image = state
	self.m_Columns[columnIndex].imageWidth = width or getColumnWidth(columnIndex)*self.m_Width - 10
	self:anyChange()
	return self
end

function GUIGridListItem:setColumnFont(columnIndex, font, size)
	self.m_Columns[columnIndex].font = font
	self.m_Columns[columnIndex].fontSize = size
	self:anyChange()
	return self
end

function GUIGridListItem:setClickable(state)
	self.m_Clickable = state

	self:setColor(state and Color.White or Color.LightBlue)
	return self
end

function GUIGridListItem:setBackgroundColor(color)
	self.m_BackgroundColor = color
end

function GUIGridListItem:getBackgroundColor()
	return self.m_BackgroundColor
end

function GUIGridListItem:drawThis()
	dxSetBlendMode("modulate_add")
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)

	local currentXPos = 0
	for columnIndex, columnValue in ipairs(self.m_Columns) do
		local columnWidth = self:getGridList():getColumnWidth(columnIndex)
		if self.m_Columns[columnIndex].image then
			dxDrawImage(self.m_AbsoluteX + currentXPos + 6, self.m_AbsoluteY + 3, self.m_AbsoluteX + currentXPos + self.m_Columns[columnIndex].imageWidth, self.m_Height - 6, self.m_Columns[columnIndex].text)
		else
			dxDrawText(self.m_Columns[columnIndex].text, self.m_AbsoluteX + currentXPos + 4, self.m_AbsoluteY + 1, self.m_AbsoluteX + currentXPos + columnWidth*self.m_Width - 4, self.m_Height, self.m_Columns[columnIndex].color or self.m_Color, self.m_Columns[columnIndex].fontSize or self.m_FontSize, self.m_Columns[columnIndex].font or self.m_Font, self.m_Columns[columnIndex].alignX)
		end
		currentXPos = currentXPos + columnWidth*self.m_Width + 5
	end
	dxSetBlendMode("blend")
end

function GUIGridListItem:onInternalLeftClick()
	if not self.m_Clickable then return end

	self:getGridList():onInternalSelectItem(self)
	if self:getGridList().onSelectItem then
		self:getGridList().onSelectItem(self)
	end
end

function GUIGridListItem:getGridList()
	return self.m_Parent.m_Parent
end
