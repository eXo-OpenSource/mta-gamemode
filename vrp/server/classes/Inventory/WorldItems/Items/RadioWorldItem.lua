-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/RadioWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
RadioWorldItem = inherit(PlayerWorldItem)
RadioWorldItem.Map = {}
addRemoteEvents{"itemRadioChangeURL", "itemRadioStopSound"}

function RadioWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local int = player:getInterior()
	local dim = player:getDimension()
	RadioWorldItem:new(placingInfo.itemData, player:getId(), player:getId(), DbElementType.Player, position, rotation, dim, int, false, "", {}, false, false)
end

function RadioWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    RadioWorldItem.Map[self.m_Id] = self
	addEventHandler("itemRadioChangeURL", self:getObject(), bind(self.Event_onRadioChangeSound, self))
	addEventHandler("itemRadioStopSound", self:getObject(), bind(self.Event_onRadioStopSound, self))
end

function RadioWorldItem:Event_onRadioChangeSound(url)
	if self:hasPlayerPermissionTo(client, WorldItem.Action.Move) then
		triggerClientEvent("itemRadioChangeURLClient", self:getObject(), url)
	end
end

function RadioWorldItem:Event_onRadioStopSound()
	if self:hasPlayerPermissionTo(client, WorldItem.Action.Move) then
		triggerClientEvent("itemRadioRemove", self:getObject())
	end
end
