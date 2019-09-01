-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/DoorWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
DoorWorldItem = inherit(PlayerWorldItem)
DoorWorldItem.Map = {}
DoorWorldItem.KeyPadLinks = {}
addRemoteEvents{"onDoorDataChange"}

function DoorWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local faction = player:getFaction()
	local int = player:getInterior()
	local dim = player:getDimension()
	-- (item, owner, pos, rotation, breakable, player, isPermanent, locked, value, interior, dimension, databaseId)
	-- FactionWorldItem:new(self, player:getFaction(), position, rotation, true, player)
	-- (itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
	DoorWorldItem:new(placingInfo.itemData, player:getId(), player:getId(), DbElementType.Player, position, rotation, dim, int, true, "", {}, true, false)
end

function DoorWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    DoorWorldItem.Map[self.m_Id] = self

	local value = self:getValue()
	local pos = self:getObject():getPosition()
	local updateDoor = false

	if not value or value == "" then
		linkedKeyPadList = "#"
		model, oX, oY, oZ, updateDoor = self.m_Model, pos.x, pos.y, pos.z - 2, true
	else
		linkedKeyPadList, model, oX, oY, oZ = gettok(value, 1, ":") or "#", tonumber(gettok(value, 2, ":")), tonumber(gettok(value, 3, ":")), tonumber(gettok(value, 4, ":")), tonumber(gettok(value, 5, ":"))
	end

	local object = self:getObject()
	object:setDoubleSided(true)
	object.Id = Id
	object.Type = "Tor"
	object.openPos = Vector3(oX or pos.x, oY or pos.y , oZ or pos.z -2)
	object.closedPos = object:getPosition()
	object.UpdateDoor = updateDoor
	object.m_Closed = true
	object:setData("clickable", true, true)
	self:seperateLinkedKeypads(linkedKeyPadList)
	self:createColshapes(object:getModel(), object, pos, rot, Vector3(0,0,0))
	self.m_BindKeyClick = bind(self.onDoorClick, self)
	addEventHandler("onElementClicked", object, self.m_BindKeyClick)

	addEventHandler("onDoorDataChange", object, bind(self.Event_onDoorDataChange, self))
	addEventHandler("onKeyPadSignal", object, bind(self.Event_onKeyPadSignal, self))
end

function DoorWorldItem:createColshapes(model, object, pos, rot, customOffset)
    local x, y, x1, y1
    if model == 980 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+180)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, -4, rot.z)
    elseif model == 971 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+180)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z)
    elseif model == 9093 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+80)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z+60)
	elseif model == 2938 then
		x1, y1 = getPointFromDistanceRotation(pos.x+2, pos.y, 4, rot.z-90)
        x2, y2 = getPointFromDistanceRotation(pos.x-2, pos.y-1, 4, rot.z+90)
	elseif model == 7657 then
		x1, y1 = getPointFromDistanceRotation(pos.x+4, pos.y, 4, rot.z-90)
        x2, y2 = getPointFromDistanceRotation(pos.x-2, pos.y, 4, rot.z+90)
	elseif model == 10558 then
		x1, y1 = getPointFromDistanceRotation(pos.x-4, pos.y+6, 3.5, rot.z)
        x2, y2 = getPointFromDistanceRotation(pos.x-4, pos.y-6, 3.5, rot.z)
    end
	if DEBUG then
		self.m_Marker1 = createMarker(Vector3(x1, y1, pos.z - 1.75) + object.matrix.forward*(customOffset and -customOffset or -2),"cylinder",1) -- Developement Test
		self.m_Marker2 = createMarker(Vector3(x2, y2, pos.z - 1.75) + object.matrix.forward*(customOffset or 2),"cylinder",1,255) -- Developement Test
    end
	self.m_ColShape1 = ColShape.Sphere(Vector3(x1, y1, pos.z - 1.75) + object.matrix.forward*(customOffset and -customOffset or -2), 5)
    self.m_ColShape2 = ColShape.Sphere(Vector3(x2, y2, pos.z - 1.75) + object.matrix.forward*(customOffset or 2), 5)
end

function DoorWorldItem:seperateLinkedKeypads(keypadString)
	local count = 1
	local sepString
	local list = {}
	if #keypadString > 1 then
		while gettok(keypadString, count, "+") do
			sepString = gettok(keypadString, count, "+")
			if tonumber(sepString) then
				sepString = tonumber(sepString)
				if not DoorWorldItem.KeyPadLinks[sepString] then DoorWorldItem.KeyPadLinks[sepString] = {} end
				table.insert(list, sepString)
				table.insert(DoorWorldItem.KeyPadLinks[sepString], self)
			end
			count = count + 1
		end
	end
	self.m_LinkedKeyPad = list
end

function DoorWorldItem:rebuildLinkedKeypads(keypadList)
	local keypadId
	local listString = ""
	for i = 1, #keypadList do
		keypadId = keypadList[i]
		listString = listString.."+"..keypadId
	end
	return listString
