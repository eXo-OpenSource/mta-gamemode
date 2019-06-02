-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemKeyPad.lua
-- *  PURPOSE:     Key Pad item class
-- *
-- ****************************************************************************
ItemKeyPad = inherit(ItemNew)
ItemKeyPad.Map = {}


function ItemKeyPad:constructor()
	--[[
	self.m_Model = 2886
	self.m_Keypads = {}
	addCommandHandler("nearbykeypads", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("delkeypad", bind(self.Event_onDeleteCommand, self))
	addRemoteEvents{"confirmKeypadDelete", "onKeyPadSubmit"}
	addEventHandler("confirmKeypadDelete", root, bind(self.Event_onConfirmKeyPadDelete, self))
	addEventHandler("onKeyPadSubmit", root, bind(self.Event_onAskForAccess, self))
	]]
	self.m_WorldItemValue = "#####"
	self.m_WorldItemIsPermanent = true
	self.m_WorldItemLocked = false
end

function ItemKeyPad:destructor()
	--[[for id , obj in pairs(self.m_Keypads) do 
		if obj.getObject and isElement(obj:getObject()) and obj:getObject().UpdatePin then 
			obj:setValue(obj:getObject().Pin)
			obj:onChanged()
		end
	end]]
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

function ItemKeyPad:use()
	local player = self.m_Inventory:getPlayer()

	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end
	if player:getData("inJail") or player:getData("inAdminPrison") then
		player:sendError(_("Du kannst hier keine Objekte platzieren.", player)) 
		return false
	end

	-- Start the object placer on the client
	player:triggerEvent("objectPlacerStart", self.m_ItemData.ModelId, "itemPlaced")
	player.m_PlacingInfo = {
		itemData = self.m_ItemData, 
		inventory = self.m_Inventory, 
		item = self.m_Item,
		worldItemValue = self.m_WorldItemValue,
		worldItemIsPermanent = self.m_WorldItemIsPermanent,
		worldItemLocked = self.m_WorldItemLocked
	}

	--[[
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventory():takeItem(self.m_Item.m_InternalId, 1)
		player:sendInfo(_("%s hinzugefügt!", player, self.m_ItemData.Name))
		local int = player:getInterior() 
		local dim = player:getDimension()
		StatisticsLogger:getSingleton():itemPlaceLogs(player, self.m_ItemData.Name, position.x..","..position.y..","..position.z)
		PlayerWorldItem:new(self.m_ItemData, player:getId(), position, rotation, false, player:getId(), true, false, "#####", int, dim)
	end)]]
end

function ItemKeyPad:place(owner, pos, rotation, amount)
	local worldItem = WorldItem:new(self, owner, pos, rotation)
	return worldItem
end

function ItemKeyPad:startObjectPlacing(player, callback, hideObject, customModel)
	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end
	if player:getData("inJail") or player:getData("inAdminPrison") then
		player:sendError(_("Du kannst hier keine Objekte platzieren.", player)) 
		return false
	end

	-- Start the object placer on the client
	player:triggerEvent("objectPlacerStart", customModel or self.m_ItemData.ModelId, "itemPlaced", hideObject)
	player.m_PlacingInfo = {item = self, callback = callback}
	return true
end

--[[
	TODO: This should be in WorldItem or WorldItemManager
]]
addEvent("itemPlaced", true)
addEventHandler("itemPlaced", root,
	function(x, y, z, rotation, moved)
		local placingInfo = client.m_PlacingInfo
		if placingInfo then
			if x then
				
				if placingInfo.callback then
					client:sendShortMessage(_("%s %s.", client, placingInfo.item.m_Item.Name, moved and "verschoben" or "platziert"), nil, nil, 1000)
					placingInfo.callback(placingInfo.item, Vector3(x, y, z), rotation)
				else
					client:sendShortMessage(_("%s %s.", client, placingInfo.itemData.Name, moved and "verschoben" or "platziert"), nil, nil, 1000)
					client:getInventory():takeItem(placingInfo.item.InternalId, 1)
					client:sendInfo(_("%s hinzugefügt!", client, placingInfo.itemData.Name))
					local int = client:getInterior() 
					local dim = client:getDimension()
					StatisticsLogger:getSingleton():itemPlaceLogs(client, placingInfo.itemData.Name, x..","..y..","..z)
					PlayerWorldItem:new(placingInfo.itemData, client:getId(), Vector3(x, y, z), rotation, false, client:getId(), placingInfo.worldItemIsPermanent, placingInfo.worldItemLocked, placingInfo.worldItemValue, int, dim)
				end
			else
				client:sendShortMessage(_("Vorgang abgebrochen.", client), nil, nil, 1000)
				if placingInfo.callback then
					placingInfo.callback(placingInfo.item, false)
				end
			end
			client.m_PlacingInfo = nil
		end
	end
)

--[[
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

]]