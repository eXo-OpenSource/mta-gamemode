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

	player = 1;
	faction = 2;
	company = 3;
	group_property = 4;
	vehicle_trunk = 5;
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
	self.m_Categories = {}
	self.m_CategoryIdToName = {}
	self.m_InventoryTypes = {}
	self.m_InventoryTypesIdToName = {}
	self:loadItems()
	self:loadCategories()
	self:loadInventoryTypes()

	addRemoteEvents{"syncInventory"}

	addEventHandler("syncInventory", root, bind(self.Event_syncInventory, self))

	self.m_Inventories = {}
end

function InventoryManagerNew:Event_syncInventory()
	if not client.m_Disconnecting then
		local inventory = client:getInventoryNew()
		client:triggerEvent("syncInventory", inventory.m_Items)
	end
end

function InventoryManagerNew:loadItems()
	local result = sql:queryFetch("SELECT i.*,c.TechnicalName AS Category, c.Name AS CategoryName FROM ??_items i INNER JOIN ??_item_categories c ON c.Id = i.CategoryId", sql:getPrefix(), sql:getPrefix())
	self.m_Items = {}
	self.m_ItemIdToName = {}

	for _, row in ipairs(result) do
		self.m_Items[row.Id] = {
			Id = row.Id;
			TechnicalName = row.TechnicalName;
			CategoryId = row.CategoryId;
			Category = row.Category;
			CategoryName = row.CategoryName;
			Name = row.Name;
			Description = row.Description;
			Icon = row.Icon;
			Size = row.Size;
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

function InventoryManagerNew:loadCategories()
	local result = sql:queryFetch("SELECT * FROM ??_item_categories", sql:getPrefix())
	self.m_Categories = {}
	self.m_CategoryIdToName = {}

	for _, row in ipairs(result) do
		self.m_Categories[row.Id] = {
			Id = row.Id;
			TechnicalName = row.TechnicalName;
			Name = row.Name;
		}

		self.m_CategoryIdToName[row.TechnicalName] = row.Id
	end
end

function InventoryManagerNew:loadInventoryTypes()
	local result = sql:queryFetch("SELECT * FROM ??_inventory_types", sql:getPrefix())
	self.m_InventoryTypes = {}

	for _, row in ipairs(result) do
		self.m_InventoryTypes[row.Id] = {
			Id = row.Id;
			TechnicalName = row.TechnicalName;
			Name = row.Name;
			Permissions = {};
			Categories = {};
			CategoryIds = {};
		}

		if row.Permissions ~= nil and row.Permissions ~= "" and fromJSON(row.Permissions) then
			self.m_InventoryTypes[row.Id].Permissions = fromJSON(row.Permissions)
		end

		local categories = sql:queryFetch("SELECT ic.* FROM ??_inventory_type_categories tc INNER JOIN ??_item_categories ic ON ic.Id = tc.CategoryId WHERE TypeId = ?", sql:getPrefix(), sql:getPrefix(), row.Id)

		for _, category in ipairs(categories) do
			self.m_InventoryTypes[row.Id].Categories[category.Id] = {
				Id = category.Id;
				TechnicalName = category.TechnicalName;
				Name = category.Name;
			}

			table.insert(self.m_InventoryTypes[row.Id].CategoryIds, category.Id)
		end

		self.m_InventoryTypesIdToName[row.TechnicalName] = row.Id
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

		local result = sql:asyncQueryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)

		if not result then
			return false
		end

		inventoryId = result.Id
	end

    return self.m_Inventories[inventoryId] and self.m_Inventories[inventoryId] or self:loadInventory(inventoryId)
end

function InventoryManagerNew:loadInventory(inventoryId)
	if type(inventoryId) ~= "number" then
		local elementId = 0
		local elementType = 0

		if type(inventoryId) == "table" then
			if not InventoryTypes[inventoryId[1]] or table.size(inventoryId) ~= 2 then
				return false
			end
			elementId = inventoryId[2]
			elementType = InventoryTypes[inventoryId[1]]
		elseif instanceof(inventoryId, Player) then
			elementId = inventoryId.m_Id
			elementType = InventoryTypes.Player
		elseif instanceof(inventoryId, Faction) then
			elementId = inventoryId.m_Id
			elementType = InventoryTypes.Faction
		elseif instanceof(inventoryId, Company) then
			elementId = inventoryId.m_Id
			elementType = InventoryTypes.Company
		elseif instanceof(inventoryId, Group) then
			elementId = inventoryId.m_Id
			elementType = InventoryTypes.Group
		end

		local row = sql:asyncQueryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ?", sql:getPrefix(), elementId, elementType)
		
		if not row then
			outputDebugString("No inventory for elementId " .. tostring(elementId) .. " and elementType " .. tostring(elementType))
			return false
		end
		inventoryId = row.Id
	end

	local inventory = InventoryNew.load(inventoryId)

	if inventory then
		self.m_Inventories[inventoryId] = inventory
		return inventory
	end

	return false
end

function InventoryManagerNew:unloadInventory(inventoryId)
	if self.m_Inventories[inventoryId] then
		delete(self.m_Inventories[inventoryId])
		return true
	else
		return false
	end
end

function InventoryManagerNew:deleteInventory(inventoryId)
	if self.m_Inventories[inventoryId] then
		self.m_Inventories[inventoryId]:delete()
		return true
	else
		return false
	end
end

function InventoryManagerNew:isItemGivable(inventoryId, itemId, amount)
    checkIfCategoryAllowed()
    checkIfSpace()
end

function InventoryManagerNew:isItemRemovable(inventoryId, itemId, amount)
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

function InventoryManagerNew:transactItem(fromInventoryId, toInventoryId, itemId, amount, value)
    if self:isItemRemovable() and self:isItemGivable() then
        self:removeItem()
        self:giveItem()
        return true
    else
        return self:isItemRemovable(), self:isItemGivable()
    end
end
