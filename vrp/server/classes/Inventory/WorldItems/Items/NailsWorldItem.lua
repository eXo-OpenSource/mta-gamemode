-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/NailsWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
NailsWorldItem = inherit(FactionWorldItem)
NailsWorldItem.Map = {}

function NailsWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local faction = player:getFaction()
	local int = player:getInterior()
	local dim = player:getDimension()
	-- (item, owner, pos, rotation, breakable, player, isPermanent, locked, value, interior, dimension, databaseId)
	-- FactionWorldItem:new(self, player:getFaction(), position, rotation, true, player)
	-- (itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
	NailsWorldItem:new(placingInfo.itemData, player:getId(), faction:getId(), DbElementType.Faction, position, rotation, dim, int, false, "", {}, true, false)
end

function NailsWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    NailsWorldItem.Map[self.m_Id] = self
    local dummy = createObject(984, position)
    dummy:setAlpha(0)
    self:attach(dummy, false, Vector3(0, 90, 0))

	addEventHandler("onClientBreakItem", self:getObject(), function()
		source.m_Super:onDelete()
    end)
end

function NailsWorldItem:destructor()
    NailsWorldItem.Map[self.m_Id] = nil
    
end

function NailsWorldItem:onChanged()

end