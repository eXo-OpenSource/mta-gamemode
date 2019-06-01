-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFurniture.lua
-- *  PURPOSE:     Furniture item class
-- *
-- ****************************************************************************
ItemFurniture = inherit(Item)
ItemFurniture.Map = {}


function ItemFurniture:constructor()
	self.m_Model = 2912
	self.m_Furniture = {}
	addCommandHandler("nearbykeypads", bind(self.Event_onNearbyCommand, self))
	addCommandHandler("delkeypad", bind(self.Event_onDeleteCommand, self))
end

function ItemFurniture:addWorldObjectCallback(id, object) 
	self.m_Furniture[id] = object
	local value = object:getValue()
	object:setModel(tonumber(value) or self.m_Model)
end

function ItemFurniture:destructor()

end

function ItemFurniture:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventoryOld()
	local value = InventoryOld:getItemValueByBag( bag, place)
	local model = tonumber(value) or self.m_Model
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventoryOld():removeItem(self:getName(), 1)
		player:sendInfo(_("%s hinzugefügt!", player, "Einrichtung"))
		local int = player:getInterior() 
		local dim = player:getDimension()
		StatisticsLogger:getSingleton():itemPlaceLogs( player, "Einrichtung", position.x..","..position.y..","..position.z)
		local worldObject = PlayerWorldItem:new(ItemManager:getSingleton():getInstance("Einrichtung"), player:getId(), position, rotation, false, player:getId(), true, false, value)
		worldObject:setInterior(int) 
		worldObject:setDimension(dim)
		local id = worldObject:forceSave() 
		if id then 
			if not self:addWorldObjectCallback(id, worldObject) then
				player:sendInfo(_("Ein Fehler trat auf beim Platzieren!", player))
			end
		end
	end, false, model)
end

function ItemFurniture:Event_onNearbyCommand( source, cmd) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	outputChatBox("** Möbel in deiner Nähe **", source, 244, 182, 66)
	local count = 0
	for id, obj in pairs(self.m_Keypads) do 
		if obj and obj.getObject and isElement(obj:getObject()) then
			count = count + 1
			objectPosition = obj:getObject():getPosition()
			dist = getDistanceBetweenPoints2D(objectPosition.x, objectPosition.y, position.x, position.y)
			if dist <= 10 then  
				outputChatBox(" #ID "..obj:getObject().Id.." Modell: "..obj:getModel().." Distanz: "..dist , source, 244, 182, 66)
			end
		end
	end
	if count == 0 then outputChatBox(" Keine in der Nähe",  source, 244, 182, 66) end
end

function ItemFurniture:removeObject( id )
	if id then 
		if self.m_Furniture[id] and self.m_Furniture[id].getObject and isElement(self.m_Furniture[id]:getObject()) then 
			self.m_Furniture[id]:forceDelete()
		end
	end
end

function ItemFurniture:Event_onDeleteCommand( source, cmd, id) 
	if source:getRank() < ADMIN_RANK_PERMISSION["placeKeypadObjects"] then return end
	local position = source:getPosition()
	local objectPosition, dist
	if id and tonumber(id) then
		local obj = self.m_Furniture[tonumber(id)] 
		if obj and obj.getObject and isElement(obj:getObject()) then 
			obj = obj:getObject()
			local objPos = obj:getPosition() 
			local sourcePos = source:getPosition() 
			if getDistanceBetweenPoints2D(objPos.x, objPos.y, sourcePos.x, sourcePos.y) <= 10 then 
				self:removeObject( tonumber(id) ) 
				source:sendInfo(_("Das Möbelstück mit der ID %s wurde gelöscht!", source, id))
			end
		end
	end
end

