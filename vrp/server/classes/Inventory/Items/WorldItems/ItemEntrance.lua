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
	self.m_ColShapeBind = bind(self.Event_onColShapeHit, self)
	self.m_ColShapeBind2 = bind(self.Event_onColShapeLeave, self)
	self.m_Model = 2986
	self.m_Entrances = {}
	self.m_Timers = {}
	self.m_KeyPadLinks = {}
end



function ItemEntrance:addWorldObjectCallback(Id, worldObject)
	local linkedKeyPadList, houseID, model, posX, posY, posZ, title, desc
	local updateEntrance = false
	local object, pos, int, dim
	local value = worldObject:getValue()
	if not value or tostring(value) == "" then 
		linkedKeyPadList, houseID, model, posX, posY, posZ, title, desc, linkToEntrance = "#", self.m_Model, false, false, false, "", "", false
		updateEntrance = true
	else 
		linkedKeyPadList, model, houseID, posX, posY, posZ = gettok(value, 1, ":") or "#", tonumber(gettok(value, 2, ":")), tonumber(gettok(value, 3, ":")) or "#", tonumber(gettok(value, 4, ":")), tonumber(gettok(value, 5, ":")), tonumber(gettok(value, 6, ":")) 
		linkedToEntrance, title, desc = tonumber(gettok( value, 7, ":")), gettok(value, 8, ":"), gettok(value, 9, ":")
	end
	worldObject:setModel(model)
	worldObject:setAnonymous(true)
	worldObject:setAccessRange(10)
	worldObject:setAccessIntDimCheck(true) 
	self.m_Entrances[Id] = worldObject
	if self.m_Entrances[Id] and houseID then
		object = worldObject:getObject()
		pos, int, dim = object:getPosition(), object:getInterior(), object:getDimension()
		object:setDoubleSided(true)
		object.m_ColShape = createColSphere(pos.x, pos.y, pos.z, 3)
		object.m_ColShape.m_EntranceID = Id
		object.m_ColShape:setInterior(int)
		object.m_ColShape:setDimension(dim)
		object.m_ColShape.m_EntranceObject = object
		addEventHandler("onColShapeHit", object.m_ColShape, self.m_ColShapeBind)
		addEventHandler("onColShapeLeave", object.m_ColShape, self.m_ColShapeBind2)
		object.Id = Id
		object.Type = "Eingang"
		object.HouseID = houseID
		object.Title = title 
		object.Description = desc
		if posX and posY and posZ then
			object.OutPos = Vector3(posX, posY, posZ)
			object.HouseID = false
			if linkedToEntrance then object.LinkToEntrance = linkedToEntrance end
		end
		object.UpdateEntrance = updateEntrance
		object.m_Closed = true
		self:seperateLinkedKeypads( self.m_Entrances[Id], linkedKeyPadList)
		object:setData("clickable", true, true)
		self.m_BindKeyClick = bind(self.onEntranceClick, self)
		addEventHandler("onElementClicked", object, self.m_BindKeyClick)
		return true
	else 
		return false 
	end
end

function ItemEntrance:Event_onColShapeHit(hE, bDim)
	if bDim then 
		if hE and isElement(hE) and getElementType(hE) == "player" then 
			hE:setPrivateSync("EntranceId", source.m_EntranceID)
			hE:setPrivateSync("EntranceObject", source.m_EntranceObject)
			triggerLatentClientEvent(hE, "drawEntranceTitleDesc", 50000, false, root, true, source.m_EntranceObject.Title, source.m_EntranceObject.Description)
		end
	end
end

function ItemEntrance:Event_onColShapeLeave( hE, bDim) 
	if bDim then
		if hE and isElement(hE) and getElementType(hE) == "player" then 
			triggerLatentClientEvent(hE, "drawEntranceTitleDesc", 50000, false, root, false)
			hE:setPrivateSync("EntranceId", false)
			hE:setPrivateSync("EntranceObject", false)
		end
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
				sepString = tonumber(sepString)
				if not self.m_KeyPadLinks[sepString] then self.m_KeyPadLinks[sepString] = {} end 
				table.insert(list, sepString)
				table.insert(self.m_KeyPadLinks[sepString], entrance)
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
			local keyPadPosition = keypad:getPosition()
			local pos
			for id, obj in ipairs(self.m_KeyPadLinks[keypad.Id] ) do 
				if obj and obj.getObject and isElement(obj:getObject()) then
					pos = obj:getObject():getPosition() 
					if getDistanceBetweenPoints3D(pos.x, pos.y, pos.z, keyPadPosition.x, keyPadPosition.y, keyPadPosition.z) <= 30 then 
						self:changeLock( obj:getObject() )
					end
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
		if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
		self:removeObject( source.m_EntranceQuestionDeleteId )
		source:sendSuccess(_("Der Eingang mit der ID %s wurde gelöscht!", source, id))
	end
end

function ItemEntrance:Event_onEntranceConfirm( id ) 
	local obj = self.m_Entrances[id]
	if obj and obj.getObject and isElement(obj:getObject()) and not getPedOccupiedVehicle(client) then
		if client.m_EntranceQuestionId or isElementWithinColShape(client, obj:getObject().m_ColShape) then 
			if not obj:getObject().m_Closed then 
				self:enter( source, id )
			else 
				client:sendError(_("Der Eingang ist verschlossen!", client))
			end
		end
	end
end

function ItemEntrance:Event_onEntranceCancel( id ) 
end

