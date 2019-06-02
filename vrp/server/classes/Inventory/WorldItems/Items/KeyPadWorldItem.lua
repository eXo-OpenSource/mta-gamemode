-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/KeyPadWorldItem.lua
-- *  PURPOSE:     
-- *
-- ****************************************************************************
KeyPadWorldItem = inherit(Object)
KeyPadWorldItem.Map = {}

function KeyPadWorldItem:constructor(worldItem, id, itemData)
    self.m_Id = id
    self.m_WorldItem = worldItem
    self.m_ItemData = itemData

    KeyPadWorldItem.Map[id] = self

    --addCommandHandler("nearbykeypads", bind(self.Event_onNearbyCommand, self))
	--addCommandHandler("delkeypad", bind(self.Event_onDeleteCommand, self))
	--addEventHandler("confirmKeypadDelete", root, bind(self.Event_onConfirmKeyPadDelete, self))
	--addEventHandler("onKeyPadSubmit", root, bind(self.Event_onAskForAccess, self))
end

function KeyPadWorldItem:onCreate()
	local pin, updatePin, object
	local value = self.m_WorldItem:getValue()
	if not value or value == "#####" then 
		pin, updatePin = "#####", true
	else 
		pin, updatePin = value, false
	end
	-- KeyPadWorldItem.Map[Id] = worldObject
	self.m_WorldItem:setAnonymous(true)
	self.m_WorldItem:setAccessRange(10)
    self.m_WorldItem:setAccessIntDimCheck(true)
    
	if self.m_WorldItem.getObject and isElement(self.m_WorldItem:getObject()) then
		object = self.m_WorldItem:getObject()
		object:setDoubleSided(true)
		object.Id = Id
		object.Type = "Keypad"
		object.UpdatePin = updatePin
		object.Pin = pin
		object:setData("clickable", true, true)
		self.m_BindKeyClick = bind(self.Event_onKeyPadClick, self)
		addEventHandler("onElementClicked", object, self.m_BindKeyClick)
		return true
	end
	return false
end


function KeyPadWorldItem:Event_onKeyPadClick(button, state, player)
    if source.Type ~= "Keypad" then return end
	if button == "right" and state == "up" then
        if source == self.m_WorldItem:getObject() then
			player.m_LastKeyPadID = self.m_Id
			player:triggerEvent("promptKeyPad", self.m_Id)
			triggerClientEvent(root, "playKeyPadSound", root, source, "keypad_access")
        end
	end
end