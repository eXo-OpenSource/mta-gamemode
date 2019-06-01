-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemKeyPad.lua
-- *  PURPOSE:     Key Pad item class
-- *
-- ****************************************************************************
ItemKeyPad = inherit(Item)
ItemKeyPad.Map = {}


function ItemKeyPad:constructor()
	self.m_Model = 2886
	self.m_Keypads = {}
	addCommandHandler("nearbykeypads", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("delkeypad", bind(self.Event_onDeleteCommand, self))
	addRemoteEvents{"confirmKeypadDelete", "onKeyPadSubmit"}
	addEventHandler("confirmKeypadDelete", root, bind(self.Event_onConfirmKeyPadDelete, self))
	addEventHandler("onKeyPadSubmit", root, bind(self.Event_onAskForAccess, self))
end

function ItemKeyPad:destructor()
	for id , obj in pairs(self.m_Keypads) do 
		if obj.getObject and isElement(obj:getObject()) and obj:getObject().UpdatePin then 
			obj:setValue(obj:getObject().Pin)
			obj:onChanged()
		end
	end
end

function ItemKeyPad:addWorldObjectCallback(Id, worldObject)
	local pin, updatePin, object
	local value = worldObject:getValue()
	if not value or value == "#####" then 
		pin, updatePin = "#####", true
	else 
		pin, updatePin = value, false
	end
	self.m_Keypads[Id] = worldObject
	worldObject:setAnonymous(true)
	worldObject:setAccessRange(10)
	worldObject:setAccessIntDimCheck(true) 
	if self.m_Keypads[Id] and self.m_Keypads[Id].getObject and isElement(self.m_Keypads[Id]:getObject()) then
		object = self.m_Keypads[Id]:getObject()
		object:setDoubleSided(true)
		object.Id = Id
		object.Type = "Keypad"
		object.UpdatePin = updatePin
		object.Pin = pin
		object:setData("clickable", true, true)
		self.m_BindKeyClick = bind(self.onKeyPadClick, self)
		addEventHandler("onElementClicked", object, self.m_BindKeyClick)
		return true
	end
	return false
end

function ItemKeyPad:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventoryOld():removeItem(self:getName(), 1)
		player:sendInfo(_("%s hinzugefügt!", player, "Keypad"))
		local int = player:getInterior() 
		local dim = player:getDimension()
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Keypad", position.x..","..position.y..","..position.z)
		local worldObject = PlayerWorldItem:new(ItemManager:getSingleton():getInstance("Keypad"), player:getId(), position, rotation, false, player:getId(), true, false, "#####")
		worldObject:setInterior(int) 
		worldObject:setDimension(dim)
		local id = worldObject:forceSave() 
		if id then 
			if not self:addWorldObjectCallback(id, worldObject) then
				player:sendInfo(_("Ein Fehler trat auf beim Platzieren!", player))
			end
		end
	end)
end

function ItemKeyPad:onKeyPadClick(button, state, player)
    if source.Type ~= "Keypad" then return end
	if button == "right" and state == "up" then
        if source:getModel() == self.m_Model then
			player.m_LastKeyPadID = source.Id
			player:triggerEvent("promptKeyPad", source.Id)
			triggerClientEvent(root, "playKeyPadSound", root, source, "keypad_access")
        end
	end
end

function ItemKeyPad:Event_onAskForAccess( pin ) 
	if client then 
		if self.m_Keypads[client.m_LastKeyPadID] then 
			local object = self.m_Keypads[client.m_LastKeyPadID]
			if object and object.getObject and isElement(object:getObject()) then
				local cKeyPad = object:getObject()
				local pinNotSet = cKeyPad.Pin:find("#")
				if pinNotSet then 
					cKeyPad.Pin = pin
					client:sendShortMessage(_("Du hast den Pin des Keypads eingestellt: %s", client, pin))
				else 
					if cKeyPad.Pin == pin then 
						client:sendInfo(_("Code akzeptiert!", client))
						triggerClientEvent(root, "playKeyPadSound", root, cKeyPad, "keypad_success")
						self:sendSignal( cKeyPad )
					else 
						client:sendError(_("Falscher Code!", client))
						triggerClientEvent(root, "playKeyPadSound", root, cKeyPad, "keypad_error")
					end
				end
			end
		end
	end
end

function ItemKeyPad:Event_onConfirmKeyPadDelete( id )
	if source.m_KeypadQuestionDeleteId then 
		if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
		self:removeObject( source.m_KeypadQuestionDeleteId )
		source:sendInfo(_("Der Keypad mit der ID %s wurde gelöscht!", source, id))
	end
end

function ItemKeyPad:sendSignal( object ) 
	if object then
		triggerEvent("onKeyPadSignal", object)
	end
end

function ItemKeyPad:removeObject( id ) 
	if id then 
		if self.m_Keypads[id] and self.m_Keypads[id].getObject and isElement(self.m_Keypads[id]:getObject()) then 
			self.m_Keypads[id]:forceDelete()
			self.m_Keypads[id] = nil
		end
	end
end

function ItemKeyPad:Event_onNearbyCommand( source, cmd) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Keypads in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	for id, obj in pairs(self.m_Keypads) do 
		if obj and obj.getObject and isElement(obj:getObject()) then
			count = count + 1
			objectPosition = obj:getObject():getPosition()
			dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
			if dist <= 10 then  
				outputChatBox(" #ID "..obj:getObject().Id.." PIN: "..obj:getObject().Pin.." Distanz: "..dist , source, 244, 182, 66)
			end
		end
	end
	if count == 0 then outputChatBox(" Keine in der Nähe",  source, 244, 182, 66) end
end

function ItemKeyPad:Event_onDeleteCommand( source, cmd, id) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = self.m_Keypads[tonumber(id)] 
		if obj and obj.getObject and isElement(obj:getObject()) then 
			obj = obj:getObject()
			local objPos = obj:getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				source:sendInfo(_("Der Keypad mit der ID %s wurde gelöscht!", source, id))
			end
		end
	end
end

