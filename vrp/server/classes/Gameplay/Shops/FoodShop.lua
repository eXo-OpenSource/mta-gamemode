-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/FoodShop.lua
-- *  PURPOSE:     FoodShop Super Class
-- *
-- ****************************************************************************
FoodShop = inherit(Object)


function FoodShop:constructor()
	addRemoteEvents{"foodShopBuyMenu"}
	addEventHandler("foodShopBuyMenu", root, bind(self.buyMenu, self))
end

function FoodShop:onFoodMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		hitElement:triggerEvent("showFoodShopMenu")
		triggerClientEvent(hitElement, "refreshFoodShopMenu", hitElement, self.m_Type, self.m_Menues, self.m_Items)
	end
end

function FoodShop:buyMenu(menu)
	if self.m_Menues[menu] then
		if client:getMoney() >= self.m_Menues[menu]["Price"] then
			client:setHealth(client:getHealth() + self.m_Menues[menu]["Health"])
			client:takeMoney(self.m_Menues[menu]["Price"])
			client:sendInfo(_("Guten Appetit!", client))
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Internal Error! Menu not found!", client))
	end
end
