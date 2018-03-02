-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDoor.lua
-- *  PURPOSE:     Door item class
-- *
-- ****************************************************************************
ItemDoor = inherit(Item)
ItemDoor.Map = {}


function ItemDoor:constructor()
	addRemoteEvents{"confirmDoorDelete", "onDoorDataChange", "onKeyPadSignal"}
	addEventHandler("confirmDoorDelete", root, bind(self.Event_onConfirmDoorDelete, self))
	addEventHandler("onDoorDataChange", root, bind(self.Event_onDoorDataChange, self))
	addEventHandler("onKeyPadSignal", root, bind(self.Event_onKeyPadSignal, self))
	addCommandHandler("nearbydoors", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("deldoor", bind(self.Event_onDeleteCommand, self))
	self.m_Model = 1493
	self.m_Doors = {}
	self.m_Timers = {}
	self.m_KeyPadLinks = {}
end

function ItemDoor:destructor()
	local rebuildKeyListString = ""
	for id , obj in pairs(self.m_Doors) do 
		if obj and obj.getObject and isElement(obj:getObject()) and obj:getObject().UpdateDoor then 
			rebuildKeyListString = self:rebuildLinkedKeypads( obj.LinkedKeyPad ) 
			obj:setValue(rebuildKeyListString..":"..getElementModel(obj:getObject())..":"..obj:getObject().openPos.x..":"..obj:getObject().openPos.y..":"..obj:getObject().openPos.z)
			obj.m_HasChanged = true
		end
	end
end

function ItemDoor:addWorldObjectCallback(Id, worldObject)
	local linkedKeyPadList, model, oX, oY, oZ
	local value = worldObject:getValue()
	local pos = worldObject:getObject():getPosition()
	local updateDoor = false
	if not value or value == "" then 
		linkedKeyPadList = "#"
		model, oX, oY, oZ, updateDoor = self.m_Model, pos.x, pos.y, pos.z - 2, true
	else 
		linkedKeyPadList, model, oX, oY, oZ = gettok(value, 1, ":") or "#", tonumber(gettok(value, 2, ":")), tonumber(gettok(value, 3, ":")), tonumber(gettok(value, 4, ":")), tonumber(gettok(value, 5, ":"))
	end
	worldObject:setModel(model)
	self.m_Doors[Id] = worldObject
	if self.m_Doors[Id] then
		local object = self.m_Doors[Id]:getObject()
		object:setDoubleSided(true)
		object.Id = Id
		object.Type = "Tor"
		object.openPos = Vector3(oX or pos.x, oY or pos.y , oZ or pos.z -2)
		object.closedPos = self.m_Doors[Id]:getObject():getPosition()
		object.UpdateDoor = updateDoor
		object.m_Closed = true
		object:setData("clickable", true, true)
		self:seperateLinkedKeypads(self.m_Doors[Id], linkedKeyPadList)
		self:createColshapes(object:getModel(), object, pos, rot, Vector3(0,0,0))
		self.m_BindKeyClick = bind(self.onDoorClick, self)
		addEventHandler("onElementClicked", object, self.m_BindKeyClick)
		return true
	else 
		return false
	end
end

function ItemDoor:seperateLinkedKeypads( door, keypadString ) 
	local count = 1
	local sepString
	local list = {}
	if #keypadString > 1 then
		while gettok(keypadString, count, "+") do 
			sepString = gettok(keypadString, count, "+") 
			if tonumber(sepString) then 
				sepString = tonumber(sepString)
				if not self.m_KeyPadLinks[sepString] then self.m_KeyPadLinks[sepString] = {} end 
				table.insert(list, sepString)
				table.insert(self.m_KeyPadLinks[sepString], door)
			end
			count = count + 1
		end
	end
	door.LinkedKeyPad = list
end

function ItemDoor:rebuildLinkedKeypads( keypadList ) 
	local keypadId
	local listString = ""
	for i = 1, #keypadList do 
		keypadId = keypadList[i]
		listString = listString.."+"..keypadId
	end
	return listString
end

function ItemDoor:removeKeyPadLink( id, keyPadId) 
	if id and keyPadId then 
		if not self.m_KeyPadLinks[keyPadId] then 
			self.m_KeyPadLinks[keyPadId] = {} 
			return true 
		end
		if type(keyPadId) == "number" then
			for i = 1, #self.m_KeyPadLinks[keyPadId] do
				if self.m_KeyPadLinks[keyPadId][i] == self.m_Doors[id] then 
					return table.remove(self.m_KeyPadLinks[keyPadId], i)
				end
			end
		end
	end
	return false
end

function ItemDoor:addKeyPadLink( id, keyPadId) 
	if id and keyPadId then 
		if not self.m_KeyPadLinks[keyPadId] then 
			self.m_KeyPadLinks[keyPadId] = {}
			return table.insert( self.m_KeyPadLinks[keyPadId], self.m_Doors[id])
		end
		if type(keyPadId) == "number" then
			for i = 1, #self.m_KeyPadLinks[keyPadId] do
				if self.m_KeyPadLinks[keyPadId][i] == self.m_Doors[id] then 
					return
				end
			end
		end
		return table.insert( self.m_KeyPadLinks[keyPadId], self.m_Doors[id])
	end
	return false
end

function ItemDoor:addLinkKey( id, keyPadId) 
	if id and keyPadId then 
		if type(keyPadId) == "number" and self.m_Doors[id] then
			for i = 1, #self.m_Doors[id].LinkedKeyPad do
				if self.m_Doors[id].LinkedKeyPad[i] == keyPadId then 
					return
				end
			end
		end
	end
	return table.insert( self.m_Doors[id].LinkedKeyPad, keyPadId)
end


function ItemDoor:removeLinkKey( id, keyPadId) 
	if id and keyPadId then 
		if type(keyPadId) == "number" and self.m_Doors[id] then
			for i = 1, #self.m_Doors[id].LinkedKeyPad do
				if self.m_Doors[id].LinkedKeyPad[i] == keyPadId then 
					return table.remove(self.m_Doors[id].LinkedKeyPad, i)
				end
			end
		end
	end
	return false
end

function ItemDoor:openDoor(door)
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

function ItemDoor:removeObject( id ) 
	if self.m_Doors[id] then 
		self.m_Doors[id]:forceDelete()
		self.m_Doors[id] = nil
	end
end

function ItemDoor:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	local model = tonumber(gettok(value, 2, ":")) or self.m_Model
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		local valueString = (value or "#:"..self.m_Model)
		player:getInventory():removeItem(self:getName(), 1)
		player:sendInfo(_("%s hinzugefügt!", player, "Tor Modell ("..model..")"))
		local dim = player:getDimension() 
		local int = player:getInterior()
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Tor", position.x..","..position.y..","..position.z)
		local worldObject = PlayerWorldItem:new(ItemManager:getSingleton():getInstance("Tor"), player:getId(), position, rotation, false, player:getId(), true, false, valueString)
		worldObject:setDimension(dim) 
		worldObject:setInterior(int)
		local id = worldObject:forceSave() 
		if id then 
			if not self:addWorldObjectCallback(id, worldObject) then
				player:sendInfo(_("Ein Fehler trat auf beim Platzieren!", player))
			end
		end
	end, false, model)
