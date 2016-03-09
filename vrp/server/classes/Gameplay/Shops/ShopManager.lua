-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/ShopManager.lua
-- *  PURPOSE:     Shop Manager Class
-- *
-- ****************************************************************************
ShopManager = inherit(Singleton)

local PIZZA_STACK_DIMS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
local CLUCKIN_BELL_DIMS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
local BURGER_SHOT_DIMS = {0, 1, 2, 3, 4, 5}

function ShopManager:constructor()
	for index, key in pairs(PIZZA_STACK_DIMS) do
		PizzaStack:new(key)
	end

	for index, key in pairs(CLUCKIN_BELL_DIMS) do
		CluckinBell:new(key)
	end

	for index, key in pairs(BURGER_SHOT_DIMS) do
		BurgerShot:new(key)
	end

	RustyBrown:new(0)

	addRemoteEvents{"foodShopBuyMenu", "foodShopBuyItem"}
	addEventHandler("foodShopBuyMenu", root, bind(self.foodShopBuyMenu, self))
	addEventHandler("foodShopBuyItem", root, bind(self.foodShopBuyItem, self))

end

function ShopManager:foodShopBuyMenu(shop, menu)
	if shop.m_Menues[menu] then
		if client:getMoney() >= shop.m_Menues[menu]["Price"] then
			client:setHealth(client:getHealth() + shop.m_Menues[menu]["Health"])
			client:takeMoney(shop.m_Menues[menu]["Price"])
			client:sendInfo(_("Guten Appetit!", client))
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Internal Error! Menu not found!", client))
	end
end

function ShopManager:foodShopBuyItem(shop, item)
	if shop.m_Items[item] then
		if client:getMoney() >= shop.m_Items[item] then
			if client:getInventory():getFreePlacesForItem(item) >= 1 then
				client:getInventory():giveItem(item, 1)
				client:takeMoney(shop.m_Items[item])
				client:sendInfo(_("Vielen Dank für den Einkauf!", client))
			else
				client:sendError(_("Die maximale Anzahl dieses Items beträgt %d!", client, client:getInventory():getMaxItemAmount(item)))
			end
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Internal Error! Menu not found!", client))
	end
end
