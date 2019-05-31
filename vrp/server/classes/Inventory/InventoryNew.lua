-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryNew.lua
-- *  PURPOSE:     InventoryNew - Class
-- *
-- ****************************************************************************
InventoryNew = inherit(Object)

function InventoryNew.create()

end

function InventoryNew.load(inventoryId)
	local inventory = sql:asyncQueryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)

	if not inventory then
		return false
	end
	-- TODO: Rename _inventory_items2 TO _inventory_items
	local items = sql:asyncQueryFetch("SELECT ii.*, i.TechnicalName, i.CategoryId, i.Name, i.Description, i.Icon, i.Size, i.ModelId, i.MaxDurability, i.Consumable, i.Tradeable, i.Expireable, i.IsUnique FROM ??_inventory_items2 ii INNER JOIN ??_items i ON i.Id = ii.ItemId WHERE InventoryId = ?", sql:getPrefix(), sql:getPrefix(), inventory.Id)

	return InventoryNew:new(inventory, items, true)
end

function InventoryNew:constructor(inventory, items, persistent)
	self.m_Id = inventory.Id
	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Size = inventory.Size
	self.m_TypeId = inventory.TypeId
	self.m_Type = InventoryManagerNew:getSingleton().m_InventoryTypes[inventory.TypeId].TechnicalName
	self.m_Persistent = persistent

	self.m_IsDirty = false
	self.m_DirtySince = 0
	self.m_NextItemId = 1

	self.m_Items = items
	for _, item in pairs(items) do
		item.InternalId = self.m_NextItemId
		self.m_NextItemId = self.m_NextItemId + 1
	end
end

function InventoryNew:destructor()
	self:save()
end

function InventoryNew:save(force)
	if self.m_IsDirty then

	end
end

--[[
	Checks to do:
		* Does the item exists?
		* Is the item compatible with the inventory?
		* Has the inventory still enough space?
		* Is the item unique and is it already in the inventory?
]]
function InventoryNew:giveItem(item, value, durability, metadata)
	-- Does the item exist?
	if type(item) == "string" then
		item = InventoryManagerNew:getSingleton().m_ItemIdToName[item]
	end

	if not InventoryManagerNew:getSingleton().m_Items[item] then
		return false, "item"
	end

	local itemData = InventoryManagerNew:getSingleton().m_Items[item]

	local cSize = self:getCurrentSize()

	iprint(itemData)
	iprint(self)

	if value < 1 then
		return false, "value"
	end

	if self.m_Size < cSize + itemData.Size * value then
		return false, "size"
	end
	
	if not self:isCompatibleWithCategory(itemData.Category) then
		return false, "category"
	end

	if itemData.m_IsUnique then
		if v.ItemId == item then
			return false, "unique"
		end 
	end

	self.m_IsDirty = true

	if self.m_DirtySince == 0 then
		self.m_DirtySince = getTickCount()
	end
	-- metadata

	for k, v in pairs(self.m_Items) do
		if v.ItemId == item then
			if (v.Metadata and #v.Metadata > 0) or metadata or itemData.MaxDurability > 0 then
				iprint({v.Metadata, metadata, itemData.MaxDurability})
			else
				v.Value = v.Value + value
				return true
			end
		end 
	end

	local internalId = self.m_NextItemId
	self.m_NextItemId = self.m_NextItemId + 1

	local data = {
		Id = -1,
		InternalId = internalId,
		ItemId = item,
		Value = value,
		Durability = durability,
		Metadata = metadata
	}

	for k, v in pairs(itemData) do
		if k ~= "Id" then
			data[k] = v
		end
	end

	table.insert(self.m_Items, data)
end

function InventoryNew:takeItem(id, value)
	
	if value < 1 then
		return false, "value"
	end

	local item = self:getItem(id)

	if not item then
		return false, "invalid"
	end

	local itemData = InventoryManagerNew:getSingleton().m_Items[item.ItemId]

	if not itemData then
		outputDebugString("[INVENTORY]: Invalid itemId " .. tostring(item.ItemId) .. " @ Inventory@takeItem", 1)
		return false, "invalid"
	end

	if item.Value < value then
		return false, "value"
	end
	
	self.m_IsDirty = true

	if self.m_DirtySince == 0 then
		self.m_DirtySince = getTickCount()
	end

	item.Value = item.Value - value

	if item.Value == 0 then
		table.remove(self.m_Items, k)
		return true, true
	end

	return true, false
end

function InventoryNew:useItem(id)
	local item = self:getItem(id)

	if not item then
		return false, "invalid"
	end

	local itemData = InventoryManagerNew:getSingleton().m_Items[item.ItemId]

	if not itemData then
		outputDebugString("[INVENTORY]: Invalid itemId " .. tostring(item.ItemId) .. " @ Inventory@takeItem", 1)
		return false, "invalid"
	end

	if itemData.Category == "food" then
		
	end
end

function InventoryNew:getItem(id)
	for k, v in pairs(self.m_Items) do
		if v.InternalId == id then
			return v
		end 
	end
	return false
end

function InventoryNew:hasPlayerAccessTo(player)
	-- Typbasierte Checks, bspw.:
	--  Fraktion: ist der Spieler OnDuty in der Besitzerfraktion
	--  Kofferrraum: hat Spieler einen Schlüssel für das Fahrzeug / ist CopDuty
	--  Haus: ist der Spieler Mieter / Besitzer des Hauses
end

function InventoryNew:isCompatibleWithCategory(category)
	local iType = InventoryManagerNew:getSingleton().m_InventoryTypes[self.m_TypeId]

	for _, c in pairs(iType.Categories) do
		if c.TechnicalName == category then
			return true
		end
	end

	return false
end

function InventoryNew:getCurrentSize()
	local size = 0

	for k, v in pairs(self.m_Items) do
		size = size + v.Size * v.Value
	end

	return size
end
