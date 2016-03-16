-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Shop.lua
-- *  PURPOSE:     Shop Super Class
-- *
-- ****************************************************************************
Shop = inherit(Object)

function Shop:constructor()

end

function Shop:createShop(id, position, typeData, dimension, robable)
	local interior, intPosition = unpack(typeData["Interior"])
	local pedSkin, pedPosition, pedRotation = unpack(typeData["Ped"])

	InteriorEnterExit:new(position, intPosition, 0, 0, interior, dimension)

	if robable == 1 then
		RobableShop:new(pedPosition, pedRotation, pedSkin, interior, dimension)
	else
		local ped = createPed(pedSkin, pedPosition, pedRotation)
		ped:setInterior(interior)
		ped:setDimension(dimension)
	end

	self.m_Marker = createMarker(typeData["Marker"], "cylinder", 1, 255, 255, 0, 200)
	self.m_Marker:setInterior(interior)
	self.m_Marker:setDimension(dimension)
end

function Shop:onFoodMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		hitElement:triggerEvent("showFoodShopMenu")
		triggerClientEvent(hitElement, "refreshFoodShopMenu", hitElement, self, self.m_Type, self.m_Menues, self.m_Items)
	end
end

function Shop:onItemMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		hitElement:triggerEvent("showItemShopGUI")
		triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self, self.m_Items)
	end
end
