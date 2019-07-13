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
	StatisticsLogger:getSingleton():itemPlaceLogs(player, placingInfo.itemData.Name, position.x..","..position.y..","..position.z)
	PlayerWorldItem:new(placingInfo.itemData, player:getId(), position, rotation, false, player:getId(), true, false, "#####", int, dim)
end

function KeyPadWorldItem:constructor(item, owner, pos, rotation, breakable, player, isPermanent, locked, value, interior, dimension, databaseId)
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

    --addCommandHandler("nearbykeypads", bind(self.Event_onNearbyCommand, self))
	--addCommandHandler("delkeypad", bind(self.Event_onDeleteCommand, self))
	--addEventHandler("confirmKeypadDelete", root, bind(self.Event_onConfirmKeyPadDelete, self))
	--addEventHandler("onKeyPadSubmit", root, bind(self.Event_onAskForAccess, self))
end

function KeyPadWorldItem:onCreate()
	--[[ -- move this to constructor
	local pin, updatePin, object
	local value = self.m_WorldItem:getValue()
	if not value or value == "#####" then
		pin, updatePin = "#####", true
	else
		pin, updatePin = value, false
	end
	self.m_Keypads[id] = worldObject
	worldObject:setAnonymous(true)
	worldObject:setAccessRange(10)
	worldObject:setAccessIntDimCheck(true)
	if self.m_Keypads[id] and self.m_Keypads[id].getObject and isElement(self.m_Keypads[Id]:getObject()) then
		object = self.m_Keypads[id]:getObject()
		object:setDoubleSided(true)
		object.Id = id
		object.Type = "Keypad"
		object.UpdatePin = updatePin
		object.Pin = pin
		object:setData("clickable", true, true)
		self.m_BindKeyClick = bind(self.onKeyPadClick, self)
		addEventHandler("onElementClicked", object, self.m_BindKeyClick)
		return true
	end
	return false
	]]
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
