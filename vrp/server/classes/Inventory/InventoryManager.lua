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

	if sql:queryFetchSingle("SHOW TABLES LIKE ?;", sql:getPrefix() .. "_items") then
		-- REDO migration
		outputDebugString("========================================")
		outputDebugString("=            RESET INVENTORY           =")
		outputDebugString("========================================")

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
		outputChatBox(tostring(inventory))

		self.m_InventorySubscriptions[elementType][elementId][player.m_Id] = true

		self:syncInventory(inventory.m_Id, player)
	end
end

function InventoryManager:Event_sunsubscribeFromInventory(elementType, elementId)
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
	local inventory = self.m_Inventories[inventoryId] and self.m_Inventories[inventoryId] or self:loadInventory(inventoryId)

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

	local inventory = Inventory.load(inventoryId, player, sync)

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

		local slot = self:getNextFreeSlot(inventory)

		if not slot then
			return false, "slot"
		end

		local id = inventory.m_NextItemId
		inventory.m_NextItemId = inventory.m_NextItemId + 1

		local data = table.copy(itemData)

		-- data.DatabaseId = uuid()
		data.Id = uuid()
		data.ItemId = item
		data.Slot = slot
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

function InventoryManager:getNextFreeSlot(inventory)
	local inventory = inventory

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if not inventory then
		return false
	end
	local totalSlots = 200 -- TODO: move this to database

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

