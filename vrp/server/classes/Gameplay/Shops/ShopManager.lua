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
	addRemoteEvents{"foodShopBuyMenu", "shopBuyItem", "vehicleBuy", "shopOpenGUI", "barBuyDrink", "barShopMusicChange", "barShopMusicStop", "shopBuy", "shopSell",
	"shopOpenBankGUI", "shopBankDeposit", "shopBankWithdraw"}

	addEventHandler("foodShopBuyMenu", root, bind(self.foodShopBuyMenu, self))
	addEventHandler("shopBuyItem", root, bind(self.buyItem, self))
	addEventHandler("barBuyDrink", root, bind(self.barBuyDrink, self))
	addEventHandler("vehicleBuy", root, bind(self.vehicleBuy, self))
	addEventHandler("barShopMusicChange", root, bind(self.barMusicChange, self))
	addEventHandler("barShopMusicStop", root, bind(self.barMusicStop, self))
	addEventHandler("shopBuy", root, bind(self.buy, self))
	addEventHandler("shopSell", root, bind(self.sell, self))
	addEventHandler("shopOpenBankGUI", root, bind(self.openBankGui, self))
	addEventHandler("shopBankDeposit", root, bind(self.deposit, self))
	addEventHandler("shopBankWithdraw", root, bind(self.withdraw, self))

	addEventHandler("shopOpenGUI", root, function(id)
		if ShopManager.Map[id] then
			ShopManager.Map[id]:onItemMarkerHit(client, true)
		else
			client:sendError(_("Invalid Shop ID!", client))
		end
	end)
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
		if not SHOP_TYPES[row.Type] then outputDebug("Error Loading Shop ID "..row.Id.." | Invalid Type") return end

		--local newName = SHOP_TYPES[row.Type]["Name"].." "..getZoneName(row.PosX, row.PosY, row.PosZ)
		--sql:queryExec("UPDATE ??_shops SET Name = ? WHERE Id = ?", sql:getPrefix(), newName ,row.Id)

		local instance = SHOP_TYPES[row.Type]["Class"]:new(row.Id, row.Name, Vector3(row.PosX, row.PosY, row.PosZ), row.Rot, SHOP_TYPES[row.Type], row.Dimension, row.RobAble, row.Money, row.LastRob, row.Owner, row.Price, row.OwnerType)
		ShopManager.Map[row.Id] = instance
		if row.Blip then
			instance:addBlip(row.Blip)
		end
	end
end

function ShopManager:loadVehicleShops()
	local result = sql:queryFetch("SELECT * FROM ??_vehicle_shops", sql:getPrefix())
    for k, row in ipairs(result) do
		local instance = VehicleShop:new(row.Id, row.Name, row.Marker, row.NPC, row.Spawn, row.Image, row.Owner, row.Price, row.Money)
		ShopManager.VehicleShopsMap[row.Id] = instance
		if row.Blip then
			instance:addBlip(row.Blip)
		end
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
			StatisticsLogger:getSingleton():addHealLog(client, shop.m_Menues[menu]["Health"], "Shop "..shop.m_Menues[menu]["Name"])
			client:takeMoney(shop.m_Menues[menu]["Price"], "Essen")
			shop:giveMoney(shop.m_Menues[menu]["Price"], "Kunden-Einkauf")
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
		if client:getMoney() >= shop.m_Items[item]*amount then
			if client:getInventory():getFreePlacesForItem(item) >= amount then
				client:getInventory():giveItem(item, amount)
				if item == "Kanne" then
					client:getInventory():setSpecialItemData(item, 10)
				elseif item == "Mautpass" then
					local validity = getRealTime().timestamp + 7*24*60*60
					client:getInventory():setSpecialItemData(item, validity)
				end
				client:takeMoney(shop.m_Items[item]*amount, "Item-Einkauf")
				client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, shop.m_Name))
				shop:giveMoney(shop.m_Items[item]*amount, "Kunden-Einkauf")
			else
				client:sendError(_("Die maximale Anzahl dieses Items beträgt %d!", client, client:getInventory():getMaxItemAmount(item)))
				return
			end
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
			return
		end
	else
		client:sendError(_("Internal Error! Item not found!", client))
		return
	end
end

function ShopManager:barBuyDrink(shopId, item, amount)
	if not item then return end
	if not amount then amount = 1 end
	local shop = self:getFromId(shopId)
	if shop.m_Items[item] then
		if client:getMoney() >= shop.m_Items[item]*amount then
			client:takeMoney(shop.m_Items[item]*amount, "Item-Einkauf")
			client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, shop.m_Name))
			shop:giveMoney(shop.m_Items[item]*amount, "Kunden-Einkauf")

			local instance = ItemManager.Map[item]
			if instance.use then
				if instance:use(client, itemId, bag, place, item) == false then
					return false
				end
			end

		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
			return
		end
	else
		client:sendError(_("Internal Error! Item not found!", client))
		return
	end
end

function ShopManager:barMusicChange(shopId, stream)
	local shop = self:getFromId(shopId)
	if shop then
		shop:changeMusic(client, stream)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:barMusicStop(shopId)
	local shop = self:getFromId(shopId)
	if shop then
		shop:stopMusic(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:buy(shopId)
	local shop = self:getFromId(shopId)
	if shop then
		shop:buy(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:sell(shopId)
	local shop = self:getFromId(shopId)
	if shop then
		shop:sell(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:deposit(amount, shopId)
	local shop = self:getFromId(shopId)
	if shop then
    	if not amount then return end

		if client:getMoney() < amount then
			client:sendError(_("Du hast nicht genügend Geld!", client))
			return
		end

		client:takeMoney(amount, "Shop-Einlage")
		shop:giveMoney(amount, "Shop-Einlage")
		shop.m_Owner:addLog(client, "Kasse", "hat "..amount.."$ in die Shop-Kasse gelegt! ("..shop:getName()..")")
		shop:refreshBankGui(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:withdraw(amount, shopId)
	local shop = self:getFromId(shopId)
	if shop then
		if not amount then return end

		if not shop:isManageAllowed(client) then
			client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
			-- Todo: Report possible cheat attempt
			return
		end

		if shop:getMoney() < amount then
			client:sendError(_("In der Shop-Kasse befindet sich nicht genügend Geld!", client))
			return
		end

		shop:takeMoney(amount, "Shop-Auslage")
		client:giveMoney(amount, "Shop-Auslage")
		shop.m_Owner:addLog(client, "Kasse", "hat "..amount.."$ aus der Shop-Kasse genommen! ("..shop:getName()..")")
		shop:refreshBankGui(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:openBankGui(shopId)
	local shop = self:getFromId(shopId)
	if shop then
		shop:openBankGui(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end