function ItemEntrance:enter( player, id ) 
	if self.m_Entrances[id] and self.m_Entrances[id].getObject and isElement(self.m_Entrances[id]:getObject()) then
		local object = self.m_Entrances[id]:getObject()
		local pDim, pInt = player:getDimension(), player:getInterior()
		local eDim, eInt = object:getDimension(), object:getInterior()
		if pDim == eDim and pInt == eInt then 
			if object.HouseID then 
				if HOUSE_INTERIOR_TABLE[object.HouseID] then
					local int, x, y, z = unpack(HOUSE_INTERIOR_TABLE[object.HouseID])
					local _, _, rz = getElementRotation( player )
					self:teleportPlayer(player, Vector3(x, y, z), rz, int, id)
					triggerClientEvent("itemEntrancePlayEnter", object)
				end
			else 
				if object.OutPos then 
					local _, _, rz = getElementRotation( player )
					local int, dim = 0, 0
					if object.LinkToEntrance then 
						if self.m_Entrances[object.LinkToEntrance] and isElement(self.m_Entrances[object.LinkToEntrance]:getObject()) then
							int, dim = self.m_Entrances[object.LinkToEntrance]:getObject():getInterior(), self.m_Entrances[object.LinkToEntrance]:getObject():getDimension()
						end
					end
					self:teleportPlayer(player, object.OutPos, rz,  int, dim)
					triggerClientEvent("itemEntrancePlayEnter", object)
				end
			end
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
			setElementDimension(player, dimension)
			player:setCameraTarget(player)
			fadeCamera(player, true)
			setTimer(function() 
				setElementFrozen( player, false)
			end, 1000, 1)
		end, 1500, 1
	)

end

function ItemEntrance:Event_onEntranceDataChange( padId, removePadId, houseId, posX, posY, posZ, entranceLink, title, desc) 
	if client then 
		if client.m_LastEntranceId then 
			if self.m_Entrances[client.m_LastEntranceId] then 
				local entrance = self.m_Entrances[client.m_LastEntranceId]
				if entrance and entrance.getObject and isElement(entrance:getObject()) then 
					entrance = entrance:getObject()
					if padId and tonumber(padId) then
						padId = tonumber(padId)
						self:addKeyPadLink(entrance.Id, padId)
						self:addLinkKey(entrance.Id, padId)
					end
					if removePadId and tonumber(removePadId) then 
						removePadId = tonumber(removePadId)
						self:removeKeyPadLink(entrance.Id, removePadId)
						self:removeLinkKey(entrance.Id, removePadId)
					end
					if tonumber(posX) and tonumber(posY) and tonumber(posZ) then 
						entrance.OutPos = Vector3(tonumber(posX), tonumber(posY), tonumber(posZ))
						entrance.HouseID = false
						if tonumber(entranceLink) then 
							entrance.LinkToEntrance = tonumber(entranceLink)
						end
					end
					if tonumber(houseId) then 
						entrance.HouseID = tonumber(houseId)
					end
					if title then 
						entrance.Title = title
					end
					if desc then 
						entrance.Description = desc
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
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Eingang", position.x..","..position.y..","..position.z)
		local worldObject = PlayerWorldItem:new(ItemManager:getSingleton():getInstance("Eingang"), player:getId(), position, rotation, false, player:getId(), true, false, valueString)
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

function ItemEntrance:onEntranceClick(button, state, player)
    if source.Type ~= "Eingang" then return end
	if button == "right" and state == "up" then
		if player.m_SupMode then
			player.m_LastEntranceId = source.Id
			local pos = {getElementPosition(source)}
			player:triggerEvent("promptEntranceOption", source.LinkedKeyPad, pos)
		end
	end
end

function ItemEntrance:removeObject( id ) 
	if id then 
		if self.m_Entrances[id] then 
			self.m_Entrances[id]:forceDelete()
			self.m_Entrances[id] = nil
		end
	end
end

function ItemEntrance:destructor()
	local rebuildKeyListString = ""
	for id , obj in pairs(self.m_Entrances) do 
		if obj and obj.getObject and isElement(obj:getObject()) and obj:getObject().UpdateEntrance then 
			rebuildKeyListString = self:rebuildLinkedKeypads( obj.LinkedKeyPad ) 
			local houseId = obj:getObject().HouseID or "#"
			local x,y,z, linkToEntrance
			local title = obj:getObject().Title or ""
			local desc = obj:getObject().Description or ""
			if obj:getObject().OutPos then 
				x, y, z, linkToEntrance = obj:getObject().OutPos.x or "#", obj:getObject().OutPos.y or "#", obj:getObject().OutPos.z or "#", obj:getObject().LinkToEntrance or "#"
			else 
				x, y, z, linkToEntrance = "#", "#", "#", "#"
			end
			obj:setValue(rebuildKeyListString..":"..obj:getModel()..":"..houseId..":"..x..":"..y..":"..z..":"..linkToEntrance..":"..title..":"..desc, obj:getObject().Id)
			obj:onChanged()
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
		objectPosition = obj:getObject():getPosition()
		dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
		if dist <= 10 then  
			if obj.HouseID then 
				house = obj:getObject().HouseID 
			else 
				house = "Keins"
			end
			outputChatBox(" #ID "..obj:getObject().Id.." Model: "..obj:getObject():getModel().." Haus-ID: "..house.." Distanz: "..dist , source, 244, 182, 66)
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
		if obj and obj.getObject and isElement(obj:getObject()) then 
			local objPos = obj:getObject():getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				source:sendInfo(_("Der Eingang mit der ID %s wurde gelöscht!", source, id))
			end
		end
	end
end
