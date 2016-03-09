-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/FoodShop.lua
-- *  PURPOSE:     FoodShop Super Class
-- *
-- ****************************************************************************
FoodShop = inherit(Object)


function FoodShop:constructor()

end

function FoodShop:onFoodMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		hitElement:triggerEvent("showFoodShopMenu")
		triggerClientEvent(hitElement, "refreshFoodShopMenu", hitElement, self, self.m_Type, self.m_Menues, self.m_Items)
	end
end
