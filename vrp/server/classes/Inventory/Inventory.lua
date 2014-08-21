Inventory = inherit(Object)
Inventory.Map = {}

function Inventory:constructor(Id, items)
	self.m_Id = Id
	self.m_Items = items or {}
	self.m_InteractingPlayer = false
end

function Inventory:destructor()
	Inventory.Map[self.m_Id] = nil
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

function Inventory:save()
	local itemData = {}
	for slot, item in ipairs(self.m_Items) do
		itemData[slot] = {item.m_ItemId, item.m_Count}
	end
	
	sql:queryExec("UPDATE ??_inventory SET Items = ? WHERE Id = ?", sql:getPrefix(), toJSON(itemData), self.m_Id)
end

function Inventory:purge()
	sql:queryExec("DELETE FROM ??_inventory WHERE Id = ?", sql:getPrefix(), self.m_Id)
	delete(self)
end

function Inventory:addItem(itemId, amount)
	local itemInfo = Items[itemId]
	if not itemInfo then
		return false
	end

	if itemInfo.maxstack > 0 then
		local existingItem = self:findItem(itemId)
		if existingItem and existingItem.m_Count+amount < itemInfo.maxstack then
			existingItem:setCount(existingItem.m_Count + amount)
			return existingItem
		end
	end
	
	outputDebug("Itemclass: "..tostring(itemInfo.class))
	local itemObject = (itemInfo.class or Item):new(itemId, amount)
	table.insert(self.m_Items, itemObject)
	local slot = #self.m_Items
	
	if self.m_InteractingPlayer then
		self.m_InteractingPlayer:triggerEvent("inventoryAddItem", self.m_Id, slot, itemId, amount)
	end
	
	--self:sync({slot, itemId, amount})
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
	
	item:setCount(item:getCount() - amount)
	if item:getCount() < 0 then
		item:setCount(0)
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

--[[function Inventory:sync(info)
	if self.m_InteractingPlayer then
		self.m_InteractingPlayer:triggerEvent("inventorySync", info)
	end
end]]

function Inventory:setInteractingPlayer(player)
	self.m_InteractingPlayer = player
end

function Inventory:getInteractingPlayer()
	return self.m_InteractingPlayer
end

function Inventory:openFor(player)
	self:setInteractingPlayer(player)
	
	-- Todo (Priority: HIGH): Don't send all items always
	local data = {}
	for slot, item in ipairs(self.m_Items) do
		data[#data + 1] = {slot, item.m_ItemId, self.m_Count}
	end
	player:triggerEvent("inventoryOpen", self.m_Id, data)
end

function Inventory:closeFor(player)
	self:setInteractingPlayer(nil)
	
	player:triggerEvent("inventoryClose", self.m_Id)
end

addEvent("inventoryUseItem", true)
addEventHandler("inventoryUseItem", root,
	function(inventoryId, itemId, slot)
		local inventory = client:getInventory()
		if inventoryId then
			inventory = Inventory.Map[inventoryId]
			
			if inventory.m_InteractingPlayer ~= client then
				AntiCheat:getSingleton():report("Not allowed inventory change", CheatSeverity.Middle)
				return
			end
		end
		
		if not inventory then
			return
		end
		
		local item = inventory.m_Items[slot]
		if not item then return end
		if item:getItemId() ~= itemId then
			AntiCheat:getSingleton():report("Inventory desync", CheatSeverity.Low)
			return
		end
		
		if item.use then
			item:use(inventory, client)
		end
		client:triggerEvent("inventoryUseItem", inventory:getId(), itemId, slot)
	end
)