end

function DoorWorldItem:removeKeyPadLink(keyPadId)
	if keyPadId then
		if not DoorWorldItem.KeyPadLinks[keyPadId] then
			DoorWorldItem.KeyPadLinks[keyPadId] = {}
			return true
		end
		if type(keyPadId) == "number" then
			for i = 1, #DoorWorldItem.KeyPadLinks[keyPadId] do
				if DoorWorldItem.KeyPadLinks[keyPadId][i] == self then
					return table.remove(DoorWorldItem.KeyPadLinks[keyPadId], i)
				end
			end
		end
	end
	return false
end

function DoorWorldItem:addKeyPadLink(keyPadId)
	if keyPadId then
		if not DoorWorldItem.KeyPadLinks[keyPadId] then
			DoorWorldItem.KeyPadLinks[keyPadId] = {}
			return table.insert(DoorWorldItem.KeyPadLinks[keyPadId], self)
		end
		if type(keyPadId) == "number" then
			for i = 1, #DoorWorldItem.KeyPadLinks[keyPadId] do
				if DoorWorldItem.KeyPadLinks[keyPadId][i] == self then
					return
				end
			end
		end
		return table.insert(DoorWorldItem.KeyPadLinks[keyPadId], self)
	end
	return false
end

function DoorWorldItem:addLinkKey(keyPadId)
	if keyPadId then
		if type(keyPadId) == "number" then
			for i = 1, #self.m_LinkedKeyPad do
				if self.m_LinkedKeyPad[i] == keyPadId then
					return
				end
			end
		end
	end
	return table.insert(self.m_LinkedKeyPad, keyPadId)
end


function DoorWorldItem:removeLinkKey(keyPadId)
	if keyPadId then
		if type(keyPadId) == "number" then
			for i = 1, #self.m_LinkedKeyPad do
				if self.m_LinkedKeyPad[i] == keyPadId then
					return table.remove(self.m_LinkedKeyPad, i)
				end
			end
		end
	end
	return false
end

function DoorWorldItem:onDoorClick(button, state, player)
    if source ~= self:getObject() then return end
	if button == "right" and state == "up" then
		if player.m_SupMode then
			player.m_LastDoorId = self.m_Id
			local pos = {getElementPosition(self:getObject())}
			player:triggerEvent("promptDoorOption", self.m_LinkedKeyPad, pos, self:getObject())
		end
	end
end

function DoorWorldItem:Event_onKeyPadSignal()
	local keypad = source
	if keypad and isElement(keypad) and keypad.m_Id then
		if self.m_KeyPadLinks[keypad.m_Id] then
			local sourcePos = keypad:getPosition()
			local pos
			for id, obj in ipairs(self.m_KeyPadLinks[keypad.m_Id] ) do
				if obj and obj.getObject and isElement(obj:getObject()) then
					pos = obj:getObject():getPosition()
					if getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z) <= 30 then
						self:openDoor(obj:getObject())
					end
				end
			end
		end
	end
end

function DoorWorldItem:openDoor(door)
	if self.m_Timers[door] and isTimer(self.m_Timers[door]) then
		killTimer(self.m_Timers[door])
	end
	if door and isElement(door) then
		if door.m_Closed then
			door:move((door.position - door.openPos).length * 800, door.openPos, 0, 0, 0, "InOutQuad")
			triggerClientEvent("itemRadioChangeURLClient", door, "files/audio/gate_open.mp3")
			door.m_Closed = false
		else
			door:move((door.position - door.closedPos).length * 800, door.closedPos, 0, 0, 0, "InOutQuad")
			triggerClientEvent("itemRadioChangeURLClient", door, "files/audio/gate_open.mp3")
			door.m_Closed = true
		end
    end
end

function DoorWorldItem:destructor()
	if self:getObject().m_LightTimer then
		self:toggleBlinkingLight(self:getObject())
	end
end


function DoorWorldItem:Event_onDoorDataChange(posX, posY, posZ, padId, removePadId, model)
	if client then
		if client.m_LastDoorId == self.m_Id then
			local door = self:getObject()
			local x,y,z = getElementPosition(door)
			door.openPos.x, door.openPos.y, door.openPos.z = tonumber(posX) or door.openPos.x, tonumber(posY) or door.openPos.y, tonumber(posZ) or door.openPos.z
			door.openPos = Vector3(door.openPos.x, door.openPos.y, door.openPos.z)
			if padId and tonumber(padId) then
				padId = tonumber(padId)
				self:addKeyPadLink(padId)
				self:addLinkKey(padId)
			end
			if removePadId and tonumber(removePadId) then
				removePadId = tonumber(removePadId)
				self:removeKeyPadLink(removePadId)
				self:removeLinkKey(removePadId)
			end
			if model and tonumber(model) then
				setElementModel(door, tonumber(model))
			end
			door.UpdateDoor = true
			client:sendSuccess(_("Tor wurde aktualisiert!", client))
		end
	end
end
