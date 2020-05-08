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
		ItemThrowable = ItemThrowable;
		WearableHelmet = WearableHelmet;
		WearableShirt = WearableShirt;
		WearablePortables = WearablePortables;
		WearableClothes = WearableClothes;
	}

	if sql:queryFetchSingle("SHOW TABLES LIKE ?;", sql:getPrefix() .. "_items") and false then -- skip it for now
		-- REDO migration
		outputServerLog("========================================")
		outputServerLog("=            RESET INVENTORY           =")
		outputServerLog("========================================")

		sqlLogs:queryExec("DROP TABLE ??_ItemTransaction", sqlLogs:getPrefix())

		sql:queryExec("DROP TABLE ??_inventory_items", sql:getPrefix())
		sql:queryExec("DROP TABLE ??_inventories", sql:getPrefix())
		sql:queryExec("DROP TABLE ??_inventory_type_categories", sql:getPrefix())
		sql:queryExec("DROP TABLE ??_inventory_types", sql:getPrefix())
		sql:queryExec("DROP TABLE ??_items", sql:getPrefix())
		sql:queryExec("DROP TABLE ??_item_categories", sql:getPrefix())

		sql:queryExec("RENAME TABLE ??_inventory_items_old TO ??_inventory_items", sql:getPrefix(), sql:getPrefix())
	end

	if not sql:queryFetchSingle("SHOW TABLES LIKE ?;", sql:getPrefix() .. "_items") then
		self:migrate()
	end

	local result = sql:queryFetchSingle("SELECT MAX(Id) AS NextId FROM ??_inventory_items", sql:getPrefix())

	self.m_NextItemId = result.NextId + 1
	self.m_Inventories = {}
	self.m_InventoryTypes = {}
	self.m_InventoryTypesIdToName = {}
	self:loadInventoryTypes()

	self.m_InventorySubscriptions = {}

	for k, v in pairs(DbElementType) do
		self.m_InventorySubscriptions[v] = {}
	end

	addRemoteEvents{"subscribeToInventory", "unsubscribeFromInventory", "onItemUse", "onItemUseSecondary", "onItemMove"}

	addEventHandler("subscribeToInventory", root, bindAsync(self.Event_subscribeToInventory, self))
	addEventHandler("unsubscribeFromInventory", root, bindAsync(self.Event_unsubscribeFromInventory, self))

	-- addEventHandler("unsubscribeFromInventory", root, bind(function(...) Async.create(function(me, player, params) me:Event_sunsubscribeFromInventory(player, unpack(params)) end)(self, client, {...}) end, self))
	-- addEventHandler("unsubscribeFromInventory", root, bind(self.Event_sunsubscribeFromInventory, self))
	addEventHandler("onItemUse", root, bind(self.Event_onItemUse, self))
	addEventHandler("onItemUseSecondary", root, bind(self.Event_onItemUseSecondary, self))
	addEventHandler("onItemMove", root, bind(self.Event_onItemMove, self))
end

function InventoryManager:destructor()
	for k, v in pairs(self.m_Inventories) do
		v:save(true)
	end
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

function InventoryManager:Event_onItemMove(fromInventoryId, fromItemId, toInventoryId, toSlot)
	if client ~= source then return end

	local fromInventory = self:getInventory(fromInventoryId)
	local toInventory = self:getInventory(toInventoryId)
	local fromItem = fromInventory:getItem(fromItemId)
	local toItem = toInventory:getItemFromSlot(toSlot)

	if toSlot < 1 or toInventory.m_Slots < toSlot then return end
	if fromInventory == toInventory then
		if toItem then
			toItem.Slot = fromItem.Slot
			fromItem.Slot = toSlot
		else
			fromItem.Slot = toSlot
		end
		fromInventory:onInventoryChanged()
	else
		-- Event_onItemMove
		local fromSlot = fromItem.Slot
		fromItem.Slot = toSlot

		for k, v in pairs(fromInventory.m_Items) do
			if v == fromItem then
				table.remove(fromInventory.m_Items, k)
				break
			end
		end

		table.insert(toInventory.m_Items, fromItem)

		if toItem then
			toItem.Slot = fromItem.Slot
			table.insert(fromInventory.m_Items, toItem)
		end

		toInventory:onInventoryChanged()
		fromInventory:onInventoryChanged()

		StatisticsLogger:getSingleton():addItemTrancactionLog(client, fromInventory.m_Id, toInventory.m_Id, fromSlot, toSlot, fromItem)

		if toItem then
			StatisticsLogger:getSingleton():addItemTrancactionLog(client, toInventory.m_Id, fromInventory.m_Id, toSlot, fromSlot, toItem)
		end
	end
end

function InventoryManager:syncInventory(inventoryId, target)
	local inventory = self:getInventory(inventoryId)
	local target = target

	local inventoryData = {
		Id = inventory.m_Id;
		ElementId = inventory.m_ElementId;
		ElementType = inventory.m_ElementType;
		Size = inventory.m_Size;
		Slots = inventory.m_Slots;
	}

	if not target then
		target = {}
		if not self.m_InventorySubscriptions[inventory.m_ElementType][inventory.m_ElementId] then
			return
		end

		for k, v in pairs(self.m_InventorySubscriptions[inventory.m_ElementType][inventory.m_ElementId]) do
			local player = DatabasePlayer.Map[k]

			if player and isElement(player) and not player.m_Disconnecting then
				table.insert(target, player)
			end
		end

		if table.size(target) == 0 then
			return
		end
	end

	triggerClientEvent(target, "onInventorySync", resourceRoot, inventoryData, inventory.m_Items)
end

function InventoryManager:Event_subscribeToInventory(elementType, elementId)
	local player = client
	if DbElementTypeName[elementType] then
		if not self.m_InventorySubscriptions[elementType][elementId] then
			self.m_InventorySubscriptions[elementType][elementId] = {}
		end

		local inventory = self:getInventory(elementType, elementId)

		self.m_InventorySubscriptions[elementType][elementId][player.m_Id] = true

		self:syncInventory(inventory.m_Id, player)
	end
end

function InventoryManager:Event_unsubscribeFromInventory(elementType, elementId)
	local player = client
	if DbElementTypeName[elementType] then
		if not self.m_InventorySubscriptions[elementType][elementId] then
			self.m_InventorySubscriptions[elementType][elementId] = {}
		end
		self.m_InventorySubscriptions[elementType][elementId][player.m_Id] = nil
	end
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

function InventoryManager:getInventory(inventoryIdOrElementType, elementId, sync)
	local inventoryId = inventoryIdOrElementType
	local elementType = inventoryId

	local inventoryId, player = self:getInventoryId(inventoryIdOrElementType, elementId, sync)
	local inventory = self.m_Inventories[inventoryId] and self.m_Inventories[inventoryId] or self:loadInventory(inventoryId, sync)

	if player then
		inventory.m_Player = player
	end

    return inventory
end

function InventoryManager:getInventoryId(inventoryIdOrElementType, elementId, sync)
	local inventoryId = inventoryIdOrElementType
	local elementType = inventoryId
	local player = nil

	if elementId then
		-- get the damn id :P
		-- is inventory already loaded?
		for id, inventory in pairs(self.m_Inventories) do
			if inventory.m_ElementId == elementId and inventory.m_ElementType == elementType then
				return inventory.m_Id
			end
		end
		local result

		if sync then
			result = sql:queryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)
		else
			result = sql:asyncQueryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)
		end

		if not result then
			return false
		end

		return result.Id, nil
	end

	if type(inventoryId) ~= "number" then
		local elementId = 0
		local elementType = 0

		if type(inventoryId) == "table" then
			if not DbElementTypeName[inventoryId[1]] or table.size(inventoryId) ~= 2 then
				return false
			end
			elementId = inventoryId[2]
			elementType = DbElementTypeName[inventoryId[1]]
		elseif instanceof(inventoryId, Player) then
			elementId = inventoryId.m_Id
			elementType = DbElementType.Player
			player = inventoryId
		elseif instanceof(inventoryId, Faction) then
			elementId = inventoryId.m_Id
			elementType = DbElementType.Faction
		elseif instanceof(inventoryId, Company) then
			elementId = inventoryId.m_Id
			elementType = DbElementType.Company
		elseif instanceof(inventoryId, Group) then
			elementId = inventoryId.m_Id
			elementType = DbElementType.Group
		elseif instanceof(inventoryId, PermanentVehicle) then
			elementId = inventoryId.m_Id
			elementType = DbElementType.Vehicle
		end

		local row

		if sync then
			row = sql:queryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)
		else
			row = sql:asyncQueryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)
		end

		if not row then
			outputDebugString("No inventory for elementId " .. tostring(elementId) .. " and elementType " .. tostring(elementType))
			return false
		end
		return row.Id, player
	end
	return inventoryId
end

function InventoryManager:loadInventory(inventoryId, sync)
	local player = nil
	if type(inventoryId) ~= "number" then
		inventoryId, player = self:getInventoryId(inventoryId, nil, sync)
	end

	local inventory = Inventory:new(inventoryId, player)

	if inventory then
		self.m_Inventories[inventoryId] = inventory
		local result = inventory:loadData(sync)
		if not result then
			self.m_Inventories[inventoryId] = nil
			return false
		end
		return self.m_Inventories[inventoryId]
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

	--[[
	local cSize = inventory:getCurrentSize()

	if amount < 1 then
		return false, "amount"
	end

	if inventory.m_Size < cSize + itemData.Size * amount then
		return false, "size"
	end
	]]
	-- TODO: Add free slot check

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

		local slot = self:getNextFreeSlot(inventory)

		if not slot then
			return false, "slot"
		end

		local id = inventory.m_NextItemId
		local player = inventory:getPlayer()
		inventory.m_NextItemId = inventory.m_NextItemId + 1

		local data = table.copy(itemData)

		data.Id = self.m_NextItemId
		data.InventoryId = inventory.m_Id
		data.ItemId = item
		data.OwnerId = player and player.m_Id or nil
		data.OwnerName = player and player.m_Name or "Unbekannt"
		data.Slot = slot
		data.Amount = amount
		data.Durability = durability or itemData.MaxDurability
		data.Metadata = metadata
		data.Tradeable = itemData.Tradeable
		data.ExpireTime = itemData.Expireable and itemData.MaxExpireTime or 0

		self.m_NextItemId = self.m_NextItemId + 1

		for k, v in pairs(itemData) do
			if k ~= "Id" then
				data[k] = v
			end
		end

		table.insert(inventory.m_Items, data)
		inventory:onInventoryChanged()
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

