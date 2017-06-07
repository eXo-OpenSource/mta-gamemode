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

WorldItem.constructor = pure_virtual

function WorldItem:virtual_constructor(item, owner, pos, rotation, breakable, player)
	iprint(player)
	print("WorldItem "..(isElement(owner) and getElementType(owner) or "something else").." "..getElementType(player), root)
	self.m_Item = item
	self.m_ItemName = item:getName()
	self.m_ModelId = item:getModelId()
	self.m_Owner = owner
	self.m_Placer = player
	self.m_Object = createObject(self.m_ModelId, pos, 0, 0, rotation)
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

function WorldItem:virtual_destructor()
	self.m_Object:destroy()
	WorldItem.Map[self.m_Owner][self.m_ModelId][self.m_Object] = nil
end

function WorldItem:onCollect(player)
	if not self:hasPlayerPermissionTo(player, WorldItem.Action.Collect) then
		return false
	end

	if player:getInventory():giveItem(self.m_ItemName, 1) then
		if self.m_Item.removeFromWorld then
			self.m_Item:removeFromWorld(player, self)
		end
		player:sendShortMessage(_("%s aufgehoben.", player, self.m_ItemName), nil, nil, 1000)
		delete(self)
		return true
	end
	return false
end

function WorldItem:onDelete(player)
	if not self:hasPlayerPermissionTo(player, WorldItem.Action.Delete) then
		return false
	end
	player:sendShortMessage(_("%s gelöscht.", player, self.m_ItemName), nil, nil, 1000)
	delete(self)
end

function WorldItem:onMove(player)
	outputDebug(player)
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

function WorldItem:hasPlayerPermissionTo(player, action)
	if not isElement(player) or player:getType() ~= "player" then return false end
	if not ADMIN_RANK_PERMISSION[action] or player:getRank() >= ADMIN_RANK_PERMISSION[action] then
		return true
	end
	return false
end

function WorldItem.getItemsByOwner(player)
	local result = {}
	for k, worldItem in pairs(WorldItem.Map) do
		if worldItem.m_Owner == player:getId() then
			result[#result + 1] = worldItem
		end
	end
	return result
end

addEvent("worldItemMove", true)
addEventHandler("worldItemMove", root,
	function(state)
		if source.m_Super then
			source.m_Super:onMove(client)
		end
	end
)

addEvent("worldItemCollect", true)
addEventHandler("worldItemCollect", root,
	function()
		if source.m_Super then
			source.m_Super:onCollect(client)
		end
	end
)

addEvent("worldItemDelete", true)
addEventHandler("worldItemDelete", root,
	function()
		if source.m_Super then
			source.m_Super:onDelete(client)
		end
	end
)


addCommandHandler("objects", function() --DEBUG
	outputConsole(inspect(WorldItem.Map))
end)
