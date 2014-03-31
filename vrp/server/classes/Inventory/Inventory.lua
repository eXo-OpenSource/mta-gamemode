Inventory = inherit(Object)
Inventory.Map = {}

function Inventory:constructor(Id, items)
	self.m_Id = Id
	self.m_Items = items or {}
end

function Inventory.create()
	local inventory = Inventory:new()
	sql:queryExec("INSERT INTO ??_inventory (Items) VALUES(?)", sql:getPrefix(), toJSON(inventory.m_Items))
	inventory.m_Id = sql:lastInsertId()
	Inventory.Map[inventory.m_Id] = inventory
	
	return inventory
end

function Inventory.loadById(Id)
	local row = sql:queryFetchSingle("SELECT Id, Items FROM ??_inventory WHERE Id = ?", sql:getPrefix(), Id)
	if not row then
		return false
	end
	
	local itemData = fromJSON(row.Items)
	local items = {}
	for slot, info in ipairs(itemData) do
		items[slot] = (Items[info[1]].class or Item):new(info[1], info[2])
	end
	
	local inv = Inventory:new(tonumber(row.Id), items)
	Inventory.Map[inv.m_Id] = inv
	return inv
end

function Inventory.getById(Id)
	return Inventory.Map[Id]
end

function Inventory:getId()
	return self.m_Id
end

function Inventory:unload()
	Inventory.Map[self.m_Id] = nil
	delete(self)
end

function Inventory:save()
	local itemData = {}
	for slot, item in ipairs(self.m_Items) do
		itemData[slot] = {item.m_ItemId, item.m_Amount}
	end
	
	sql:queryExec("UPDATE ??_inventory SET Items = ? WHERE Id = ?", sql:getPrefix(), toJSON(itemData), self.m_Id)
end

function Inventory:purge()
	sql:queryExec("DELETE FROM ??_inventory WHERE Id = ?", sql:getPrefix(), self.m_Id)
	self:unload()
end

function Inventory:addItem(itemId, amount)
	local itemInfo = Items[itemId]
	if not itemInfo then
		return false
	end

	if itemInfo.maxstack > 0 then
		local existingItem = self:findItem(itemId)
		if existingItem and existingItem.m_Amount+amount < itemInfo.maxstack then
			existingItem:setAmount(existingItem.m_Amount + amount)
			return existingItem
		end
	end
	
	local itemObject = (itemInfo.class or Item):new(itemId, amount)
	table.insert(self.m_Items, itemObject)
	return itemObject
end

function Inventory:removeItem(slot, amount)
	local item = self.m_Items[slot]
	if not item then
		return false
	end
	
	if not amount then
		table.remove(self.m_Items, slot)
		return true
	end
	
	item:setAmount(item:getAmount() - amount)
	if item:getAmount() < 0 then
		item:setAmount(0)
	end
	return true
end

function Inventory:findItem(itemId)
	for slot, item in ipairs(self.m_Items) do
		if item.m_ItemId == itemId then
			return item
		end
	end
	return false
end

function Inventory:hasItem(itemId)
	return self:findItem(itemId) ~= false
end

function Inventory:findAllItems(itemId)
	local result = {}
	for slot, item in ipairs(self.m_Items) do
		if item.m_ItemId == itemId then
			table.insert(result, item)
		end
	end
	return result
end

function Inventory:getItems()
	return self.m_Items
end
