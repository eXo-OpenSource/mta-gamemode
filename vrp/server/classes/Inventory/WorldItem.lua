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
	self.m_ItemName = item:getName()
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
	if self.m_Item.removeFromWorld then
		self.m_Item:removeFromWorld(self)
	end

	player:getInventory():giveItem(self.m_ItemName, 1)

	delete(self)
end

function WorldItem:onClick(player)
	if self.m_Owner and self.m_Owner ~= player then
		AntiCheat:getSingleton():report(player, "Triggered collect event on an item which is not owned by the client", CheatSeverity.Middle)
		return
	end

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

function WorldItem.getItemsByOwner(player)
	local result = {}
	for k, worldItem in pairs(WorldItem.Map) do
		if worldItem.m_Owner == player then
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

		if worldItem.m_Owner and worldItem.m_Owner ~= client then
			AntiCheat:getSingleton():report(player, "Triggered collect event on an item which is not owned by the client", CheatSeverity.Middle)
			return
		end

		worldItem:collect(client)
	end
)

-- TODO: Automatically collect all items when the player disconnects (do we actually have to?)
