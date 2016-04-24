-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/ShopManager.lua
-- *  PURPOSE:     Shop Manager Class
-- *
-- ****************************************************************************
ShopManager = inherit(Singleton)
ShopManager.Map = {}
ShopManager.VehicleShopsMap = {}

local PIZZA_STACK_DIMS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
local CLUCKIN_BELL_DIMS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
local BURGER_SHOT_DIMS = {0, 1, 2, 3, 4, 5}

function ShopManager:constructor()
	self:loadShops()
	self:loadVehicleShops()
	addRemoteEvents{"foodShopBuyMenu", "shopBuyItem", "vehicleBuy"}
	addEventHandler("foodShopBuyMenu", root, bind(self.foodShopBuyMenu, self))
	addEventHandler("shopBuyItem", root, bind(self.buyItem, self))
	addEventHandler("vehicleBuy", root, bind(self.vehicleBuy, self))

end

function ShopManager:destructor()
	for index, shop in pairs(ShopManager.Map) do
		shop:save()
	end
	for index, shop in pairs(ShopManager.VehicleShopsMap) do
		shop:save()
	end
end

function ShopManager:loadShops()
	local result = sql:queryFetch("SELECT * FROM ??_shops", sql:getPrefix())
    for k, row in ipairs(result) do
		if not SHOP_TYPES[row.Type] then outputDebug("Error Loading Shop ID "..row.Id.." | Invalid Type") end

		--local newName = SHOP_TYPES[row.Type]["Name"].." "..getZoneName(row.PosX, row.PosY, row.PosZ)
		--sql:queryExec("UPDATE ??_shops SET Name = ? WHERE Id = ?", sql:getPrefix(), newName ,row.Id)

		local instance = SHOP_TYPES[row.Type]["Class"]:new(row.Id, row.Name, Vector3(row.PosX, row.PosY, row.PosZ), row.Rot, SHOP_TYPES[row.Type], row.Dimension, row.RobAble, row.Money, row.LastRob, row.Owner, row.Price)
		ShopManager.Map[row.Id] = instance
	end
end

function ShopManager:loadVehicleShops()
	local result = sql:queryFetch("SELECT * FROM ??_vehicle_shops", sql:getPrefix())
    for k, row in ipairs(result) do
		local instance = VehicleShop:new(row.Id, row.Name, row.Marker, row.NPC, row.Spawn, row.Image, row.Owner, row.Price, row.Money)
		ShopManager.VehicleShopsMap[row.Id] = instance
	end

	local result = sql:queryFetch("SELECT * FROM ??_vehicle_shop_veh", sql:getPrefix())
    for k, row in ipairs(result) do
		local shop = self:getFromId(row.ShopId, true)
		shop:addVehicle(row.Id, row.Model, row.Name, row.Category, row.Price, row.Level, Vector3(row.X, row.Y, row.Z), Vector3(row.RX, row.RY, row.RZ))
	end
end

function ShopManager:getFromId(id, vehicle)
	if vehicle == true then
		return ShopManager.VehicleShopsMap[id]
	else
		return ShopManager.Map[id]
	end
end


function ShopManager:vehicleBuy(shopId, vehicleModel)
	if not self:getFromId(shopId, true) then return end

	self:getFromId(shopId, true):buyVehicle(client, vehicleModel)

end

function ShopManager:foodShopBuyMenu(shopId, menu)
	local shop = self:getFromId(shopId)
	if shop.m_Menues[menu] then
		if client:getMoney() >= shop.m_Menues[menu]["Price"] then
			client:setHealth(client:getHealth() + shop.m_Menues[menu]["Health"])
			client:takeMoney(shop.m_Menues[menu]["Price"])
			shop:giveMoney(shop.m_Menues[menu]["Price"])
			client:sendInfo(_("%s wünscht guten Appetit!", client, shop.m_Name))
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Internal Error! Menu not found!", client))
	end
end

function ShopManager:buyItem(shopId, item, amount)
	if not item then return end
	if not amount then amount = 1 end
	local shop = self:getFromId(shopId)
	if shop.m_Items[item] then
		if client:getMoney() >= shop.m_Items[item] then
			if client:getInventory():getFreePlacesForItem(item) >= 1 then
				client:getInventory():giveItem(item, 1)
				client:takeMoney(shop.m_Items[item])
				client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, shop.m_Name))
				shop:giveMoney(shop.m_Items[item])
			else
				client:sendError(_("Die maximale Anzahl dieses Items beträgt %d!", client, client:getInventory():getMaxItemAmount(item)))
			end
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Internal Error! Item not found!", client))
	end
end
