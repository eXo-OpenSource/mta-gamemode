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

function Inventory.load(inventoryId, player, sync)
	local inventory

	if sync then
		inventory = sql:queryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)
	else
		inventory = sql:asyncQueryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)
	end

	if not inventory then
		return false
	end

	local items
	if sync then
		items = sql:queryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), inventory.Id)
	else
		items = sql:asyncQueryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), inventory.Id)
	end

	return Inventory:new(inventory, items, true, player)
end

function Inventory:constructor(inventory, items, persistent, player)
	self.m_Id = inventory.Id
	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Size = inventory.Size
	self.m_Slots = inventory.Slots
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
				if k == "Tradeable" then
					if item[k] == 1 and v == 0 then
						item[k] = v
					end
				else
					item[k] = v
				end
			end
		end
		--item.DatabaseId = item.Id
		--item.Id = self.m_NextItemId
		--self.m_NextItemId = self.m_NextItemId + 1
	end
end

function Inventory:destructor()
	self:save(true)
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

function Inventory:takeItem(itemId, amount, all)
	return InventoryManager:getSingleton():takeItem(self, itemId, amount, all)
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

	InventoryManager:getSingleton():syncInventory(self.m_Id)
end

function Inventory:getItem(id)
	for k, v in pairs(self.m_Items) do
		if v.Id == id then
			return v
		end
	end
	return false
end

function Inventory:getItemFromSlot(slot)
	for k, v in pairs(self.m_Items) do
		if v.Slot == slot then
			return v
		end
	end
	return false
end

function Inventory:getItemDurability(id)
	local item = self:getItem(id)
	if not item then return false end

	return item.Durability
end

function Inventory:getItemMaxDurability(id)
	local item = self:getItem(id)
	if not item then return false end

	return item.MaxDurability
end

function Inventory:setItemDurability(id, durability)
	local durability = tonumber(durability)
	if durability < 0 then return false end

	local item = self:getItem(id)
	if not item then return false end

	if durability > item.MaxDurability then
		item.Durability = item.MaxDurability
	else
		if durability == 0 and item.DurabilityDestroy then
			self:takeItem(id, 1)
			return true
		else
			item.Durability = durability
		end
	end
	self:onInventoryChanged()
	return true
end

function Inventory:increaseItemDurability(id, durability)
	local durability = tonumber(durability) or 1
	if durability < 1 then return false end
	local item = self:getItem(id)
	if not item then return false end

	local newDurability = item.Durability + durability

	if newDurability > item.MaxDurability then
		item.Durability = item.MaxDurability
	else
		item.Durability = newDurability
	end

	self:onInventoryChanged()
	return true
end

function Inventory:decreaseItemDurability(id, durability)
	local durability = tonumber(durability) or 1
	if durability < 1 then return false end
	local item = self:getItem(id)
	if not item then return false end

	local newDurability = item.Durability - durability

	if newDurability < 1 then
		if item.DurabilityDestroy then
			self:takeItem(id, 1)
			return true
		else
			item.Durability = 0
		end
	else
		item.Durability = newDurability
	end

	self:onInventoryChanged()
	return true
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

function Inventory:save(sync)
	if not self.m_IsDirty then
		return false
	end
	local items

	if sync then
		items = sql:queryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), self.m_Id)
	else
		items = sql:asyncQueryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), self.m_Id)
	end
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

			-- Check OwnerId
			if dbItem.OwnerId ~= v.OwnerId then
				needsUpdate = true
				update.OwnerId = v.OwnerId
			end

			-- Check Tradeable
			if dbItem.Tradeable ~= v.Tradeable then
				needsUpdate = true
				update.Tradeable = v.Tradeable
			end

			-- Check ExpireTime
			if dbItem.ExpireTime ~= v.ExpireTime then
				needsUpdate = true
				update.ExpireTime = v.ExpireTime
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
			table.insert(changes.insert, {
				Id = v.Id;
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

		if v.OwnerId then
			if params ~= "" then params = params .. ", " end
			params = params .. "OwnerId = ?"
			table.insert(queriesParams, v.OwnerId)
		end

		if v.Tradeable then
			if params ~= "" then params = params .. ", " end
			params = params .. "Tradeable = ?"
			table.insert(queriesParams, v.Tradeable)
		end

		if v.ExpireTime then
			if params ~= "" then params = params .. ", " end
			params = params .. "ExpireTime = ?"
			table.insert(queriesParams, v.ExpireTime)
		end

		query = query .. params .. " WHERE Id = ?;"
		table.insert(queriesParams, v.Id)

		if queries ~= "" then queries = queries .. " " end
		queries = queries .. query
	end

	if #changes.remove > 0 then
		if queries ~= "" then queries = queries .. " " end
		queries = queries .. "DELETE FROM ??_inventory_items WHERE Id IN (?" .. string.rep(", ?", #changes.remove - 1) .. ");"
		table.insert(queriesParams, sql:getPrefix())
		for k, v in pairs(changes.remove) do
			table.insert(queriesParams, v.Id)
		end
	end

	if #changes.insert > 0 then
		if queries ~= "" then queries = queries .. " " end
		for k, v in pairs(changes.insert) do
			queries = queries .. "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Tradeable, Slot, Amount, Durability, ExpireTime, Metadata) VALUES "
			table.insert(queriesParams, sql:getPrefix())
			queries = queries .. "(?, ?, ?, ?, ?, ?, "

			table.insert(queriesParams, v.Id)				-- 1 - Id
			table.insert(queriesParams, self.m_Id)			-- 2 - InventoryId
			table.insert(queriesParams, v.ItemId)			-- 3 - ItemId
			table.insert(queriesParams, v.OwnerId)			-- 4 - OwnerId
			table.insert(queriesParams, v.Tradeable)		-- 5 - Tradeable
			table.insert(queriesParams, v.Slot)				-- 6 - Slot
			table.insert(queriesParams, v.Amount)			-- 7 - Amount
			table.insert(queriesParams, v.Durability)		-- 8 - Durability
			table.insert(queriesParams, v.ExpireTime)		-- 9 - ExpireTime
			if not v.Metadata then
				queries = queries .. "NULL) ON DUPLICATE KEY UPDATE InventoryId = ?, ItemId = ?, OwnerId = ?, Tradeable = ?, Slot = ?, Amount = ?, Durability = ?, ExpireTime = ?, Metadata = NULL;"
			else
				queries = queries .. "?) ON DUPLICATE KEY UPDATE InventoryId = ?, ItemId = ?, OwnerId = ?, Tradeable = ?, Slot = ?, Amount = ?, Durability = ?, ExpireTime = ?, Metadata = ?;"
				table.insert(queriesParams, v.Metadata or nil)	-- 7 - Metadata
			end

			table.insert(queriesParams, self.m_Id)			-- 2 - InventoryId
			table.insert(queriesParams, v.ItemId)			-- 3 - ItemId
			table.insert(queriesParams, v.OwnerId)			-- 4 - OwnerId
			table.insert(queriesParams, v.Tradeable)		-- 5 - Tradeable
			table.insert(queriesParams, v.Slot)				-- 6 - Slot
			table.insert(queriesParams, v.Amount)			-- 7 - Amount
			table.insert(queriesParams, v.Durability)		-- 8 - Durability
			table.insert(queriesParams, v.ExpireTime)		-- 9 - ExpireTime
		end
		queries = queries .. ";"
	end

	if queries ~= "" then
		sql:queryExec(queries, unpack(queriesParams))
	end

	return true
end
