-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Clientside inventory class
-- *
-- ****************************************************************************
Inventory = inherit(Object)
Inventory.Map = {}
addRemoteEvents{"inventoryUnload", "inventoryAddItem", "inventoryRemoveItem", "inventoryUseItem", "inventoryReceiveFullSync"}

local function getInvGUI() return InventoryGUI:getSingleton() end

function Inventory:constructor(Id)
	self.m_Id = Id
	self.m_Items = {}
end

function Inventory:destructor()
	Inventory.Map[self.m_Id] = nil
end

function Inventory:requestFullSync()
	triggerServerEvent("inventoryRequestFullSync", resourceRoot, self.m_Id)
end

function Inventory:addItem(item)
	local inv = getInvGUI()
	if inv then
		inv:addItem(item)
	end

	if TradeGUI:isInstantiated() then
		TradeGUI:getSingleton():updateMyInventory(self)
	end
end

function Inventory:removeItem(item, amount)
	item.m_Count = item.m_Count - amount

	local inv = getInvGUI()
	if inv then
		inv:removeItem(item, amount)
	end

	if item.m_Count == 0 then
		delete(item)
		table.removevalue(self.m_Items, item)
	end

	if TradeGUI:isInstantiated() then
		TradeGUI:getSingleton():updateMyInventory(self)
	end
end

function Inventory:useItem(item)
	if item.use then
		item:use(inventory)
	end
end

function Inventory:getItems()
	return self.m_Items
end

function Inventory:applyItemsFromFullsync(items)
	for k, itemInfo in ipairs(items) do
		local slot, itemId, amount = unpack(itemInfo)

		local itemClass = Items[itemId].class
		table.insert(self.m_Items, (itemClass or Item):new(itemId, amount, slot))
		self:addItem(self.m_Items[#self.m_Items])
	end
end

function Inventory:findItem(slot, itemId)
	for k, item in pairs(self.m_Items) do
		if item:getSlot() == slot then
			-- Check itemid to ensure we're not desynced
			if item:getItemId() == itemId or not itemId then
				return item
			end
			break
		end
	end
end

addEventHandler("inventoryUnload", root,
	function(inventoryId)
		local inventory = Inventory.Map[inventoryId]
		if not inventory then return end
		delete(inventory)
	end
)

addEventHandler("inventoryAddItem", root,
	function(inventoryId, slot, itemId, amount)
		local inventory = Inventory.Map[inventoryId]
		if not inventory then return end

		local itemClass = Items[itemId].class
		table.insert(inventory.m_Items, (itemClass or Item):new(itemId, amount, slot))
		inventory:addItem(inventory.m_Items[#inventory.m_Items])
	end
)
addEventHandler("inventoryRemoveItem", root,
	function(inventoryId, slot, itemId, amount)
		local inventory = Inventory.Map[inventoryId]
		if not inventory then return end

		local item = inventory:findItem(slot, itemId)
		if item then
			inventory:removeItem(item, amount)
		end
	end
)
addEventHandler("inventoryUseItem", root,
	function(inventoryId, itemId, slot)
		local inventory = Inventory.Map[inventoryId]
		if not inventory then return end

		local item = inventory:findItem(slot, itemId)
		if item then
			inventory:useItem(item)
		end
	end
)
addEventHandler("inventoryReceiveFullSync", root,
	function(inventoryId, data)
		if not Inventory.Map[inventoryId] then
			Inventory.Map[inventoryId] = Inventory:new(inventoryId)
		end

		local inventory = Inventory.Map[inventoryId]
		inventory:applyItemsFromFullsync(data)

		InventoryGUI:getSingleton():setInventory(inventory, true)
	end
)