function InventoryManager:getNextFreeSlot(inventory)
	local inventory = inventory

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if not inventory then
		return false
	end
	local totalSlots = inventory.m_Slots

	for i = 1, totalSlots, 1 do
		local found = false
		for k, v in pairs(inventory.m_Items) do
			if v.Slot == i then
				found = true
				break
			end
		end

		if not found then
			return i
		end
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
		outputDebugString("[INVENTORY]: Invalid item " .. tostring(id) .. " @ InventoryManager@useItem", 1)
		return false, "invalid"
	end

	local itemData = ItemManager.get(item.ItemId)

	if not itemData then
		outputDebugString("[INVENTORY]: Invalid itemId " .. tostring(item.ItemId) .. " @ InventoryManager@useItem", 1)
		return false, "invalid"
	end

	local class = InventoryItemClasses[itemData.Class]

	if not class then
		outputDebugString("[INVENTORY]: Invalid item class " .. tostring(itemData.Class) .. " @ InventoryManager@useItem", 1)
		return false, "class"
	end

	local instance = class:new(inventory, itemData, item)

	if not instance.use then
		outputDebugString("[INVENTORY]: Invalid item class use method " .. tostring(itemData.Class) .. " @ InventoryManager@useItem", 1)
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

function InventoryManager:migrate()
	local h1, h2, h3, h4 = debug.gethook()
	debug.sethook() -- disable infinity loop check

	local st = getTickCount()
	outputServerLog("========================================")
	outputServerLog("=     STARTING INVENTORY MIGRATION     =")
	outputServerLog("========================================")

	setServerPassword(string.random(128)) -- No player should be on the server while the migration runs
	for _, v in pairs(getElementsByType("player")) do
		v:kick("Migration")
	end

	sql:queryExec("RENAME TABLE ??_inventory_items TO ??_inventory_items_old", sql:getPrefix(), sql:getPrefix())

	-- Create tables
	sql:queryExec([[
		CREATE TABLE ??_item_categories  (
			`Id` int(11) NOT NULL AUTO_INCREMENT,
			`TechnicalName` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
			`Name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
			PRIMARY KEY (`Id`) USING BTREE
		);
	]], sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_items  (
			`Id` int(11) NOT NULL AUTO_INCREMENT,
			`TechnicalName` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
			`CategoryId` int(11) NOT NULL,
			`Class` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
			`Name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
			`Description` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
			`Icon` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
			`ModelId` int(11) NOT NULL DEFAULT 0,
			`MaxDurability` int(11) NOT NULL DEFAULT 0,
			`DurabilityDestroy` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Destroys item on zero durability',
			`MaxExpireTime` int(11) NOT NULL DEFAULT 0,
			`Consumable` tinyint(1) NOT NULL DEFAULT 0,
			`Tradeable` tinyint(1) NOT NULL DEFAULT 1,
			`Expireable` tinyint(1) NOT NULL DEFAULT 0,
			`IsUnique` tinyint(1) NOT NULL DEFAULT 0,
			`Throwable` tinyint(1) NOT NULL DEFAULT 0,
			`Breakable` tinyint(4) NOT NULL DEFAULT 0,
			`IsStackable` tinyint(1) NOT NULL DEFAULT 0,
			`StackSize` tinyint(4) NOT NULL DEFAULT 0,
			PRIMARY KEY (`Id`) USING BTREE,
			INDEX `CategoryId`(`CategoryId`) USING BTREE,
			CONSTRAINT ??_items_ibfk_1 FOREIGN KEY (`CategoryId`) REFERENCES ??_item_categories (`Id`) ON DELETE RESTRICT ON UPDATE RESTRICT
		);
	]], sql:getPrefix(), sql:getPrefix(), sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_inventory_types  (
			`Id` int NOT NULL AUTO_INCREMENT,
			`TechnicalName` varchar(128) NOT NULL,
			`Name` varchar(128) NOT NULL,
			`Permissions` text NOT NULL,
			PRIMARY KEY (`Id`)
		);
	]], sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_inventory_type_categories  (
			`TypeId` int NOT NULL,
			`CategoryId` int NOT NULL,
			PRIMARY KEY (`TypeId`, `CategoryId`),
			FOREIGN KEY (`TypeId`) REFERENCES ??_inventory_types (`Id`),
			FOREIGN KEY (`CategoryId`) REFERENCES ??_item_categories (`Id`)
		);
	]], sql:getPrefix(), sql:getPrefix(), sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_inventories  (
			`Id` int NOT NULL AUTO_INCREMENT,
			`ElementId` int NOT NULL,
			`ElementType` int NOT NULL,
			`TypeId` int NOT NULL,
			`Slots` int NOT NULL,
			`Deleted` datetime NULL DEFAULT NULL,
			PRIMARY KEY (`Id`),
			FOREIGN KEY (`TypeId`) REFERENCES ??_inventory_types (`Id`)
		  );
	]], sql:getPrefix(), sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_inventory_items  (
			`Id` int NOT NULL,
			`InventoryId` int(0) NOT NULL,
			`ItemId` int(0) NOT NULL,
			`OwnerId` int(0) NULL DEFAULT NULL,
			`Tradeable` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Tradeable override',
			`Slot` int(0) NOT NULL,
			`Amount` int(0) NOT NULL,
			`Durability` int(0) NOT NULL,
			`ExpireTime` int(0) NOT NULL DEFAULT 0,
			`Metadata` text NULL DEFAULT NULL,
			`CreatedAt` datetime NOT NULL DEFAULT NOW(),
			`UpdatedAt` datetime NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,

			PRIMARY KEY (`Id`),
			FOREIGN KEY (`InventoryId`) REFERENCES ??_inventories (`Id`) ON DELETE CASCADE,
			FOREIGN KEY (`ItemId`) REFERENCES ??_items (`Id`)
		);
	]], sql:getPrefix(), sql:getPrefix(), sql:getPrefix())


	sqlLogs:queryExec([[
		CREATE TABLE ??_ItemTransaction  (
			`Id` int NOT NULL AUTO_INCREMENT,
			`Date` datetime NOT NULL DEFAULT NOW(),
			`UserId` int NOT NULL,
			`FromInventory` int NULL,
			`ToInventory` int NOT NULL,
			`FromSlot` int NULL,
			`ToSlot` int NOT NULL,
			`InventoryItemId` int NOT NULL,
			`ItemId` int NOT NULL,
			`Amount` int NOT NULL DEFAULT 1,
			`Durability` int NOT NULL DEFAULT 0,
			`Metadata` text NULL,
			PRIMARY KEY (`Id`)
		);
	]], sqlLogs:getPrefix())

	-- Insert data

	sql:queryExec([[
		INSERT INTO ??_item_categories VALUES
			(1, 'food', 'Essen'),
			(2, 'weapons', 'Waffen'),
			(3, 'items', 'Items'),
			(4, 'objects', 'Objekte'),
			(5, 'drugs', 'Drogen'),
			(6, 'fish', 'Fische'),
			(7, 'weapon', 'Waffe'),
			(8, 'ammunition', 'Munition');
	]], sql:getPrefix())


	sql:queryExec([[
		INSERT INTO `vrp_items` VALUES (1, 'weed', 5, 'ItemDrugs', 'Weed', 'Weed ist geil', 'Drogen/Weed.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (2, 'burger', 1, 'ItemFood', 'Burger', 'Fuellt deinen Hunger auf', 'Essen/Burger.png', 2880, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (3, 'jerrycan', 3, 'ItemFuelcan', 'Benzinkanister', 'Fuellt den Tank eines Fahrzeuges auf!', 'Items/Benzinkanister.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (4, 'chips', 3, '-', 'Chips', 'Casino-Chips', 'Items/Chips.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (5, 'binoculars', 3, '-', 'Fernglas', 'Augen wie ein Adler', 'Items/Fernglas.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (6, 'medkit', 3, 'ItemHealpack', 'Medikit', 'Fuellt deine Gesundheit auf', 'Items/Medikit.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (7, 'radio', 4, 'ItemRadio', 'Radio', 'Platzierbares Radio zum Musik abspielen!', 'Items/Radio.png', 2226, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (8, 'dice', 3, 'ItemDice', 'Würfel', 'kleines Gluecksspiel', 'Items/Wuerfel.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (9, 'cigarette', 5, 'ItemFood', 'Zigarette', 'Rauche eine zwischendurch', 'Essen/Zigeretten.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (10, 'pepperAmunation', 3, '-', 'Pfeffermunition', 'Laesst den getroffenen Husten', 'Items/Munition.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (11, 'identityCard', 3, 'ItemIDCard', 'Ausweis', 'Personalausweis und Fuehrerscheine', 'Items/Ausweis.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (12, 'weedSeed', 5, 'ItemPlant', 'Weed-Samen', 'Samen der begehrten Weed-Pflanze', 'Drogen/Samen.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (13, 'shrooms', 5, 'ItemDrugs', 'Shrooms', 'illegale Pilze', 'Drogen/Shroom.png', 1947, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (14, 'fries', 1, 'ItemFood', 'Pommes', 'Ein Snack fuer zwischen durch', 'Essen/Pommes.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (15, 'candyBar', 1, '-', 'Snack', 'Ein Schoko-Riegel für Zwischendurch', 'Essen/Snack.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (16, 'beer', 1, 'ItemAlcohol', 'Bier', 'Ein Bierchen am Morgen vertreibt Kummer und Sorgen', 'Essen/Bier.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (17, 'exoPad', 3, '-', 'eXoPad', 'Tablet von eXo-Reallife', 'Items/eXoPad.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (18, 'gameBoy', 3, '-', 'Gameboy', 'Spiele Tetris und knacke den Highscore', 'Items/Gameboy.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (19, 'materials', 3, '-', 'Mats', 'Baue Waffen aus diesen illegalen Materialien', 'Items/Mats.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (20, 'fish', 3, '-', 'Fische', 'Fische, frisch ausm Meer', 'Items/Fische.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (21, 'newspaper', 3, '-', 'Zeitung', 'Neuigkeiten der SAN-News', 'Items/Zeitung.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (22, 'ecstasy', 5, '-', 'Ecstasy', 'Finger weg von den Drogen!', 'Drogen/Ecstasy.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (23, 'heroin', 5, 'ItemDrugs', 'Heroin', 'Finger weg von den Drogen!', 'Drogen/Heroin.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (24, 'cocaine', 5, 'ItemDrugs', 'Kokain', 'Finger weg von den Drogen!', 'Drogen/Koks.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (25, 'repairKit', 3, 'ItemRepairKit', 'Reparaturkit', 'Zum reparieren von Totalschaeden', 'Items/Reparaturkit.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (26, 'candies', 1, 'ItemFood', 'Suessigkeiten', 'Was zum Naschen fuer Zwischendurch', 'Essen/Suessigkeiten.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (27, 'pumpkin', 3, 'ItemPumpkin', 'Kürbis', 'Sammle diese und Kauf dir wundervolle Praemien davon!', 'Items/Kuerbis.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (28, 'packet', 3, '-', 'Päckchen', 'Nettes Päckchen vom Weihnachtsmann', 'Items/Paeckchen.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (29, 'gluvine', 1, 'ItemAlcohol', 'Glühwein', 'Gibts was besseres zur kalten Adventzeit\'', 'Essen/Gluehwein.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (30, 'coffee', 1, 'ItemFood', 'Kaffee', 'Warmer Kaffee, nicht vor dem Schlafen gehen trinken!', 'Essen/Kaffee.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (31, 'gingerbread', 1, 'ItemFood', 'Lebkuchen', 'Nette Jause zwischendurch in den kalten Monaten', 'Essen/Lebkuchen.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (32, 'shot', 1, 'ItemAlcohol', 'Shot', 'alkoholhaltiges Getraenk, das in 2-cl- oder 4-cl-Glaesern serviert und zumeist in einem Zug getrunken wird', 'Essen/Shot.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (33, 'sousage', 1, 'ItemFood', 'Würstchen', 'Lecker Wuerstchen mit Senf!', 'Essen/Wuerstchen.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (34, 'tollTicket', 3, '-', 'Mautpass', 'Damit kommst du kostenlos durch Mautstellen. 1 Woche gueltig!', 'Items/Mautpass.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (35, 'cookie', 1, 'ItemFood', 'Keks', 'Verliehen von Entwicklern für besondere Verdienste', 'Items/Keks.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (36, 'helmet', 3, 'WearableHelmet', 'Helm', 'Safty First! Setze ihn auf wann immer du möchtest!', 'Items/Helm.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (37, 'mask', 3, '-', 'Maske', 'Verleihe dir ein nie dargewesenes Aussehen mit einer tollen Maske!', 'Items/Maske.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (38, 'cowUdderWithFries', 1, 'ItemFood', 'Kuheuter mit Pommes', 'Wiederliches Essen', 'Essen/Kuheuter mit Pommes.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (39, 'zombieBurger', 1, 'ItemFood', 'Zombie-Burger', 'Wiederliches Burger aus Zombiefleisch', 'Essen/Zombie-Burger.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (40, 'christmasHat', 3, 'WearableHelmet', 'Weihnachtsmütze', 'Weihnachtsmuetze', 'Objekte/Weihnachtsmuetze.png', 1936, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (41, 'barricade', 4, 'ItemBarricade', 'Barrikade', 'Barrikade', 'Items/Barrikade.png', 1422, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (42, 'explosive', 3, 'ItemBomb', 'Sprengstoff', 'Sprenge verschiedene Tueren', 'Items/Sprengstoff.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (43, 'pizza', 1, 'ItemFood', 'Pizza', 'Fuellt deinen Hunger auf', 'Essen/Pizza.png', 2881, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (44, 'mushroom', 1, 'ItemFood', 'Pilz', 'Essbarer Pilz', 'Essen/Pilz.png', 1882, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (45, 'can', 3, 'ItemCan', 'Kanne', 'Zum Bewaessern von Pflanzen', 'Items/Kanne.png', 0, 10, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (46, 'sellContract', 3, 'ItemSellContract', 'Handelsvertrag', 'Dieser Vertrag wird zum verkaufen von Fahrzeugen benoetigt', 'Items/Contract.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (47, 'speedCamera', 4, 'ItemSpeedCam', 'Blitzer', 'Zum aufstellen und bestrafen von Geschwindikeitsueberschreitungen', 'Items/Blitzer.png', 3902, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (48, 'nailStrip', 4, 'ItemNails', 'Nagel-Band', 'Fahrzeuge bekommen beim darueber fahren platte Reifen', 'Items/NagelBand.png', 2892, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (49, 'whiskey', 1, 'ItemAlcohol', 'Whiskey', 'Whiskey ist eine durch Destillation aus Getreidemaische gewonnene und im Holzfass gereifte Spirituose.', 'Essen/Long Drink Brown.png', 1455, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (50, 'sexOnTheBeach', 1, 'ItemAlcohol', 'Sex on the Beach', 'fruchtiger, maessig suesser Cocktail', 'Essen/Cocktail.png', 1455, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (51, 'pinaColada', 1, 'ItemAlcohol', 'Pina Colada', 'ein suesser, cremiger Cocktail aus Rum, Kokosnusscreme und Ananassaft.', 'Essen/Cocktail.png', 1455, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (52, 'monster', 1, 'ItemAlcohol', 'Monster', 'extrem starker Cocktail der einem die Schuhe auszieht', 'Essen/Cocktail.png', 1455, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (53, 'cubaLibre', 1, 'ItemAlcohol', 'Cuba-Libre', 'ein Longdrink mit Rum und Cola, der um 1900 in Kuba entstand.', 'Essen/Long Drink Brown.png', 1455, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (54, 'donutBox', 1, 'ItemDonutBox', 'Donutbox', '  Mhhh... Donuts...', 'Essen/ItemDonutBox.png', 0, 9, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (55, 'donut', 1, 'ItemFood', 'Donut', 'Doh!', 'Essen/ItemDonut.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (56, 'integralHelmet', 3, 'WearableHelmet', 'Helm', 'Ein Integralhelm der dich vor Wind und Blicken schützt!', 'Objekte/helm.png', 2052, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (57, 'motoHelmet', 3, 'WearableHelmet', 'Motorcross-Helm', 'Ein Motocross-Helm welcher sehr gut den Dreck beim Fahren abwendet!', 'Objekte/crosshelmet.png', 1924, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (58, 'pothelmet', 3, 'WearableHelmet', 'Pot-Helm', 'Auf der Harley besonders stylish!', 'Objekte/bikerhelmet.png', 3911, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (59, 'gasmask', 3, 'WearableHelmet', 'Gasmaske', 'Hält Gase fern!', 'Objekte/gasmask.png', 3890, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (60, 'kevlar', 3, 'WearableShirt', 'Kevlar', 'Egal ob 9mm oder .45, alles wird gestoppt!', 'Objekte/kevlar.png', 3916, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (61, 'duffle', 3, 'WearableShirt', 'Tragetasche', 'Es passt einiges hier rein!', 'Objekte/dufflebag.png', 3915, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (62, 'swatshield', 3, 'WearablePortables', 'Swatschild', 'Ein Einsatzschild für Spezialtruppen!', 'Objekte/riot_shield.png', 1631, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (63, 'stolenGoods', 3, '-', 'Diebesgut', 'Eine Beutel voller Gegenstände! Legal\'', 'Objekte/diebesgut.png', 3915, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (64, 'clothing', 3, '-', 'Kleidung', 'Ein Set Kleidung.', 'Items/Kleidung.png', 1275, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (65, 'bambooFishingRod', 3, 'ItemFishing', 'Bambusstange', 'Wollen fangen Fische\'', 'Items/Bamboorod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (66, 'coolingBoxSmall', 3, 'ItemFishing', 'Kleine Kühltasche', 'Kühlt gut, wieder und wieder!', 'Items/Coolbag.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (67, 'coolingBoxMedium', 3, 'ItemFishing', 'Kühltasche', 'Kühlt gut, wieder und wieder!', 'Items/Coolbag.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (68, 'coolingBoxLarge', 3, 'ItemFishing', 'Kühlbox', 'Kühlt gut, wieder und wieder!', 'Items/Coolbox.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (69, 'swathelmet', 3, 'WearableHelmet', 'Einsatzhelm', 'Falls es hart auf hart kommt.', 'Objekte/einsatzhelm.png', 3911, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (70, 'bait', 3, 'ItemFishing', 'Köder', 'Lockt ein paar Fische an und vereinfacht das Angeln', 'Items/Bait.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (71, 'easterEgg', 3, 'ItemEasteregg', 'Osterei', 'Event-Special: Osterei', 'Items/Osterei.png', 1933, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (72, 'bunnyEars', 3, 'WearableHelmet', 'Hasenohren', 'Event-Special Hasenohren', 'Objekte/Hasenohren.png', 1934, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (73, 'warningCones', 4, 'ItemBarricade', 'Warnkegel', 'zum Markieren von Einsatzorten', 'Objekte/Warnkegel.png', 1238, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (74, 'apple', 1, 'ItemFood', 'Apfel', 'gesundes Obst', 'Essen/Apfel.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (75, 'appleSeed', 1, 'ItemPlant', 'Apfelbaum-Samen', 'Pflanze deinen eigenen Apfelbaum', 'Drogen/Samen.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (76, 'trashcan', 4, '-', 'Trashcan', 'Deine eigene Mülltonne für dein Haus!', 'Essen/Apfel.png', 1337, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (77, 'taser', 3, 'ItemTaser', 'Taser', 'Haut den gegner mit Stromstößen um', 'Items/Taser.png', 347, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (78, 'candyCane', 1, 'ItemFood', 'Zuckerstange', 'Event-Special Zuckerstange', 'Essen/Zuckerstange.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (79, 'medikit2', 3, 'ItemHealpack', 'Medikit', 'Medikit zum schnellen selbst heilen', 'Items/Chips.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (80, 'keypad', 4, 'ItemKeyPad', 'Keypad', 'Ein Eingabegerät.', 'Objekte/keypad.png', 2886, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (81, 'gate', 4, 'ItemDoor', 'Tor', 'Ein benutzbares Tor zum platzieren.', 'Objekte/door.png', 1493, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (82, 'entrance', 4, 'ItemEntrance', 'Eingang', 'Ein platzierbarer Eingang', 'Objekte/entrance.png', 1318, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (83, 'fireworksRocket', 3, 'ItemFirework', 'Rakete', 'Feuerwerks Rakete', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (84, 'fireworksPipeBomb', 3, 'ItemFirework', 'Rohrbombe', 'macht einen lauten Krach', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (85, 'fireworksBattery', 3, 'ItemFirework', 'Raketen Batterie', 'Eine Batterie aus mehreren Raketen', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (86, 'fireworksRoman', 3, 'ItemFirework', 'Römische Kerze', 'Römische Kerze', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (87, 'fireworksRomanBattery', 3, 'ItemFirework', 'Römische Kerzen Batterie', 'Eine Batterie aus mehreren Römischen Kerzen', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (88, 'fireworksBomb', 3, 'ItemFirework', 'Kugelbombe', 'macht ordentlich Krach', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (89, 'fireworksCracker', 3, 'ItemFirework', 'Böller', 'macht kleine explosionen', 'Items/Feuerwerk.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (90, 'slam', 3, 'ItemSlam', 'SLAM', 'Ein Sprengsatz mit Fernzünder.', 'Items/Slam.png', 1252, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (91, 'smokeGrenade', 3, 'ItemSmokeGrenade', 'Rauchgranate', 'Eine Rauchgranate um Sicht zu verhindern.', 'Items/Smokegrenade.png', 1672, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (92, 'transmitter', 4, '-', 'Transmitter', 'Ein Radiosender der über Ultrakurzwelle empfängt.', 'Objekte/transmitter.png', 3031, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (93, 'star', 4, 'WearableHelmet', 'Stern', 'Ein Stern erhalten durch den Braboy!', 'Objekte/star.png', 902, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (94, 'keycard', 3, '-', 'Keycard', 'Benutze die Keycard um Knasttüren zu öffnen', 'Items/Keycard.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (95, 'flowerSeed', 1, 'ItemPlant', 'Blumen-Samen', 'Pflanze diese Samen um einen wunderschönen Blumenstrauß zu ernten', 'Drogen/Samen.png', 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (96, 'defuseKit', 3, 'ItemDefuseKit', 'DefuseKit', 'Zum Entschärfen von SLAMs', 'Items/DefuseKit.png', 2886, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (97, 'fishLexicon', 3, 'ItemFishing', 'Fischlexikon', 'Sammelt Informationen über deine geangelte Fische!', 'Items/FishEncyclopedia.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (98, 'fishingRod', 3, 'ItemFishing', 'Angelrute', 'Für angehende Angler!', 'Items/fishingrod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (99, 'expertFishingRod', 3, 'ItemFishing', 'Profi Angelrute', 'Für profi Angler!', 'Items/ProFishingrod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (100, 'legendaryFishingRod', 3, 'ItemFishing', 'Legendäre Angelrute', 'Für legendäre Angler! Damit fängst du jeden Fisch!', 'Items/LegendaryFishingrod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (101, 'glowBait', 3, 'ItemFishing', 'Leuchtköder', 'Lockt allgemeine Fische an', 'Items/Glowingbait.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (102, 'pilkerBait', 3, 'ItemFishing', 'Pilkerköder', 'Spezieller Köder für Meeresangeln', 'Items/Pilkerbait.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (103, 'swimmer', 3, 'ItemFishing', 'Schwimmer', 'Zubehör. Auf der Wasseroberfläche treibender Bissanzeiger', 'Items/Bobber.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (104, 'spinner', 3, 'ItemFishing', 'Spinner', 'Zubehör. Eine rotierende Metallscheibe für ein einfaches und effektives fangen von kleinen als auch große Fische', 'Items/Spinner.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (105, 'clubCard', 3, '-', 'Clubkarte', 'Willkommen im Club der Riskanten.', 'Items/Clubcard.png', 2886, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (106, 'albacore', 6, 'ItemFish', 'Weißer Thun', '', 'albacore.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (107, 'anchovy', 6, 'ItemFish', 'Sardelle', '', 'anchovy.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (108, 'bream', 6, 'ItemFish', 'Brasse', '', 'bream.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (109, 'bullhead', 6, 'ItemFish', 'Zwergwels', '', 'bullhead.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (110, 'carp', 6, 'ItemFish', 'Karpfen', '', 'carp.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (111, 'catfish', 6, 'ItemFish', 'Katzenfisch', '', 'catfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (112, 'chub', 6, 'ItemFish', 'Kaulbarsch', '', 'chub.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (113, 'dorado', 6, 'ItemFish', 'Goldmakrele', '', 'dorado.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (114, 'eel', 6, 'ItemFish', 'Aal', '', 'eel.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (115, 'halibut', 6, 'ItemFish', 'Heilbutt', '', 'halibut.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (116, 'herring', 6, 'ItemFish', 'Hering', '', 'herring.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (117, 'largemouthBass', 6, 'ItemFish', 'Forellenbarsch', '', 'largemouthBass.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (118, 'lingcod', 6, 'ItemFish', 'Lengdorsch', '', 'lingcod.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (119, 'squid', 6, 'ItemFish', 'Tintenfisch', '', 'squid.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (120, 'perch', 6, 'ItemFish', 'Barsch', '', 'perch.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (121, 'pike', 6, 'ItemFish', 'Hecht', '', 'pike.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (122, 'pufferfish', 6, 'ItemFish', 'Kugelfisch', '', 'pufferfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (123, 'rainbowTrout', 6, 'ItemFish', 'Regenbogenforelle', '', 'rainbowTrout.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (124, 'redMullet', 6, 'ItemFish', 'Rotbarbe', '', 'redMullet.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (125, 'redSnapper', 6, 'ItemFish', 'Riffbarsch', '', 'redSnapper.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (126, 'salmon', 6, 'ItemFish', 'Lachs', '', 'salmon.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (127, 'sandfish', 6, 'ItemFish', 'Sandfisch', '', 'sandfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (128, 'sardine', 6, 'ItemFish', 'Sardine', '', 'sardine.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (129, 'seaCucumber', 6, 'ItemFish', 'Seegurke', '', 'seaCucumber.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (130, 'shad', 6, 'ItemFish', 'Blaubarsch', '', 'shad.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (131, 'smallmouthBass', 6, 'ItemFish', 'Schwarzbarsch', '', 'smallmouthBass.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (132, 'octopus', 6, 'ItemFish', 'Oktopus', '', 'octopus.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (133, 'stonefish', 6, 'ItemFish', 'Steinfisch', '', 'stonefish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (134, 'sturgeon', 6, 'ItemFish', 'Stör', '', 'sturgeon.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (135, 'sunfish', 6, 'ItemFish', 'Gotteslachs', '', 'sunfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (136, 'superCucumber', 6, 'ItemFish', 'Super Seegurke', '', 'superCucumber.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (137, 'tigerTrout', 6, 'ItemFish', 'Tigerforelle', '', 'tigerTrout.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (138, 'tilapia', 6, 'ItemFish', 'Buntbarsch', '', 'tilapia.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (139, 'tuna', 6, 'ItemFish', 'Thunfisch', '', 'tuna.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (140, 'walleye', 6, 'ItemFish', 'Glasaugenbarsch', '', 'walleye.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (141, 'snailfish', 6, 'ItemFish', 'Scheibenbäuche', '', 'snailfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (142, 'blobfisch', 6, 'ItemFish', 'Blobfisch', '', 'blobfisch.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (143, 'barbeledDragonfish', 6, 'ItemFish', 'Schuppendrachenfisch', '', 'barbeledDragonfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (144, 'voidSalmon', 6, 'ItemFish', 'Schattenlachs', '', 'voidSalmon.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (145, 'slimejack', 6, 'ItemFish', 'Schleimmakrele', '', 'slimejack.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (146, 'swordfish', 6, 'ItemFish', 'Schwertfisch', '', 'swordfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (147, 'indianGlassCatfish', 6, 'ItemFish', 'Indischer Glaswels', '', 'indianGlassCatfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (148, 'forestJumper', 6, 'ItemFish', 'Waldspringer', '', 'forestJumper.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (149, 'mudWhipper', 6, 'ItemFish', 'Schlammpeitzger', '', 'mudWhipper.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (150, 'sableFish', 6, 'ItemFish', 'Zobelfisch', '', 'sableFish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (151, 'lakeTrout', 6, 'ItemFish', 'Seeforelle', '', 'lakeTrout.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (152, 'burbot', 6, 'ItemFish', 'Quappe', '', 'burbot.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (153, 'sootyNose', 6, 'ItemFish', 'Rußnase', '', 'sootyNose.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (154, 'rudd', 6, 'ItemFish', 'Rotfeder', '', 'rudd.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (155, 'roach', 6, 'ItemFish', 'Rotauge', '', 'roach.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (156, 'asp', 6, 'ItemFish', 'Rapfen', '', 'asp.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (157, 'pearlFish', 6, 'ItemFish', 'Perlfisch', '', 'pearlFish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (158, 'threeSpinedStrickleback', 6, 'ItemFish', 'Dreistachliger Stichling', '', 'threeSpinedStrickleback.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (159, 'ghostFish', 6, 'ItemFish', 'Gespensterfisch', '', 'ghostFish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (160, 'perch', 6, 'ItemFish', 'Flussbarsch', '', 'perch.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (161, 'zander', 6, 'ItemFish', 'Zander', '', 'zander.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (162, 'blackSeabream', 6, 'ItemFish', 'Streifenbrasse', '', 'blackSeabream.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (163, 'duskyGrouper', 6, 'ItemFish', 'Zackenbarsch', '', 'duskyGrouper.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (164, 'eaglefish', 6, 'ItemFish', 'Adlerfisch', '', 'eaglefish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (165, 'salmonHerring', 6, 'ItemFish', 'Lachshering', '', 'salmonHerring.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (166, 'sabreToothedFish', 6, 'ItemFish', 'Säbelzahnfisch', '', 'sabreToothedFish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (167, 'deepSeaDevil', 6, 'ItemFish', 'Tiefseeteufel', '', 'deepSeaDevil.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (168, 'viperFish', 6, 'ItemFish', 'Viperfisch', '', 'viperFish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (169, 'hammerheadJawfish', 6, 'ItemFish', 'Hammerkieferfisch', '', 'hammerheadJawfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (170, 'sawBelly', 6, 'ItemFish', 'Sägebauch', '', 'sawBelly.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (171, 'luminousHerring', 6, 'ItemFish', 'Leuchthering', '', 'luminousHerring.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (172, 'scaledFish', 6, 'ItemFish', 'Großschuppenfisch', '', 'scaledFish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (173, 'longTailedHake', 6, 'ItemFish', 'Langschwanz-Seehecht', '', 'longTailedHake.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (174, 'tripod', 6, 'ItemFish', 'Dreibeinfisch', '', 'tripod.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (175, 'rodAngler', 6, 'ItemFish', 'Rutenangler', '', 'rodAngler.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (176, 'oarfish', 6, 'ItemFish', 'Riemenfisch', '', 'oarfish.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (177, 'cod', 6, 'ItemFish', 'Kabeljau', '', 'cod.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (178, 'mutantSardine', 6, 'ItemFish', 'Mutantensardine', '', 'mutantSardine.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (179, 'mutantCarp', 6, 'ItemFish', 'Mutantenkarpfen', '', 'mutantCarp.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (180, 'scorpionCarp', 6, 'ItemFish', 'Skorpionkarpfen', '', 'scorpionCarp.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (181, 'brassknuckle', 7, 'ItemWeapon', 'Schlagring', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (182, 'golfclub', 7, 'ItemWeapon', 'Golfschläger', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (183, 'nightstick', 7, 'ItemWeapon', 'Schlagstock', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (184, 'knife', 7, 'ItemWeapon', 'Messer', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (185, 'bat', 7, 'ItemWeapon', 'Baseballschläger', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (186, 'shovel', 7, 'ItemWeapon', 'Schaufel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (187, 'poolstick', 7, 'ItemWeapon', 'Billiardschläger', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (188, 'katana', 7, 'ItemWeapon', 'Katana', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (189, 'chainsaw', 7, 'ItemWeapon', 'Kettensäge', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (190, 'colt45', 7, 'ItemWeapon', 'Colt 45', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (191, 'deagle', 7, 'ItemWeapon', 'Deagle', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (192, 'shotgun', 7, 'ItemWeapon', 'Schrotflinte', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (193, 'sawedOff', 7, 'ItemWeapon', 'Abgesägte Schrotflinte', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (194, 'combatShotgun', 7, 'ItemWeapon', 'SPAZ-12', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (195, 'uzi', 7, 'ItemWeapon', 'Uzi', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (196, 'mp5', 7, 'ItemWeapon', 'MP5', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (197, 'tec9', 7, 'ItemWeapon', 'Tec-9', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (198, 'ak47', 7, 'ItemWeapon', 'AK-47', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (199, 'm4', 7, 'ItemWeapon', 'M4', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (200, 'rifle', 7, 'ItemWeapon', 'Jagdgewehr', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (201, 'sniper', 7, 'ItemWeapon', 'Scharfschützengewehr', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (202, 'rocketLauncher', 7, 'ItemWeapon', 'Raketenwerfer', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (203, 'rocketLauncherHS', 7, 'ItemWeapon', 'Javelin', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (204, 'flamethrower', 7, 'ItemWeapon', 'Flammenwerfer', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (205, 'minigun', 7, 'ItemWeapon', 'Minigun', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (206, 'grenade', 7, 'ItemWeapon', 'Granate', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (207, 'teargas', 7, 'ItemWeapon', 'Tränengas', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (208, 'molotov', 7, 'ItemWeapon', 'Molotov', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (209, 'satchel', 7, 'ItemWeapon', 'Rucksackbombe', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (210, 'spraycan', 7, 'ItemWeapon', 'Spraydose', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (211, 'fireExtinguisher', 7, 'ItemWeapon', 'Feuerlöscher', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (212, 'camera', 7, 'ItemWeapon', 'Kamera', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (213, 'longDildo', 7, 'ItemWeapon', 'Langer Dildo', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (214, 'shortDildo', 7, 'ItemWeapon', 'Kurzer Dildo', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (215, 'vibrator', 7, 'ItemWeapon', 'Vibrator', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (216, 'flower', 7, 'ItemWeapon', 'Blumenstrauss', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (217, 'cane', 7, 'ItemWeapon', 'Gehstock', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (218, 'nightvision', 7, 'ItemWeapon', 'Nachtsichtgerät', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (219, 'infrared', 7, 'ItemWeapon', 'Wärmesichtgerät', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (220, 'parachute', 7, 'ItemWeapon', 'Fallschirm', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (221, 'satchelDetonator', 7, 'ItemWeapon', 'Fernzünder', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (222, 'colt45Bullet', 8, 'ItemWeapon', 'Colt 45 Patrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (223, 'taserBullet', 8, 'ItemWeapon', 'Taser Patrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (224, 'deagleBullet', 8, 'ItemWeapon', 'Deagle Kugel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (225, 'shotgunPallet', 8, 'ItemWeapon', 'Schrotpatrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (226, 'sawedOffPallet', 8, 'ItemWeapon', 'Abgesägte Schrotflintenpatrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (227, 'combatShotgunPallet', 8, 'ItemWeapon', 'SPAZ-12 Patrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (228, 'uziBullet', 8, 'ItemWeapon', 'Uzi Patrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (229, 'tec9Bullet', 8, 'ItemWeapon', 'Tec-9 Patrone', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (230, 'mp5Bullet', 8, 'ItemWeapon', 'MP5 Kugel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (231, 'ak47Bullet', 8, 'ItemWeapon', 'AK-47 Kugel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (232, 'm4Bullet', 8, 'ItemWeapon', 'M4 Kugel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (233, 'rifleBullet', 8, 'ItemWeapon', 'Flintenmunition', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (234, 'sniperBullet', 8, 'ItemWeapon', 'Scharfschützengewehrkugel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (235, 'rocketLauncherRocket', 8, 'ItemWeapon', 'Rakete', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (236, 'rocketLauncherHSRocket', 8, 'ItemWeapon', 'Rakete', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (237, 'flamethrowerGas', 8, 'ItemWeapon', 'Flammenwerfergas', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (238, 'minigunBullet', 8, 'ItemWeapon', 'Minigunkugel', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (239, 'spraycanGas', 8, 'ItemWeapon', 'Spraydosengas', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (240, 'fireExtinguisherGas', 8, 'ItemWeapon', 'Feuerlöschergas', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (241, 'cameraFilm', 8, 'ItemWeapon', 'Kamerafilm', '', 'Items/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (242, 'bottle', 4, 'ItemThrowable', 'Flasche', 'Leere Flasche, Gravität tut den Rest.', 'Items/EmptyBottle.png', 1486, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (243, 'trash', 4, 'ItemThrowable', 'Abfall', 'Dreckig, Gravität tut den Rest.', 'Items/Trash.png', 1265, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (244, 'shoe', 4, 'ItemThrowable', 'Schuh', 'Dreckig, Gravität tut den Rest.', 'Items/Schuh.png', 1901, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	]])


	sql:queryExec([[
		INSERT INTO `vrp_inventory_types` VALUES (1, 'player_inventory', 'Spielerinventar', '');
		INSERT INTO `vrp_inventory_types` VALUES (2, 'weaponbox', 'Waffenbox', '[ [\"faction\": [1, 2, 3] ] ]');
		INSERT INTO `vrp_inventory_types` VALUES (3, 'coolingBox', 'Kühlbox', '');
		INSERT INTO `vrp_inventory_types` VALUES (4, 'trunk', 'Kofferaum', '');
		INSERT INTO `vrp_inventory_types` VALUES (5, 'factionDepot', 'Fraktions Depot', '');
		INSERT INTO `vrp_inventory_types` VALUES (6, 'property', 'Immobilie', '');
	]])


	sql:queryExec([[
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 1);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 2);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 3);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 4);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 5);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 7);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 8);
		INSERT INTO `vrp_inventory_type_categories` VALUES (2, 2);
		INSERT INTO `vrp_inventory_type_categories` VALUES (3, 6);
		INSERT INTO `vrp_inventory_type_categories` VALUES (4, 1);
		INSERT INTO `vrp_inventory_type_categories` VALUES (4, 2);
		INSERT INTO `vrp_inventory_type_categories` VALUES (4, 3);
		INSERT INTO `vrp_inventory_type_categories` VALUES (4, 4);
		INSERT INTO `vrp_inventory_type_categories` VALUES (4, 5);
	]])

	local ItemMapping = {
		["Weed"] = "weed", ["Burger"] = "burger", ["Benzinkanister"] = "jerrycan", ["Chips"] = "chips", ["Fernglas"] = "binoculars", ["Medikit"] = "medkit",
		["Radio"] = "radio", ["Wuerfel"] = "dice", ["Zigarette"] = "cigarette", ["Pfeffermunition"] = "pepperAmunation", ["Ausweis"] = "identityCard",
		["Weed-Samen"] = "weedSeed", ["Shrooms"] = "shrooms", ["Pommes"] = "fries", ["Snack"] = "candyBar", ["Bier"] = "beer", ["eXoPad"] = "exoPad",
		["Gameboy"] = "gameBoy", ["Mats"] = "materials", ["Fische"] = "fish", ["Zeitung"] = "newspaper", ["Ecstasy"] = "ecstasy", ["Heroin"] = "heroin",
		["Kokain"] = "cocaine", ["Reparaturkit"] = "repairKit", ["Suessigkeiten"] = "candies", ["Kürbis"] = "pumpkin", ["Päckchen"] = "packet",
		["Gluehwein"] = "gluvine", ["Kaffee"] = "coffee", ["Lebkuchen"] = "gingerbread", ["Shot"] = "shot", ["Wuerstchen"] = "sousage", ["Mautpass"] = "tollTicket",
		["Keks"] = "cookie", ["Helm"] = "helmet", ["Maske"] = "mask", ["Kuheuter mit Pommes"] = "cowUdderWithFries", ["Zombie-Burger"] = "zombieBurger",
		["Weihnachtsmütze"] = "christmasHat", ["Barrikade"] = "barricade", ["Sprengstoff"] = "explosive", ["Pizza"] = "pizza", ["Pilz"] = "mushroom",
		["Kanne"] = "can", ["Handelsvertrag"] = "sellContract", ["Blitzer"] = "speedCamera", ["Nagel-Band"] = "nailStrip", ["Whiskey"] = "whiskey",
		["Sex on the Beach"] = "sexOnTheBeach", ["Pina Colada"] = "pinaColada", ["Monster"] = "monster", ["Cuba-Libre"] = "cubaLibre", ["Donutbox"] = "donutBox",
		["Donut"] = "donut", ["Helm"] = "integralHelmet", ["Motorcross-Helm"] = "motoHelmet", ["Pot-Helm"] = "pothelmet", ["Gasmaske"] = "gasmask",
		["Kevlar"] = "kevlar", ["Tragetasche"] = "duffle", ["Swatschild"] = "swatshield", ["Diebesgut"] = "stolenGoods", ["Kleidung"] = "clothing",
		["Bambusstange"] = "bambooFishingRod", ["Kleine Kühltasche"] = "coolingBoxSmall", ["Kühltasche"] = "coolingBoxMedium", ["Kühlbox"] = "coolingBoxLarge",
		["Einsatzhelm"] = "swathelmet", ["Köder"] = "bait", ["Osterei"] = "easterEgg", ["Hasenohren"] = "bunnyEars", ["Warnkegel"] = "warningCones",
		["Apfel"] = "apple", ["Apfelbaum-Samen"] = "appleSeed", ["Trashcan"] = "trashcan", ["Taser"] = "taser", ["Zuckerstange"] = "candyCane",
		["Medikit"] = "medikit2", ["Keypad"] = "keypad", ["Tor"] = "gate", ["Eingang"] = "entrance", ["Rakete"] = "fireworksRocket",
		["Rohrbombe"] = "fireworksPipeBomb", ["Raketen Batterie"] = "fireworksBattery", ["Römische Kerze"] = "fireworksRoman",
		["Römische Kerzen Batterie"] = "fireworksRomanBattery", ["Kugelbombe"] = "fireworksBomb", ["Böller"] = "fireworksCracker", ["SLAM"] = "slam",
		["Rauchgranate"] = "smokeGrenade", ["Transmitter"] = "transmitter", ["Stern"] = "star", ["Keycard"] = "keycard", ["Blumen-Samen"] = "flowerSeed",
		["DefuseKit"] = "defuseKit", ["Fischlexikon"] = "fishLexicon", ["Angelrute"] = "fishingRod", ["Profi Angelrute"] = "expertFishingRod",
		["Legendäre Angelrute"] = "legendaryFishingRod", ["Leuchtköder"] = "glowBait", ["Pilkerköder"] = "pilkerBait", ["Schwimmer"] = "swimmer",
		["Spinner"] = "spinner", ["Clubkarte"] = "clubCard", ["Flasche"] = "bottle", ["Abfall"] = "trash", ["Schuh"] = "shoe"
	}

	local WeaponMapping = {
		[1] = "brassknuckle", [2] = "golfclub", [3] = "nightstick", [4] = "knife", [5] = "bat", [6] = "shovel", [7] = "poolstick", [8] = "katana", [9] = "chainsaw",
		[10] = "longDildo", [11] = "shortDildo", [12] = "vibrator", [14] = "flower",  [15] = "cane", [16] = "grenade", [17] = "teargas", [18] = "molotov",
		[22] = "colt45", [23] = "taser", [24] = "deagle", [25] = "shotgun", [26] = "sawedOff", [27] = "combatShotgun", [28] = "uzi", [29] = "mp5", [30] = "ak47",
		[31] = "m4", [32] = "tec9", [33] = "rifle", [34] = "sniper", [35] = "rocketLauncher", [36] = "rocketLauncherHS", [37] = "flamethrower", [38] = "minigun",
		[39] = "satchel", [40] = "satchelDetonator", [41] = "spraycan", [42] = "fireExtinguisher", [43] = "camera", [44] = "nightvision", [45] = "infrared",
		[46] = "parachute"
	}

	local WeaponMappingAmmunition = {
		[22] = "colt45Bullet", [23] = "taserBullet", [24] = "deagleBullet", [25] = "shotgunPallet", [26] = "sawedOffPallet", [27] = "combatShotgunPallet",
		[28] = "uziBullet", [29] = "mp5Bullet", [30] = "ak47Bullet", [31] = "m4Bullet", [32] = "tec9Bullet", [33] = "rifleBullet", [34] = "sniperBullet",
		[35] = "rocketLauncherRocket", [36] = "rocketLauncherHSRocket", [37] = "flamethrowerGas", [38] = "minigunBullet"
	}

	local WeaponAmmoIsDurability = {
		[41] = "spraycan", [42] = "fireExtinguisher", [43] = "camera"
	}

	local FishMapping = {
		[1] = "albacore", [2] = "anchovy", [3] = "bream", [4] = "bullhead", [5] = "carp", [6] = "catfish", [7] = "chub", [8] = "dorado", [9] = "eel", [10] = "halibut",
		[11] = "herring", [12] = "largemouthBass", [13] = "lingcod", [14] = "squid", [15] = "perch", [16] = "pike", [17] = "pufferfish", [18] = "rainbowTrout",
		[19] = "redMullet", [20] = "redSnapper", [21] = "salmon", [22] = "sandfish", [23] = "sardine", [24] = "seaCucumber", [25] = "shad", [26] = "smallmouthBass",
		[27] = "octopus", [28] = "stonefish", [29] = "sturgeon", [30] = "sunfish", [31] = "superCucumber", [32] = "tigerTrout", [33] = "tilapia", [34] = "tuna",
		[35] = "walleye", [36] = "snailfish", [37] = "blobfisch", [38] = "barbeledDragonfish", [39] = "voidSalmon", [40] = "slimejack", [41] = "swordfish",
		[42] = "indianGlassCatfish", [43] = "forestJumper", [44] = "mudWhipper", [45] = "sableFish", [46] = "lakeTrout", [47] = "burbot", [48] = "sootyNose",
		[49] = "rudd", [50] = "roach", [51] = "asp", [52] = "pearlFish", [53] = "threeSpinedStrickleback", [54] = "ghostFish", [55] = "perch", [56] = "zander",
		[57] = "blackSeabream", [58] = "duskyGrouper", [59] = "eaglefish", [60] = "salmonHerring", [61] = "sabreToothedFish", [62] = "deepSeaDevil", [63] = "viperFish",
		[64] = "hammerheadJawfish", [65] = "sawBelly", [66] = "luminousHerring", [67] = "scaledFish", [68] = "longTailedHake", [69] = "tripod", [70] = "rodAngler",
		[71] = "oarfish", [72] = "cod", [73] = "mutantSardine", [74] = "mutantCarp", [75] = "scorpionCarp"
	}

	local items = sql:queryFetch("SELECT * FROM ??_items", sql:getPrefix())
	local ItemMappingId = {}
	local ItemMappingExpire = {}
	for _, item in pairs(items) do
		ItemMappingId[item.TechnicalName] = item.Id
		ItemMappingExpire[item.TechnicalName] = item.MaxExpireTime
	end

	-- Step 1 - Create player inventories
	local players = sql:queryFetch("SELECT * FROM ??_account", sql:getPrefix())
	local query = "INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES "
	local first = true

	for _, player in pairs(players) do
		if first then
			first = false
		else
			query = query .. ", "
		end
		query = query .. "(" .. player.Id .. ", " .. DbElementType.Player .. ", 40, 1)"
	end

	sql:queryExec(query, sql:getPrefix())

	-- Step 1 - Create player weapon box
	local query = "INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES "
	local first = true

	for _, player in pairs(players) do
		if first then
			first = false
		else
			query = query .. ", "
		end
		query = query .. "(" .. player.Id .. ", " .. DbElementType.WeaponBox .. ", 8, 2)"
	end

	sql:queryExec(query, sql:getPrefix())

	local nextId = 1

	local inventoriesDb = sql:queryFetch("SELECT * FROM ??_inventories WHERE ElementType = " .. DbElementType.Player .. " OR ElementType = " .. DbElementType.WeaponBox .. "", sql:getPrefix())
	local inventories = {}
	local inventoriesWeapon = {}
	for _, inventory in pairs(inventoriesDb) do
		if inventory.ElementType == 1 then
			inventories[inventory.ElementId] = inventory.Id
		elseif inventory.ElementType == 8 then
			inventoriesWeapon[inventory.ElementId] = inventory.Id
		end
	end

	local items = sql:queryFetch("SELECT * FROM ??_inventory_slots ORDER BY PlayerId ASC", sql:getPrefix())
	local query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Tradeable, Slot, Amount, Durability, ExpireTime, Metadata) VALUES "
	local first = true
	local playerSlot = {}
	local count = 1
	local total = table.size(items)

	for _, item in pairs(items) do
		if inventories[item.PlayerId] then
			if ItemMapping[item.Objekt] then
				local itemTechnicalName = ItemMapping[item.Objekt]
				local metadata = "NULL"
				local durability = 0

				if not playerSlot[item.PlayerId] then playerSlot[item.PlayerId] = 1 end

				--[[
					Kleine Kühltasche
					Kühlbox
					Kühltasche
				]]
				if item.Value and item.Value ~= "" then
					if itemTechnicalName == "clothing" then
						metadata = "\"[".. item.Value .."]\""
					elseif itemTechnicalName == "can" then
						durability = item.Value
					elseif itemTechnicalName == "donutBox" then
						durability = item.Value
					elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
						durability = item.WearLevel
					elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
						durability = item.WearLevel
					elseif itemTechnicalName == "clubCard" then
						metadata = "\"[".. item.Value .."]\""
					elseif itemTechnicalName == "tollTicket" then
						metadata = "\"[".. item.Value .."]\""
					end
				end


				if item.Value and item.Value ~= "" and (itemTechnicalName == "coolingBoxSmall" or itemTechnicalName == "coolingBoxMedium" or itemTechnicalName == "coolingBoxLarge") then
					sql:queryExec("INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Slot, Amount, Durability, Metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ??)",
						sql:getPrefix(), nextId, inventories[item.PlayerId], ItemMappingId[itemTechnicalName], item.PlayerId, playerSlot[item.PlayerId], 1, 0, "NULL")
					local coolingBoxId = sql:lastInsertId()
					playerSlot[item.PlayerId] = playerSlot[item.PlayerId] + 1
					nextId = nextId + 1

					sql:queryExec("INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES (?, ?, ?, ?)",
						sql:getPrefix(), coolingBoxId, DbElementType.CoolingBox, 40, 3)

					local coolingBoxInventoryId = sql:lastInsertId()
					local coolingBoxSlot = 1

					local fishes = fromJSON(item.Value)

					if fishes then
						--  [ [ { "fishName": "Karpfen", "Id": 5, "timestamp": 1532891919, "size": 84, "quality": 1 }, { "fishName": "Kaulbarsch", "Id": 7, "timestamp": 1532892059, "quality": 0, "size": 41 } ] ]
						local tmpQuery = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Slot, Amount, Durability, ExpireTime, Metadata, CreatedAt) VALUES "
						local tmpFirst = true
						local params = {}
						for _, v in pairs(fishes) do
							local fishName = FishMapping[v.Id]
							local timestamp = os.time()

							if v.timestamp and v.timestamp > 0 then
								timestamp = v.timestamp
							end

							local data = {}

							if v.size then
								data.size = v.size
							end

							if v.quality then
								data.quality = v.quality
							end

							data = toJSON(data, true)
							data = data:sub(2, #data-1)
							table.insert(params, data)
							if tmpFirst then tmpFirst = false else tmpQuery = tmpQuery .. ", " end
							tmpQuery = tmpQuery .. "(" .. nextId .. ", " .. coolingBoxInventoryId .. ", " .. ItemMappingId[fishName] .. ", " .. item.PlayerId .. ", " .. coolingBoxSlot .. ", 1, 0, " .. ItemMappingExpire[fishName] .. ", ?, FROM_UNIXTIME(" .. timestamp .. "))"
							coolingBoxSlot = coolingBoxSlot + 1
							nextId = nextId + 1
						end
						if not tmpFirst then sql:queryExec(tmpQuery, sql:getPrefix(), unpack(params)) end
					end
				else
					if first then first = false else query = query .. ", " end
					query = query .. "(" .. nextId .. ", " .. inventories[item.PlayerId].. ", " .. ItemMappingId[itemTechnicalName] .. ", " .. item.PlayerId .. ", " .. 1 .. ", " .. playerSlot[item.PlayerId] .. ", " .. item.Menge .. ", " .. durability .. ", " .. ItemMappingExpire[itemTechnicalName] .. ", " .. metadata .. ")"
					playerSlot[item.PlayerId] = playerSlot[item.PlayerId] + 1
					nextId = nextId + 1
				end
			else
				outputServerLog("[MIGRATION] Found unknown item " .. tostring(item.Objekt) .. " for player " .. tostring(item.PlayerId))
			end
		else
			--outputServerLog("[MIGRATION] Failed to migrate item " .. tostring(item.Objekt) .. " for player " .. tostring(item.PlayerId))
		end

		if count % 2500 == 0 then
			outputServerLog("[MIGRATION] WAIT PLAYER ITEMS " .. tostring(count) .. "/" .. tostring(total))
			if not first then
				first = true
				sql:queryExec(query, sql:getPrefix())
				query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Tradeable, Slot, Amount, Durability, ExpireTime, Metadata) VALUES "
			end
		end
		count = count + 1
	end

	if not first then sql:queryExec(query, sql:getPrefix()) end
	outputServerLog("[MIGRATION] FINISH PLAYER ITEMS " .. tostring(count - 1) .. "/" .. tostring(total))

	local items = sql:queryFetch("SELECT Id, Weapons, GunBox FROM ??_character", sql:getPrefix())
	local query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Slot, Amount, Durability, Metadata) VALUES "
	local first = true
	local count = 1
	local total = table.size(items)
	local weaponBoxSlot = {}

	for _, item in pairs(items) do
		-- Do some magic for weapons
		if item.Weapons then
			local weapons = fromJSON(item.Weapons)
			if weapons then
				for _, weapon in pairs(weapons) do
					if weapon[1] ~= 0 and WeaponMapping[weapon[1]] and inventories[item.Id] then
						if not playerSlot[item.Id] then playerSlot[item.Id] = 1 end
						local menge = 1
						local durability = 0
						local metadata = "NULL"

						if first then
							first = false
						else
							query = query .. ", "
						end

						if not WeaponMappingAmmunition[weapon[1]] then
							if WeaponAmmoIsDurability[weapon[1]] then
								durability = weapon[2]
							else
								menge = weapon[2]
							end
						end

						query = query .. "(" .. nextId .. ", " .. inventories[item.Id].. ", " .. ItemMappingId[WeaponMapping[weapon[1]]] .. ", " .. item.Id .. ", " .. playerSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
						playerSlot[item.Id] = playerSlot[item.Id] + 1
						nextId = nextId + 1


						if WeaponMappingAmmunition[weapon[1]] then
							query = query .. ", "

							menge = weapon[2]
							durability = 0
							metadata = "NULL"
							query = query .. "(" .. nextId .. ", " .. inventories[item.Id].. ", " .. ItemMappingId[WeaponMappingAmmunition[weapon[1]]] .. ", " .. item.Id .. ", " .. playerSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
							playerSlot[item.Id] = playerSlot[item.Id] + 1
							nextId = nextId + 1
						end
					end
				end
			end
		end



		if item.GunBox then
			local weapons = fromJSON(item.GunBox)
			if weapons then
				for _, weapon in pairs(weapons) do
					if weapon.WeaponId ~= 0 and WeaponMapping[weapon.WeaponId] and inventoriesWeapon[item.Id] then
						if not weaponBoxSlot[item.Id] then weaponBoxSlot[item.Id] = 1 end
						local menge = 1
						local durability = 0
						local metadata = "NULL"

						if first then
							first = false
						else
							query = query .. ", "
						end

						if not WeaponMappingAmmunition[weapon.WeaponId] then
							if WeaponAmmoIsDurability[weapon.WeaponId] then
								durability = weapon.Amount
							else
								menge = weapon.Amount
							end
						end

						query = query .. "(" .. nextId .. ", " .. inventoriesWeapon[item.Id].. ", " .. ItemMappingId[WeaponMapping[weapon.WeaponId]] .. ", " .. item.Id .. ", " .. weaponBoxSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
						weaponBoxSlot[item.Id] = weaponBoxSlot[item.Id] + 1
						nextId = nextId + 1


						if WeaponMappingAmmunition[weapon.WeaponId] then
							query = query .. ", "

							menge = weapon.Amount
							durability = 0
							metadata = "NULL"
							query = query .. "(" .. nextId .. ", " .. inventoriesWeapon[item.Id].. ", " .. ItemMappingId[WeaponMappingAmmunition[weapon.WeaponId]] .. ", " .. item.Id .. ", " .. weaponBoxSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
							weaponBoxSlot[item.Id] = weaponBoxSlot[item.Id] + 1
							nextId = nextId + 1
						end
					end
				end
			end
		end

		if count % 500 == 0 then
			outputServerLog("[MIGRATION] WAIT PLAYER WEAPONS " .. tostring(count) .. "/" .. tostring(total))
			if not first then
				first = true
				sql:queryExec(query, sql:getPrefix())
				query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Slot, Amount, Durability, Metadata) VALUES "
			end
		end
		count = count + 1
	end

	if not first then sql:queryExec(query, sql:getPrefix()) end
	outputServerLog("[MIGRATION] FINISH PLAYER WEAPONS " .. tostring(count - 1) .. "/" .. tostring(total))

	local vehicles = sql:queryFetch("SELECT Id, TrunkId FROM ??_vehicles", sql:getPrefix())
	local query = "INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES "
	local first = true

	for _, vehicle in pairs(vehicles) do
		if first then
			first = false
		else
			query = query .. ", "
		end
		query = query .. "(" .. vehicle.Id .. ", " .. DbElementType.Vehicle .. ", 30, 4)" -- TODO add logic for different trunk sizes
	end

	sql:queryExec(query, sql:getPrefix())

	local inventoriesDb = sql:queryFetch("SELECT * FROM ??_inventories WHERE ElementType = " .. DbElementType.Vehicle, sql:getPrefix())
	local inventories = {}
	for _, inventory in pairs(inventoriesDb) do
		inventories[inventory.ElementId] = inventory.Id
	end

	local trunkVehicleId = {}

	for _, vehicle in pairs(vehicles) do
		if vehicle.TrunkId and vehicle.TrunkId ~= 0 then
			trunkVehicleId[vehicle.TrunkId] = vehicle.Id
		end
	end

	local items = sql:queryFetch("SELECT * FROM ??_vehicle_trunks", sql:getPrefix())
	local trunkSlot = {}
	local query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, Slot, Amount, Durability, Metadata) VALUES "
	local first = true
	local total = table.size(items)
	local count = 1

	for _, item in pairs(items) do
		if trunkVehicleId[item.Id] and inventories[trunkVehicleId[item.Id]] then
			local inventoryId = inventories[trunkVehicleId[item.Id]]
			if not trunkSlot[item.Id] then trunkSlot[item.Id] = 1 end

			local itemSlot1 = fromJSON(item.ItemSlot1)
			local itemSlot2 = fromJSON(item.ItemSlot2)
			local itemSlot3 = fromJSON(item.ItemSlot3)
			local itemSlot4 = fromJSON(item.ItemSlot4)
			local weaponSlot1 = fromJSON(item.WeaponSlot1)
			local weaponSlot1 = fromJSON(item.WeaponSlot2)
			local itemsNew = {itemSlot1, itemSlot2, itemSlot3, itemSlot4}
			local weaponsNew = {weaponSlot1, weaponSlot2}

			for _, v in pairs(itemsNew) do
				if v.Item ~= "none" and v.Item ~= "" then
					if ItemMapping[v.Item] then
						local itemTechnicalName = ItemMapping[v.Item]

						local menge = v.Amount
						local durability = 0
						local metadata = "NULL"

						--[[
							Kleine Kühltasche [ [ { "Id": 10, "timestamp": 1547756920, "size": 61, "quality": 1 }, { "Id": 10, "timestamp": 1547756954, "quality": 1, "size": 56 }, { "Id": 11, "timestamp": 1547756983, "size": 29, "quality": 0 }, { "Id": 16, "timestamp": 1547757012, "quality": 1, "size": 107 }, { "Id": 11, "timestamp": 1547757055, "size": 33, "quality": 1 }, { "Id": 16, "timestamp": 1547757084, "quality": 1, "size": 92 }, { "Id": 10, "timestamp": 1547757111, "size": 56, "quality": 1 }, { "Id": 11, "timestamp": 1547757151, "quality": 0, "size": 27 }, { "Id": 11, "timestamp": 1547757180, "size": 32, "quality": 1 }, { "Id": 10, "timestamp": 1547757201, "quality": 0, "size": 43 }, { "Id": 10, "timestamp": 1547757226, "size": 62, "quality": 1 }, { "Id": 10, "timestamp": 1547757253, "quality": 1, "size": 55 }, { "Id": 16, "timestamp": 1547757625, "size": 108, "quality": 1 }, { "Id": 16, "timestamp": 1547757672, "quality": 1, "size": 97 }, { "Id": 11, "timestamp": 1547757722, "size": 27, "quality": 0 }, { "Id": 10, "timestamp": 1547757818, "quality": 1, "size": 47 }, { "Id": 11, "timestamp": 1547757885, "size": 20, "quality": 0 }, { "Id": 11, "timestamp": 1547757927, "quality": 0, "size": 25 }, { "Id": 16, "timestamp": 1547758015, "size": 80, "quality": 1 }, { "Id": 11, "timestamp": 1547799344, "quality": 1, "size": 37 }, { "Id": 16, "timestamp": 1547799373, "size": 106, "quality": 1 }, { "Id": 10, "timestamp": 1547799403, "quality": 1, "size": 47 }, { "Id": 23, "timestamp": 1547799433, "size": 13, "quality": 1 }, { "Id": 23, "timestamp": 1547799467, "quality": 1, "size": 17 }, { "Id": 19, "timestamp": 1547799495, "size": 34, "quality": 0 }, { "Id": 34, "timestamp": 1547799526, "quality": 1, "size": 104 }, { "Id": 10, "timestamp": 1547799547, "size": 52, "quality": 1 }, { "Id": 16, "timestamp": 1547799580, "quality": 3, "size": 155 }, { "Id": 19, "timestamp": 1547799602, "size": 36, "quality": 1 }, { "Id": 11, "timestamp": 1547799643, "quality": 1, "size": 32 }, { "Id": 11, "timestamp": 1547799696, "size": 53, "quality": 3 }, { "Id": 23, "timestamp": 1547799721, "quality": 1, "size": 16 }, { "Id": 16, "timestamp": 1547799748, "size": 104, "quality": 1 }, { "Id": 23, "timestamp": 1547799780, "quality": 0, "size": 10 }, { "Id": 19, "timestamp": 1547799811, "size": 43, "quality": 1 }, { "Id": 16, "timestamp": 1547799837, "quality": 1, "size": 83 }, { "Id": 19, "timestamp": 1547799868, "size": 41, "quality": 1 }, { "Id": 23, "timestamp": 1547799900, "quality": 1, "size": 16 }, { "Id": 34, "timestamp": 1547799921, "size": 105, "quality": 1 }, { "Id": 16, "timestamp": 1547799943, "quality": 1, "size": 88 }, { "Id": 10, "timestamp": 1547799966, "size": 60, "quality": 1 }, { "Id": 23, "timestamp": 1547800003, "quality": 0, "size": 7 }, { "Id": 11, "timestamp": 1547800042, "size": 34, "quality": 1 }, { "Id": 11, "timestamp": 1547800072, "quality": 1, "size": 34 }, { "Id": 34, "timestamp": 1547800087, "size": 114, "quality": 1 }, { "Id": 11, "timestamp": 1547800136, "quality": 1, "size": 32 } ] ]
							Kühlbox     [ [ { "Id": 5, "timestamp": 1547588718, "quality": 0, "size": 38 } ] ]
							Kühltasche  [ [ { "fishName": "Karpfen", "Id": 5, "timestamp": 1532891919, "size": 84, "quality": 1 }, { "fishName": "Kaulbarsch", "Id": 7, "timestamp": 1532892059, "quality": 0, "size": 41 } ] ]
						]]

						if v.Value and v.Value ~= "" then
							if itemTechnicalName == "clothing" then
								metadata = "\"[".. v.Value .."]\""
							elseif itemTechnicalName == "can" then
								durability = v.Value
							elseif itemTechnicalName == "donutBox" then
								durability = v.Value
							elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
							--	durability = v.WearLevel
							elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
							--	durability = v.WearLevel
							elseif itemTechnicalName == "clubCard" then
								metadata = "\"[".. v.Value .."]\""
							elseif itemTechnicalName == "tollTicket" then
								metadata = "\"[".. v.Value .."]\""
							end
						end

						if v.Value and v.Value ~= "" and (itemTechnicalName == "coolingBoxSmall" or itemTechnicalName == "coolingBoxMedium" or itemTechnicalName == "coolingBoxLarge") then
							outputServerLog("COOLING BOX IN VEHICLE")
						else
							if first then first = false else query = query .. ", " end
							query = query .. "(" .. nextId .. ", " .. inventoryId .. ", " .. ItemMappingId[itemTechnicalName] .. ", " .. trunkSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
							trunkSlot[item.Id] = trunkSlot[item.Id] + 1
							nextId = nextId + 1
						end
					end
				end
			end

			for _, weapon in pairs(weaponsNew) do
				if weapon.WeaponId ~= 0 and WeaponMapping[weapon.WeaponId] and inventoriesWeapon[item.Id] then
					if not weaponBoxSlot[item.Id] then weaponBoxSlot[item.Id] = 1 end
					local menge = 1
					local durability = 0
					local metadata = "NULL"

					if first then
						first = false
					else
						query = query .. ", "
					end

					if not WeaponMappingAmmunition[weapon.WeaponId] then
						if WeaponAmmoIsDurability[weapon.WeaponId] then
							durability = weapon.Amount
						else
							menge = weapon.Amount
						end
					end

					query = query .. "(" .. nextId .. ", " .. inventoriesWeapon[item.Id].. ", " .. ItemMappingId[WeaponMapping[weapon.WeaponId]] .. ", " .. weaponBoxSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
					weaponBoxSlot[item.Id] = weaponBoxSlot[item.Id] + 1
					nextId = nextId + 1


					if WeaponMappingAmmunition[weapon.WeaponId] then
						query = query .. ", "

						menge = weapon.Amount
						durability = 0
						metadata = "NULL"
						query = query .. "(" .. nextId .. ", " .. inventoriesWeapon[item.Id].. ", " .. ItemMappingId[WeaponMappingAmmunition[weapon.WeaponId]] .. ", " .. weaponBoxSlot[item.Id] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
						weaponBoxSlot[item.Id] = weaponBoxSlot[item.Id] + 1
						nextId = nextId + 1
					end
				end
			end
		else
			--outputServerLog("[MIGRATION] Unknown trunk " .. tostring(item.Id))
		end

		if count % 500 == 0 then
			outputServerLog("[MIGRATION] WAIT VEHICLE TRUNK " .. tostring(count - 1) .. "/" .. tostring(total))
			if not first then
				first = true
				sql:queryExec(query, sql:getPrefix())
				query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, Slot, Amount, Durability, Metadata) VALUES "
			end
		end
		count = count + 1
	end

	if not first then sql:queryExec(query, sql:getPrefix()) end
	outputServerLog("[MIGRATION] FINISH VEHICLE TRUNK " .. tostring(count - 1) .. "/" .. tostring(total))


	local items = sql:queryFetch("SELECT * FROM ??_depot", sql:getPrefix())
	local factions = sql:queryFetch("SELECT * FROM ??_factions", sql:getPrefix())
	local properties = sql:queryFetch("SELECT * FROM ??_group_property", sql:getPrefix())

	local query = "INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES "
	local first = true
	local depotOwners = {}
	for _, item in pairs(items) do
		if item.OwnerType == "faction" then
			for _, v in pairs(factions) do
				if item.Id == v.Depot then
					if first then first = false else query = query .. ", " end
					depotOwners[item.Id] = {ElementId = v.Id, ElementType = 2}
					query = query .. "(" .. v.Id .. ", " .. DbElementType.Faction .. ", 10000, 5)"
					break
				end
			end
		elseif item.OwnerType == "GroupProperty" then
			for _, v in pairs(properties) do
				if item.Id == v.DepotId then
					if first then first = false else query = query .. ", " end
					depotOwners[item.Id] = {ElementId = v.Id, ElementType = 7}
					query = query .. "(" .. v.Id .. ", " .. DbElementType.Property .. ", 40, 6)" -- well
					break
				end
			end
		end
	end

	if not first then sql:queryExec(query, sql:getPrefix()) end

	local inventoriesDb = sql:queryFetch("SELECT * FROM ??_inventories WHERE ElementType = " .. DbElementType.Faction .. " OR ElementType = " .. DbElementType.Property, sql:getPrefix())
	local inventories = {}

	for _, inventory in pairs(inventoriesDb) do
		for depot, v in pairs(depotOwners) do
			if v.ElementType == inventory.ElementType and v.ElementId == inventory.ElementId then
				inventories[depot] = inventory.Id
				break
			end
		end
	end


	local query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, Slot, Amount, Durability, Metadata) VALUES "
	local first = true
	local total = table.size(items)
	local count = 1
	local depotSlot = {}

	for _, item in pairs(items) do
		local inventoryId = inventories[item.Id]
		local weapons = fromJSON(item.Weapons)
		local items2 = fromJSON(item.Items)
		local equipments = item.Equipments and fromJSON(item.Equipments) or false

		if weapons then
			for _, weapon in pairs(weapons) do
				if weapon.Id ~= 0 and (weapon.Waffe ~= 0 or weapon.Munition ~= 0) and WeaponMapping[weapon.Id] then
					if not depotSlot[inventoryId] then depotSlot[inventoryId] = 1 end

					for i = 1, weapon.Waffe, 1 do
						if first then first = false else query = query .. ", " end
						local menge = 1
						local durability = 0
						local metadata = "NULL"

						if not WeaponMappingAmmunition[weapon.Id] then
							--[[
							if WeaponAmmoIsDurability[weapon.Id] then
								durability = weapon.Munition
							else
								menge = weapon.Munition
							end
							]]
							-- TODO well fucked?
						end

						query = query .. "(" .. nextId .. ", " .. inventoryId .. ", " .. ItemMappingId[WeaponMapping[weapon.Id]] .. ", " .. depotSlot[inventoryId] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
						depotSlot[inventoryId] = depotSlot[inventoryId] + 1
						nextId = nextId + 1
					end


					if WeaponMappingAmmunition[weapon.Id] and weapon.Munition ~= 0 then
						if first then first = false else query = query .. ", " end

						menge = weapon.Munition
						durability = 0
						metadata = "NULL"
						query = query .. "(" .. nextId .. ", " .. inventoryId .. ", " .. ItemMappingId[WeaponMappingAmmunition[weapon.Id]] .. ", " .. depotSlot[inventoryId] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
						depotSlot[inventoryId] = depotSlot[inventoryId] + 1
						nextId = nextId + 1
					end
				end
			end
		end

		if items2 then
			for _, v in pairs(items2) do
				if ItemMapping[v.Item] then
					local itemTechnicalName = ItemMapping[v.Item]
					if first then first = false else query = query .. ", " end
					if not depotSlot[inventoryId] then depotSlot[inventoryId] = 1 end

					local menge = v.Amount
					local durability = 0
					local metadata = "NULL"

					--[[
						Kleine Kühltasche
						Kühlbox
						Kühltasche
					]]
					if v.Value and v.Value ~= "" then
						if itemTechnicalName == "clothing" then
							metadata = "\"[".. v.Value .."]\""
						elseif itemTechnicalName == "can" then
							durability = v.Value
						elseif itemTechnicalName == "donutBox" then
							durability = v.Value
						elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
						--	durability = v.WearLevel
						elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
						--	durability = v.WearLevel
						elseif itemTechnicalName == "clubCard" then
							metadata = "\"[".. v.Value .."]\""
						elseif itemTechnicalName == "tollTicket" then
							metadata = "\"[".. v.Value .."]\""
						end
					end

					query = query .. "(" .. nextId .. ", " .. inventoryId .. ", " .. ItemMappingId[itemTechnicalName] .. ", " .. depotSlot[inventoryId] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
					depotSlot[inventoryId] = depotSlot[inventoryId] + 1
					nextId = nextId + 1
				end
			end
		end

		--[[
			[ {
				"Rauchgranate": 0,
				"Gasgranate": 0,
				"Granate": 0,
				"Gasmaske": 0,
				"Fallschirm": 0,
				"SLAM": 0,
				"DefuseKit": 0,
				"RPG-7": 0,
				"Scharfschützengewehr": 0
			} ]
		]]

		if equipments then
			for name, amount in pairs(equipments) do
				local itemTechnicalName = ItemMapping[name]
				if itemTechnicalName and amount > 0 then
					if first then first = false else query = query .. ", " end
					if not depotSlot[inventoryId] then depotSlot[inventoryId] = 1 end

					local menge = amount
					local durability = 0
					local metadata = "NULL"

					query = query .. "(" .. nextId .. ", " .. inventoryId .. ", " .. ItemMappingId[itemTechnicalName] .. ", " .. depotSlot[inventoryId] .. ", " .. menge .. ", " .. durability .. ", " .. metadata .. ")"
					depotSlot[inventoryId] = depotSlot[inventoryId] + 1
					nextId = nextId + 1
				end
			end
		end

		if count % 500 == 0 then
			outputServerLog("[MIGRATION] WAIT VEHICLE TRUNK " .. tostring(count - 1) .. "/" .. tostring(total))
			if not first then
				first = true
				sql:queryExec(query, sql:getPrefix())
				query = "INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, Slot, Amount, Durability, Metadata) VALUES "
			end
		end
		count = count + 1
	end

	if not first then sql:queryExec(query, sql:getPrefix()) end

	outputServerLog("========================================")
	outputServerLog("=     INVENTORY MIGRATION FINISHED     =")
	outputServerLog("========================================")
	setServerPassword()
	iprint(debug.gethook())
	iprint({h1 = h1, h2 = h2, h3 = h3, h4 = h4})
	debug.sethook(nil, h1, h2, h3) -- enable infinity loop check
	iprint(debug.gethook())
end
