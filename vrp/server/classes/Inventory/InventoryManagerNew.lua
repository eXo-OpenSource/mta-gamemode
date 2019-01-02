-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryManagerNew.lua
-- *  PURPOSE:     InventoryManagerNew Class
-- *
-- ****************************************************************************
InventoryManagerNew = inherit(Singleton)

InventoryTypes = {
	Player = 1;
	Faction = 2;
	Company = 3;
	GroupProperty = 4;
	VehicleTrunk = 5;
}

InventoryTemplates = {
	Player = {
		"consumables",
		"weapons..."
	};
	Faction = 2;
	Company = 3;
	GroupProperty = 4;
	VehicleTrunk = 5;
}

function InventoryManagerNew:constructor()
	self.m_Items = {}
	self.m_ItemIdToName = {}
	self:loadItems()
end

function InventoryManagerNew:loadItems()
	local result = sql:queryFetch("SELECT i.*, c.Name AS Category FROM ??_items i INNER JOIN ??_item_categories c ON c.Id = i.CategoryId", sql:getPrefix(), sql:getPrefix())
	self.m_Items = {}
	self.m_ItemIdToName = {}

	for _, row in ipairs(result) do
		self.m_Items[row.Id] = {
			Id = row.Id;
			TechnicalName = row.TechnicalName;
			CategoryId = row.CategoryId;
			Category = row.Category;
			Name = row.Name;
			Description = row.Description;
			Icon = row.Icon;
			ModelId = row.ModelId;
			MaxDurability = row.MaxDurability;
			Consumable = row.Consumable == 1;
			Tradeable = row.Tradeable == 1;
			Expireable = row.Expireable == 1;
			IsUnique = row.IsUnique == 1;
		}

		self.m_ItemIdToName[row.TechnicalName] = row.Id
	end
end

function InventoryManagerNew:createInventory(elementId, elementType, size, allowedCategories)
	local inventory = InventoryNew.create(elementId, elementType, size, allowedCategories)

	self.m_Inventories[inventory.Id] = inventory

    return inventory
end

function InventoryManagerNew:getInventory(inventoryIdOrElementType, elementId)
	local inventoryId = inventoryIdOrElementType
	local elementType = inventoryId

	if elementId then
		-- get the damn id :P
		-- is inventory already loaded?
		for id, inventory in pairs(self.m_Inventories) do
			if inventory.m_ElementId == elementId and inventory.m_ElementType == elementType then
				return inventory
			end
		end

		local result = sql:queryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)

		if not result then
			return false
		end

		inventoryId = result.Id
	end

    return self.m_Inventories[inventoryId] and self.m_Inventories[inventoryId] or self:loadInventory(inventoryId)
end

function InventoryManagerNew:loadInventory(inventoryId)
	local inventory = InventoryNew.load(inventoryId)

	if inventory then
		self.m_Inventories[inventoryId] = inventory
		return inventory
	end

	return false
end

function InventoryManagerNew:unloadInventory(inventoryId)
    save()
    unload()
end

function InventoryManagerNew:deleteInventory(inventoryId)
    unload()
    delete()
end

function InventoryManagerNew:isItemGivable(inventoryId, itemId, amount)
    checkIfCategoryAllowed()
    checkIfSpace()
end

function InventoryManagerNew:isItemRemovable(int Uid, int itemId, int amount)
    checkIfCategoryAllowed()
    checkIfSpace()
end

function InventoryManagerNew:removeItem()
    if self:isItemRemovable() then
        remove()
        return true
    end
    return false
end

function InventoryManagerNew:giveItem()
    if self:isItemGivable() then
        give()
        return true
    end
    return false
end

function InventoryManagerNew:transactItem(int givingInventoryUId, int recievingInventoryUid, int itemId, int amount, [string value])
    if self:isItemRemovable() and self:isItemGivable() then
        self:removeItem()
        self:giveItem()
        return true
    else
        return self:isItemRemovable(), self:isItemGivable()
    end
end
