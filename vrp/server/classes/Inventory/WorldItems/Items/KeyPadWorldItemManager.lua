-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/KeyPadWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
KeyPadWorldItemManager = inherit(Singleton)
addRemoteEvents{"confirmKeypadDelete", "onKeyPadSubmit"}

function KeyPadWorldItemManager:constructor()
	addCommandHandler("nearbykeypads", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("delkeypad", bind(self.Event_onDeleteCommand, self))
	addEventHandler("confirmKeypadDelete", root, bind(self.Event_onConfirmKeyPadDelete, self))
	addEventHandler("onKeyPadSubmit", root, bind(self.Event_onAskForAccess, self))
end

function KeyPadWorldItemManager:Event_onAskForAccess(pin)
	if client then
		if KeyPadWorldItem.Map[client.m_LastKeyPadID] then
			local object = KeyPadWorldItem.Map[client.m_LastKeyPadID]
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

function KeyPadWorldItemManager:Event_onConfirmKeyPadDelete(id)
	if source.m_KeypadQuestionDeleteId then
		if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
		self:removeObject( source.m_KeypadQuestionDeleteId )
		source:sendInfo(_("Der Keypad mit der ID %s wurde gelöscht!", source, id))
	end
end

function KeyPadWorldItemManager:sendSignal(object)
	if object then
		triggerEvent("onKeyPadSignal", object)
	end
end

function KeyPadWorldItemManager:removeObject(id)
	if id then
		if KeyPadWorldItem.Map[id] and KeyPadWorldItem.Map[id].getObject and isElement(KeyPadWorldItem.Map[id]:getObject()) then
			KeyPadWorldItem.Map[id]:forceDelete()
			KeyPadWorldItem.Map[id] = nil
		end
	end
end

function KeyPadWorldItemManager:Event_onNearbyCommand(source, cmd)
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Keypads in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	for id, obj in pairs(KeyPadWorldItem.Map) do
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

function KeyPadWorldItemManager:Event_onDeleteCommand(source, cmd, id)
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = KeyPadWorldItem.Map[tonumber(id)]
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

