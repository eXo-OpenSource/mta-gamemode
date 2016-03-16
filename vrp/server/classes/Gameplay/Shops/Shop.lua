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

function Shop:createShopPed(pedSkin, pedPosition, pedRotation, interior, dimension, robable)
	if robable == 1 then
		RobableShop:new(pedPosition, pedRotation, pedSkin, interior, dimension)
	else
		local ped = createPed(pedSkin, pedPosition, pedRotation)
		ped:setInterior(interior)
		ped:setDimension(dimension)
	end
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
