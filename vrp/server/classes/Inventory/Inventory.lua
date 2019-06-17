-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory - Class
-- *
-- ****************************************************************************
Inventory = inherit(Object)

function Inventory.create()

end

function Inventory.load(inventoryId, player)
	local inventory = sql:asyncQueryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)

	if not inventory then
		return false
	end
	local items = sql:asyncQueryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), inventory.Id)

	return Inventory:new(inventory, items, true, player)
end

function Inventory:constructor(inventory, items, persistent, player)
	self.m_Id = inventory.Id
	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Size = inventory.Size
	self.m_TypeId = inventory.TypeId
	self.m_Type = InventoryManager:getSingleton().m_InventoryTypes[inventory.TypeId].TechnicalName
	self.m_Persistent = persistent
	self.m_Player = player

	self.m_IsDirty = false
	self.m_DirtySince = 0
	self.m_NextItemId = 1

	self.m_Items = items
	for _, item in pairs(items) do
		local itemData = ItemManager.get(item.ItemId)
		for k, v in pairs(itemData) do
			if not item[k] then
				item[k] = v
			end
		end

		item.InternalId = self.m_NextItemId
		self.m_NextItemId = self.m_NextItemId + 1
	end
end

function Inventory:destructor()
	self:save()
end

function Inventory:save(force)
	if self.m_IsDirty then

	end
end

function Inventory:getPlayer()
	if self.m_Player and isElement(self.m_Player)then
		return self.m_Player
	end
	return false
end
--[[
	Checks to do:
		* Does the item exists?
		* Is the item compatible with the inventory?
		* Has the inventory still enough space?
		* Is the item unique and is it already in the inventory?
]]
function Inventory:giveItem(item, amount, durability, metadata)
	return InventoryManager:getSingleton():giveItem(self, item, amount, durability, metadata)
end

function Inventory:takeItem(itemInternalId, amount)
	return InventoryManager:getSingleton():takeItem(self, itemInternalId, amount)
end

function Inventory:useItem(id)
	return InventoryManager:getSingleton():useItem(self, id)
end

function Inventory:useItemSecondary(id)
	return InventoryManager:getSingleton():useItem(self, id)
end

function Inventory:onInventoryChanged()
	self.m_IsDirty = true

	if self.m_DirtySince == 0 then
		self.m_DirtySince = getTickCount()
	end

	if self.m_Player and isElement(self.m_Player) then
		InventoryManager:getSingleton():syncInventory(self.m_Player)
	end
end

function Inventory:getItem(id)
	for k, v in pairs(self.m_Items) do
		if v.InternalId == id then
			return v
		end
	end
	return false
end

function Inventory:hasPlayerAccessTo(player)
	-- Typbasierte Checks, bspw.:
	--  Fraktion: ist der Spieler OnDuty in der Besitzerfraktion
	--  Kofferrraum: hat Spieler einen Schlüssel für das Fahrzeug / ist CopDuty
	--  Haus: ist der Spieler Mieter / Besitzer des Hauses
end

function Inventory:isCompatibleWithCategory(category)
	local iType = InventoryManager:getSingleton().m_InventoryTypes[self.m_TypeId]

	for _, c in pairs(iType.Categories) do
		if c.TechnicalName == category then
			return true
		end
	end

	return false
end

function Inventory:getCurrentSize()
	local size = 0

	for k, v in pairs(self.m_Items) do
		size = size + v.Size * v.Amount
	end

	return size
end

function Inventory:save()
	if not self.m_IsDirty then
		return false
	end
	local items = sql:asyncQueryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), self.m_Id)
	local changes = {
		insert = {},
		remove = {},
		update = {}
	}

	local dbItems = {}
	for k, v in pairs(items) do
		dbItems[v.Id] = v
	end

	for k, v in pairs(self.m_Items) do
		if v.Id and v.Id ~= -1 then
			if dbItems[v.Id] then
				local dbItem = dbItems[v.Id]
				local needsUpdate = false
				local update = {
					Id = v.Id;
				}

				-- Check amount
				if dbItem.Amount ~= v.Amount then
					needsUpdate = true
					update.Amount = v.Amount
				end

				-- Check durability
				if dbItem.Durability ~= v.Durability then
					needsUpdate = true
					update.Durability = v.Durability
				end

				-- Check slot
				if dbItem.Slot ~= v.Slot then
					needsUpdate = true
					update.Slot = v.Slot
				end

				-- Check metadata
				if dbItem.Metadata ~= v.Metadata then
					needsUpdate = true
					update.Metadata = v.Metadata
				end

				if needsUpdate then
					table.insert(changes.update, update)
				end

				dbItems[v.Id] = nil
			else
				outputDebugString("[INVENTORY]: Item has been deleted from db but still exists ingame!")
			end
		else
			table.insert(changes.insert, {
				InternalId = v.InternalId;
				ItemId = v.ItemId;
				Amount = v.Amount;
				Durability = v.Durability;
				Slot = v.Slot;
				Metadata = v.Metadata;
			})
		end
	end

	for k, v in pairs(dbItems) do
		if v then
			table.insert(changes.remove, {
				Id = k;
			})
		end
	end

	self.m_IsDirty = false

	local queries = ""
	local queriesParams = {}

	for k, v in pairs(changes.update) do
		local query = "UPDATE ??_inventory_items SET "
		table.insert(queriesParams, sql:getPrefix())

		local params = ""

		if v.Amount then
			if params ~= "" then params = params .. ", " end
			params = params .. "Amount = ?"
			table.insert(queriesParams, v.Amount)
		end

		if v.Durability then
			if params ~= "" then params = params .. ", " end
			params = params .. "Durability = ?"
			table.insert(queriesParams, v.Durability)
		end

		if v.Slot then
			if params ~= "" then params = params .. ", " end
			params = params .. "Slot = ?"
			table.insert(queriesParams, v.Slot)
		end

		if v.Metadata then
			if params ~= "" then params = params .. ", " end
			params = params .. "Metadata = ?"
			table.insert(queriesParams, v.Metadata)
		end

		query = query .. params .. " WHERE Id = ?;"
		table.insert(queriesParams, v.Id)

		if queries ~= "" then queries = queries .. " " end
		queries = queries .. query
	end

	if #changes.remove > 0 then
		if queries ~= "" then queries = queries .. " " end
		queries = queries .. "DELETE FROM ??_inventory_items WHERE Id IN (?" .. string.rep(", ?", #changes.remove - 1) .. ")"
		table.insert(queriesParams, sql:getPrefix())
		for k, v in pairs(changes.remove) do
			table.insert(queriesParams, v.Id)
		end
	end

	sql:queryExec(queries, unpack(queriesParams))

	for k, v in pairs(changes.insert) do
		sql:queryExec("INSERT INTO ??_inventory_items (InventoryId, ItemId, Slot, Amount, Durability, Metadata) VALUES (?, ?, ?, ?, ?, ?)",
			sql:getPrefix(), self.m_Id, v.ItemId, v.Slot, v.Amount, v.Durability, v.Metadata or nil)
		local id = sql:lastInsertId()
		for _, i in pairs(self.m_Items) do
			if v.InternalId == i.InternalId then
				i.Id = id
				break
			end
		end
	end

	return true
end
