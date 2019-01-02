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
	GUIColorable.constructor(self)
	GUIFontContainer.constructor(self, "", 1, VRPFont(28))

	self.m_Columns = {}
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

function GUIGridListItem:getColumnColor(columnIndex)
	return self.m_Columns[columnIndex].color
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

	self:setColor(state and Color.White or Color.Accent)
	return self
end

function GUIGridListItem:getBackgroundColor()
	return self.m_BackgroundColor
end

function GUIGridListItem:drawThis()
	dxSetBlendMode("modulate_add")

	if self.m_BackgroundColor then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BackgroundColor)
	end

	local currentXPos = 0
	for columnIndex, columnValue in ipairs(self.m_Columns) do
		local columnWidth = self:getGridList():getColumnWidth(columnIndex)
		if self.m_Columns[columnIndex].image then
			dxDrawImage(self.m_AbsoluteX + currentXPos + 6, self.m_AbsoluteY + 3, self.m_AbsoluteX + currentXPos + self.m_Columns[columnIndex].imageWidth, self.m_Height - 6, self.m_Columns[columnIndex].text, 0, 0, 0, self.m_Columns[columnIndex].color or self.m_Color)
		else
			local font = self.m_Columns[columnIndex].font and getVRPFont(self.m_Columns[columnIndex].font) or self:getFont()
			local fontSize = self.m_Columns[columnIndex].fontSize or self:getFontSize()
			dxDrawText(self.m_Columns[columnIndex].text, self.m_AbsoluteX + currentXPos + 4, self.m_AbsoluteY, self.m_AbsoluteX + currentXPos + columnWidth*self.m_Width - 4, self.m_AbsoluteY + self.m_Height, self.m_Columns[columnIndex].color or self.m_Color, fontSize, font, self.m_Columns[columnIndex].alignX, "center")
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
