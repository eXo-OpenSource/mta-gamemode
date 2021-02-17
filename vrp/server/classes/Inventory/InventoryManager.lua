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

InventoryItemClasses = {}

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
		ItemFishingRod = ItemFishingRod;
		ItemFishingLexicon = ItemFishingLexicon;
		ItemCoolingBox = ItemCoolingBox;
		ItemBait = ItemBait;
		WearableHelmet = WearableHelmet;
		WearableShirt = WearableShirt;
		WearablePortables = WearablePortables;
		WearableClothes = WearableClothes;
	}

	DbElementTypeClass = {
		[DbElementType.Temporary] = false,
		[DbElementType.Player] = Player,
		[DbElementType.Faction] = Faction,
		[DbElementType.Company] = Company,
		[DbElementType.Group] = Group,
		[DbElementType.Vehicle] = PermanentVehicle,
		[DbElementType.House] = House,
		[DbElementType.Property] = GroupProperty,
		[DbElementType.WeaponBox] = false,
		[DbElementType.CoolingBox] = false,
		[DbElementType.FactionDepot] = false,
		[DbElementType.Server] = false,
		[DbElementType.Shop] = false,
		[DbElementType.VehicleShop] = false,
		[DbElementType.Admin] = false,
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

	self.m_NextItemId = not result.NextId and 1 or result.NextId + 1
	self.m_Inventories = {}
	self.m_InventoryTypes = {}
	self.m_InventoryTypesIdToName = {}
	self:loadInventoryTypes()

	self.m_InventorySubscriptions = {}

	for k, v in pairs(DbElementType) do
		self.m_InventorySubscriptions[v] = {}
	end

	--Initialize other Manager classes
	InventoryTradingManager:new()

	--Initialize Item Manager classes
	ItemCanManager:new()
	ItemNailsManager:new()

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

function InventoryManager:Event_onItemMove(fromInventoryId, fromItemId, toInventoryId, toSlot, moveType)
	if client ~= source then return end

	local amount = moveType == "half" and math.floor(item.Amount/2) or moveType == "single" and 1
	self:moveItem(fromInventoryId, fromItemId, toInventoryId, toSlot, amount)
end

function InventoryManager:syncInventory(inventoryId, target, sync)
	local inventory = self:getInventory(inventoryId, nil, sync)
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
			local player = Player.getFromId(k)

			if player and not player.m_Disconnecting then
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
		local inventory = self:getInventory(elementType, elementId)
		if not inventory then
			outputDebugString("Inventory not found (elementType or elementId invalid)", 1)
			return
		end

		if not self.m_InventorySubscriptions[elementType][elementId] then
			self.m_InventorySubscriptions[elementType][elementId] = {}
		end

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

function InventoryManager:createPermanentInventory(elementId, elementType, size, typeId)
	local inventory = Inventory.createPermanent(elementId, elementType, size, typeId)

	self.m_Inventories[inventory.m_Id] = inventory

    return inventory
end

function InventoryManager:createTemporaryInventory(slots, typeId)
	local inventory = Inventory.createTemporary(slots, typeId)

	self.m_Inventories[inventory.m_Id] = inventory

    return inventory
end

function InventoryManager:getInventory(inventoryIdOrElementType, elementId, sync)
	local inventoryId = inventoryIdOrElementType
	local elementType = inventoryId

	local inventoryId = self:getInventoryId(inventoryIdOrElementType, elementId, sync)
	if not inventoryId then
		return false
	end

	local inventory = self.m_Inventories[inventoryId] and self.m_Inventories[inventoryId] or self:loadInventory(inventoryId, sync)

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

		if type(inventoryId) == "table" or type(inventoryId) == "userdata" then
			for index, dbElementType in pairs(DbElementType) do
				if DbElementTypeClass[dbElementType] and instanceof(inventoryId, DbElementTypeClass[dbElementType]) then
					elementId = inventoryId.m_Id
					elementType = dbElementType
				end
			end

			if elementId == 0 then
				if not DbElementTypeName[inventoryId[1]] or table.size(inventoryId) ~= 2 then
					return false
				end
				elementId = inventoryId[2]
				elementType = DbElementTypeName[inventoryId[1]]
			end
		end

		local row

		if sync then
			row = sql:queryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)
		else
			row = sql:asyncQueryFetchSingle("SELECT Id FROM ??_inventories WHERE ElementId = ? AND ElementType = ? AND Deleted IS NULL", sql:getPrefix(), elementId, elementType)
		end

		if not row then
			if DEBUG then outputDebugString("No inventory for elementId " .. tostring(elementId) .. " and elementType " .. tostring(elementType)) end
			return false
		end
		return row.Id
	end
	return inventoryId
end

function InventoryManager:loadInventory(inventoryId, sync)
	if type(inventoryId) ~= "number" then
		inventoryId = self:getInventoryId(inventoryId, nil, sync)
		if inventoryId then
			return false
		end
	end

	local inventory = Inventory:new(inventoryId)

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
		item = ItemManager:getSingleton().m_ItemIdToName[item]
	end

	if not ItemManager.get(item) then
		return false, "item"
	end

	local itemData = ItemManager.get(item)

	if amount < 1 then
		return false, "amount"
	end

	local maxItemAmount = inventory:getItemSetting(itemData.TechnicalName, "MaxAmount") or itemData.MaxAmount
	if inventory:getItemAmount(itemData.TechnicalName) + amount > maxItemAmount then
		return false, "maxAmount"
	end
	
	if not self:getNextFreeSlot(inventory) then
		return false, "slot"
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

