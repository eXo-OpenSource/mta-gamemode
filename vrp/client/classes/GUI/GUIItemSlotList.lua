-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIItemSlotList.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
GUIItemSlotList = inherit(GUIElement)
inherit(GUIColorable, GUIItemSlotList)

function GUIItemSlotList:constructor(posX, posY, width, height, parent)
	checkArgs("GUIItemSlot:constructor", "number", "number", "number")
	posX, posY = math.floor(posX), math.floor(posY)
	width, height = math.floor(width), math.floor(height)

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, tocolor(0, 0, 0, 180))

	self.m_Multiline = false
	self.m_AlignX = "left"
	self.m_AlignY = "top"
	self.m_Rotation = 0

	self.m_SlotSize = 40
	self.m_SlotMinMargin = 1

	self.m_ScrollArea = GUIScrollableArea:new(0, 0, self.m_Width, self.m_Height, self.m_Width, 1, true, false, self, 0)

	self.m_SlotsPerRow = math.floor(self.m_Width / (self.m_SlotSize + self.m_SlotMinMargin))
	self.m_Spacing = math.floor((self.m_Width - (self.m_SlotSize * self.m_SlotsPerRow)) / (self.m_SlotsPerRow + 1))

	self.m_Slots = {}
	self.m_SlotCount = 0
end

function GUIItemSlotList:setSlots(slots)
	if self.m_SlotCount ~= slots then
		for k, v in pairs(self.m_Slots) do
			delete(v)
		end

		self.m_Slots = {}
		self.m_SlotCount = slots

		local row = 1
		local column = 1
		for i = 1, self.m_SlotCount, 1  do
			self.m_Slots[i] = GUIItemSlot:new(self.m_Spacing * row + self.m_SlotSize * (row - 1), self.m_Spacing * column + self.m_SlotSize * (column - 1), self.m_SlotSize, self.m_SlotSize, i, self.m_ScrollArea)

			row = row + 1

			if row > self.m_SlotsPerRow then
				row = 1
				column = column + 1
			end
		end

		self.m_ScrollArea:resize(self.m_Width, self.m_Spacing * column + self.m_SlotSize * (column - 1))
	end
end

function GUIItemSlotList:setItem(slot, inventoryId, item)
	if self.m_Slots[slot] then
		self.m_Slots[slot]:setItem(inventoryId, item)
		return self.m_Slots[slot]
	end
	return false
end

function GUIItemSlotList:drawThis(incache)
	dxSetBlendMode("modulate_add")

	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX - 4, self.m_AbsoluteY - 4, self.m_Width + 8, self.m_Height + 8, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

	dxSetBlendMode("blend")
end

function GUIItemSlotList:setLineSpacing(lineSpacing)
	self.m_LineSpacing = lineSpacing
	return self
end

function GUIItemSlotList:setMultiline(multilineEnabled)
	self.m_Multiline = multilineEnabled
	return self
end

function GUIItemSlotList:setAlignX(alignX)
	self.m_AlignX = alignX
	return self
end

function GUIItemSlotList:setAlignY(alignY)
	self.m_AlignY = alignY
	return self
end

function GUIItemSlotList:setBackgroundColor(color)
	self.m_BackgroundColor = color
	return self
end

function GUIItemSlotList:getRotation()
	return self.m_Rotation
end

function GUIItemSlotList:setRotation(rot)
	self.m_Rotation = rot
	self:anyChange()
	return self
end

function GUIItemSlotList:setAlign(x, y)
	self.m_AlignX = x or self.m_AlignX
	self.m_AlignY = y or self.m_AlignY
	return self
end

function GUIItemSlotList:setClickable(state)
	if state then
		self:setColor(Color.Accent)
		self.onInternalHover = function()
			self:setColor(Color.White)
		end
		self.onInternalUnhover = function()
			self:setColor(Color.Accent)
		end
	else
		self:setColor(Color.White)
		self.onInternalHover = nil
		self.onInternalUnhover = nil
	end
	return self
end
