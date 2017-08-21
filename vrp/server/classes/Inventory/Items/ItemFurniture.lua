-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Furniture item class
-- *
-- ****************************************************************************
ItemFurniture = inherit(Item)

function ItemFurniture:use(player, itemId, bag, place, itemName)
	if player.m_CurrentHouse ~= nil and player.m_CurrentHouse:isValidToEnter(player) then
		local result = self:startObjectPlacing(player,
			function(item, position, rotation)
				if item ~= self or not position then return end
				player.m_CurrentHouse:createInsideFurniture(item, item:getModelId(), position, rotation)

				player:getInventory():removeItemFromPlace(bag, place, 1)
			end
		)
	else
		player:sendError("No Access!")
	end
end
