-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemEntrance.lua
-- *  PURPOSE:     Entrance item class
-- *
-- ****************************************************************************
ItemEntrance = inherit(Item)
ItemEntrance.Map = {}


function ItemEntrance:constructor()
	addRemoteEvents{"confirmEntranceDelete", "onEntranceDataChange", "onKeyPadSignal", "confirmEntranceEnter", "cancelEntranceEnter"}
	addEventHandler("confirmEntranceDelete", root, bind(self.Event_onConfirmEntranceDelete, self))
	addEventHandler("onEntranceDataChange", root, bind(self.Event_onEntranceDataChange, self))
	addEventHandler("confirmEntranceEnter", root, bind(self.Event_onEntranceConfirm, self))
	addEventHandler("cancelEntranceEnter", root, bind(self.Event_onEntranceCancel, self))
	addEventHandler("onKeyPadSignal", root, bind(self.Event_onKeyPadSignal, self))
	addCommandHandler("nearbyentrances", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("delentrance", bind(self.Event_onDeleteCommand, self))
	self.m_Model = 2986
	self.m_Entrances = {}
	self.m_Timers = {}
	self.m_KeyPadLinks = {}
end


function ItemEntrance:addObject(Id, pos, rot, int, dim, value)
	local linkedKeyPadList, houseID, model, posX, posY, posZ
	if not value or tostring(value) == "" then 
		linkedKeyPadList = "#"
		houseID = "#"
		model = self.m_Model
		posX = false 
		posY = false 
		posZ = false
		updateEntrance = true
	else 
		linkedKeyPadList = gettok(value, 1, ":") or "#"
		model = tonumber(gettok(value, 2, ":"))
		houseID = tonumber(gettok(value, 3, ":")) or "#"
		posX = tonumber(gettok(value, 4, ":")) 
		posY = tonumber(gettok(value, 5, ":")) 
		posZ = tonumber(gettok(value, 6, ":")) 
		updateEntrance	= false
	end
	int = tostring(int) or 0 
	dim = tostring(dim) or 0
	self.m_Entrances[Id] = createObject(model or self.m_Model, pos.x, pos.y, pos.z, 3)
	if self.m_Entrances[Id] and houseID then
		setElementDimension(self.m_Entrances[Id], dim)
		setElementInterior(self.m_Entrances[Id], int)
		setElementDoubleSided(self.m_Entrances[Id], true)
		self.m_Entrances[Id]:setRotation( rot ) 
		self.m_Entrances[Id].Id = Id
		self.m_Entrances[Id].Type = "Eingang"
		self.m_Entrances[Id].HouseID = houseID
		if posX and posY and posZ then
			self.m_Entrances[Id].OutPos = Vector3(posX, posY, posZ)
			self.m_Entrances[Id].HouseID = false
		end
		self.m_Entrances[Id].UpdateEntrance = updateEntrance
		self.m_Entrances[Id].m_Closed = true
		self:seperateLinkedKeypads( self.m_Entrances[Id], linkedKeyPadList)
		self.m_Entrances[Id]:setData("clickable", true, true)
		self.m_BindKeyClick = bind(self.onEntranceClick, self)
		addEventHandler("onElementClicked", self.m_Entrances[Id], self.m_BindKeyClick)
		return self.m_Entrances[Id]
	else 
		return nil 
	end
end

function ItemEntrance:seperateLinkedKeypads( entrance, keypadString ) 
	local count = 1
	local sepString
	local list = {}
	if #keypadString > 1 then
		while gettok(keypadString, count, "+") do 
			sepString = gettok(keypadString, count, "+") 
			if tonumber(sepString) then 
				if not self.m_KeyPadLinks[tonumber(sepString)] then self.m_KeyPadLinks[tonumber(sepString)] = {} end 
				table.insert(list, tonumber(sepString))
				table.insert(self.m_KeyPadLinks[tonumber(sepString)], entrance)
			end
			count = count + 1
		end
	end
	entrance.LinkedKeyPad = list
end

function ItemEntrance:rebuildLinkedKeypads( keypadList ) 
	local keypadId
	local listString = ""
	for i = 1, #keypadList do 
		keypadId = keypadList[i]
		listString = listString.."+"..keypadId
	end
	return listString
end

function ItemEntrance:removeKeyPadLink( id, keyPadId) 
	if id and keyPadId then 
		if not self.m_KeyPadLinks[keyPadId] then 
			self.m_KeyPadLinks[keyPadId] = {} 
			return true 
		end
		if type(keyPadId) == "number" then
			for i = 1, #self.m_KeyPadLinks[keyPadId] do
				if self.m_KeyPadLinks[keyPadId][i] == self.m_Entrances[id] then 
					return table.remove(self.m_KeyPadLinks[keyPadId], i)
				end
			end
		end
	end
	return false
end

function ItemEntrance:addKeyPadLink( id, keyPadId) 
	if id and keyPadId then 
		if not self.m_KeyPadLinks[keyPadId] then 
			self.m_KeyPadLinks[keyPadId] = {}
			return table.insert( self.m_KeyPadLinks[keyPadId], self.m_Entrances[id])
		end
		if type(keyPadId) == "number" then
			for i = 1, #self.m_KeyPadLinks[keyPadId] do
				if self.m_KeyPadLinks[keyPadId][i] == self.m_Entrances[id] then 
					return
				end
			end
		end
		return table.insert( self.m_KeyPadLinks[keyPadId], self.m_Entrances[id])
	end
	return false
end

function ItemEntrance:addLinkKey( id, keyPadId) 
	if id and keyPadId then 
		if type(keyPadId) == "number" and self.m_Entrances[id] then
			for i = 1, #self.m_Entrances[id].LinkedKeyPad do
				if self.m_Entrances[id].LinkedKeyPad[i] == keyPadId then 
					return
				end
			end
		end
	end
	return table.insert( self.m_Entrances[id].LinkedKeyPad, keyPadId)
end


function ItemEntrance:removeLinkKey( id, keyPadId) 
	if id and keyPadId then 
		if type(keyPadId) == "number" and self.m_Entrances[id] then
			for i = 1, #self.m_Entrances[id].LinkedKeyPad do
				if self.m_Entrances[id].LinkedKeyPad[i] == keyPadId then 
					return table.remove(self.m_Entrances[id].LinkedKeyPad, i)
				end
			end
		end
	end
	return false
end



function ItemEntrance:Event_onKeyPadSignal( ) 
	local keypad = source
	if keypad and isElement(keypad) and keypad.Id then
		if self.m_KeyPadLinks[keypad.Id] then 
			local x,y,z = getElementPosition(keypad)
			local dx, dy, dz
			for id, obj in ipairs(self.m_KeyPadLinks[keypad.Id] ) do 
				dx, dy, dz = getElementPosition(obj) 
				if getDistanceBetweenPoints3D(dx, dy, dz, x, y, z) <= 30 then 
					self:changeLock( obj )
				end
			end
		end
	end
end

function ItemEntrance:changeLock( entrance ) 
	entrance.m_Closed = not entrance.m_Closed 
	triggerClientEvent("itemEntrancePlayLock", entrance, entrance.m_Closed)
end
function ItemEntrance:Event_onConfirmEntranceDelete( id ) 
	if source.m_EntranceQuestionDeleteId then 
		self:removeObject( source.m_EntranceQuestionDeleteId )
		source:sendSuccess(_("Der Eingang mit der ID %s wurde gelöscht!", source, id))
	end
end

function ItemEntrance:Event_onEntranceConfirm( id ) 
	if source.m_EntranceQuestionId then 
		if self.m_Entrances[id] and isElement(self.m_Entrances[id]) then 
			if not self.m_Entrances[id].m_Closed then 
				self:enter( source, id )
			else 
				source:sendError(_("Der Eingang ist verschlossen!", source))
			end
		end
	end
	source.m_EntranceQuestionVisible = false
end

function ItemEntrance:Event_onEntranceCancel( id ) 
	source.m_EntranceQuestionVisible = false
end

function ItemEntrance:enter( player, id ) 
	if self.m_Entrances[id].HouseID then 
		if HOUSE_INTERIOR_TABLE[self.m_Entrances[id].HouseID] then
			local int, x, y, z = unpack(HOUSE_INTERIOR_TABLE[self.m_Entrances[id].HouseID])
			local _, _, rz = getElementRotation( player )
			self:teleportPlayer(player, Vector3(x, y, z), rz, int, 0)
			triggerClientEvent("itemEntrancePlayEnter", self.m_Entrances[id])
		end
	else 
		if self.m_Entrances[id].OutPos then 
			local _, _, rz = getElementRotation( player )
			self:teleportPlayer(player, self.m_Entrances[id].OutPos, rz,  0, 0)
			triggerClientEvent("itemEntrancePlayEnter", self.m_Entrances[id])
		end
	end
end

function ItemEntrance:teleportPlayer( player, pos, rotation, interior, dimension) 
	fadeCamera(player,false,1,0,0,0)
	setElementFrozen(player, true)
	setTimer(
		function()
			setElementInterior(player,interior, pos)
			player:setRotation(0, 0, rotation)
			player:setPosition(pos)
			setElementDimension(player,dimension)
			player:setCameraTarget(player)
			fadeCamera(player, true)
			setTimer(function() 
				setElementFrozen( player, false)
			end, 1000, 1)
		end, 1500, 1
	)

	triggerEvent("onElementInteriorChange", player, interior)
	triggerEvent("onElementDimensionChange", player, dimension)
end

function ItemEntrance:Event_onEntranceDataChange( padId, removePadId, houseId, posX, posY, posZ) 
	if client then 
		if client.m_LastEntranceId then 
			if self.m_Entrances[client.m_LastEntranceId] then 
				local entrance = self.m_Entrances[client.m_LastEntranceId]
				if isElement(entrance) then 
					if padId and tonumber(padId) then
						self:addKeyPadLink(entrance.Id, tonumber(padId))
						self:addLinkKey(entrance.Id, tonumber(padId))
					end
					if removePadId and tonumber(removePadId) then 
						self:removeKeyPadLink(entrance.Id, tonumber(removePadId))
						self:removeLinkKey(entrance.Id, tonumber(removePadId))
					end
					if tonumber(posX) and tonumber(posY) and tonumber(posZ) then 
						entrance.OutPos = Vector3(tonumber(posX), tonumber(posY), tonumber(posZ))
						entrance.HouseID = false
					end
					if tonumber(houseId) then 
						entrance.HouseID = tonumber(houseId)
					end
					entrance.UpdateEntrance = true
					client:sendSuccess(_("Der Eingang wurde aktualisiert!", client))
				end
			end
		end
	end
end


function ItemEntrance:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	local model = tonumber(gettok(value, 2, ":")) or self.m_Model
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		local valueString = (value or "#:"..self.m_Model)
		player:getInventory():removeItem(self:getName(), 1)
		player:sendInfo(_("%s hinzugefügt!", player, "Eingang Modell ("..model..")"))
		local dim = getElementDimension(player) 
		local int = getElementInterior(player)
		--FactionState:getSingleton():sendShortMessage(_("%s hat ein Keypad bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Eingang", position.x..","..position.y..","..position.z)
		sql:queryExec("INSERT INTO ??_word_objects(Typ, PosX, PosY, PosZ, RotationZ, Interior, Dimension,  Value, ZoneName, Admin, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), "Eingang", position.x, position.y, position.z, rotation, int, dim, valueString , getZoneName(position).."/"..getZoneName(position, true), player:getId())
		if not self:addObject(sql:lastInsertId(), position, Vector3(0,0,rotation), int, dim, valueString ) then 
			sql:queryExec("DELETE FROM ??_word_objects WHERE Id=?", sql:getPrefix(), sql:lastInsertId())	
		end
	end, false, model)
end

function ItemEntrance:onEntranceClick(button, state, player)
    if source.Type ~= "Eingang" then return end
	if button == "left" and state == "up" then
		if player.m_SupMode then
			player.m_LastEntranceId = source.Id
			local pos = {getElementPosition(source)}
			player:triggerEvent("promptEntranceOption", source.LinkedKeyPad, pos)
			player:sendShortMessage(_("Beachte X-,Y- und Z-Position nur angeben wenn im Interior ein Eingang nach draußen platziert wird!", player))
		else 
			if not player.m_EntranceQuestionVisible then
				player.m_EntranceQuestionVisible = true
				player.m_EntranceQuestionId = source.Id
				QuestionBox:new(player, player, _("Eintreten?", player), "confirmEntranceEnter", "cancelEntranceEnter", source.Id)
			end
		end
	elseif button == "right" and state == "up" then 
		if player.m_SupMode then 
			player.m_EntranceQuestionDeleteId = source.Id
			QuestionBox:new(player, player, _("Möchtest du diesen Eingang (#"..source.Id.." Modell: "..getElementModel(source)..") löschen?", player), "confirmEntranceDelete", nil, source.Id)
		end
    end
end

function ItemEntrance:removeObject( id ) 
	if id then 
		if self.m_Entrances[id] then 
			destroyElement(self.m_Entrances[id])
			self.m_Entrances[id] = nil
			sql:queryExec("DELETE FROM ??_word_objects WHERE Id=?", sql:getPrefix(), id)
		end
	end
end


function ItemEntrance:destructor()
	local rebuildKeyListString = ""
	for id , obj in pairs(self.m_Entrances) do 
		if obj.UpdateEntrance then 
			rebuildKeyListString = self:rebuildLinkedKeypads( obj.LinkedKeyPad ) 
			local houseId = obj.HouseID or "#"
			local x,y,z 
			if obj.OutPos then 
				x = obj.OutPos.x or "#"
				y = obj.OutPos.y or "#"
				z = obj.OutPos.z or "#"
			else 
				x = "#"
				y = "#" 
				z = "#"
			end
			sql:queryExec("UPDATE ??_word_objects SET value=? WHERE Id=?;", sql:getPrefix(), rebuildKeyListString..":"..getElementModel(obj)..":"..houseId..":"..x..":"..y..":"..z, obj.Id )
		end
	end
end


function ItemEntrance:Event_onNearbyCommand( source, cmd) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Eingänge in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	local house = ""
	for id , obj in pairs(self.m_Entrances) do 
		count = count + 1
		objectPosition = obj:getPosition()
		dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
		if dist <= 10 then  
			if obj.HouseID then 
				house = obj.HouseID 
			else 
				house = "Keins"
			end
			outputChatBox(" #ID "..obj.Id.." Model: "..getElementModel(obj).." Haus-ID: "..house.." Distanz: "..dist , source, 244, 182, 66)
		end
	end
	if count == 0 then outputChatBox(" Keine in der Nähe",  source, 244, 182, 66) end
end

function ItemEntrance:Event_onDeleteCommand( source, cmd, id) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = self.m_Entrances[tonumber(id)] 
		if obj then 
			local objPos = obj:getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				source:sendInfo(_("Der Eingang mit der ID %s wurde gelöscht!", source, id))
			end
		end
	end
end