end

function ItemDoor:onDoorClick(button, state, player)
    if source.Type ~= "Tor" then return end
	if button == "right" and state == "up" then
		if player.m_SupMode then
			player.m_LastDoorId = source.Id
			local pos = {getElementPosition(source)}
			player:triggerEvent("promptDoorOption", source.LinkedKeyPad, pos)
		end
	end
end

function ItemDoor:Event_onKeyPadSignal( ) 
	local keypad = source
	if keypad and isElement(keypad) and keypad.Id then
		if self.m_KeyPadLinks[keypad.Id] then 
			local sourcePos = keypad:getPosition()
			local pos
			for id, obj in ipairs(self.m_KeyPadLinks[keypad.Id] ) do 
				if obj and obj.getObject and isElement(obj:getObject()) then
					pos = obj:getObject():getPosition() 
					if getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z) <= 30 then 
						self:openDoor( obj:getObject() )
					end
				end
			end
		end
	end
end

function ItemDoor:Event_onConfirmDoorDelete( id ) 
	if source.m_DoorQuestionDeleteId then 
		if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
		self:removeObject( source.m_DoorQuestionDeleteId )
		source:sendSuccess(_("Das Tor mit der ID %s wurde gelöscht!", source, id))
	end
end

function ItemDoor:Event_onDoorDataChange( posX, posY, posZ, padId, removePadId, model) 
	if client then 
		if client.m_LastDoorId then 
			if self.m_Doors[client.m_LastDoorId] then 
				local door = self.m_Doors[client.m_LastDoorId]
				if door and door.getObject and isElement(door:getObject()) then 
					door = door:getObject()
					local x,y,z = getElementPosition(door)
					door.openPos.x, door.openPos.y, door.openPos.z = tonumber(posX) or door.openPos.x, tonumber(posY) or door.openPos.y, tonumber(posZ) or door.openPos.z
					door.openPos = Vector3(door.openPos.x, door.openPos.y, door.openPos.z)
					if padId and tonumber(padId) then
						padId = tonumber(padId)
						self:addKeyPadLink(door.Id, padId)
						self:addLinkKey(door.Id, padId)
					end
					if removePadId and tonumber(removePadId) then
						removePadId = tonumber(removePadId)
						self:removeKeyPadLink(door.Id, removePadId)
						self:removeLinkKey(door.Id, removePadId)
					end
					if model and tonumber(model) then 
						setElementModel(door, tonumber(model))
					end
					door.UpdateDoor = true
					client:sendSuccess(_("Tor wurde aktualisiert!", client))
				end
			end
		end
	end
end

function ItemDoor:Event_onNearbyCommand( source, cmd) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Tore in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	for id , obj in pairs(self.m_Doors) do 
		if obj and obj.getObject and isElement(obj:getObject()) then
			count = count + 1
			objectPosition = obj:getObject():getPosition()
			dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
			if dist <= 10 then  
				outputChatBox(" #ID "..obj:getObject().Id.." Model: "..getElementModel(obj:getObject()).." Distanz: "..dist , source, 244, 182, 66)
			end
		end
	end
	if count == 0 then outputChatBox(" Keine in der Nähe",  source, 244, 182, 66) end
end

function ItemDoor:Event_onDeleteCommand( source, cmd, id)
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = self.m_Doors[tonumber(id)] 
		if obj and obj.getObject and isElement(obj:getObject()) then 
			obj = obj:getObject()
			local objPos = obj:getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				source:sendInfo(_("Das Tor mit der ID %s wurde gelöscht!", source, id))
			end
		end
	end
end

function ItemDoor:createColshapes(model, object, pos, rot, customOffset)
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


