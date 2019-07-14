-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/KeyPadWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
KeyPadWorldItem = inherit(PlayerWorldItem)
KeyPadWorldItem.Map = {}

function KeyPadWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local int = player:getInterior()
	local dim = player:getDimension()
	KeyPadWorldItem:new(placingInfo.itemData, player:getId(), player:getId(), DbElementType.Player, position, rotation, dim, int, true, "#####", {locked = false}, false, false)
end

function KeyPadWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    KeyPadWorldItem.Map[self.m_Id] = self

	self:setAnonymous(true)
	self:setAccessRange(10)
	self:setAccessIntDimCheck(true)

	local pin, updatePin
	local value = self:getValue()
	if not value or value == "#####" then
		pin, updatePin = "#####", true
	else
		pin, updatePin = value, false
	end

	local object = self:getObject()
	object:setDoubleSided(true)
	object.Id = databaseId
	object.Type = "Keypad"
	object.UpdatePin = updatePin
	object.Pin = pin
	object:setData("clickable", true, true)
	self.m_BindKeyClick = bind(self.Event_onKeyPadClick, self)
	addEventHandler("onElementClicked", object, self.m_BindKeyClick)
end

function KeyPadWorldItem:Event_onKeyPadClick(button, state, player)
    if source.Type ~= "Keypad" then return end
	if button == "right" and state == "up" then
        if source == self:getObject() then
			player.m_LastKeyPadID = self.m_Id
			player:triggerEvent("promptKeyPad", self.m_Id)
			triggerClientEvent(root, "playKeyPadSound", root, source, "keypad_access")
        end
	end
end