function InventoryManager:giveItem(inventory, item, amount, durability, metadata, forceNewSlot, setInSlot)
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

		if not forceNewSlot and not setInSlot then
			for k, v in pairs(inventory.m_Items) do
				if v.ItemId == item then
					if self:compareItems({TechnicalName = item, Metadata = metadata, Durability = durability or itemData.MaxDurability}, v) then
						v.Amount = v.Amount + amount
						v.Durability = v.Durability == itemData.MaxDurability and (durability and durability or v.Durability) or v.Durability
						inventory:onInventoryChanged()
						return true
					end
				end
			end
		end

		local slot
		if setInSlot and not inventory:getItemFromSlot(setInSlot) then
			slot = setInSlot
		else
			slot = self:getNextFreeSlot(inventory)

			if not slot then
				return false, "slot"
			end
		end

		local id = inventory.m_NextItemId
		local playerId = inventory:getPlayerId()
		inventory.m_NextItemId = inventory.m_NextItemId + 1

		local data = table.copy(itemData)

		data.Id = self.m_NextItemId
		data.InventoryId = inventory.m_Id
		data.ItemId = item
		data.OwnerId = playerId
		data.OwnerName = playerId and Account.getNameFromId(playerId) or "Unbekannt"
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

function InventoryManager:moveItem(fromInventoryId, fromItemId, toInventoryId, toSlot, amount)
	local fromInventoryId = type(fromInventoryId) == "table" and fromInventoryId.m_Id or fromInventoryId
	local fromInventory = self:getInventory(fromInventoryId)
	local toInventoryId = type(toInventoryId) == "table" and toInventoryId.m_Id or toInventoryId
	local toInventory = self:getInventory(toInventoryId)
	local fromItem = fromInventory:getItem(fromItemId)
	if not fromItem then return false, "noItem" end
	if type(fromItemId) == "string" then fromItemId = fromItem.Id end
	local fromItemData = ItemManager.get(fromItem.TechnicalName)
	local toSlot = toSlot and toSlot or self:getNextFreeSlot(toInventoryId)
	local toItem = toInventory:getItemFromSlot(toSlot)

	if amount then
		if amount == 0 then
			return false, "invalidAmount"
		end

		if amount > fromItem.Amount then
			return false, "amountTooBig"
		end

		local isTakeable, reason = self:isItemTakeable(fromInventoryId, fromItemId, amount)
		if isTakeable then
			local result, reason = self:giveItem(toInventoryId, fromItem.TechnicalName, amount, false, fromItem.Metadata, false, toSlot)

			if result then
				self:takeItem(fromInventoryId, fromItemId, amount)
				if fromInventory ~= toInventory then
					StatisticsLogger:getSingleton():addItemTrancactionLog(client, fromInventory.m_Id, toInventory.m_Id, fromSlot, toSlot, fromItem, amount)
				end
				return true
			end
			return false, reason
		end

		return false, reason
	end

	if toSlot < 1 or toInventory.m_Slots < toSlot then return end
	if fromInventory == toInventory then
		if toItem then
			if self:compareItems(fromItem, toItem) then
				toItem.Amount = toItem.Amount + fromItem.Amount
				toItem.Durability = toItem.Durability == fromItemData.MaxDurability and fromItem.Durability or toItem.Durability
				for k, v in pairs(fromInventory.m_Items) do
					if v == fromItem then
						table.remove(fromInventory.m_Items, k)
						break
					end
				end
			else
				toItem.Slot = fromItem.Slot
				fromItem.Slot = toSlot
			end
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
	return true
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

function InventoryManager:getFreeSlots(inventory)
	local inventory = inventory

	if type(inventory) == "number" then
		inventory = self:getInventory(inventory)
	end

	if not inventory then
		return false
	end
	local totalSlots = inventory.m_Slots
	local freeSlots = {}

	for i = 1, totalSlots, 1 do
		local found = false
		for k, v in pairs(inventory.m_Items) do
			if v.Slot == i then
				found = true
				break
			end
		end

		if not found then
			table.insert(freeSlots, i)
		end
	end

    return freeSlots
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

