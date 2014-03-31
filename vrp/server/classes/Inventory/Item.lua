Item = inherit(Object)

function Item:constructor(itemId, amount)
	Item.derived_constructor(self, itemId, amount)
end

function Item:derived_constructor(itemId, amount)
	self.m_ItemId = itemId
	self.m_Amount = amount
end

function Item:getAmount()
	return self.m_Amount
end

function Item:setAmount(amount)
	self.m_Amount = amount
end

function Item:use()
end
