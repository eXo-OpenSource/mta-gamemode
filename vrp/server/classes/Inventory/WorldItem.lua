-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
WorldItem = inherit(Object)
WorldItem.Map = {}

function WorldItem:constructor(item, player, pos, rotation, breakable)
	self.m_Item = item
	self.m_ItemName = item:getName()
	self.m_Owner = player:getId() or false
	self.m_Object = createObject(item:getModelId(), pos, 0, 0, rotation)
	setElementData(self.m_Object, "worlditem", true) -- Tell the client that this is a world item (to be able to handle clicks properly)
	self.m_Object.m_Super = self
	self.m_Object:setData("Owner", player:getName() or "Unknown", true)

	-- Add an entry to the map
	WorldItem.Map[self.m_Object] = self
end

function WorldItem:destructor()
	WorldItem.Map[self.m_Object] = nil
	self.m_Object:destroy()
end

function WorldItem:collect(player)
	if self.m_Item.isCollectAllowed then
		if not self.m_Item:isCollectAllowed(player, self) then
			return
		end
	end

	if self.m_Item.removeFromWorld then
		self.m_Item:removeFromWorld(player, self)
	end

	if player:getInventory():giveItem(self.m_ItemName, 1) then
		delete(self)
		return true
	end
	return false
end

function WorldItem:onClick(player)
 	if self.m_Item.onClick then
		self.m_Item:onClick(player, self)
	end
end

function WorldItem:getObject()
	return self.m_Object
end

function WorldItem:getOwner()
	return self.m_Owner
end

function WorldItem:getItem()
	return self.m_Item
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

addEvent("worldItemClick", true)
addEventHandler("worldItemClick", root,
	function()
		local worldItem = WorldItem.Map[source]
		if not worldItem then return end

		worldItem:onClick(client)
	end
)

addEvent("worldItemCollect", true)
addEventHandler("worldItemCollect", root,
	function()
		local worldItem = WorldItem.Map[source]
		if not worldItem then return end

		worldItem:collect(client)
	end
)

addEvent("worldItemDelete", true)
addEventHandler("worldItemDelete", root,
	function()
		if client:getRank() > RANK.Supporter then
			local worldItem = WorldItem.Map[source]
			if not worldItem then return end

			if worldItem.m_Item.removeFromWorld then
				worldItem.m_Item:removeFromWorld(client, worldItem)
			end
			delete(worldItem)
		end
	end
)

-- TODO: Automatically collect all items when the player disconnects (do we actually have to?)