function InventoryManager:compareItems(item, itemToCompare) --are two items stackable on each other?
	local itemData = ItemManager.get(item.TechnicalName)
	if item.TechnicalName ~= itemToCompare.TechnicalName then
		return false
	end

	if ((not item.Metadata or table.size(item.Metadata) == 0) and (not itemToCompare.Metadata or table.size(itemToCompare.Metadata) == 0)) or not equals(item.Metadata, itemToCompare.Metadata) then
		return false
	end

	if (itemData.MaxDurability > 0 and (item.Durability ~= itemData.MaxDurability and itemToCompare.Durability ~= itemData.MaxDurability)) then
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
			`MaxAmount` int(11) NOT NULL DEFAULT 0,
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
			`Permissions` text NULL DEFAULT NULL,
			`ItemSettings` text NULL DEFAULT NULL,
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
		INSERT INTO `vrp_items` VALUES (27, 'pumpkin', 3, 'WearableHelmet', 'Kürbis', 'Sammle diese und Kauf dir wundervolle Praemien davon!', 'Items/Kuerbis.png', 1935, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
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
		INSERT INTO `vrp_items` VALUES (65, 'bambooFishingRod', 3, 'ItemFishingRod', 'Bambusstange', 'Wollen fangen Fische\'', 'Items/Bamboorod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (66, 'coolingBoxSmall', 3, 'ItemCoolingBox', 'Kleine Kühltasche', 'Kühlt gut, wieder und wieder!', 'Items/Coolbag.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (67, 'coolingBoxMedium', 3, 'ItemCoolingBox', 'Kühltasche', 'Kühlt gut, wieder und wieder!', 'Items/Coolbag.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (68, 'coolingBoxLarge', 3, 'ItemCoolingBox', 'Kühlbox', 'Kühlt gut, wieder und wieder!', 'Items/Coolbox.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (69, 'swathelmet', 3, 'WearableHelmet', 'Einsatzhelm', 'Falls es hart auf hart kommt.', 'Objekte/einsatzhelm.png', 3911, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
		INSERT INTO `vrp_items` VALUES (70, 'bait', 3, 'ItemBait', 'Köder', 'Lockt ein paar Fische an und vereinfacht das Angeln', 'Items/Bait.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (71, 'easterEgg', 3, '-', 'Osterei', 'Event-Special: Osterei', 'Items/Osterei.png', 1933, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);
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
		INSERT INTO `vrp_items` VALUES (97, 'fishLexicon', 3, 'ItemFishingLexicon', 'Fischlexikon', 'Sammelt Informationen über deine geangelte Fische!', 'Items/FishEncyclopedia.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (98, 'fishingRod', 3, 'ItemFishingRod', 'Angelrute', 'Für angehende Angler!', 'Items/fishingrod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (99, 'expertFishingRod', 3, 'ItemFishingRod', 'Profi Angelrute', 'Für profi Angler!', 'Items/ProFishingrod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (100, 'legendaryFishingRod', 3, 'ItemFishingRod', 'Legendäre Angelrute', 'Für legendäre Angler! Damit fängst du jeden Fisch!', 'Items/LegendaryFishingrod.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (101, 'glowBait', 3, 'ItemBait', 'Leuchtköder', 'Lockt allgemeine Fische an', 'Items/Glowingbait.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (102, 'pilkerBait', 3, 'ItemBait', 'Pilkerköder', 'Spezieller Köder für Meeresangeln', 'Items/Pilkerbait.png', 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
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
		INSERT INTO `vrp_items` VALUES (181, 'brassknuckle', 7, 'ItemWeapon', 'Schlagring', '', '/files/images/Weapons/1.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (182, 'golfclub', 7, 'ItemWeapon', 'Golfschläger', '', '/files/images/Weapons/2.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (183, 'nightstick', 7, 'ItemWeapon', 'Schlagstock', '', '/files/images/Weapons/3.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (184, 'knife', 7, 'ItemWeapon', 'Messer', '', '/files/images/Weapons/4.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (185, 'bat', 7, 'ItemWeapon', 'Baseballschläger', '', '/files/images/Weapons/5.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (186, 'shovel', 7, 'ItemWeapon', 'Schaufel', '', '/files/images/Weapons/6.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (187, 'poolstick', 7, 'ItemWeapon', 'Billiardschläger', '', '/files/images/Weapons/7.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (188, 'katana', 7, 'ItemWeapon', 'Katana', '', '/files/images/Weapons/8.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (189, 'chainsaw', 7, 'ItemWeapon', 'Kettensäge', '', '/files/images/Weapons/9.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (190, 'colt45', 7, 'ItemWeapon', 'Colt 45', '', '/files/images/Weapons/22.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (191, 'deagle', 7, 'ItemWeapon', 'Deagle', '', '/files/images/Weapons/24.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (192, 'shotgun', 7, 'ItemWeapon', 'Schrotflinte', '', '/files/images/Weapons/25.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (193, 'sawedOff', 7, 'ItemWeapon', 'Abgesägte Schrotflinte', '', '/files/images/Weapons/26.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (194, 'combatShotgun', 7, 'ItemWeapon', 'SPAZ-12', '', '/files/images/Weapons/27.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (195, 'uzi', 7, 'ItemWeapon', 'Uzi', '', '/files/images/Weapons/28.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (196, 'mp5', 7, 'ItemWeapon', 'MP5', '', '/files/images/Weapons/29.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (197, 'tec9', 7, 'ItemWeapon', 'Tec-9', '', '/files/images/Weapons/32.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (198, 'ak47', 7, 'ItemWeapon', 'AK-47', '', '/files/images/Weapons/30.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (199, 'm4', 7, 'ItemWeapon', 'M4', '', '/files/images/Weapons/31.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (200, 'rifle', 7, 'ItemWeapon', 'Jagdgewehr', '', '/files/images/Weapons/33.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (201, 'sniper', 7, 'ItemWeapon', 'Scharfschützengewehr', '', '/files/images/Weapons/34.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (202, 'rocketLauncher', 7, 'ItemWeapon', 'Raketenwerfer', '', '/files/images/Weapons/35.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (203, 'rocketLauncherHS', 7, 'ItemWeapon', 'Javelin', '', '/files/images/Weapons/36.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (204, 'flamethrower', 7, 'ItemWeapon', 'Flammenwerfer', '', '/files/images/Weapons/37.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (205, 'minigun', 7, 'ItemWeapon', 'Minigun', '', '/files/images/Weapons/38.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (206, 'grenade', 7, 'ItemWeapon', 'Granate', '', '/files/images/Weapons/16.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (207, 'teargas', 7, 'ItemWeapon', 'Tränengas', '', '/files/images/Weapons/17.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (208, 'molotov', 7, 'ItemWeapon', 'Molotov', '', '/files/images/Weapons/18.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (209, 'satchel', 7, 'ItemWeapon', 'Rucksackbombe', '', '/files/images/Weapons/39.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (210, 'spraycan', 7, 'ItemWeapon', 'Spraydose', '', '/files/images/Weapons/41.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (211, 'fireExtinguisher', 7, 'ItemWeapon', 'Feuerlöscher', '', '/files/images/Weapons/42.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (212, 'camera', 7, 'ItemWeapon', 'Kamera', '', '/files/images/Weapons/43.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (213, 'longDildo', 7, 'ItemWeapon', 'Langer Dildo', '', '/files/images/Weapons/10.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (214, 'shortDildo', 7, 'ItemWeapon', 'Kurzer Dildo', '', '/files/images/Weapons/11.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (215, 'vibrator', 7, 'ItemWeapon', 'Vibrator', '', '/files/images/Weapons/12.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (216, 'flower', 7, 'ItemWeapon', 'Blumenstrauss', '', '/files/images/Weapons/14.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (217, 'cane', 7, 'ItemWeapon', 'Gehstock', '', '/files/images/Weapons/15.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (218, 'nightvision', 7, 'ItemWeapon', 'Nachtsichtgerät', '', '/files/images/Weapons/44.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (219, 'infrared', 7, 'ItemWeapon', 'Wärmesichtgerät', '', '/files/images/Weapons/45.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (220, 'parachute', 7, 'ItemWeapon', 'Fallschirm', '', '/files/images/Weapons/46.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		INSERT INTO `vrp_items` VALUES (221, 'satchelDetonator', 7, 'ItemWeapon', 'Fernzünder', '', '/files/images/Weapons/40.png', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
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

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] FINISH BASE MIGRATIONS")

	local newInventories = {}

	local items = sql:queryFetch("SELECT * FROM ??_items", sql:getPrefix())
	local ItemMappingId = {}
	local ItemMappingExpire = {}
	local ItemMappingTechnicalNameFromId = {}
	for _, item in pairs(items) do
		ItemMappingId[item.TechnicalName] = item.Id
		ItemMappingExpire[item.TechnicalName] = item.MaxExpireTime
		ItemMappingTechnicalNameFromId[item.Id] = item.TechnicalName
	end

	-- Step 1 - Create player inventories

	local players = sql:queryFetch("SELECT * FROM ??_account", sql:getPrefix())
	local inventories = {}
	local inventoriesWeapon = {}

	for _, player in pairs(players) do
		-- Normal inventory
		inventories[player.Id] = {
			ElementId = player.Id,
			ElementType = DbElementType.Player,
			Slots = 40, -- TODO: Adjust default slot count
			TypeId = 1,
			items = {}
		}
		table.insert(newInventories, inventories[player.Id])

		-- Weapon box
		inventoriesWeapon[player.Id] = {
			ElementId = player.Id,
			ElementType = DbElementType.WeaponBox,
			Slots = 8, -- TODO: Maybe increase it slightly?
			TypeId = 2,
			items = {}
		}
		table.insert(newInventories, inventoriesWeapon[player.Id])
	end

	local items = sql:queryFetch("SELECT * FROM ??_inventory_slots ORDER BY PlayerId ASC", sql:getPrefix())
	local count = 0
	local total = table.size(items)

	for _, item in pairs(items) do
		if inventories[item.PlayerId] then
			if ItemMapping[item.Objekt] then
				local itemTechnicalName = ItemMapping[item.Objekt]

				local inventoryItem = {
					ItemId = ItemMappingId[itemTechnicalName],
					OwnerId = item.PlayerId,
					Tradeable = 1,
					Amount = item.Menge,
					Durability = 0,
					ExpireTime = ItemMappingExpire[itemTechnicalName],
					Metadata = nil,
					items = {}
				}

				if item.Value and item.Value ~= "" then
					if itemTechnicalName == "clothing" then
						inventoryItem.Metadata = { tonumber(item.Value) }
					elseif itemTechnicalName == "can" then
						inventoryItem.Durability = item.Value
					elseif itemTechnicalName == "donutBox" then
						inventoryItem.Durability = item.Value
					elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
						inventoryItem.Durability = item.WearLevel
						inventoryItem.Metadata = {}

						local data = fromJSON(item.Value)

						if data and data.accessories then
							inventoryItem.Metadata.accessory = ItemMapping[data.accessories]
						end

						if data and data.bait then
							inventoryItem.Metadata.bait = ItemMapping[data.bait]
						end
					elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
						inventoryItem.Durability = item.WearLevel
					elseif itemTechnicalName == "clubCard" then
						inventoryItem.Metadata = { tonumber(item.Value) }
					elseif itemTechnicalName == "tollTicket" then
						inventoryItem.Metadata = { tonumber(item.Value) }
					end
				end


				if itemTechnicalName == "coolingBoxSmall" or itemTechnicalName == "coolingBoxMedium" or itemTechnicalName == "coolingBoxLarge" then
					local fishes = fromJSON(item.Value)

					if fishes then
						--  [ [ { "fishName": "Karpfen", "Id": 5, "timestamp": 1532891919, "size": 84, "quality": 1 }, { "fishName": "Kaulbarsch", "Id": 7, "timestamp": 1532892059, "quality": 0, "size": 41 } ] ]

						for _, v in pairs(fishes) do
							local fishName = FishMapping[v.Id]

							table.insert(inventoryItem.items, {
								ItemId = ItemMappingId[fishName],
								OwnerId = item.PlayerId,
								Tradeable = 1,
								Amount = 1,
								Durability = 0,
								ExpireTime = ItemMappingExpire[fishName],
								Metadata = {size = v.size, quality = v.quality},
								CreatedAt = (v.timestamp and v.timestamp > 0) and v.timestamp or os.time()
							})
						end
					end
				end

				table.insert(inventories[item.PlayerId].items, inventoryItem)
			else
				outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] Found unknown item " .. tostring(item.Objekt) .. " for player " .. tostring(item.PlayerId))
			end
		end
		count = count + 1
	end

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] FINISH PLAYER ITEMS " .. tostring(count) .. "/" .. tostring(total))

	local items = sql:queryFetch("SELECT Id, Weapons, GunBox FROM ??_character", sql:getPrefix())
	local count = 0
	local total = table.size(items)
	local weaponBoxSlot = {}

	for _, item in pairs(items) do
		-- Do some magic for weapons
		if item.Weapons then
			local weapons = fromJSON(item.Weapons)
			if weapons then
				for _, weapon in pairs(weapons) do
					if weapon[1] ~= 0 and WeaponMapping[weapon[1]] and inventories[item.Id] then
						local inventoryItem = {
							ItemId = ItemMappingId[WeaponMapping[weapon[1]]],
							OwnerId = item.Id,
							Tradeable = 1,
							Amount = not WeaponMappingAmmunition[weapon[1]] and 1 or (not WeaponAmmoIsDurability[weapon[1]] and weapon[2] or 1),
							Durability = not WeaponMappingAmmunition[weapon[1]] and 0 or (WeaponAmmoIsDurability[weapon[1]] and weapon[2] or 0),
							ExpireTime = 0,
							Metadata = nil
						}

						table.insert(inventories[item.Id].items, inventoryItem)

						if WeaponMappingAmmunition[weapon[1]] then
							local inventoryItem = {
								ItemId = ItemMappingId[WeaponMappingAmmunition[weapon[1]]],
								OwnerId = item.Id,
								Tradeable = 1,
								Amount = weapon[2],
								Durability = 0,
								ExpireTime = 0,
								Metadata = nil
							}

							table.insert(inventories[item.Id].items, inventoryItem)
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
						local inventoryItem = {
							ItemId = ItemMappingId[WeaponMapping[weapon.WeaponId]],
							OwnerId = item.Id,
							Tradeable = 1,
							Amount = not WeaponMappingAmmunition[weapon.WeaponId] and 1 or (not WeaponAmmoIsDurability[weapon.WeaponId] and weapon.Amount or 1),
							Durability = not WeaponMappingAmmunition[weapon.WeaponId] and 0 or (WeaponAmmoIsDurability[weapon.WeaponId] and weapon.Amount or 0),
							ExpireTime = 0,
							Metadata = nil
						}

						table.insert(inventoriesWeapon[item.Id].items, inventoryItem)

						if WeaponMappingAmmunition[weapon.WeaponId] then
							local inventoryItem = {
								ItemId = ItemMappingId[WeaponMappingAmmunition[weapon.WeaponId]],
								OwnerId = item.Id,
								Tradeable = 1,
								Amount = weapon.Amount,
								Durability = 0,
								ExpireTime = 0,
								Metadata = nil
							}

							table.insert(inventoriesWeapon[item.Id].items, inventoryItem)
						end
					end
				end
			end
		end
		count = count + 1
	end

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] FINISH PLAYER WEAPONS " .. tostring(count) .. "/" .. tostring(total))

	local vehicles = sql:queryFetch("SELECT Id, TrunkId, Model FROM ??_vehicles", sql:getPrefix())
	local inventories = {}
	local trunkVehicleId = {}

	for _, vehicle in pairs(vehicles) do
		if vehicle.TrunkId and vehicle.TrunkId ~= 0 then
			trunkVehicleId[vehicle.TrunkId] = vehicle.Id
			inventories[vehicle.Id] = {
				ElementId = vehicle.Id,
				ElementType = DbElementType.Vehicle,
				Slots = 30, -- TODO: Adjust default slot count
				TypeId = 4,
				VehicleModel = vehicle.Model,
				items = {}
			}
			table.insert(newInventories, inventories[vehicle.Id])
		end
	end

	local items = sql:queryFetch("SELECT * FROM ??_vehicle_trunks", sql:getPrefix())
	local total = table.size(items)
	local count = 0

	for _, item in pairs(items) do
		if trunkVehicleId[item.Id] and inventories[trunkVehicleId[item.Id]] then
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

						local inventoryItem = {
							ItemId = ItemMappingId[itemTechnicalName],
							OwnerId = 0,
							Tradeable = 1,
							Amount = v.Amount,
							Durability = 0,
							ExpireTime = 0,
							Metadata = nil
						}

						--[[
							Kleine Kühltasche [ [ { "Id": 10, "timestamp": 1547756920, "size": 61, "quality": 1 }, { "Id": 10, "timestamp": 1547756954, "quality": 1, "size": 56 }, { "Id": 11, "timestamp": 1547756983, "size": 29, "quality": 0 }, { "Id": 16, "timestamp": 1547757012, "quality": 1, "size": 107 }, { "Id": 11, "timestamp": 1547757055, "size": 33, "quality": 1 }, { "Id": 16, "timestamp": 1547757084, "quality": 1, "size": 92 }, { "Id": 10, "timestamp": 1547757111, "size": 56, "quality": 1 }, { "Id": 11, "timestamp": 1547757151, "quality": 0, "size": 27 }, { "Id": 11, "timestamp": 1547757180, "size": 32, "quality": 1 }, { "Id": 10, "timestamp": 1547757201, "quality": 0, "size": 43 }, { "Id": 10, "timestamp": 1547757226, "size": 62, "quality": 1 }, { "Id": 10, "timestamp": 1547757253, "quality": 1, "size": 55 }, { "Id": 16, "timestamp": 1547757625, "size": 108, "quality": 1 }, { "Id": 16, "timestamp": 1547757672, "quality": 1, "size": 97 }, { "Id": 11, "timestamp": 1547757722, "size": 27, "quality": 0 }, { "Id": 10, "timestamp": 1547757818, "quality": 1, "size": 47 }, { "Id": 11, "timestamp": 1547757885, "size": 20, "quality": 0 }, { "Id": 11, "timestamp": 1547757927, "quality": 0, "size": 25 }, { "Id": 16, "timestamp": 1547758015, "size": 80, "quality": 1 }, { "Id": 11, "timestamp": 1547799344, "quality": 1, "size": 37 }, { "Id": 16, "timestamp": 1547799373, "size": 106, "quality": 1 }, { "Id": 10, "timestamp": 1547799403, "quality": 1, "size": 47 }, { "Id": 23, "timestamp": 1547799433, "size": 13, "quality": 1 }, { "Id": 23, "timestamp": 1547799467, "quality": 1, "size": 17 }, { "Id": 19, "timestamp": 1547799495, "size": 34, "quality": 0 }, { "Id": 34, "timestamp": 1547799526, "quality": 1, "size": 104 }, { "Id": 10, "timestamp": 1547799547, "size": 52, "quality": 1 }, { "Id": 16, "timestamp": 1547799580, "quality": 3, "size": 155 }, { "Id": 19, "timestamp": 1547799602, "size": 36, "quality": 1 }, { "Id": 11, "timestamp": 1547799643, "quality": 1, "size": 32 }, { "Id": 11, "timestamp": 1547799696, "size": 53, "quality": 3 }, { "Id": 23, "timestamp": 1547799721, "quality": 1, "size": 16 }, { "Id": 16, "timestamp": 1547799748, "size": 104, "quality": 1 }, { "Id": 23, "timestamp": 1547799780, "quality": 0, "size": 10 }, { "Id": 19, "timestamp": 1547799811, "size": 43, "quality": 1 }, { "Id": 16, "timestamp": 1547799837, "quality": 1, "size": 83 }, { "Id": 19, "timestamp": 1547799868, "size": 41, "quality": 1 }, { "Id": 23, "timestamp": 1547799900, "quality": 1, "size": 16 }, { "Id": 34, "timestamp": 1547799921, "size": 105, "quality": 1 }, { "Id": 16, "timestamp": 1547799943, "quality": 1, "size": 88 }, { "Id": 10, "timestamp": 1547799966, "size": 60, "quality": 1 }, { "Id": 23, "timestamp": 1547800003, "quality": 0, "size": 7 }, { "Id": 11, "timestamp": 1547800042, "size": 34, "quality": 1 }, { "Id": 11, "timestamp": 1547800072, "quality": 1, "size": 34 }, { "Id": 34, "timestamp": 1547800087, "size": 114, "quality": 1 }, { "Id": 11, "timestamp": 1547800136, "quality": 1, "size": 32 } ] ]
							Kühlbox     [ [ { "Id": 5, "timestamp": 1547588718, "quality": 0, "size": 38 } ] ]
							Kühltasche  [ [ { "fishName": "Karpfen", "Id": 5, "timestamp": 1532891919, "size": 84, "quality": 1 }, { "fishName": "Kaulbarsch", "Id": 7, "timestamp": 1532892059, "quality": 0, "size": 41 } ] ]
						]]

						if v.Value and v.Value ~= "" then
							if itemTechnicalName == "clothing" then
								inventoryItem.Metadata = { tonumber(v.Value) }
							elseif itemTechnicalName == "can" then
								inventoryItem.Durability = v.Value
							elseif itemTechnicalName == "donutBox" then
								inventoryItem.Durability = v.Value
							elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
								-- inventoryItem.Durability = v.WearLevel
							elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
								-- inventoryItem.Durability = v.WearLevel
							elseif itemTechnicalName == "clubCard" then
								inventoryItem.Metadata = { tonumber(v.Value) }
							elseif itemTechnicalName == "tollTicket" then
								inventoryItem.Metadata = { tonumber(v.Value) }
							end
						end

						if itemTechnicalName == "coolingBoxSmall" or itemTechnicalName == "coolingBoxMedium" or itemTechnicalName == "coolingBoxLarge" then
							outputServerLog("COOLING BOX IN VEHICLE" .. item.Id)
						elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
							outputServerLog("SWIMMER OR SPINNER IN VEHICLE" .. item.Id)
						elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
							outputServerLog("FISHING ROD IN VEHICLE " .. item.Id)
						end

						table.insert(inventories[trunkVehicleId[item.Id]].items, inventoryItem)
					end
				end
			end

			for _, weapon in pairs(weaponsNew) do
				if weapon.WeaponId ~= 0 and WeaponMapping[weapon.WeaponId] and inventoriesWeapon[item.Id] then


					local inventoryItem = {
						ItemId = ItemMappingId[WeaponMapping[weapon.WeaponId]],
						OwnerId = item.Id,
						Tradeable = 1,
						Amount = not WeaponMappingAmmunition[weapon.WeaponId] and 1 or (not WeaponAmmoIsDurability[weapon.WeaponId] and weapon.Amount or 1),
						Durability = not WeaponMappingAmmunition[weapon.WeaponId] and 0 or (WeaponAmmoIsDurability[weapon.WeaponId] and weapon.Amount or 0),
						ExpireTime = 0,
						Metadata = nil
					}

					table.insert(inventories[trunkVehicleId[item.Id]].items, inventoryItem)

					if WeaponMappingAmmunition[weapon.WeaponId] then
						local inventoryItem = {
							ItemId = ItemMappingId[WeaponMappingAmmunition[weapon.WeaponId]],
							OwnerId = item.Id,
							Tradeable = 1,
							Amount = weapon.Amount,
							Durability = 0,
							ExpireTime = 0,
							Metadata = nil
						}

						table.insert(inventories[trunkVehicleId[item.Id]].items, inventoryItem)
					end
				end
			end
		else
			--outputServerLog("[MIGRATION] Unknown trunk " .. tostring(item.Id))
		end
		count = count + 1
	end

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] FINISH VEHICLE TRUNK " .. tostring(count) .. "/" .. tostring(total))


	local items = sql:queryFetch("SELECT * FROM ??_depot", sql:getPrefix())
	local factions = sql:queryFetch("SELECT * FROM ??_factions", sql:getPrefix())
	local properties = sql:queryFetch("SELECT * FROM ??_group_property", sql:getPrefix())

	local inventories = {}
	local depotInventories = {}
	local depotOwners = {}

	for _, item in pairs(items) do
		if item.OwnerType == "faction" then
			for _, v in pairs(factions) do
				if item.Id == v.Depot then
					depotOwners[item.Id] = {ElementId = v.Id, ElementType = DbElementType.Faction}
					inventories[item.Id] = {
						ElementId = v.Id,
						ElementType = DbElementType.Faction,
						Slots = 500, -- TODO: Maybe add infinity option?
						TypeId = 5,
						items = {}
					}
					depotInventories[item.Id] = {
						ElementId = v.Id,
						ElementType = DbElementType.FactionDepot,
						Slots = 500, -- TODO: Maybe add infinity option?
						TypeId = 5,
						items = {}
					}
					table.insert(newInventories, inventories[item.Id])
					table.insert(newInventories, depotInventories[item.Id])
					break
				end
			end
		elseif item.OwnerType == "GroupProperty" then
			for _, v in pairs(properties) do
				if item.Id == v.DepotId then
					depotOwners[item.Id] = {ElementId = v.Id, ElementType = DbElementType.Property}
					inventories[item.Id] = {
						ElementId = v.Id,
						ElementType = DbElementType.Property,
						Slots = 40, -- TODO: Update slot count
						TypeId = 6,
						VehicleModel = -1,
						items = {}
					}
					table.insert(newInventories, inventories[item.Id])
					break
				end
			end
		end
	end

	local total = table.size(items)
	local count = 0
	local depotSlot = {}

	for _, item in pairs(items) do
		local weapons = fromJSON(item.Weapons)
		local items2 = fromJSON(item.Items)
		local equipments = item.Equipments and fromJSON(item.Equipments) or false

		if weapons then
			for _, weapon in pairs(weapons) do
				if weapon.Id ~= 0 and (weapon.Waffe ~= 0 or weapon.Munition ~= 0) and WeaponMapping[weapon.Id] then
					for i = 1, weapon.Waffe, 1 do
						local inventoryItem = {
							ItemId = ItemMappingId[WeaponMapping[weapon.Id]],
							Tradeable = 1,
							Amount = 1,
							Durability = 0,
							ExpireTime = 0,
							Metadata = nil
						}


						if not WeaponMappingAmmunition[weapon.Id] then
							if WeaponAmmoIsDurability[weapon.Id] then
								durability = weapon.Munition
								outputServerLog("Weapon without ammunation in depot " .. WeaponMapping[weapon.Id] .. " - " .. item.Id)
							else
								inventoryItem.Amount = weapon.Munition
							end
						end

						table.insert(depotInventories[item.Id].items, inventoryItem)
					end


					if WeaponMappingAmmunition[weapon.Id] and weapon.Munition ~= 0 then
						local inventoryItem = {
							ItemId = ItemMappingId[WeaponMappingAmmunition[weapon.Id]],
							Tradeable = 1,
							Amount = weapon.Munition,
							Durability = 0,
							ExpireTime = 0,
							Metadata = nil
						}

						table.insert(depotInventories[item.Id].items, inventoryItem)
					end
				end
			end
		end

		if items2 then
			for _, v in pairs(items2) do
				if ItemMapping[v.Item] then
					local itemTechnicalName = ItemMapping[v.Item]

					local inventoryItem = {
						ItemId = ItemMappingId[itemTechnicalName],
						OwnerId = 0,
						Tradeable = 1,
						Amount = v.Amount,
						Durability = 0,
						ExpireTime = 0,
						Metadata = nil
					}

					if v.Value and v.Value ~= "" then
						if itemTechnicalName == "clothing" then
							inventoryItem.Metadata = { tonumber(v.Value) }
						elseif itemTechnicalName == "can" then
							inventoryItem.Durability = v.Value
						elseif itemTechnicalName == "donutBox" then
							inventoryItem.Durability = v.Value
						elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
							-- inventoryItem.Durability = v.WearLevel
						elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
							-- inventoryItem.Durability = v.WearLevel
						elseif itemTechnicalName == "clubCard" then
							inventoryItem.Metadata = { tonumber(v.Value) }
						elseif itemTechnicalName == "tollTicket" then
							inventoryItem.Metadata = { tonumber(v.Value) }
						end
					end

					if itemTechnicalName == "coolingBoxSmall" or itemTechnicalName == "coolingBoxMedium" or itemTechnicalName == "coolingBoxLarge" then
						outputServerLog("COOLING BOX IN DEPOT" .. item.Id)
					elseif itemTechnicalName == "swimmer" or itemTechnicalName == "spinner" then
						outputServerLog("SWIMMER OR SPINNER IN DEPOT" .. item.Id)
					elseif itemTechnicalName == "bambooFishingRod" or itemTechnicalName == "fishingRod" or itemTechnicalName == "expertFishingRod" or itemTechnicalName == "legendaryFishingRod" then
						outputServerLog("FISHING ROD IN DEPOT" .. item.Id)
					end

					table.insert(inventories[item.Id].items, inventoryItem)
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
				if itemTechnicalName and amount > 0 then -- TODO: Rework this thing, split weapon and ammunation!!
					local inventoryItem = {
						ItemId = ItemMappingId[itemTechnicalName],
						OwnerId = 0,
						Tradeable = 1,
						Amount = amount,
						Durability = 0,
						ExpireTime = 0,
						Metadata = nil
					}

					table.insert(inventories[item.Id].items, inventoryItem)
				end
			end
		end
		count = count + 1
	end

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] FINISH DEPOTS " .. tostring(count) .. "/" .. tostring(total))

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] PREPARED DATA START WRITTING IT TO DATABASE")

	local itemId = 1
	for _, inventory in ipairs(newInventories) do
		sql:queryExec("INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES (?, ?, ?, ?)",
			sql:getPrefix(), inventory.ElementId, inventory.ElementType, inventory.Slots, inventory.TypeId)
		local inventoryId = sql:lastInsertId()
		local slot = 1

		for _, item in ipairs(inventory.items) do
			local itemTechnicalName = ItemMappingTechnicalNameFromId[item.ItemId]
			if itemTechnicalName == "coolingBoxSmall" or itemTechnicalName == "coolingBoxMedium" or itemTechnicalName == "coolingBoxLarge" then
				local metadata = nil

				if item.Metadata then
					local data = toJSON(item.Metadata, true)
					metadata = data:sub(2, #data-1)
				end

				sql:queryExec("INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Tradeable, Slot, Amount, Durability, ExpireTime, Metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
					sql:getPrefix(), itemId, inventoryId, item.ItemId, item.OwnerId or nil, item.Tradeable or 1, slot, item.Amount, item.Durability or 0, item.ExpireTime or 0, metadata)
				local coolBoxItemId = sql:lastInsertId()

				slot = slot + 1
				itemId = itemId + 1

				sql:queryExec("INSERT INTO ??_inventories (ElementId, ElementType, Slots, TypeId) VALUES (?, ?, ?, ?)",
				sql:getPrefix(), coolBoxItemId, DbElementType.CoolingBox, 99, 3) -- TODO: Add logic for cooling box size
				local coolingBoxInventoryId = sql:lastInsertId()

				local coolingBoxSlot = 1
				for _, fish in ipairs(item.items) do
					local metadata = nil

					if item.Metadata then
						local data = toJSON(item.Metadata, true)
						metadata = data:sub(2, #data-1)
					end

					-- TODO: Maybe batch the insert statement?
					sql:queryExec("INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Tradeable, Slot, Amount, Durability, ExpireTime, Metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
						sql:getPrefix(), itemId, coolingBoxInventoryId, fish.ItemId, fish.OwnerId or nil, fish.Tradeable or 1, coolingBoxSlot, fish.Amount, fish.Durability or 0, fish.ExpireTime or 0, metadata)
						coolingBoxSlot = coolingBoxSlot + 1
					itemId = itemId + 1
				end
			else
				local metadata = nil

				if item.Metadata then
					local data = toJSON(item.Metadata, true)
					metadata = data:sub(2, #data-1)
				end

				-- TODO: Maybe batch the insert statement?
				sql:queryExec("INSERT INTO ??_inventory_items (Id, InventoryId, ItemId, OwnerId, Tradeable, Slot, Amount, Durability, ExpireTime, Metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
					sql:getPrefix(), itemId, inventoryId, item.ItemId, item.OwnerId or nil, item.Tradeable or 1, slot, item.Amount, item.Durability or 0, item.ExpireTime or 0, metadata)
				slot = slot + 1
				itemId = itemId + 1
			end
		end
	end

	outputServerLog("[MIGRATION - " .. (getTickCount() - st) .. "ms] FINISHED WRITTING TO DATABASE")

	outputServerLog("========================================")
	outputServerLog("=     INVENTORY MIGRATION FINISHED     =")
	outputServerLog("========================================")
	setServerPassword()
	debug.sethook(nil, h1, h2, h3) -- enable infinity loop check
end
