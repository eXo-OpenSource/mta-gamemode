-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
WorldItem = inherit(Object)
WorldItem.Map = {}

function WorldItem:constructor(item, player, pos, rotation)
	self.m_Item = item
	self.m_Owner = player or false
	self.m_Object = createObject(item:getModelId(), pos, 0, 0, rotation)
	setElementData(self.m_Object, "worlditem", true) -- Tell the client that this is a world item (to be able to handle clicks properly)

	-- Add an entry to the map
	WorldItem.Map[self.m_Object] = self
end

function WorldItem:destructor()
	self.m_Object:destroy()
end

function WorldItem:collect(player)
	local item = self.m_Item
	if item.onCollect then
		if item:onCollect(player) ~= false then
			player:getInventory():addItemByItem(item)
		end
	else
		player:getInventory():addItemByItem(item)
	end

	delete(self)
end

function WorldItem:onClick(player)
	-- DroppableItem:onClick should return true if we should handle the click, false if the item wants to handle the click itself
	if self.m_Item:onClick(player, self) == true then
		-- Let's reacquire the item
		self:collect(player)
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

addEvent("worldItemClick", true)
addEventHandler("worldItemClick", root,
	function()
		local worldItem = WorldItem.Map[source]
		if not worldItem then return end

		worldItem:onClick(client)
	end
)

-- TODO: Automatically collect all items when the player disconnects (do we actually have to?)