function InventoryManager:migrate()
	local st = getTickCount()
	outputDebugString("========================================")
	outputDebugString("=     STARTING INVENTORY MIGRATION     =")
	outputDebugString("========================================")

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
			`Size` int(11) NOT NULL,
			`ModelId` int(11) NOT NULL DEFAULT 0,
			`MaxDurability` int(11) NOT NULL DEFAULT 0,
			`DurabilityDestroy` tinyint(1) NOT NULL COMMENT 'Destroys item on zero durability',
			`Consumable` tinyint(1) NOT NULL DEFAULT 0,
			`Tradeable` tinyint(1) NOT NULL DEFAULT 0,
			`Expireable` tinyint(1) NOT NULL DEFAULT 0,
			`IsUnique` tinyint(1) NOT NULL DEFAULT 0,
			`Throwable` tinyint(1) NOT NULL DEFAULT 0,
			`Breakable` tinyint(4) NOT NULL DEFAULT 0,
			`IsStackable` tinyint(1) NOT NULL DEFAULT 0,
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
			`Size` int NOT NULL,
			`TypeId` int NOT NULL,
			`Deleted` datetime NULL DEFAULT NULL,
			PRIMARY KEY (`Id`),
			FOREIGN KEY (`TypeId`) REFERENCES ??_inventory_types (`Id`)
		  );
	]], sql:getPrefix(), sql:getPrefix())

	sql:queryExec([[
		CREATE TABLE ??_inventory_items  (
			`Id` varchar(36) NOT NULL,
			`InventoryId` int(0) NOT NULL,
			`ItemId` int(0) NOT NULL,
			`Slot` int(0) NOT NULL,
			`Amount` int(0) NOT NULL,
			`Durability` int(0) NOT NULL,
			`Metadata` text NULL DEFAULT NULL,
			PRIMARY KEY (`Id`),
			FOREIGN KEY (`InventoryId`) REFERENCES ??_inventories (`Id`) ON DELETE CASCADE,
			FOREIGN KEY (`ItemId`) REFERENCES ??_items (`Id`)
		);
	]], sql:getPrefix(), sql:getPrefix(), sql:getPrefix())


	-- Insert data

	sql:queryExec([[
		INSERT INTO ??_item_categories VALUES
			(1, 'food', 'Essen'),
			(2, 'weapons', 'Waffen'),
			(3, 'items', 'Items'),
			(4, 'objects', 'Objekte'),
			(5, 'drugs', 'Drogen');
	]], sql:getPrefix())


	sql:queryExec([[
		INSERT INTO `vrp_items` VALUES (1, 'weed', 5, 'ItemDrugs', 'Weed', 'Weed ist geil', 'Drogen/Weed.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (2, 'burger', 1, 'ItemFood', 'Burger', 'Fuellt deinen Hunger auf', 'Essen/Burger.png', 1, 2880, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (3, 'jerrycan', 3, 'ItemFuelcan', 'Benzinkanister', 'Fuellt den Tank eines Fahrzeuges auf!', 'Items/Benzinkanister.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (4, 'chips', 3, '-', 'Chips', 'Casino-Chips', 'Items/Chips.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (5, 'binoculars', 3, '-', 'Fernglas', 'Augen wie ein Adler', 'Items/Fernglas.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (6, 'medkit', 3, 'ItemHealpack', 'Medikit', 'Fuellt deine Gesundheit auf', 'Items/Medikit.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (7, 'radio', 4, 'ItemRadio', 'Radio', 'Platzierbares Radio zum Musik abspielen!', 'Items/Radio.png', 1, 2226, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (8, 'dice', 3, 'ItemDice', 'Würfel', 'kleines Gluecksspiel', 'Items/Wuerfel.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (9, 'cigarette', 5, 'ItemFood', 'Zigarette', 'Rauche eine zwischendurch', 'Essen/Zigeretten.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (10, 'pepperAmunation', 3, '-', 'Pfeffermunition', 'Laesst den getroffenen Husten', 'Items/Munition.png', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (11, 'identityCard', 3, 'ItemIDCard', 'Ausweis', 'Personalausweis und Fuehrerscheine', 'Items/Ausweis.png', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (12, 'weedSeed', 5, 'ItemPlant', 'Weed-Samen', 'Samen der begehrten Weed-Pflanze', 'Drogen/Samen.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (13, 'shrooms', 5, 'ItemDrugs', 'Shrooms', 'illegale Pilze', 'Drogen/Shroom.png', 1, 1947, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (14, 'fries', 1, 'ItemFood', 'Pommes', 'Ein Snack fuer zwischen durch', 'Essen/Pommes.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (15, 'candyBar', 1, '-', 'Snack', 'Ein Schoko-Riegel für Zwischendurch', 'Essen/Snack.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (16, 'beer', 1, 'ItemAlcohol', 'Bier', 'Ein Bierchen am Morgen vertreibt Kummer und Sorgen', 'Essen/Bier.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (17, 'exoPad', 3, '-', 'eXoPad', 'Tablet von eXo-Reallife', 'Items/eXoPad.png', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (18, 'gameBoy', 3, '-', 'Gameboy', 'Spiele Tetris und knacke den Highscore', 'Items/Gameboy.png', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (19, 'materials', 3, '-', 'Mats', 'Baue Waffen aus diesen illegalen Materialien', 'Items/Mats.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (20, 'fish', 3, '-', 'Fische', 'Fische, frisch ausm Meer', 'Items/Fische.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (21, 'newspaper', 3, '-', 'Zeitung', 'Neuigkeiten der SAN-News', 'Items/Zeitung.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (22, 'ecstasy', 5, '-', 'Ecstasy', 'Finger weg von den Drogen!', 'Drogen/Ecstasy.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (23, 'heroin', 5, 'ItemDrugs', 'Heroin', 'Finger weg von den Drogen!', 'Drogen/Heroin.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (24, 'cocaine', 5, 'ItemDrugs', 'Kokain', 'Finger weg von den Drogen!', 'Drogen/Koks.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (25, 'repairKit', 3, 'ItemRepairKit', 'Reparaturkit', 'Zum reparieren von Totalschaeden', 'Items/Reparaturkit.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (26, 'candies', 1, 'ItemFood', 'Suessigkeiten', 'Was zum Naschen fuer Zwischendurch', 'Essen/Suessigkeiten.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (27, 'pumpkin', 3, 'ItemPumpkin', 'Kürbis', 'Sammle diese und Kauf dir wundervolle Praemien davon!', 'Items/Kuerbis.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (28, 'packet', 3, '-', 'Päckchen', 'Nettes Päckchen vom Weihnachtsmann', 'Items/Paeckchen.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (29, 'gluvine', 1, 'ItemAlcohol', 'Glühwein', 'Gibts was besseres zur kalten Adventzeit?', 'Essen/Gluehwein.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (30, 'coffee', 1, 'ItemFood', 'Kaffee', 'Warmer Kaffee, nicht vor dem Schlafen gehen trinken!', 'Essen/Kaffee.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (31, 'gingerbread', 1, 'ItemFood', 'Lebkuchen', 'Nette Jause zwischendurch in den kalten Monaten', 'Essen/Lebkuchen.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (32, 'shot', 1, 'ItemAlcohol', 'Shot', 'alkoholhaltiges Getraenk, das in 2-cl- oder 4-cl-Glaesern serviert und zumeist in einem Zug getrunken wird', 'Essen/Shot.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (33, 'sousage', 1, 'ItemFood', 'Würstchen', 'Lecker Wuerstchen mit Senf!', 'Essen/Wuerstchen.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (34, 'tollticket', 3, '-', 'Mautpass', 'Damit kommst du kostenlos durch Mautstellen. 1 Woche gueltig!', 'Items/Mautpass.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (35, 'cookie', 1, 'ItemFood', 'Keks', 'Verliehen von Entwicklern für besondere Verdienste', 'Items/Keks.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (36, 'helmet', 3, 'WearableHelmet', 'Helm', 'Safty First! Setze ihn auf wann immer du möchtest!', 'Items/Helm.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (37, 'mask', 3, '-', 'Maske', 'Verleihe dir ein nie dargewesenes Aussehen mit einer tollen Maske!', 'Items/Maske.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (38, 'cowUdderWithFries', 1, 'ItemFood', 'Kuheuter mit Pommes', 'Wiederliches Essen', 'Essen/Kuheuter mit Pommes.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (39, 'zombieBurger', 1, 'ItemFood', 'Zombie-Burger', 'Wiederliches Burger aus Zombiefleisch', 'Essen/Zombie-Burger.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (40, 'christmasHat', 3, 'WearableHelmet', 'Weihnachtsmütze', 'Weihnachtsmuetze', 'Objekte/Weihnachtsmuetze.png', 1, 1936, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (41, 'barricade', 4, 'ItemBarricade', 'Barrikade', 'Barrikade', 'Items/Barrikade.png', 1, 1422, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (42, 'explosive', 3, 'ItemBomb', 'Sprengstoff', 'Sprenge verschiedene Tueren', 'Items/Sprengstoff.png', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (43, 'pizza', 1, 'ItemFood', 'Pizza', 'Fuellt deinen Hunger auf', 'Essen/Pizza.png', 1, 2881, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (44, 'mushroom', 1, 'ItemFood', 'Pilz', 'Essbarer Pilz', 'Essen/Pilz.png', 1, 1882, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (45, 'can', 3, 'ItemCan', 'Kanne', 'Zum Bewaessern von Pflanzen', 'Items/Kanne.png', 1, 0, 10, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (46, 'sellContract', 3, 'ItemSellContract', 'Handelsvertrag', 'Dieser Vertrag wird zum verkaufen von Fahrzeugen benoetigt', 'Items/Contract.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (47, 'speedCamera', 4, 'ItemSpeedCam', 'Blitzer', 'Zum aufstellen und bestrafen von Geschwindikeitsueberschreitungen', 'Items/Blitzer.png', 1, 3902, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (48, 'nailStrip', 4, 'ItemNails', 'Nagel-Band', 'Fahrzeuge bekommen beim darueber fahren platte Reifen', 'Items/NagelBand.png', 1, 2892, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (49, 'whiskey', 1, 'ItemAlcohol', 'Whiskey', 'Whiskey ist eine durch Destillation aus Getreidemaische gewonnene und im Holzfass gereifte Spirituose.', 'Essen/Long Drink Brown.png', 1, 1455, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (50, 'sexOnTheBeach', 1, 'ItemAlcohol', 'Sex on the Beach', 'fruchtiger, maessig suesser Cocktail', 'Essen/Cocktail.png', 1, 1455, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (51, 'pinaColada', 1, 'ItemAlcohol', 'Pina Colada', 'ein suesser, cremiger Cocktail aus Rum, Kokosnusscreme und Ananassaft.', 'Essen/Cocktail.png', 1, 1455, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (52, 'monster', 1, 'ItemAlcohol', 'Monster', 'extrem starker Cocktail der einem die Schuhe auszieht', 'Essen/Cocktail.png', 1, 1455, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (53, 'cubaLibre', 1, 'ItemAlcohol', 'Cuba-Libre', 'ein Longdrink mit Rum und Cola, der um 1900 in Kuba entstand.', 'Essen/Long Drink Brown.png', 1, 1455, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (54, 'donutBox', 1, 'ItemDonutBox', 'Donutbox', ' ', 'Essen/ItemDonutBox.png', 1, 0, 9, 1, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (55, 'donut', 1, 'ItemFood', 'Donut', ' ', 'Essen/ItemDonut.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (56, 'integralHelmet', 3, 'WearableHelmet', 'Helm', 'Ein Integralhelm der dich vor Wind und Blicken schützt!', 'Objekte/helm.png', 1, 2052, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (57, 'motoHelmet', 3, 'WearableHelmet', 'Motorcross-Helm', 'Ein Motocross-Helm welcher sehr gut den Dreck beim Fahren abwendet!', 'Objekte/crosshelmet.png', 1, 2799, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (58, 'pothelmet', 3, 'WearableHelmet', 'Pot-Helm', 'Auf der Harley besonders stylish!', 'Objekte/bikerhelmet.png', 1, 3911, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (59, 'gasmask', 3, 'WearableHelmet', 'Gasmaske', 'Hält Gase fern!', 'Objekte/gasmask.png', 1, 3911, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (60, 'kevlar', 3, 'WearableShirt', 'Kevlar', 'Egal ob 9mm oder .45, alles wird gestoppt!', 'Objekte/kevlar.png', 1, 3916, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (61, 'duffle', 3, 'WearableShirt', 'Tragetasche', 'Es passt einiges hier rein!', 'Objekte/dufflebag.png', 1, 3915, 0, 0, 0, 1, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (62, 'swatshield', 3, 'WearablePortables', 'Swatschild', 'Ein Einsatzschild für Spezialtruppen!', 'Objekte/riot_shield.png', 1, 1631, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (63, 'stolenGoods', 3, '-', 'Diebesgut', 'Eine Beutel voller Gegenstände! Legal?', 'Objekte/diebesgut.png', 1, 3915, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (64, 'clothing', 3, '-', 'Kleidung', 'Ein Set Kleidung.', 'Items/Kleidung.png', 1, 1275, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (65, 'bambooFishingRod', 3, 'ItemFishing', 'Bambusstange', 'Wollen fangen Fische?', 'Items/Bamboorod.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (66, 'coolingBoxSmall', 3, 'ItemFishing', 'Kleine Kühltasche', 'Kühlt gut, wieder und wieder!', 'Items/Coolbag.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (67, 'coolingBoxMedium', 3, 'ItemFishing', 'Kühltasche', 'Kühlt gut, wieder und wieder!', 'Items/Coolbag.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (68, 'coolingBoxLarge', 3, 'ItemFishing', 'Kühlbox', 'Kühlt gut, wieder und wieder!', 'Items/Coolbox.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (69, 'swathelmet', 3, 'WearableHelmet', 'Einsatzhelm', 'Falls es hart auf hart kommt.', 'Objekte/einsatzhelm.png', 1, 3911, 0, 0, 0, 0, 0, 0, 1, 0, 1);
		INSERT INTO `vrp_items` VALUES (70, 'bait', 3, 'ItemFishing', 'Köder', 'Lockt ein paar Fische an und vereinfacht das Angeln', 'Items/Bait.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (71, 'easterEgg', 3, 'ItemEasteregg', 'Osterei', 'Event-Special: Osterei', 'Items/Osterei.png', 1, 1933, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (72, 'bunnyEars', 3, 'WearableHelmet', 'Hasenohren', 'Event-Special Hasenohren', 'Objekte/Hasenohren.png', 1, 1934, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (73, 'warningCones', 4, 'ItemBarricade', 'Warnkegel', 'zum Markieren von Einsatzorten', 'Objekte/Warnkegel.png', 1, 1238, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (74, 'apple', 1, 'ItemFood', 'Apfel', 'gesundes Obst', 'Essen/Apfel.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (75, 'appleSeed', 1, 'ItemPlant', 'Apfelbaum-Samen', 'Pflanze deinen eigenen Apfelbaum', 'Drogen/Samen.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (76, 'trashcan', 4, '-', 'Trashcan', 'Deine eigene Mülltonne für dein Haus!', 'Essen/Apfel.png', 1, 1337, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (77, 'taser', 3, 'ItemTaser', 'Taser', 'Haut den gegner mit Stromstößen um', 'Items/Taser.png', 1, 347, 0, 0, 0, 0, 0, 0, 0, 0, 1);
		INSERT INTO `vrp_items` VALUES (78, 'candyCane', 1, 'ItemFood', 'Zuckerstange', 'Event-Special Zuckerstange', 'Essen/Zuckerstange.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (79, 'medikit', 3, 'ItemHealpack', 'Medikit', 'Medikit zum schnellen selbst heilen', 'Items/Chips.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (80, 'keypad', 4, 'ItemKeyPad', 'Keypad', 'Ein Eingabegerät.', 'Objekte/keypad.png', 1, 2886, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (81, 'gate', 4, 'ItemDoor', 'Tor', 'Ein benutzbares Tor zum platzieren.', 'Objekte/door.png', 1, 1493, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (82, 'entrance', 4, 'ItemEntrance', 'Eingang', 'Ein platzierbarer Eingang', 'Objekte/entrance.png', 1, 1318, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (83, 'fireworksRocket', 3, 'ItemFirework', 'Rakete', 'Feuerwerks Rakete', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (84, 'fireworksPipeBomb', 3, 'ItemFirework', 'Rohrbombe', 'macht einen lauten Krach', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (85, 'fireworksBattery', 3, 'ItemFirework', 'Raketen Batterie', 'Eine Batterie aus mehreren Raketen', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (86, 'fireworksRoman', 3, 'ItemFirework', 'Römische Kerze', 'Römische Kerze', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (87, 'fireworksRomanBattery', 3, 'ItemFirework', 'Römische Kerzen Batterie', 'Eine Batterie aus mehreren Römischen Kerzen', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (88, 'fireworksBomb', 3, 'ItemFirework', 'Kugelbombe', 'macht ordentlich Krach', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (89, 'fireworksCracker', 3, 'ItemFirework', 'Böller', 'macht kleine explosionen', 'Items/Feuerwerk.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (90, 'slam', 3, 'ItemSlam', 'SLAM', 'Ein Sprengsatz mit Fernzünder.', 'Items/Slam.png', 1, 1252, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (91, 'smokeGrenade', 3, 'ItemSmokeGrenade', 'Rauchgranate', 'Eine Rauchgranate um Sicht zu verhindern.', 'Items/Smokegrenade.png', 1, 1672, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (92, 'transmitter', 4, '-', 'Transmitter', 'Ein Radiosender der über Ultrakurzwelle empfängt.', 'Objekte/transmitter.png', 1, 3031, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (93, 'star', 4, '-', 'Stern', 'Ein Stern erhalten durch den Braboy!', 'Objekte/star.png', 1, 3031, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (94, 'keycard', 3, '-', 'Keycard', 'Benutze die Keycard um Knasttüren zu öffnen', 'Items/Keycard.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (95, 'flowerSeed', 1, 'ItemPlant', 'Blumen-Samen', 'Pflanze diese Samen um einen wunderschönen Blumenstrauß zu ernten', 'Drogen/Samen.png', 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (96, 'defuseKit', 3, 'ItemDefuseKit', 'DefuseKit', 'Zum Entschärfen von SLAMs', 'Items/DefuseKit.png', 1, 2886, 0, 0, 0, 1, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (97, 'fishLexicon', 3, 'ItemFishing', 'Fischlexikon', 'Sammelt Informationen über deine geangelte Fische!', 'Items/FishEncyclopedia.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (98, 'fishingRod', 3, 'ItemFishing', 'Angelrute', 'Für angehende Angler!', 'Items/fishingrod.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (99, 'expertFishingRod', 3, 'ItemFishing', 'Profi Angelrute', 'Für profi Angler!', 'Items/ProFishingrod.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (100, 'legendaryFishingRod', 3, 'ItemFishing', 'Legendäre Angelrute', 'Für legendäre Angler! Damit fängst du jeden Fisch!', 'Items/LegendaryFishingrod.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (101, 'glowBait', 3, 'ItemFishing', 'Leuchtköder', 'Lockt allgemeine Fische an', 'Items/Glowingbait.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (102, 'pilkerBait', 3, 'ItemFishing', 'Pilkerköder', 'Spezieller Köder für Meeresangeln', 'Items/Pilkerbait.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (103, 'swimmer', 3, 'ItemFishing', 'Schwimmer', 'Zubehör. Auf der Wasseroberfläche treibender Bissanzeiger', 'Items/Bobber.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
		INSERT INTO `vrp_items` VALUES (104, 'spinner', 3, 'ItemFishing', 'Spinner', 'Zubehör. Eine rotierende Metallscheibe für ein einfaches und effektives fangen von kleinen als auch große Fische', 'Items/Spinner.png', 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
	]])


	sql:queryExec([[
		INSERT INTO `vrp_inventory_types` VALUES (1, 'player_inventory', 'Spielerinventar', '');
		INSERT INTO `vrp_inventory_types` VALUES (2, 'weaponbox', 'Waffenbox', '[ [\"faction\": [1, 2, 3] ] ]');
	]])


	sql:queryExec([[
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 1);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 2);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 3);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 4);
		INSERT INTO `vrp_inventory_type_categories` VALUES (1, 5);
		INSERT INTO `vrp_inventory_type_categories` VALUES (2, 2);
	]])




end
