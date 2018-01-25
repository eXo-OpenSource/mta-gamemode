-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemTransmitter.lua
-- *  PURPOSE:     Transmitter item class
-- *
-- ****************************************************************************
ItemTransmitter = inherit(Item)
ItemTransmitter.Map = {}


function ItemTransmitter:constructor()
	self.m_Model = 3031
	self.m_Transmitters = {}
	addRemoteEvents{"onTransmitterDataChange"}
	addEventHandler("onTransmitterDataChange", root, bind(self.Event_onTransmitterDataChange, self))
	addCommandHandler("nearbytransmitters", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("deltransmitters", bind(self.Event_onDeleteCommand, self))
end

function ItemTransmitter:destructor()
	for id , obj in pairs(self.m_Transmitters) do 
		if obj.m_UpdateFrequency then 
			local frequency, frequencyName
			frequency = obj.m_Frequency or "#"
			frequencyName = obj.m_FrequencyName or "#"
			sql:queryExec("UPDATE ??_word_objects SET value=? WHERE Id=?;", sql:getPrefix(), frequency..":"..frequencyName, obj.Id )
		end
	end
end


function ItemTransmitter:addObject(Id, pos, rot, int, dim, value)
	local frequency, frequencyName
	if not value or tostring(value) == "#" then 
		frequency = "#"  
		frequencyName = "#"
	else 
		frequency = tonumber(gettok(value, 1, ":")) or "#"
		frequencyName = tonumber(gettok(value, 2, ":")) or "#"
	end
	int = tostring(int) or 0 
	dim = tostring(dim) or 0
	self.m_Transmitters[Id] = createObject(self.m_Model, pos)
	setElementDimension(self.m_Transmitters[Id], dim)
	setElementInterior(self.m_Transmitters[Id], int)
	setElementDoubleSided(self.m_Transmitters[Id], true)
	setElementFrozen(self.m_Transmitters[Id], true)
	self.m_Transmitters[Id]:setRotation( rot ) 
	self.m_Transmitters[Id].Id = Id
	self.m_Transmitters[Id].Type = "Transmitter"
	self.m_Transmitters[Id].m_UpdateFrequency = false
	self.m_Transmitters[Id].m_Frequency = frequency
	self.m_Transmitters[Id].m_FrequencyName  = frequencyName
    self.m_Transmitters[Id]:setData("clickable", true, true)
	self.m_Transmitters[Id].m_ColShape = createColTube(pos.x, pos.y, pos.z-4, 20, 400)
	self.m_Transmitters[Id].m_ColShape.m_Transmitter = self.m_Transmitters[Id]
	addEventHandler("onColShapeHit", self.m_Transmitters[Id].m_ColShape, bind(self.Event_onColShapeHit, self))
	self.m_BindKeyClick = bind(self.onTransmitterClick, self)
    addEventHandler("onElementClicked",self.m_Transmitters[Id], self.m_BindKeyClick)
	return self.m_Transmitters[Id]
end

function ItemTransmitter:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventory():removeItem(self:getName(), 1)
		player:sendInfo(_("%s hinzugefügt!", player, "Transmitter"))
		local int = getElementInterior(player) 
		local dim = getElementDimension(player)
		--FactionState:getSingleton():sendShortMessage(_("%s hat ein Keypad bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Transmitter", position.x..","..position.y..","..position.z)
		sql:queryExec("INSERT INTO ??_word_objects(Typ, PosX, PosY, PosZ, RotationZ, Interior, Dimension, Value, ZoneName, Admin, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), "Transmitter", position.x, position.y, position.z, rotation, int, dim, "#:#", getZoneName(position).."/"..getZoneName(position, true), player:getId())
		self:addObject(sql:lastInsertId(), position, Vector3(0,0,rotation), int, dim)
	end)
end

function ItemTransmitter:onTransmitterClick(button, state, player)
    if source.Type ~= "Transmitter" then return end
	if button == "left" and state == "up" then
        if source:getModel() == self.m_Model then
			player.m_LastTransmitterID = source.Id
			player:triggerEvent("promptTransmitter", source.Id)
        end
	elseif button == "right" and state == "up" then 
		if player.m_SupMode then 
			player.m_TransmitterQuestionDeleteId = source.Id
			QuestionBox:new(player, player, _("Möchtest du diesen Transmitter (# "..source.Id..") löschen?", player), "confirmTransmitterDelete", nil, source.Id)
		end
    end
end


function ItemTransmitter:Event_onTransmitterDataChange( freqName, freqCode) 
	if client then 
		if client.m_LastTransmitterID then 
			if self.m_Transmitters[client.m_LastTransmitterID] then 
				local transmitter = self.m_Transmitters[client.m_LastTransmitterID]
				if isElement(transmitter) then 
					if tostring(freqName) and tostring(freqCode) then 
						transmitter.m_Frequency = freqCode
						transmitter.m_FrequencyName = freqName
						transmitter.m_UpdateFrequency = true
					end
					client:sendSuccess(_("Der Transmitter wurde aktualisiert!", client))
				end
			end
		end
	end
end

function ItemTransmitter:Event_onConfirmTransmitterDelete( id )
	if source.m_TransmitterQuestionDeleteId then 
		--if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end -- Terror fraktio n
		self:removeObject( source.m_TransmitterQuestionDeleteId )
		source:sendInfo(_("Der Transmitter mit der ID %s wurde gelöscht!", source, id))
	end
end

function ItemTransmitter:Event_onColShapeHit(hE, bMatch) 
	if bMatch then 
		if hE then 
			triggerEvent("onTransmitterHit", source.m_Transmitter, hE)
		end
	end
end

function ItemTransmitter:Event_onNearbyCommand( source, cmd) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Transmitters in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	for id , obj in pairs(self.m_Transmitters) do 
		count = count + 1
		objectPosition = obj:getPosition()
		dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
		if dist <= 10 then  
			outputChatBox(" #ID "..obj.Id.." PIN: "..obj.m_FrequencyName.." Distanz: "..dist , source, 244, 182, 66)
		end
	end
	if count == 0 then outputChatBox(" Keine in der Nähe",  source, 244, 182, 66) end
end

function ItemTransmitter:Event_onDeleteCommand( source, cmd, id) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = self.m_Transmitters[tonumber(id)] 
		if obj then 
			local objPos = obj:getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				source:sendInfo(_("Der Transmitter mit der ID %s wurde gelöscht!", source, id))
			end
		end
	end
end


function ItemTransmitter:removeObject( id ) 
	if id then 
		if self.m_Transmitters[id] then 
			destroyElement(self.m_Transmitters[id])
			self.m_Transmitters[id] = nil
			sql:queryExec("DELETE FROM ??_word_objects WHERE Id=? ", sql:getPrefix(), id)
		end
	end
end

