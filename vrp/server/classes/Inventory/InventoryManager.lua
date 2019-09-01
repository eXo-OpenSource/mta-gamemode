-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryManager.lua
-- *  PURPOSE:     InventoryManager Class
-- *
-- ****************************************************************************
InventoryManager = inherit(Singleton)

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

InventoryItemClasses = {
}

function InventoryManager:constructor()
	InventoryItemClasses = {
		ItemFood = ItemFood;
		ItemKeyPad = ItemKeyPad;
		ItemDoor = ItemDoor;
		ItemFurniture = ItemFurniture;
		ItemEntrance = ItemEntrance;
		ItemTransmitter = ItemTransmitter;
		ItemBarricade = ItemBarricade;
		ItemSpeedCam = ItemSpeedCam;
		ItemNails = ItemNails;
		ItemRadio = ItemRadio;
		ItemBomb = ItemBomb;
		ItemDrugs = ItemDrugs;
		ItemDonutBox = ItemDonutBox;
		ItemEasteregg = ItemEasteregg;
		ItemPumpkin = ItemPumpkin;
		ItemTaser = ItemTaser;
		ItemSlam = ItemSlam;
		ItemSmokeGrenade = ItemSmokeGrenade;
		ItemDefuseKit = ItemDefuseKit;
		ItemFishing = ItemFishing;
		ItemDice = ItemDice;
		ItemPlant = ItemPlant;
		ItemCan = ItemCan;
		ItemSellContract = ItemSellContract;
		ItemIDCard = ItemIDCard;
		ItemFuelcan = ItemFuelcan;
		ItemRepairKit = ItemRepairKit;
		ItemHealpack = ItemHealpack;
		ItemAlcohol = ItemAlcohol;
		ItemFirework = ItemFirework;
		WearableHelmet = WearableHelmet;
		WearableShirt = WearableShirt;
		WearablePortables = WearablePortables;
		WearableClothes = WearableClothes;
	}

	self.m_InventoryTypes = {}
	self.m_InventoryTypesIdToName = {}
	self:loadInventoryTypes()

	addRemoteEvents{"syncInventory", "onItemUse", "onItemUseSecondary"}

	addEventHandler("syncInventory", root, bind(self.Event_syncInventory, self))
	addEventHandler("onItemUse", root, bind(self.Event_onItemUse, self))
	addEventHandler("onItemUseSecondary", root, bind(self.Event_onItemUseSecondary, self))

	self.m_Inventories = {}
end

function InventoryManager:Event_onItemUse(inventoryId, itemId)
	if client ~= source then return end
	if client:getInventory() and client:getInventory().m_Id == inventoryId then
		client:getInventory():useItem(itemId)
	end
end

function InventoryManager:Event_onItemUseSecondary(inventoryId, itemId)
	if client ~= source then return end
	if client:getInventory() and client:getInventory().m_Id == inventoryId then
		client:getInventory():useItemSecondary(itemId)
	end
end

function InventoryManager:syncInventory(player, inventoryId)
	if not player.m_Disconnecting then
		local inventory = player:getInventory()
		player:triggerEvent("syncInventory", inventory.m_Items, inventory.m_Id)

		if inventoryId then inventory = self:getInventory(inventoryId) end

		player:triggerEvent("onInventorySync", inventory.m_Id, inventory.m_ElementId, inventory.m_ElementType, inventory.m_Size, inventory.m_Items)
	end
end

function InventoryManager:Event_syncInventory()
	self:syncInventory(client)
end

function InventoryManager:loadInventoryTypes()
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

function InventoryManager:createInventory(elementId, elementType, size, allowedCategories)
	local inventory = Inventory.create(elementId, elementType, size, allowedCategories)

	self.m_Inventories[inventory.Id] = inventory

    return inventory
end

function InventoryManager:getInventory(inventoryIdOrElementType, elementId)
	local inventoryId = inventoryIdOrElementType
	local elementType = inventoryId

	local inventoryId, player = self:getInventoryId(inventoryIdOrElementType, elementId)

	local inventory = self.m_Inventories[inventoryId] and self.m_Inventories[inventoryId] or self:loadInventory(inventoryId)

	if player then
		inventory.m_Player = player
	end

    return inventory
end

function InventoryManager:getInventoryId(inventoryIdOrElementType, elementId)
	local inventoryId = inventoryIdOrElementType
	local elementType = inventoryId
	local player = nil

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

		return result.Id, nil
	end

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
			player = inventoryId
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
		return row.Id, player
	end
	return inventoryId
end

function InventoryManager:loadInventory(inventoryId)
	local player = nil
	if type(inventoryId) ~= "number" then
		inventoryId, player = self:getInventoryId(inventoryId)
	end

	local inventory = Inventory.load(inventoryId, player)

	if inventory then
		self.m_Inventories[inventoryId] = inventory
		return inventory
	end

	return false
end

function InventoryManager:unloadInventory(inventoryId)
	if self.m_Inventories[inventoryId] then
		delete(self.m_Inventories[inventoryId])
		return true
	else
		return false
	end
end

function InventoryManager:deleteInventory(inventoryId)
	if self.m_Inventories[inventoryId] then
		self.m_Inventories[inventoryId]:delete()
		return true
	else
		return false
	end
end

