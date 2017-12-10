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
		if obj.UpdatePin then 
			sql:queryExec("UPDATE ??_word_objects SET value=? WHERE Id=?;", sql:getPrefix(), obj.Pin, obj.Id )
		end
	end
end


function ItemKeyPad:addObject(Id, pos, rot, value)
	local pin, updatePin
	if not value or tostring(value) == "####" then 
		pin = "####"
		updatePin = true
	else 
		pin = tostring(value)
		updatePin = false
	end
	self.m_Keypads[Id] = createObject(self.m_Model, pos)
	setElementDoubleSided(self.m_Keypads[Id], true)
	self.m_Keypads[Id]:setRotation( rot ) 
	self.m_Keypads[Id].Id = Id
	self.m_Keypads[Id].Type = "Keypad"
	self.m_Keypads[Id].UpdatePin = updatePin
	self.m_Keypads[Id].Pin = pin
    self.m_Keypads[Id]:setData("clickable", true, true)
	self.m_BindKeyClick = bind(self.onKeyPadClick, self)
    addEventHandler("onElementClicked",self.m_Keypads[Id], self.m_BindKeyClick)
	return self.m_Keypads[Id]
end

function ItemKeyPad:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventory():removeItem(self:getName(), 1)
		player:sendInfo(_("%s hinzugefügt!", player, "Keypad"))
		--FactionState:getSingleton():sendShortMessage(_("%s hat ein Keypad bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Keypad", position.x..","..position.y..","..position.z)
		sql:queryExec("INSERT INTO ??_word_objects(Typ, PosX, PosY, PosZ, RotationZ, Value, ZoneName, Admin, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), "Keypad", position.x, position.y, position.z, rotation, "####", getZoneName(position).."/"..getZoneName(position, true), player:getId())
		self:addObject(sql:lastInsertId(), position, Vector3(0,0,rotation))
	end)
end

function ItemKeyPad:onKeyPadClick(button, state, player)
    if source.Type ~= "Keypad" then return end
	if button == "left" and state == "up" then
        if source:getModel() == self.m_Model then
			player.m_LastKeyPadID = source.Id
			player:triggerEvent("promptKeyPad", source.Id)
			triggerClientEvent(root, "playKeyPadSound", root, source, "keypad_access")
        end
	elseif button == "right" and state == "up" then 
		if player.m_SupMode then 
			player.m_KeypadQuestionDeleteId = source.Id
			QuestionBox:new(player, player, _("Möchtest du diesen Keypad (# "..source.Id..") löschen?", player), "confirmKeypadDelete", nil, source.Id)
		end
    end
end

function ItemKeyPad:Event_onAskForAccess( pin ) 
	if client then 
		if self.m_Keypads[client.m_LastKeyPadID] then 
			local cKeyPad = self.m_Keypads[client.m_LastKeyPadID]
			local pinNotSet = cKeyPad.Pin:find("#")
			if pinNotSet then 
				cKeyPad.Pin = pin
				outputChatBox("Du hast den Pin des Keypads eingestellt: "..pin, client, 0, 200, 0)
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

function ItemKeyPad:Event_onConfirmKeyPadDelete( id ) 
	if source.m_KeypadQuestionDeleteId then 
		self:removeObject( source.m_KeypadQuestionDeleteId )
		outputChatBox("Der Keypad mit der ID "..id.." wurde gelöscht!", source, 0, 200, 0)
	end
end

function ItemKeyPad:Event_onNearbyCommand( source, cmd) 
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Keypads in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	for id , obj in pairs(self.m_Keypads) do 
		count = count + 1
		objectPosition = obj:getPosition()
		dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
		if dist <= 10 then  
			outputChatBox(" #ID "..obj.Id.." PIN: "..obj.Pin.." Distanz: "..dist , source, 244, 182, 66)
		end
	end
	if count == 0 then outputChatBox(" Keine in der Nähe",  source, 244, 182, 66) end
end

function ItemKeyPad:Event_onDeleteCommand( source, cmd, id) 
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = self.m_Keypads[tonumber(id)] 
		if obj then 
			local objPos = obj:getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				outputChatBox("Der Keypad mit der ID "..id.." wurde gelöscht!", source, 0, 200, 0)
			end
		end
	end
end


function ItemKeyPad:sendSignal( object ) 
	if object then
		triggerEvent("onKeyPadSignal", object)
	end
end

function ItemKeyPad:removeObject( id ) 
	if id then 
		if self.m_Keypads[id] then 
			destroyElement(self.m_Keypads[id])
			self.m_Keypads[id] = nil
			sql:queryExec("DELETE FROM ??_word_objects WHERE Id=?", sql:getPrefix(), id)
		end
	end
end

