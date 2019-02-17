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
	local inventory = sql:queryFetchSingle("SELECT * FROM ??_inventories WHERE Id = ? AND Deleted IS NULL", sql:getPrefix(), inventoryId)

	if not inventory then
		return false
	end

	local items = sql:queryFetch("SELECT * FROM ??_inventory_items WHERE InventoryId = ?", sql:getPrefix(), inventory.Id)

	return InventoryNew:new(inventory, items)
end

function InventoryNew:constructor(inventory, items)
	self.m_Id = inventory.Id
	self.m_ElementId = inventory.ElementId
	self.m_ElementType = inventory.ElementType
	self.m_Size = inventory.Size
	self.m_AllowedCategories = fromJSON(inventory.AllowedCategories)
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

function InventoryNew:hasPlayerAccessTo(ele player)
	-- Typbasierte Checks, bspw.:
	--  Fraktion: ist der Spieler OnDuty in der Besitzerfraktion
	--  Kofferrraum: hat Spieler einen Schlüssel für das Fahrzeug / ist CopDuty
	--  Haus: ist der Spieler Mieter / Besitzer des Hauses
end
