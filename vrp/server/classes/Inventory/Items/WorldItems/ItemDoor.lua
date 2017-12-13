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
	self.m_Model = 1493
	self.m_Doors = {}
	self.m_Timers = {}
	self.m_KeyPadLinks = {}
end


function ItemDoor:addObject(Id, pos, rot, int, dim, value)
	local linkedKeyPadList, model, oX, oY, oZ, updateDoor
	if not value or tostring(value) == "" then 
		linkedKeyPadList = "#"
		model = self.m_Model
		oX = pos.x
		oY = pos.y 
		oZ = pos.z - 2
		updateDoor = true
	else 
		linkedKeyPadList = gettok(value, 1, ":") or "#"
		model = tonumber(gettok(value, 2, ":"))
		oX = tonumber(gettok(value, 3, ":"))
		oY = tonumber(gettok(value, 4, ":"))
		oZ = tonumber(gettok(value, 5, ":"))
		updateDoor = false
	end
	int = tostring(int) or 0 
	dim = tostring(dim) or 0
	self.m_Doors[Id] = createObject(model or self.m_Model, pos)
	if self.m_Doors[Id] then
		setElementDimension(self.m_Doors[Id], dim)
		setElementInterior(self.m_Doors[Id], int)
		setElementDoubleSided(self.m_Doors[Id], true)
		self.m_Doors[Id]:setRotation( rot ) 
		self.m_Doors[Id].Id = Id
		self.m_Doors[Id].Type = "Tor"
		self.m_Doors[Id].openPos = Vector3(oX or pos.x, oY or pos.y , oZ or pos.z -2)
		self.m_Doors[Id].closedPos = self.m_Doors[Id]:getPosition()
		self.m_Doors[Id].UpdateDoor = updateDoor
		self.m_Doors[Id].m_Closed = true
		self:seperateLinkedKeypads( self.m_Doors[Id], linkedKeyPadList)
		self.m_Doors[Id]:setData("clickable", true, true)
		self:createColshapes(getElementModel(self.m_Doors[Id]), self.m_Doors[Id], pos, rot, Vector3(0,0,0))
		self.m_BindKeyClick = bind(self.onDoorClick, self)
		addEventHandler("onElementClicked",self.m_Doors[Id], self.m_BindKeyClick)
		return self.m_Doors[Id]
	else 
		return nil 
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
				if not self.m_KeyPadLinks[tonumber(sepString)] then self.m_KeyPadLinks[tonumber(sepString)] = {} end 
				table.insert(list, tonumber(sepString))
				table.insert(self.m_KeyPadLinks[tonumber(sepString)], door)
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



function ItemDoor:Event_onKeyPadSignal( ) 
	local keypad = source
	if keypad and isElement(keypad) and keypad.Id then
		if self.m_KeyPadLinks[keypad.Id] then 
			local x,y,z = getElementPosition(keypad)
			local dx, dy, dz
			for id, obj in ipairs(self.m_KeyPadLinks[keypad.Id] ) do 
				dx, dy, dz = getElementPosition(obj) 
				if getDistanceBetweenPoints3D(dx, dy, dz, x, y, z) <= 30 then 
					self:openDoor( obj )
				end
			end
		end
	end
end

function ItemDoor:Event_onConfirmDoorDelete( id ) 
	if source.m_DoorQuestionDeleteId then 
		self:removeObject( source.m_DoorQuestionDeleteId )
		source:sendSuccess(_("Das Tor mit der ID %s wurde gelöscht!", source, id))
	end
end

function ItemDoor:Event_onDoorDataChange( posX, posY, posZ, padId, removePadId, model) 
	if client then 
		if client.m_LastDoorId then 
			if self.m_Doors[client.m_LastDoorId] then 
				local door = self.m_Doors[client.m_LastDoorId]
				if isElement(door) then 
					local x,y,z = getElementPosition(door)
					door.openPos.x = tonumber(posX) or door.openPos.x
					door.openPos.y = tonumber(posY) or door.openPos.y
					door.openPos.z = tonumber(posZ) or door.openPos.z
					door.openPos = Vector3(door.openPos.x, door.openPos.y, door.openPos.z)
					if padId and tonumber(padId) then
						self:addKeyPadLink(door.Id, tonumber(padId))
						self:addLinkKey(door.Id, tonumber(padId))
					end
					if removePadId and tonumber(removePadId) then 
						self:removeKeyPadLink(door.Id, tonumber(removePadId))
						self:removeLinkKey(door.Id, tonumber(removePadId))
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
		local dim = getElementDimension(player) 
		local int = getElementInterior(player)
		--FactionState:getSingleton():sendShortMessage(_("%s hat ein Keypad bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Tor", position.x..","..position.y..","..position.z)
		sql:queryExec("INSERT INTO ??_word_objects(Typ, PosX, PosY, PosZ, RotationZ, Interior, Dimension,  Value, ZoneName, Admin, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), "Tor", position.x, position.y, position.z, rotation, int, dim, valueString , getZoneName(position).."/"..getZoneName(position, true), player:getId())
		if not self:addObject(sql:lastInsertId(), position, Vector3(0,0,rotation), int, dim, valueString ) then 
			sql:queryExec("DELETE FROM ??_word_objects WHERE Id=?", sql:getPrefix(), sql:lastInsertId())	
		end
	end, false, model)
end

function ItemDoor:onDoorClick(button, state, player)
    if source.Type ~= "Tor" then return end
	if button == "left" and state == "up" then
		if player.m_SupMode then
			player.m_LastDoorId = source.Id
			local pos = {getElementPosition(source)}
			player:triggerEvent("promptDoorOption", source.LinkedKeyPad, pos)
		end
	elseif button == "right" and state == "up" then 
		if player.m_SupMode then 
			player.m_DoorQuestionDeleteId = source.Id
			QuestionBox:new(player, player, _("Möchtest du dieses Tor (#"..source.Id.." Modell: "..getElementModel(source)..") löschen?", player), "confirmDoorDelete", nil, source.Id)
		end
    end
end

function ItemDoor:removeObject( id ) 
	if id then 
		if self.m_Doors[id] then 
			destroyElement(self.m_Doors[id])
			self.m_Doors[id] = nil
			sql:queryExec("DELETE FROM ??_word_objects WHERE Id=?", sql:getPrefix(), id)
		end
	end
end


function ItemDoor:destructor()
	local rebuildKeyListString = ""
	for id , obj in pairs(self.m_Doors) do 
		if obj.UpdateDoor then 
			rebuildKeyListString = self:rebuildLinkedKeypads( obj.LinkedKeyPad ) 
			sql:queryExec("UPDATE ??_word_objects SET value=? WHERE Id=?;", sql:getPrefix(), rebuildKeyListString..":"..getElementModel(obj)..":"..obj.openPos.x..":"..obj.openPos.y..":"..obj.openPos.z, obj.Id )
		end
	end
end
