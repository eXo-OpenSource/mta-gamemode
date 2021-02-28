-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory - Class
-- *
-- ****************************************************************************
Inventory = inherit(Object)
Inventory.TemporaryCount = 0

function Inventory.createTemporary(slots, typeId)
	Inventory.TemporaryCount = Inventory.TemporaryCount - 1

	return Inventory:new(Inventory.TemporaryCount, Inventory.TemporaryCount, DbElementType.Temporary, slots, typeId)
end

function Inventory.createPermanent(elementId, elementType, slots, typeId)
	sql:queryExec("INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES (?, ?, ?, ?)", 
		sql:getPrefix(), elementId, elementType, slots, typeId)
	local inventoryId = sql:lastInsertId()

	return Inventory:new(inventoryId, elementId, elementType, slots, typeId)
end

function Inventory:constructor(inventoryId, elementId, elementType, slots, typeId)
	self.m_Id = inventoryId

	self.m_ElementId = elementId
	self.m_ElementType = elementType

	self.m_Slots = slots

	self.m_TypeId = typeId or 0
	self.m_Type = typeId and InventoryManager:getSingleton().m_InventoryTypes[typeId].TechnicalName or "Unknown"

	self.m_Items = {}

	self.m_Persistent = false
end

function Inventory:loadData(sync)
	local inventory

	if sync then
		inventory = sql:queryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), self.m_Id)
	else
		inventory = sql:asyncQueryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), self.m_Id)
	end

	if not inventory then
		return false
	end

	local items
	if sync then
		items = sql:queryFetch("SELECT i.*, IF(a.Name IS NULL, 'Unbekannt', a.Name) AS OwnerName FROM ??_inventory_items i LEFT JOIN ??_account a ON a.Id = i.OwnerId WHERE i.InventoryId = ?", sql:getPrefix(), sql:getPrefix(), inventory.Id)
	else
		items = sql:asyncQueryFetch("SELECT i.*, IF(a.Name IS NULL, 'Unbekannt', a.Name) AS OwnerName FROM ??_inventory_items i LEFT JOIN ??_account a ON a.Id = i.OwnerId WHERE i.InventoryId = ?", sql:getPrefix(), sql:getPrefix(), inventory.Id)
	end

	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Slots = inventory.Slots
	self.m_TypeId = inventory.TypeId
	self.m_Type = InventoryManager:getSingleton().m_InventoryTypes[inventory.TypeId].TechnicalName
	self.m_Persistent = true

	self.m_IsDirty = false
	self.m_DirtySince = 0

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
		if item.Metadata then
			item.Metadata = fromJSON(item.Metadata)
		end
	end
	self.m_Items = items

	if inventory.ItemSettings then
		self.m_ItemSettings = fromJSON(inventory.ItemSettings)
	end

	InventoryManager:getSingleton():syncInventory(self.m_Id)

	return true
end

function Inventory:destructor()
	self:save(true)
end

function Inventory:getPlayer()
	if self.m_ElementType == DbElementType.Player then
		return Player.getFromId(self.m_ElementId) or false
	end
	return false
end

function Inventory:getPlayerId()
	if self.m_ElementType == DbElementType.Player then
		return self.m_ElementId
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
function Inventory:giveItem(item, amount, data, setInSlot)
	return InventoryManager:getSingleton():giveItem(self, item, amount, data, setInSlot)
end

function Inventory:takeItem(itemId, amount, all)
	return InventoryManager:getSingleton():takeItem(self, itemId, amount, all)
end

function Inventory:useItem(id)
	return InventoryManager:getSingleton():useItem(self, id)
end

function Inventory:useItemSecondary(id)
	return InventoryManager:getSingleton():useItemSecondary(self, id)
end

function Inventory:onInventoryChanged()
	self.m_IsDirty = true

	if self.m_DirtySince == 0 then
		self.m_DirtySince = getTickCount()
	end

	InventoryManager:getSingleton():syncInventory(self.m_Id)
end

function Inventory:getItem(idOrName)
	for k, v in pairs(self.m_Items) do
		if (type(idOrName) == "number" and v.Id or v.TechnicalName) == idOrName then
			return v
		end
	end
	return false
end

function Inventory:getItemAmount(item)
	local amount = 0
	for k, v in pairs(self.m_Items) do
		if v.TechnicalName == item then
			amount = amount + v.Amount
		end
	end
	return amount
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
			return true, true
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
			return true, true
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

	-- Diese Funktion sollte von der Klasse, die das Inventar benötigt, überschrieben werden.

	return true
end

function Inventory:hasPlayerAccessToItem(player, item)
	-- Check, ob ein Spieler Zugriff auf ein bestimmtest Item im Inventar hat.

	-- Diese Funktion sollte von der Klasse, die das Inventar benötigt, überschrieben werden.

	return true
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

function Inventory:setItemSetting(item, setting, value)
	if not self.m_ItemSettings then self.m_ItemSettings = {} end
	if not self.m_ItemSettings[item] then self.m_ItemSettings[item] = {} end
	self.m_ItemSettings[item][setting] = value

	return true
end

function Inventory:getItemSetting(item, setting)
	if not self.m_ItemSettings then return false end
	if not self.m_ItemSettings[item] then return false end
	
	return self.m_ItemSettings[item][setting]
