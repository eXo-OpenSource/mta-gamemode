Item = inherit(Object)

function Item:constructor(itemId, count, slot)
	Item.virtual_constructor(self, itemId, count)
end

function Item:virtual_constructor(itemId, count, slot)
	self.m_ItemId = itemId
	self.m_Count = count or 1
	self.m_Slot = slot
end

function Item:getItemId()
	return self.m_ItemId
end

function Item:getCount()
	return self.m_Count
end

function Item:getSlot()
	return self.m_Slot
end

function Item:use()
end
