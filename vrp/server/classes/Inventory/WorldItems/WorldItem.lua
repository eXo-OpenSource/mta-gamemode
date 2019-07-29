-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/WorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
WorldItem = inherit(Object)
WorldItem.MapByOwner = {}
WorldItem.Map = {}
WorldItem.DirtyMap = {}
WorldItem.Action = {
	Move = "moveWorldItem",
	Collect = "collectWorldItem",
	Delete = "deleteWorldItem",
}
WorldItem.m_NextId = 1
addRemoteEvents{"worldItemMove", "worldItemCollect", "worldItemMassCollect", "worldItemDelete", "worldItemMassDelete", "requestWorldItemListOfOwner"}

WorldItem.constructor = pure_virtual
--[[
	itemData,
	placedBy,
	elementId,
	elementType,
	position,
	rotation,
	dimension,
	interior,
	isPermanent,
	value,
	metadata,
	breakable,
	locked,
	databaseId

	(item, owner, pos, rotation, breakable, player, isPermanent, locked, value, interior, dimension, databaseId)
	(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
]]
function WorldItem:virtual_constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
	self.m_Id = WorldItem.m_NextId
	WorldItem.m_NextId = WorldItem.m_NextId + 1
	WorldItem.Map[self.m_Id] = self
	self.m_Item = itemData
	self.m_ItemName = itemData.Name
	self.m_ModelId = itemData.ModelId

	self.m_ElementId = elementId
	self.m_ElementType = elementType
	self.m_PlacedBy = placedBy
	self.m_Placer = player

	self.m_Dimension = dimension
	self.m_Interior = interior

	if metadata then
		if type(metadata) == "string" then
			self.m_Metadata = fromJSON(metadata)
		else
			self.m_Metadata = metadata
		end
	else
		self.m_Metadata = false
	end

	self.m_OnMovePlayerDisconnectFunc = bind(WorldItem.Event_OnMovePlayerDisconnect, self)

	self.m_IsPermanent = isPermanent -- This indicates wether the item should be saved when the server shutsdown/restarts
	self.m_Locked = locked -- This indicates wether the Item was locked by an admin so no user can pick it up
	self.m_DatabaseId = 0 -- This represents the database-id from teh vrp_WorldItems table
	self.m_MaxAccessRange = 0 -- This is the range at which the object can be picked up via the placedObjects-GUI ( 0 stands for infinite )
	self.m_AccessIntDim = false -- If set to true the player must be in the same dimension/interior as the item in order to pick it up
	self.m_Value = value or "" -- This will be used to store meta-info about the world-item

	self.m_Object = createObject(self.m_ModelId, position, rotation)
	self.m_Object:setData("WorldItem:AccessRange", 0, true) -- this will be used at the client WorldItemOverViewGUI to filter out elements that are not in reach
	self.m_Object:setData("WorldItem:IntDimCheck", false, true) -- this will be used at the client WorldItemOverViewGUI to filter out elements that are not in reach
	self.m_Object:setData("WorldItem:anonymousInfo", false, true) -- this will be used to hide infomration from users if wished

	local ownerName = "Unbekannt"

	if self.m_ElementType == DbElementType.Player then
		ownerName = Account.getNameFromId(self.m_ElementId)
	elseif self.m_ElementType == DbElementType.Faction then
		ownerName = FactionManager:getSingleton().Map[self.m_ElementId].m_Name
	elseif self.m_ElementType == DbElementType.Company then
		ownerName = CompanyManager:getSingleton().Map[self.m_ElementId].m_Name
	elseif self.m_ElementType == DbElementType.Group then
		ownerName = GroupManager:getSingleton().Map[self.m_ElementId].m_Name
	end

	local placerName = Account.getNameFromId(self.m_PlacedBy)
	self.m_Object:setData("Owner", tostring(ownerName), true)
	self.m_Object:setData("Placer", tostring(placerName), true)

	self.m_Object:setDimension(self.m_Dimension)
	self.m_Object:setInterior(self.m_Interior)

	self.m_AttachedElements = {}
	self.m_Object.m_Super = self

	setElementData(self.m_Object, "worlditem", true) -- Tell the client that this is a world item (to be able to handle clicks properly)

	self.m_Object:setData("Name", self.m_ItemName or "Unknown", true)
	self.m_Object:setData("PlacedTimestamp", getRealTime().timestamp, true)

	-- Add an entry to the map
	if not WorldItem.MapByOwner[self.m_ElementType] then
		WorldItem.MapByOwner[self.m_ElementType] = {}
	end
	if not WorldItem.MapByOwner[self.m_ElementType][self.m_ElementId] then
		WorldItem.MapByOwner[self.m_ElementType][self.m_ElementId] = {}
	end
	if not WorldItem.MapByOwner[self.m_ElementType][self.m_ElementId][self.m_ModelId] then
		WorldItem.MapByOwner[self.m_ElementType][self.m_ElementId][self.m_ModelId] = {}
	end

	WorldItem.MapByOwner[self.m_ElementType][self.m_ElementId][self.m_ModelId][self.m_Object] = self -- this is for keeping track of players and objects for in-game usage

	if databaseId then
		self:setDatabaseId(databaseId)
	else
		StatisticsLogger:getSingleton():itemPlaceLogs(self.m_PlacedBy, itemData.Name, position.x..","..position.y..","..position.z)
		self.m_CreationDate = getRealTime().timestamp
		self:onChanged()
	end
end

function WorldItem:attach(ele, offsetPos, offsetRot)
	if isElement(ele) then
		self.m_AttachedElements[ele] = self
		ele:attach(self.m_Object, offsetPos or Vector3(0, 0, 0), offsetRot or Vector3(0, 0, 0))
		if getElementType(ele) == "object" then
			setElementData(ele, "worlditem_attachment", self.m_Object)
			self:onChanged()
		end
		return ele
	end
	return false
end

function WorldItem:virtual_destructor()
	if isElement(self.m_Object) then
		if self.m_AttachedElements then
			for i,v in pairs(self.m_AttachedElements) do
				if isElement(i) then
					destroyElement(i)
				end
			end
		end
		self.m_Object:destroy()
	end
	WorldItem.MapByOwner[self.m_ElementType][self.m_ElementId][self.m_ModelId][self.m_Object] = nil
end

function WorldItem:onCollect(player, resendList, id, typ)
	if self:getMovingPlayer() then
		player:sendError(_("Dieses Objekt wird von %s verwendet.", player, self:getMovingPlayer():getName()))
		return false
	end
	if not isElement(self:getObject()) then
		player:sendError(_("Dieses Objekt existiert nicht mehr.", player))
		return false
	end
	if not self:hasPlayerPermissionTo(player, WorldItem.Action.Collect) then
		player:sendError(_("Du bist nicht berechtigt dieses Objekt aufzuheben!", player))
		return false
	end

	if player:getInventory():giveItem(self.m_Item.TechnicalName, 1) then

		local x, y, z = getElementPosition(self:getObject())
		local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
		StatisticsLogger:getSingleton():worldItemLog("Collect", "Player", player:getId(), 0, self:getDatabaseId() or 0, zone1, zone2)

		if self.m_Item.removeFromWorld then
			self.m_Item:removeFromWorld(player, self, self.m_Object)
		end
		if not player.m_Disconnecting then
			player:sendShortMessage(_("%s aufgehoben.", player, self.m_ItemName), nil, nil, 1000)
		end
		delete(self)
		self.m_Delete = true
		self:onChanged()
		if resendList then WorldItem.sendItemListToPlayer(id, typ, player) end

		return true
	end
	return false
end

function WorldItem:forceSave()
	if self:isPermanent() and self:getDatabaseId() <= 0 then
		local pos = self:getObject():getPosition()
		local rot = self:getObject():getRotation()
		sql:queryExec("INSERT INTO ??_WorldItems (Item, Model, Owner, PosX, posY, posZ, Rotation, Value, Interior, Dimension, Breakable, Locked, Date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", sql:getPrefix(),
		self:getItem().TechnicalName or "Generic", self:getModel(), self:getOwner(), pos.x, pos.y, pos.z, rot.z, self:getValue(), self:getInterior(), self:getDimension(), self:isBreakable(), self:isLocked())
		self.m_HasChanged = false
		local rowId = sql:lastInsertId()
		self:setDatabaseId(rowId)
		outputDebugString("-- Force Saved WorldItem "..rowId.." into Database! --")
		return rowId
	end
	return false
end

function WorldItem:forceDelete()
	if self:isPermanent() then
		if self:getDatabaseId() > 0 then
			local id = self:getDatabaseId()
			self:setDatabaseId(0)
			sql:queryExec("DELETE FROM ??_WorldItems WHERE Id=?", sql:getPrefix(), id)
			outputDebugString("-- Force Deleted WorldItem "..id.." from Database! --")
		end
		delete(self)
		self.m_Delete = true
	else
		delete(self)
		self.m_Delete = true
	end
end

function WorldItem:onDelete(player, resendList, id, type)
	if player then
		if not isElement(self:getObject()) then
			player:sendError(_("Dieses Objekt existiert nicht mehr.", player))
			return false
		end
		if not self:hasPlayerPermissionTo(player, WorldItem.Action.Delete) then
			return false
		end
		local x, y, z = getElementPosition(self:getObject())
		local zone1, zone2 = getZoneName(x, y, z), getZoneName(x, y, z, true)
		StatisticsLogger:getSingleton():worldItemLog( "Delete", "Player", player:getId(), 0, self:getDatabaseId() or 0, zone1, zone2)
		local placer = self:getPlacer()
		placer = DatabasePlayer.getFromId(placer)
		if placer and isElement(placer) then
			placer:sendWarning(_("%s %s hat dein Objekt %s in %s, %s gelöscht!", placer,
			RANK[player:getRank()], player:getName(), self.m_ItemName, zone1, zone2), 10000)
		end
		player:sendShortMessage(_("%s gelöscht.", player, self.m_ItemName), nil, nil, 1000)
	end

	if self.m_Item.removeFromWorld then
		self.m_Item:removeFromWorld(nil, self, self.m_Object)
	end
	if resendList then WorldItem.sendItemListToPlayer(id, type, player) end
	delete(self)
	self:onChanged()
	self.m_Delete = true
end

function WorldItem:onMove(player)
	if self:getMovingPlayer() then
		player:sendError(_("Dieses Objekt wird von %s verwendet.", player, self:getMovingPlayer():getName()))
		return false
	end
	if not isElement(self:getObject()) then
		player:sendError(_("Dieses Objekt existiert nicht mehr.", player))
		return false
	end
	if not self:hasPlayerPermissionTo(player, WorldItem.Action.Move) then
		return false
	end
	self.m_CurrentMovingPlayer = player
	addEventHandler("onPlayerQuit", player, self.m_OnMovePlayerDisconnectFunc)

	player.m_PlacingInfo = {
		item = self,
		callback = function(item, position, rotation)
			if not isElement(self:getObject()) then
				player:sendError(_("Dieses Objekt existiert nicht mehr.", player))
				return false
			end
			if position then -- item moved
				self.m_Object:setCollisionsEnabled(false)
				nextframe(function()
					self.m_Object:setPosition(position)
					self.m_Object:setRotation(0, 0, rotation)
					self.m_Object:setInterior(player:getInterior())
					self.m_Object:setDimension(player:getDimension())
					self.m_Object:setCollisionsEnabled(true)
					self:onChanged()
				end)
			end
			self.m_CurrentMovingPlayer = nil
			removeEventHandler("onPlayerQuit", player, self.m_OnMovePlayerDisconnectFunc)
		end
	}
	player:triggerEvent("objectPlacerStart", self.m_Item.ModelId, "itemPlaced", self.m_Object)

--[[
	self.m_Item:startObjectPlacing(player,
		function(item, position, rotation)
			if not isElement(self:getObject()) then
				player:sendError(_("Dieses Objekt existiert nicht mehr.", player))
				return false
			end
			if position then -- item moved
				self.m_Object:setCollisionsEnabled(false)
				nextframe(function()
					self.m_Object:setPosition(position)
					self.m_Object:setRotation(0, 0, rotation)
					self.m_Object:setInterior(player:getInterior())
					self.m_Object:setDimension(player:getDimension())
					self.m_Object:setCollisionsEnabled(true)
					self:onChanged()
				end)
			end
			self.m_CurrentMovingPlayer = nil
			removeEventHandler("onPlayerQuit", player, self.m_OnMovePlayerDisconnectFunc)
		end, self.m_Object
	)]]
end

function WorldItem:getMovingPlayer()
	return self.m_CurrentMovingPlayer
end

function WorldItem:Event_OnMovePlayerDisconnect()
	if self.m_CurrentMovingPlayer == source then
		self.m_CurrentMovingPlayer = nil
	end
end

function WorldItem:getObject()
	return self.m_Object
end

function WorldItem:getPlacer()
	return self.m_PlacedBy
end

function WorldItem:getItem()
	return self.m_Item
end

function WorldItem:getModel()
	return self:getObject() and self:getObject():getModel()
end
function WorldItem:getDimension()
	return isElement(self.m_Object) and self.m_Object:getDimension()
end

function WorldItem:setDimension(dim)
	return isElement(self.m_Object) and self.m_Object:setDimension(dim)
end

function WorldItem:getInterior()
	return isElement(self.m_Object) and self.m_Object:getInterior()
end

function WorldItem:setInterior(int)
	return isElement(self.m_Object) and self.m_Object:setInterior(int)
end

function WorldItem:isPermanent()
	return self.m_IsPermanent
end

function WorldItem:setAnonymous( state )
	self.m_Anonymous = state
	self.m_Object:setData("WorldItem:anonymousInfo", state, true)
end

function WorldItem:getAnonymous( )
	return self.m_Anonymous
end

function WorldItem:onChanged()
	if self.m_IsPermanent then
		WorldItem.DirtyMap[self.m_Id] = getRealTime().timestamp
	end
end

function WorldItem:hasChanged()
	return self.m_HasChanged
end

function WorldItem:isLocked()
	return self.m_Locked
end

function WorldItem:setAccessRange(range)
	self.m_MaxAccessRange = range
	self.m_Object:setData("WorldItem:AccessRange", range, true)
end

function WorldItem:getAccessRange()
	return self.m_MaxAccessRange
end

function WorldItem:setAccessIntDimCheck(state)
	self.m_AccessIntDim = state
	self.m_Object:setData("WorldItem:IntDimCheck", state, true)
end

function WorldItem:getAccessIntDimCheck()
	return self.m_AccessIntDim
end

function WorldItem:setDatabaseId(id)
	self.m_DatabaseId = id
	if id > 0 then
		self.m_HasChanged = false
	end
end

function WorldItem:setValue(value)
	self.m_Value = value
end

function WorldItem:getValue()
	return self.m_Value
end

function WorldItem:getDatabaseId()
	return self.m_DatabaseId
end

function WorldItem:setModel(model)
	return self.getObject and isElement(self:getObject()) and self:getObject():setModel(model)
end

function WorldItem:getModel()
	return self.getObject and isElement(self:getObject()) and self:getObject():getModel()
end

function WorldItem:isBreakable()
	return false -- for now since there is no way to check breakability
end

function WorldItem:hasPlayerPermissionTo(player, action) --override this with group specific permissions, but always check for admin rights
	if not isElement(player) or player:getType() ~= "player" then return false end

	if ADMIN_RANK_PERMISSION[action] and player:getRank() >= ADMIN_RANK_PERMISSION[action] then -- admin rights
		return true
	end

	if action == WorldItem.Action.Move then
		if self.m_ElementType == DbElementType.Player then
			if self.m_ElementId == player:getId() then
				return true
			else
				return false
			end
		end
	elseif action == WorldItem.Action.Collect then
		if self.m_ElementType == DbElementType.Player then
			if self.m_ElementId == player:getId() then
				return true
			else
				return false
			end
		end
	elseif action == WorldItem.Action.Delete then
		return false
	end

	return false
end

function WorldItem.collectAllFromOwner(owner)
	if WorldItem.MapByOwner[owner] then
		for modelid, objects in pairs(WorldItem.MapByOwner[owner]) do
			for object, worlditem in pairs(objects) do
				worlditem:onCollect(owner)
			end
		end
	end
end

function WorldItem.sendItemListToPlayer(id, type, player)
	local owner = id
	local name
	local typ = 0
	if type == "player" then
		name = Account.getNameFromId(id)
		typ = 1
	elseif type == "faction" then
		owner = FactionManager:getSingleton():getFromId(id)
		name = owner:getName()
		typ = 2
	elseif type == "company" then
		owner = FactionManager:getSingleton():getFromId(id)
		name = owner:getName()
		typ = 3
	else
		typ = 4
	end
	if owner then
		triggerClientEvent(player, "recieveWorldItemListOfOwner", root, name, WorldItem.MapByOwner[typ][owner] or {}, id, type)
	end
end

function WorldItem.isAccessible( player, object)
	if object and object.getObject and isElement(object:getObject()) then
		if object:getAccessRange() > 0 then
			local x,y,z = getElementPosition(player)
			local ox, oy, oz = getElementPosition(object:getObject())
			local dist = getDistanceBetweenPoints3D(x, y, z, ox, oy, oz) <= object:getAccessRange()
			if dist then
				if object:getAccessIntDimCheck() then
					local int, dim = player:getInterior(), player:getDimension()
					local oInt, oDim = object:getObject():getInterior(), object:getObject():getDimension()
					if (int == oInt) and (dim == oDim) then
						return true
					else
						return false
					end
				else
					return true
				end
			else
				return false
			end
		else
			return true
		end
	end
end

addEventHandler("worldItemMove", root,
	function(...)
		if source.m_Super then
			source.m_Super:onMove(client, ...)
		end
	end
)

addEventHandler("worldItemCollect", root,
	function(...)
		if source.m_Super then
			source.m_Super:onCollect(client, ...)
		end
	end
)

addEventHandler("worldItemMassCollect", root,
	function(tblObjects, ...)
		local accessViolation = false
		for i, object in pairs(tblObjects) do
			if object.m_Super then
				if i == #tblObjects then
					if WorldItem.isAccessible( client, object.m_Super) then
						object.m_Super:onCollect(client, ...)
					else
						accessViolation = true
					end
				else
					if WorldItem.isAccessible( client, object.m_Super) then
						object.m_Super:onCollect(client)
					else
						accessViolation = true
					end
				end
			end
		end
		if accessViolation then
			client:sendError(_("Einige Objekte konnten nicht aufgehoben werden, da sie zu weit von dir entfernt sind!", client))
		end
	end
)

addEventHandler("worldItemDelete", root,
	function(...)
		if source.m_Super then
			source.m_Super:onDelete(client, ...)
		end
	end
)

addEventHandler("worldItemMassDelete", root,
	function(tblObjects, ...)
		for i, object in pairs(tblObjects) do
			if object.m_Super then
				if i == #tblObjects then
					object.m_Super:onDelete(client, ...)
				else
					object.m_Super:onDelete(client)
				end
			end
		end
	end
)


addEventHandler("requestWorldItemListOfOwner", root,
	function(id, type)
		WorldItem.sendItemListToPlayer(id, type, client)
	end
)


addCommandHandler("objects", function(player) --DEBUG
	if player:getRank() >= RANK.Developer then
		for owner, objects in pairs(WorldItem.MapByOwner) do
			outputConsole(owner:getName(), player)
			for id, elements in pairs(objects) do
				outputConsole(("%d Model %d"):format(table.size(elements), id), player)
			end
		end
	end
end)