function InventoryManager:isItemGivable(inventory, item, amount)
	local inventory = inventory
	local item = item

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if type(item) == "string" then
		item = InventoryManager:getSingleton().m_ItemIdToName[item]
	end

	if not ItemManager.get(item) then
		return false, "item"
	end

	local itemData = ItemManager.get(item)

	local cSize = inventory:getCurrentSize()

	if amount < 1 then
		return false, "amount"
	end

	if inventory.m_Size < cSize + itemData.Size * amount then
		return false, "size"
	end

	if not inventory:isCompatibleWithCategory(itemData.Category) then
		return false, "category"
	end

	if itemData.m_IsUnique then
		if v.ItemId == item then
			return false, "unique"
		end
	end

	return true
end

function InventoryManager:isItemTakeable(inventory, itemId, amount, all)
	local inventory = inventory

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if (not amount or amount < 1) and not all then
		return false, "amount"
	end

	local item = inventory:getItem(itemId)

	if not item then
		return false, "invalid"
	end

	local itemData = ItemManager.get(item.ItemId)

	if not itemData then
		outputDebugString("[INVENTORY]: Invalid itemId " .. tostring(item.ItemId) .. " @ InventoryManager@isItemTakeable", 1)
		return false, "invalid"
	end

	if item.Amount < amount and not all then
		return false, "amount"
	end
	return true
end

function InventoryManager:giveItem(inventory, item, amount, durability, metadata)
	local inventory = inventory
	local item = item

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if not inventory then
		return false
	end

	if type(item) == "string" then
		item = ItemManager.getId(item)
	end

	local isGivable, reason = self:isItemGivable(inventory, item, amount)
	if isGivable then
		local itemData = ItemManager.get(item)

		for k, v in pairs(inventory.m_Items) do
			if v.ItemId == item then
				if (v.Metadata and #v.Metadata > 0) or metadata or itemData.MaxDurability > 0 then
					iprint({v.Metadata, metadata, itemData.MaxDurability}) -- TODO: Implement Metadata comparision
				else
					v.Amount = v.Amount + amount
					inventory:onInventoryChanged()
					return true
				end
			end
		end

		local id = inventory.m_NextItemId
		inventory.m_NextItemId = inventory.m_NextItemId + 1

		local data = table.copy(itemData)

		-- data.DatabaseId = uuid()
		data.Id = uuid()
		data.ItemId = item
		data.Slot = 0
		data.Amount = amount
		data.Durability = durability or itemData.MaxDurability
		data.Metadata = metadata

		for k, v in pairs(itemData) do
			if k ~= "Id" then
				data[k] = v
			end
		end

		table.insert(inventory.m_Items, data)
		inventory:onInventoryChanged(inventory)
        return true
    end
    return false, reason
end

function InventoryManager:takeItem(inventory, itemId, amount, all)
	local inventory = inventory

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if not inventory then
		return false
	end

	local isTakeable, reason = self:isItemTakeable(inventory, itemId, amount)

	if isTakeable then
		local item = inventory:getItem(itemId)
		if all then
			item.Amount = 0
		else
			item.Amount = item.Amount - amount
		end

		if item.Amount <= 0 then
			for k, v in pairs(inventory.m_Items) do
				if v == item then
					table.remove(inventory.m_Items, k)
					break
				end
			end
			inventory:onInventoryChanged()
			return true, true
		end
		inventory:onInventoryChanged()
		return true, false
    end
    return false, reason
end

function InventoryManager:transactItem(fromInventoryId, toInventoryId, itemId, amount)
    if self:isItemRemovable() and self:isItemGivable() then
        self:removeItem()
        self:giveItem()
        return true
    else
        return self:isItemRemovable(), self:isItemGivable()
    end
end

function InventoryManager:useItem(inventory, id)
	local item = inventory:getItem(id)

	if not item then
		return false, "invalid"
	end

	local itemData = ItemManager.get(item.ItemId)

	if not itemData then
		outputDebugString("[INVENTORY]: Invalid itemId " .. tostring(item.ItemId) .. " @ InventoryManager@useItem", 1)
		return false, "invalid"
	end

	local class = InventoryItemClasses[itemData.Class]

	if not class then
		return false, "class"
	end

	local instance = class:new(inventory, itemData, item)

	if not instance.use then
		return false, "classUse"
	end

	local success, remove, removeAll = instance:use()
	delete(instance)

	if remove then
		inventory:takeItem(id, 1)
	end

	if removeAll then
		inventory:takeItem(id, nil, true)
	end


	if not success then
		return false
	end

	return true
end

function InventoryManager:useItemSecondary(inventory, id)
	local item = inventory:getItem(id)

	if not item then
		return false, "invalid"
	end

	local itemData = ItemManager.get(item.ItemId)

	if not itemData then
		outputDebugString("[INVENTORY]: Invalid itemId " .. tostring(item.ItemId) .. " @ InventoryManager@useItem", 1)
		return false, "invalid"
	end

	local class = InventoryItemClasses[itemData.Class]

	if not class then
		return false
	end

	local instance = class:new(inventory, itemData, item)
	delete(instance)

	if not instance.useSecondary then
		return false
	end

	local success, remove = instance:useSecondary()

	if remove then
		inventory:takeItem(id, 1)
	end

	if not success then
		return false
	end

	return true
end
