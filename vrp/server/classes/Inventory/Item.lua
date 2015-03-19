Item = inherit(Object)

function Item:constructor(itemId, count)
	Item.virtual_constructor(self, itemId, count)
end

function Item:virtual_constructor(itemId, count)
	self.m_ItemId = itemId
	self.m_Count = count or 1
end

function Item:getItemId()
	return self.m_ItemId
end

function Item:getCount()
	return self.m_Count
end

function Item:setCount(count)
	self.m_Count = count
end

function Item:use()
end

function Item:getModelId()
	return Items[self.m_ItemId].modelId ~= 0 and Items[self.m_ItemId].modelId or 2969
end

function Item:copy()
	local newItem = setmetatable({}, getmetatable(self))

	-- Copy properties (only 1 level to avoid circular loops for now)
	for k, v in pairs(self) do
		newItem[k] = v
	end

	return newItem
end

function Item:startObjectPlacing(player, callback)
	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end

	-- Start the object placer on the client
	player:triggerEvent("objectPlacerStart", self:getModelId(), "itemPlaced")
	player.m_PlacingInfo = {item = self, callback = callback}
	return true
 end

addEvent("itemPlaced", true)
addEventHandler("itemPlaced", root,
	function(x, y, z, rotation)
		local placingInfo = client.m_PlacingInfo
		if placingInfo then
			-- Check if the player still has the item | The item has already been removed from the inventory here!!!
			--[[if not client:getInventory():hasItem(placingInfo.item:getItemId()) then
				return
			end]]

			placingInfo.callback(placingInfo.item, Vector3(x, y, z), rotation)
			client.m_PlacingInfo = nil
		end
	end
)