end

function Inventory:save(sync)
	if not self.m_IsDirty then
		return false
	end
	local inventory
	local items

	if sync then
		inventory = sql:queryFetch("SELECT * FROM ??_inventories WHERE Id = ?", sql:getPrefix(), self.m_Id)
		items = sql:queryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), self.m_Id)
	else
		inventory = sql:asyncQueryFetch("SELECT * FROM ??_inventories WHERE Id = ?", sql:getPrefix(), self.m_Id)
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
			if type(v.Metadata) == "table" and not equals(dbItem.Metadata and fromJSON(dbItem.Metadata), v.Metadata) then
				needsUpdate = true
				update.Metadata = toJSON(v.Metadata)
			end

			if needsUpdate then
				table.insert(changes.update, update)
			end

			dbItems[v.Id] = nil
		else
			table.insert(changes.insert, {
				Id = v.Id;
				ItemId = v.ItemId;
				OwnerId = v.OwnerId;
				Amount = v.Amount;
				Durability = v.Durability;
				Slot = v.Slot;
				Metadata = type(v.Metadata) == "table" and toJSON(v.Metadata);
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
			queries = queries .. "(?, ?, ?, ?, ?, ?, ?, ?, ?, "
			-- 1 - Id, 2 - InventoryId, 3 - ItemId, 4 - OwnerId, 5 - Tradeable, 6 - Slot, 7 - Amount, 8 - Durability, 9 - ExpireTime, 10 - Metadata

			table.insert(queriesParams, v.Id)				-- 1 - Id
			table.insert(queriesParams, self.m_Id)			-- 2 - InventoryId
			table.insert(queriesParams, v.ItemId)			-- 3 - ItemId
			table.insert(queriesParams, v.OwnerId)			-- 4 - OwnerId
			table.insert(queriesParams, v.Tradeable and 1 or 0)		-- 5 - Tradeable
			table.insert(queriesParams, v.Slot)				-- 6 - Slot
			table.insert(queriesParams, v.Amount)			-- 7 - Amount
			table.insert(queriesParams, v.Durability)		-- 8 - Durability
			table.insert(queriesParams, v.ExpireTime or 0)		-- 9 - ExpireTime

			if not v.Metadata then
				queries = queries .. "NULL)"
			else
				queries = queries .. "?)"
				table.insert(queriesParams, v.Metadata or nil)	-- 10 - Metadata
			end

			queries = queries .. " ON DUPLICATE KEY UPDATE InventoryId = ?, ItemId = ?, OwnerId = ?, Tradeable = ?, Slot = ?, Amount = ?, Durability = ?, ExpireTime = ?, "
			-- 2 - InventoryId = ?, 3 - ItemId = ?, 4 - OwnerId = ?, 5 - Tradeable = ?, 6 - Slot = ?, 7 - Amount = ?, 8 - Durability = ?, 9 - ExpireTime = ?

			table.insert(queriesParams, self.m_Id)			-- 2 - InventoryId
			table.insert(queriesParams, v.ItemId)			-- 3 - ItemId
			table.insert(queriesParams, v.OwnerId)			-- 4 - OwnerId
			table.insert(queriesParams, v.Tradeable and 1 or 0)		-- 5 - Tradeable
			table.insert(queriesParams, v.Slot)				-- 6 - Slot
			table.insert(queriesParams, v.Amount)			-- 7 - Amount
			table.insert(queriesParams, v.Durability)		-- 8 - Durability
			table.insert(queriesParams, v.ExpireTime or 0)		-- 9 - ExpireTime

			if not v.Metadata then
				queries = queries .. "Metadata = NULL"
			else
				queries = queries .. "Metadata = ?"
				table.insert(queriesParams, v.Metadata or nil)	-- 10 - Metadata
			end
			queries = queries .. ";"
		end
	end

	if inventory.ItemSettings then
		local query = ""

		if self.m_ItemSettings and table.size(self.m_ItemSettings) == 0 then
			query = "UPDATE ??_inventories SET ItemSettings = NULL WHERE Id = ?;"
			table.insert(queriesParams, sql:getPrefix())
			table.insert(queriesParams, self.m_Id)
		elseif not equals(fromJSON(inventory.ItemSettings), self.m_ItemSettings) then
			query = "UPDATE ??_inventories SET ItemSettings = ? WHERE Id = ?;"
			table.insert(queriesParams, sql:getPrefix())
			table.insert(queriesParams, toJSON(self.m_ItemSettings))
			table.insert(queriesParams, self.m_Id)
		end

		if queries ~= "" then queries = queries .. " " end
		queries = queries .. query

	elseif self.m_ItemSettings and table.size(self.m_ItemSettings) > 0 then
		local query = "UPDATE ??_inventories SET ItemSettings = ? WHERE Id = ?;"
		table.insert(queriesParams, sql:getPrefix())
		table.insert(queriesParams, toJSON(self.m_ItemSettings))
		table.insert(queriesParams, self.m_Id)

		if queries ~= "" then queries = queries .. " " end
		queries = queries .. query
	end
			

	if queries ~= "" then
		sql:queryExec(queries, unpack(queriesParams))
	end

	return true
end
