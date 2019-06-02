-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Inventory.lua
-- *  PURPOSE:     Inventory - Class
-- *
-- ****************************************************************************
Inventory = inherit(Object)

function Inventory.create()

end

function Inventory.load(inventoryId, player)
	local inventory = sql:asyncQueryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)

	if not inventory then
		return false
	end
	-- TODO: Rename _inventory_items2 TO _inventory_items
	local items = sql:asyncQueryFetch("SELECT * FROM ??_inventory_items2 WHERE InventoryId = ?", sql:getPrefix(), inventory.Id)

	return Inventory:new(inventory, items, true, player)
end

function Inventory:constructor(inventory, items, persistent, player)
	self.m_Id = inventory.Id
	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Size = inventory.Size
	self.m_TypeId = inventory.TypeId
	self.m_Type = InventoryManager:getSingleton().m_InventoryTypes[inventory.TypeId].TechnicalName
	self.m_Persistent = persistent
	self.m_Player = player

	self.m_IsDirty = false
	self.m_DirtySince = 0
	self.m_NextItemId = 1

	self.m_Items = items
	for _, item in pairs(items) do
		local itemData = InventoryManager:getSingleton().m_Items[item.ItemId]
		for k, v in pairs(itemData) do
			if not item[k] then
				item[k] = v
			end
		end

		item.InternalId = self.m_NextItemId
		self.m_NextItemId = self.m_NextItemId + 1
	end
end

function Inventory:destructor()
	self:save()
end

function Inventory:save(force)
	if self.m_IsDirty then

	end
end

function Inventory:getPlayer()
	if self.m_Player and isElement(self.m_Player)then
		return self.m_Player
	end
	return false
end
--[[
	Checks to do:
		* Does the item exists?
		* Is the item compatible with the inventory?
		* Has the inventory still enough space?
		* Is the item unique and is it already in the inventory?
]]
function Inventory:giveItem(item, amount, durability, metadata)
	return InventoryManager:getSingleton():giveItem(self, item, amount, durability, metadata)
end

function Inventory:takeItem(itemInternalId, amount)
	return InventoryManager:getSingleton():takeItem(self, itemInternalId, amount)
end

function Inventory:useItem(id)
	return InventoryManager:getSingleton():useItem(self, id)
end

function Inventory:useItemSecondary(id)
	return InventoryManager:getSingleton():useItem(self, id)
end

function Inventory:onInventoryChanged()
	self.m_IsDirty = true

	if self.m_DirtySince == 0 then
		self.m_DirtySince = getTickCount()
	end

	if self.m_Player and isElement(self.m_Player) then
		InventoryManager:getSingleton():syncInventory(self.m_Player)
	end
end

function Inventory:getItem(id)
	for k, v in pairs(self.m_Items) do
		if v.InternalId == id then
			return v
		end 
	end
	return false
end

function Inventory:hasPlayerAccessTo(player)
	-- Typbasierte Checks, bspw.:
	--  Fraktion: ist der Spieler OnDuty in der Besitzerfraktion
	--  Kofferrraum: hat Spieler einen Schlüssel für das Fahrzeug / ist CopDuty
	--  Haus: ist der Spieler Mieter / Besitzer des Hauses
end

function Inventory:isCompatibleWithCategory(category)
	local iType = InventoryManager:getSingleton().m_InventoryTypes[self.m_TypeId]

	for _, c in pairs(iType.Categories) do
		if c.TechnicalName == category then
			return true
		end
	end

	return false
end

function Inventory:getCurrentSize()
	local size = 0

	for k, v in pairs(self.m_Items) do
		size = size + v.Size * v.Amount
	end

	return size
end
