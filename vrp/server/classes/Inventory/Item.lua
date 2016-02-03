Item = inherit(Object)

function Item:constructor(itemName, itemClass, itemModel)
	self.m_ItemName = itemName
	self.m_ItemClass = itemClass
	self.m_ItemModel = itemModel
	self.m_ItemClass:new()
end

function Item:getName()
	return self.m_ItemName
end

function Item:use()
end

function Item:getModelId()
	return self.m_ItemModel ~= 0 and self.m_ItemModel or 2969
end

function Item:place(owner, pos, rotation, amount)
	-- We need to duplicate the item if the amount does not match the available amount of items
	outputChatBox(self.m_ItemModel)
	local worldItem = WorldItem:new(self, owner, pos, rotation)
	if owner then
		--owner:triggerEvent("worldItemPlace", self.m_ItemName, worldItem:getObject())
	end
	return worldItem
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
