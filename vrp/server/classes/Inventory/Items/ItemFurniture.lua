-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Furniture item class
-- *
-- ****************************************************************************
ItemFurniture = inherit(Item)

function ItemFurniture:use(player, itemId, bag, place, itemName)
	local currentHouse = self:getHouse(player)
	if instanceof(currentHouse, House) then
		if currentHouse:isValidToEnter(player) and currentHouse.m_HasGTAInterior == false then
			local result = self:startObjectPlacing(player,
				function(item, position, rotation)
					if item ~= self or not position then return end
					player.m_CurrentHouse:createInsideFurniture(item, position, rotation)
					player:getInventory():removeItemFromPlace(bag, place, 1)
				end
			)
			return
		end
	end

	player:sendError(_("Du kannst hier kein(e) %s platzieren!", player, self:getName()))
end

function ItemFurniture:getHouse(player)
	if player.m_CurrentHouse then
		return player.m_CurrentHouse
	end

	local houses = HouseManager:getSingleton():getPlayerRentedHouses(player)
	local nearest = {math.huge, false}
	for index, house in pairs(houses) do
		local distance = getDistanceBetweenPoints3D(house.m_Pickup:getPosition(), player:getPosition())
		if distance < nearest[1] then
			nearest = {distance, house}
		end
	end

	return nearest[2]
end
