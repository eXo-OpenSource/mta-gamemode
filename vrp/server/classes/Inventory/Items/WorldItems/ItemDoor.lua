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
	self.m_Model = 2886
	self.m_Doors = {}
end


function ItemDoor:addObject(Id, pos, rot, value)
	local linkKeyPadID, model, updateDoor
	if not value or tostring(value) == "#" then 
		linkKeyPadID = "#"
		model = gettok(value, 2, ":")
		updateKeyPad = true
	else 
		linkKeyPadID = gettok(value, 1, ":")
		model = gettok(value, 2, ":")
		updateDoor = false
	end
	self.m_Doors[Id] = createObject(model or self.m_Model, pos)
	if self.m_Doors[Id] then
		setElementDoubleSided(self.m_Doors[Id], true)
		self.m_Doors[Id]:setRotation( rot ) 
		self.m_Doors[Id].Id = Id
		self.m_Doors[Id].Type = "Door"
		self.m_Doors[Id].UpdatePin = updatePin
		self.m_Doors[Id].Pin = pin
		self.m_Doors[Id]:setData("clickable", true, true)
		self.m_BindKeyClick = bind(self.onKeyPadClick, self)
		addEventHandler("onElementClicked",self.m_Doors[Id], self.m_BindKeyClick)
		return self.m_Doors[Id]
	else 
		return nil 
	end
end


function ItemDoor:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local value = inventory:getItemValueByBag( bag, place)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventory():removeItem(self:getName(), 1)
		self:addObject(sql:lastInsertId(), position, Vector3(0,0,rotation), "#:"..(value or self.m_Model))
		player:sendInfo(_("%s hinzugefügt!", player, "Tor Modell ("..(value or self.m_Model)..")"))
		--FactionState:getSingleton():sendShortMessage(_("%s hat ein Keypad bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Keypad", position.x..","..position.y..","..position.z)
		sql:queryExec("INSERT INTO ??_word_objects(Typ, PosX, PosY, PosZ, RotationZ, Value, ZoneName, Admin, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), "Tor", position.x, position.y, position.z, rotation, "#:"..(value or self.m_Model) , getZoneName(position).."/"..getZoneName(position, true), player:getId())
	end)
end

function ItemDoor:onDoorClick(button, state, player)
    if source.Type ~= "Door" then return end
	if button == "left" and state == "up" then
        if source:getModel() == self.m_Model then
			player.m_LastDoorId = source.Id
			player:triggerEvent("promptDoorOption", source.Id)
        end
	elseif button == "right" and state == "up" then 
		if player.m_SupMode then 
			player.m_KeypadQuestionDeleteId = source.Id
			QuestionBox:new(player, player, _("Möchtest du dieses Tor (# "..source.Id..") löschen?", player), "confirmKeypadDelete", nil, source.Id)
		end
    end
end

function ItemDoor:destructor()
	for id , obj in pairs(self.m_Doors) do 
		if obj.UpdateLink then 
			sql:queryExec("UPDATE ??_word_objects SET value=? WHERE Id=?;", sql:getPrefix(), obj.LinkKeyPadID, obj.Id )
		end
	end
end
