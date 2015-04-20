-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory.lua
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
	for slot, info in pairs(itemData) do
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
	for slot, item in pairs(self.m_Items) do
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

	if itemInfo.stackable then
		local existingItem = self:findItem(itemId)
		if existingItem then
			existingItem:setCount(existingItem.m_Count + amount)
			return existingItem
		end
	end

	local itemObject = (itemInfo.class or Item):new(itemId, amount)
	self:addItemByItem(itemObject)
	return itemObject
end

function Inventory:addItemByItem(item)
	local slot = #self.m_Items + 1
	self.m_Items[slot] = item

	if self.m_InteractingPlayer then
		self.m_InteractingPlayer:triggerEvent("inventoryAddItem", self.m_Id, slot, item:getItemId(), item:getCount())
	end
end

function Inventory:removeItem(slot, amount)
	local item = self.m_Items[slot]
	if not item then
		return false
	end

	if not amount then
		self.m_Items[slot] = nil
		delete(item)
		return true
	end

	local newCount = item:getCount() - amount
	item:setCount(newCount)
	if newCount <= 0 then
		self.m_Items[slot] = nil
	end

	if self.m_InteractingPlayer then
		self.m_InteractingPlayer:triggerEvent("inventoryRemoveItem", self.m_Id, slot, item:getItemId(), amount)
	end

	delete(item)
	return true
end

function Inventory:removeItemByItem(item, slot, amount)
	return self:removeItem(slot, amount or item:getCount())
end

function Inventory:removeItemByItemId(itemId, amount)
	local item, slot = self:findItem(itemId)
	if not item then return end

	-- We cannot have multiple stacks, so returning here is okay
	if amount and item:getCount() < amount then
		return false
	end

	return self:removeItemByItem(item, slot, amount)
end

function Inventory:placeItem(item, slot, owner, pos, rotation, amount)
	-- We need to duplicate the item if the amount does not match the available amount of items
	local newItem = item
	if not amount or amount ~= item:getCount() then
		newItem = item:copy()
		newItem:setCount(amount or item:getCount())
	end

	local worldItem = WorldItem:new(newItem, owner, pos, rotation)
	self:removeItemByItem(item, slot, amount)
	return worldItem
end

function Inventory:findItem(itemId)
	for slot, item in pairs(self.m_Items) do
		if item.m_ItemId == itemId then
			return item, slot
		end
	end
	return false
end

function Inventory:hasItem(itemId)
	return self:findItem(itemId) ~= false
end

function Inventory:findAllItems(itemId)
	local result = {}
	for slot, item in pairs(self.m_Items) do
		if item.m_ItemId == itemId then
			result[#result + 1] = item
		end
	end
	return result
end

function Inventory:getItems()
	return self.m_Items
end

function Inventory:getItem(slot)
	return self.m_Items[slot]
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
		if item:use(self, client, slot) == false then
			return false
		end
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
	for slot, item in pairs(self.m_Items) do
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
			AntiCheat:getSingleton():report(client, "Inventory desync #1", CheatSeverity.Low)
			return
		end

		inventory:useItem(item, client, slot)
	end
)

addEvent("inventoryDropItem", true)
addEventHandler("inventoryDropItem", root,
	function(inventoryId, itemId, slot, amount)
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
			AntiCheat:getSingleton():report(client, "Inventory desync #2", CheatSeverity.Low)
			return
		end

		if amount > item:getCount() then -- TODO: Fix cheatlog (sql table)
			AntiCheat:getSingleton():report(client, "Tried to drop not existing items", CheatSeverity.Low)
			return
		end

		inventory:removeItemByItem(item, slot, amount)
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

addEvent("tradeItemAdd", true)
addEventHandler("tradeItemAdd", root,
	function(itemId, amount, slot)
		local inv = client:getInventory()
		if not inv then return end

		local tradingPartner = client:getTradingPartner()
		if not tradingPartner then return end

		local item = inv:getItem(slot)
		if item:getItemId() ~= itemId then
			AntiCheat:getSingleton():report(client, "Inventory desync #3", CheatSeverity.Low)
			return
		end

		-- TODO: Implement stacking
		client.m_TradeItems[#client.m_TradeItems + 1] = {itemId, amount}
		tradingPartner:triggerEvent("tradeItemUpdate", client.m_TradeItems)
	end
)

addEvent("tradeItemRemove", true)
addEventHandler("tradeItemRemove", root,
	function(itemId, amount)
		local inv = client:getInventory()
		if not inv then return end

		local tradingPartner = client:getTradingPartner()
		if not tradingPartner then return end

		-- TODO: Implement stacking
		for k, item in pairs(client.m_TradeItems) do
			if item[1] == itemId then
				if not amount or amount >= item[2] then
					client.m_TradeItems[k] = nil
				else
					client.m_TradeItems[k][2] = item[2] - amount
				end
				break
			end
		end

		tradingPartner:triggerEvent("tradeItemUpdate", client.m_TradeItems)
	end
)

addEvent("tradeMoneyChange", true)
addEventHandler("tradeMoneyChange", root,
	function(money)
		local tradingPartner = client:getTradingPartner()
		if not tradingPartner then return end

		client.m_TradeMoney = money
		tradingPartner:triggerEvent("tradeMoneyChange", money)
	end
)

addEvent("tradeAcceptStatusChange", true)
addEventHandler("tradeAcceptStatusChange", root,
	function(state)
		client.m_TradingStatus = state

		local tradingPartner = client:getTradingPartner()
		if not tradingPartner then return end

		-- Are we ready to perform the trade?
		if state and tradingPartner.m_TradingStatus then
			-- Transfer client's trade items to tradingPartner
			for k, item in pairs(client.m_TradeItems) do
				local itemId, amount = unpack(item)
				if tradingPartner:removeItemByItemId(itemId, amount) then
					client:getInventory():addItem(itemId, amount)
				end
			end

			-- Vice versa
			-- Transfer client's trade items to tradingPartner
			for k, item in pairs(tradingPartner.m_TradeItems) do
				local itemId, amount = unpack(item)
				if client:removeItemByItemId(itemId, amount) then
					tradePartner:getInventory():addItem(itemId, amount)
				end
			end
		end
	end
)
