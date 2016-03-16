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
	self:loadShops()

	addRemoteEvents{"foodShopBuyMenu", "foodShopBuyItem"}
	addEventHandler("foodShopBuyMenu", root, bind(self.foodShopBuyMenu, self))
	addEventHandler("foodShopBuyItem", root, bind(self.foodShopBuyItem, self))
end

function ShopManager:loadShops()
	local result = sql:queryFetch("SELECT * FROM ??_shops", sql:getPrefix())
    for k, row in ipairs(result) do
		if not SHOP_TYPES[row.Type] then outputDebug("Error Loading Shop ID "..row.Id.." | Invalid Type") end

		--local newName = SHOP_TYPES[row.Type]["Name"].." "..getZoneName(row.PosX, row.PosY, row.PosZ)
		--sql:queryExec("UPDATE ??_shops SET Name = ? WHERE Id = ?", sql:getPrefix(), newName ,row.Id)

		SHOP_TYPES[row.Type]["Class"]:new(row.Id, Vector3(row.PosX, row.PosY, row.PosZ), SHOP_TYPES[row.Type], row.Dimension, row.robable)

	end
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
