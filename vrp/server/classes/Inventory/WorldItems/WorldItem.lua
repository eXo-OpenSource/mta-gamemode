-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/WorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
WorldItem = inherit(Object)
WorldItem.Map = {}
WorldItem.Action = {
	Move = "moveWorldItem",
	Collect = "collectWorldItem",
	Delete = "deleteWorldItem",
}
addRemoteEvents{"worldItemMove", "worldItemCollect", "worldItemMassCollect", "worldItemDelete", "worldItemMassDelete", "requestWorldItemListOfOwner"}

WorldItem.constructor = pure_virtual

function WorldItem:virtual_constructor(item, owner, pos, rotation, breakable, player)
	self.m_Item = item
	self.m_ItemName = item:getName()
	self.m_ModelId = item:getModelId()
	self.m_Owner = owner
	self.m_Placer = player
	self.m_OnMovePlayerDisconnectFunc = bind(WorldItem.Event_OnMovePlayerDisconnect, self)
	self.m_Object = createObject(self.m_ModelId, pos, 0, 0, rotation)
	self.m_Object:setInterior(player:getInterior())
	self.m_Object:setDimension(player:getDimension())

	self.m_AttachedElements = {}
	self.m_Object.m_Super = self
	--self.m_Object:setBreakable(breakable)
	setElementData(self.m_Object, "worlditem", true) -- Tell the client that this is a world item (to be able to handle clicks properly)
	self.m_Object:setData("Owner", ((owner.getShortName and owner:getShortName()) or (owner.getName and owner:getName())) or "Unknown", true)
	self.m_Object:setData("Name", self.m_ItemName or "Unknown", true)
	self.m_Object:setData("Placer", player:getName() or "Unknown", true)
	self.m_Object:setData("PlacedTimestamp", getRealTime().timestamp, true)

	-- Add an entry to the map
	if not WorldItem.Map[owner] then
		WorldItem.Map[owner] = {}
	end
	if not WorldItem.Map[owner][self.m_ModelId] then
		WorldItem.Map[owner][self.m_ModelId] = {}
	end
	WorldItem.Map[owner][self.m_ModelId][self.m_Object] = self
end

function WorldItem:attach(ele, offsetPos, offsetRot)
	if isElement(ele) then
		self.m_AttachedElements[ele] = self
		ele:attach(self.m_Object, offsetPos or Vector3(0, 0, 0), offsetRot or Vector3(0, 0, 0))
		if getElementType(ele) == "object" then
			setElementData(ele, "worlditem_attachment", self.m_Object)
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
	WorldItem.Map[self.m_Owner][self.m_ModelId][self.m_Object] = nil
end

function WorldItem:onCollect(player, resendList, id, type)
	if self:getMovingPlayer() then 
		player:sendError(_("Dieses Objekt wird von %s verwendet.", player, self:getMovingPlayer():getName())) 
		return false 
	end
	if not isElement(self:getObject()) then 
		player:sendError(_("Dieses Objekt existiert nicht mehr.", player)) 
		return false 
	end
	if not self:hasPlayerPermissionTo(player, WorldItem.Action.Collect) then
		return false
	end

	if player:getInventory():giveItem(self.m_ItemName, 1) then
		if self.m_Item.removeFromWorld then
			self.m_Item:removeFromWorld(player, self, self.m_Object)
		end
		if not self.m_Owner.m_Disconnecting then player:sendShortMessage(_("%s aufgehoben.", player, self.m_ItemName), nil, nil, 1000) end
		delete(self)
		if resendList then WorldItem.sendItemListToPlayer(id, type, player) end
		return true
	end
	return false
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
		player:sendShortMessage(_("%s gelöscht.", player, self.m_ItemName), nil, nil, 1000)
	end
	if self.m_Item.removeFromWorld then
		self.m_Item:removeFromWorld(nil, self, self.m_Object)
	end
	if resendList then WorldItem.sendItemListToPlayer(id, type, player) end
	delete(self)
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
	if player:getData("inJail") or player:getData("inAdminPrison") then
		player:sendError(_("Du kannst hier keine Objekte platzieren.", player, self:getMovingPlayer():getName())) 
		return false
	end
	self.m_CurrentMovingPlayer = player
	addEventHandler("onPlayerQuit", player, self.m_OnMovePlayerDisconnectFunc)
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
				end)
			end
			self.m_CurrentMovingPlayer = nil
			removeEventHandler("onPlayerQuit", player, self.m_OnMovePlayerDisconnectFunc)
		end, self.m_Object
	)
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

function WorldItem:getOwner()
	return self.m_Owner
end

function WorldItem:getPlacer()
	return self.m_Placer
end

function WorldItem:getItem()
	return self.m_Item
end

function WorldItem:hasPlayerPermissionTo(player, action) --override this with group specific permissions, but always check for admin rights
	if not isElement(player) or player:getType() ~= "player" then return false end
	if not ADMIN_RANK_PERMISSION[action] or player:getRank() < ADMIN_RANK_PERMISSION[action] then
		return false
	end
	return true
end

function WorldItem.collectAllFromOwner(owner)
	if WorldItem.Map[owner] then
		for modelid, objects in pairs(WorldItem.Map[owner]) do
			for object, worlditem in pairs(objects) do
				worlditem:onCollect(owner)
			end
		end
	end
end

function WorldItem.sendItemListToPlayer(id, type, player)
	local owner
	if type == "player" then
		owner = DatabasePlayer.getFromId(id)	
	elseif type == "faction" then
		owner = FactionManager:getSingleton():getFromId(id)
	elseif type == "company" then
		owner = FactionManager:getSingleton():getFromId(id)
	end
	if owner then
		triggerClientEvent(player, "recieveWorldItemListOfOwner", root, owner:getName(), WorldItem.Map[owner] or {}, id, type)
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
		for i, object in pairs(tblObjects) do
			if object.m_Super then
				if i == #tblObjects then
					object.m_Super:onCollect(client, ...)
				else
					object.m_Super:onCollect(client)
				end
			end
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
		for owner, objects in pairs(WorldItem.Map) do
			outputConsole(owner:getName(), player)
			for id, elements in pairs(objects) do
				outputConsole(("%d Model %d"):format(table.size(elements), id), player)
			end
		end
	end
end)
