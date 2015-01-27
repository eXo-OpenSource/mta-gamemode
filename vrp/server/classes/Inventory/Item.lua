Item = inherit(Object)

function Item:constructor(itemId, count)
	Item.virtual_constructor(self, itemId, count)
end

function Item:virtual_constructor(itemId, count)
	self.m_ItemId = itemId
	self.m_Count = count or 1
end

function Item:getItemId()
	return self.m_ItemId
end

function Item:getCount()
	return self.m_Count
end

function Item:setCount(count)
	self.m_Count = count
end

function Item:use()
end

function Item:getModelId()
	return Items[self.m_ItemId].modelId ~= 0 and Items[self.m_ItemId].modelId or 2969
end
