-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Furniture item class
-- *
-- ****************************************************************************
ItemFurniture = inherit(Item)

function ItemFurniture:use(player, itemId, bag, place, itemName)
	local currentHouse = player.m_CurrentHouse
	if currentHouse ~= nil then
		if currentHouse:isValidToEnter(player) and currentHouse.m_HasGTAInterior == false then
			local result = self:startObjectPlacing(player,
				function(item, position, rotation)
					if item ~= self or not position then return end
					player.m_CurrentHouse:createInsideFurniture(item, position, rotation)
					player:getInventory():removeItemFromPlace(bag, place, 1)
					return
				end
			)
		end
	end

	player:sendError(_("Du kannst hier kein(e) %s platzieren!", player, self:getName()))
end
