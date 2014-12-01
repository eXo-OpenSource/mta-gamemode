-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InventoryGUI.lua
-- *  PURPOSE:     Inventory GUI class
-- *
-- ****************************************************************************
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

	amount = amount or 1
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
	
	-- Todo: Call destructor
	if not amount then
		table.remove(self.m_Items, slot)
		return true
	end
	
	item:setCount(item:getCount() - amount)
	if item:getCount() <= 0 then
		table.remove(self.m_Items, slot)
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

function Inventory:setInteractingPlayer(player)
	if self.m_InteractingPlayer and self.m_InteractingPlayer ~= player then
		self:unloadOnClient()
	end
	self.m_InteractingPlayer = player
end

function Inventory:getInteractingPlayer()
	return self.m_InteractingPlayer
end

function Inventory:openFor(player)
	self:setInteractingPlayer(player)
	
	player:triggerEvent("inventoryOpen", self.m_Id)
end

function Inventory:closeFor(player)
	self:setInteractingPlayer(nil)
	
	player:triggerEvent("inventoryClose", self.m_Id)
end

function Inventory:useItem(item, player, slot)
	local itemInfo = Items[item:getItemId()]
	if not itemInfo then
		return false
	end
	
	-- Possible issue: If Item:use fails, the item will never get removed
	if item.use then
		item:use(self, client)
	end
	
	-- Tell the client that we started using the item
	player:triggerEvent("inventoryUseItem", self:getId(), itemId, slot)
	
	if itemInfo.removeAfterUsage then
		self:removeItem(slot, 1)
	end
end

function Inventory:sendFullSync()
	if not self.m_InteractingPlayer then return end

	local data = {}
	for slot, item in ipairs(self.m_Items) do
		data[#data + 1] = {slot, item.m_ItemId, item.m_Count}
	end
	
	self.m_InteractingPlayer:triggerEvent("inventoryReceiveFullSync", self.m_Id, data)
end

function Inventory:unloadOnClient()
	if self.m_InteractingPlayer then
		self.m_InteractingPlayer:triggerEvent("inventoryUnload")
	end
end

addEvent("inventoryUseItem", true)
addEventHandler("inventoryUseItem", root,
	function(inventoryId, itemId, slot)
		local inventory = client:getInventory()
		if inventoryId then
			inventory = Inventory.Map[inventoryId]
			
			if inventory.m_InteractingPlayer ~= client then
				AntiCheat:getSingleton():report(client, "Not allowed inventory change", CheatSeverity.Middle)
				return
			end
		end
		
		if not inventory then
			return
		end
		
		local item = inventory.m_Items[slot]
		if not item then return end
		if item:getItemId() ~= itemId then
			AntiCheat:getSingleton():report(client, "Inventory desync", CheatSeverity.Low)
			return
		end
		
		inventory:useItem(item, client, slot)
	end
)

addEvent("inventoryRequestFullSync", true)
addEventHandler("inventoryRequestFullSync", root,
	function(inventoryId)
		local inv
		if inventoryId then
			inv = Inventory.Map[inventoryId]
		end
		if not inv or inv:getInteractingPlayer() ~= client then
			-- Todo: Report @ AC
			return
		end
		
		inv:sendFullSync()
	end
)
