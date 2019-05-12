-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/InventoryNew.lua
-- *  PURPOSE:     InventoryNew - Class
-- *
-- ****************************************************************************
InventoryNew = inherit(Object)

function InventoryNew.create()

end

function InventoryNew.load(inventoryId)
	local inventory = sql:asyncQueryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)

	if not inventory then
		return false
	end
	-- TODO: Rename _inventory_items2 TO _inventory_items
	local items = sql:asyncQueryFetch("SELECT ii.*, i.TechnicalName, i.CategoryId, i.Name, i.Description, i.Icon, i.ModelId, i.MaxDurability, i.Consumable, i.Tradeable, i.Expireable, i.IsUnique FROM ??_inventory_items2 ii INNER JOIN ??_items i ON i.Id = ii.ItemId WHERE InventoryId = ?", sql:getPrefix(), sql:getPrefix(), inventory.Id)

	return InventoryNew:new(inventory, items)
end

function InventoryNew:constructor(inventory, items)
	self.m_Id = inventory.Id
	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Size = inventory.Size
	self.m_AllowedCategories = inventory.AllowedCategories == nil and {} or fromJSON(inventory.AllowedCategories)
	if not self.m_AllowedCategories then self.m_AllowedCategories = {} end
	self.m_IsDirty = false
	self.m_DirtySince = 0

	self.m_Items = items
end

function InventoryNew:destructor()
	self:save()
end

function InventoryNew:save(force)
	if self.m_IsDirty then

	end
end

function InventoryNew:giveItem(item, value, durability, metadata)
	-- Does the item exist?
	if type(item) == "string" then
		item = InventoryManagerNew:getSingleton().m_ItemIdToName[item]
	end

	if not InventoryManagerNew:getSingleton().m_Items[item] then
		return false
	end
	
	-- TODO: Do some magical checks here

	self.m_IsDirty = true

	local itemData = InventoryManagerNew:getSingleton().m_Items[item]
	-- itemData.IsUnique
	-- metadata

	for k, v in pairs(self.m_Items) do
		if v.ItemId == item then
			if (v.Metadata and #v.Metadata > 0) or metadata or itemData.MaxDurability > 0 then
				iprint({v.Metadata, metadata, itemData.MaxDurability})
			else
				v.Value = v.Value + value
				return
			end
		end
	end

	local data = {
		Id = -1,
		ItemId = item,
		Value = value,
		Durability = durability,
		Metadata = metadata
	}

	for k, v in pairs(itemData) do
		if k ~= "Id" then
			data[k] = v
		end
	end

	table.insert(self.m_Items, data)
end

function InventoryNew:hasPlayerAccessTo(player)
	-- Typbasierte Checks, bspw.:
	--  Fraktion: ist der Spieler OnDuty in der Besitzerfraktion
	--  Kofferrraum: hat Spieler einen Schlüssel für das Fahrzeug / ist CopDuty
	--  Haus: ist der Spieler Mieter / Besitzer des Hauses
end
