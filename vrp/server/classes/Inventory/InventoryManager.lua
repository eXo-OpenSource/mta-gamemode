-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryManager.lua
-- *  PURPOSE:     InventoryManager Class
-- *
-- ****************************************************************************
InventoryManager = inherit(Singleton)

function InventoryManager:constructor()

	self.m_Slots={
		["Items"] = 14,
		["Objekte"] = 3,
		["Essen"] = 5,
		["Drogen"] = 7,
	}

	self.m_ItemData = {}
	self.m_ItemData = self:loadItems()
	self.Map = {}

	addRemoteEvents{"changePlaces", "onPlayerItemUseServer", "c_stackItems", "wegwerfItem", "c_setItemPlace", "refreshInventory"}
	addEventHandler("changePlaces", root, bind(self.Event_changePlaces, self))
	addEventHandler("onPlayerItemUseServer", root, bind(self.Event_onItemUse, self))
	addEventHandler("c_stackItems", root, bind(self.Event_c_stackItems, self))
	addEventHandler("throwItem", root, bind(self.Event_throwItem, self))
	addEventHandler("c_setItemPlace", root, bind(self.Event_c_setItemPlace, self))
	addEventHandler("refreshInventory", root, bind(self.Event_refreshInventory, self))
end

function InventoryManager:destructor()

end

function InventoryManager:getItemData()
	return self.m_ItemData
end

function InventoryManager:getItemDataForItem(itemName)
	return self.m_ItemData[itemName]
end

function InventoryManager:loadItems()
	local result = sql:queryFetch("SELECT * FROM ??_inventory_items", sql:getPrefix())
	local itemData = {}
	local itemName
	for i, row in ipairs(result) do
		itemName = row["Objektname"]
		itemData[itemName] = {}
		itemData[itemName]["Name"] = itemName
		itemData[itemName]["Info"] = row["Info"]
		itemData[itemName]["Tasche"] = row["Tasche"]
		itemData[itemName]["Icon"] = row["Icon"]
		itemData[itemName]["Item_Max"] = tonumber(row["max_items"])
		itemData[itemName]["Wegwerf"] = tonumber(row["wegwerfen"])
		itemData[itemName]["Handel"] = tonumber(row["Handel"])
		itemData[itemName]["Stack_max"] = tonumber(row["stack_max"])
		itemData[itemName]["Verbraucht"] = tonumber(row["verbraucht"])
		itemData[itemName]["ModelID"] = tonumber(row["ModelID"])
	end

	return itemData
end

function InventoryManager:loadInventory(player)
	if not self.Map[player] then
		local instance = Inventory:new(player, self.m_Slots, self.m_ItemData,ItemManager:getSingleton():getClassItems())
		self.Map[player] = instance
		return instance
	end
end

function InventoryManager:deleteInventory(player)
	self.Map[player] = nil
end

function InventoryManager:getPlayerInventory(player)
	if self.Map[player] then
		return self.Map[player]
	end
	return false
end

function InventoryManager:Event_changePlaces(bag, oPlace, nPlace)
	self:getPlayerInventory(client):changePlaces(bag, oPlace, nPlace)
end


function InventoryManager:Event_onItemUse(itemid, bag, itemName, place, delete)
	self:getPlayerInventory(client):useItem(itemid, bag, itemName, place, delete)

end

function InventoryManager:Event_c_stackItems(newId, oldId, oldPlace)
	self:getPlayerInventory(client):c_stackItems(newId, oldId, oldPlace)
end


function InventoryManager:Event_c_setItemPlace(bag, oldPlace, newPlace)
	self:getPlayerInventory(client):c_setItemPlace(bag, oldPlace, newPlace)
end


function InventoryManager:Event_throwItem(item, bag, id, place)
	self:getPlayerInventory(client):throwItem(item, bag, id, place)
end

function InventoryManager:Event_refreshInventory()
	self:getPlayerInventory(client):syncClient()
end
