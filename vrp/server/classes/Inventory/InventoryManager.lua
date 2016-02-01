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
	addEventHandler("wegwerfItem", root, bind(self.Event_wegwerfItem, self))
	addEventHandler("c_setItemPlace", root, bind(self.Event_c_setItemPlace, self))
	addEventHandler("refreshInventory", root, bind(self.Event_refreshInventory, self))
end

function InventoryManager:destructor()

end

function InventoryManager:getItemData()
	return self.m_ItemData
end

function InventoryManager:loadItems()
	local result = sql:queryFetch("SELECT * FROM ??_inventory_items", sql:getPrefix())
	local itemData = {}
	for i, row in ipairs(result) do
		itemData[row["Objektname"]] = {}
		itemData[row["Objektname"]]["Name"] = row["Objektname"]
		itemData[row["Objektname"]]["Info"] = row["Info"]
		itemData[row["Objektname"]]["Tasche"] = row["Tasche"]
		itemData[row["Objektname"]]["Icon"] = row["Icon"]
		itemData[row["Objektname"]]["Item_Max"] = tonumber(row["max_items"])
		itemData[row["Objektname"]]["Wegwerf"] = tonumber(row["wegwerfen"])
		itemData[row["Objektname"]]["Handel"] = tonumber(row["Handel"])
		itemData[row["Objektname"]]["Stack_max"] = tonumber(row["stack_max"])
		itemData[row["Objektname"]]["Verbraucht"] = tonumber(row["verbraucht"])
	end

	return itemData
end

function InventoryManager:loadInventory(player)
	if not self:getPlayerInventory(player) then
		local instance = Inventory:new(player, self.m_Slots, self.m_ItemData)
		self.Map[player] = instance
	end
end

function InventoryManager:getPlayerInventory(player)
	if self.Map[player] then
		return self.Map[player]
	end
	return false
end

function InventoryManager:Event_changePlaces(tasche, oPlace, nPlace)
	self:getPlayerInventory(client):changePlaces(tasche, oPlace, nPlace)
end


function InventoryManager:Event_onItemUse(itemid, tasche, itemname, platz, delete)
	self:getPlayerInventory(client):useItem(itemid, tasche, itemname, platz, delete)

end

function InventoryManager:Event_c_stackItems(newid, oldid, oldplatz)
	self:getPlayerInventory(client):c_stackItems(newid, oldid, oldplatz)
end


function InventoryManager:Event_c_setItemPlace(tasche, platz, nplatz)
	self:getPlayerInventory(client):c_setItemPlace(tasche, platz, nplatz)
end


function InventoryManager:Event_wegwerfItem(item, tasche, id, platz)
	self:getPlayerInventory(client):wegwerfItem(item, tasche, id, platz)
end

function InventoryManager:Event_refreshInventory()
	self:getPlayerInventory(client):syncClient()
end
