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

function ShopManager:constructor()
	self:loadShops()
	self:loadVehicleShops()
	addRemoteEvents{"foodShopBuyMenu", "shopBuyItem", "shopBuyClothes", "vehicleBuy", "shopOpenGUI", "shopBuy", "shopSell", "gasStationFill",
	"barBuyDrink", "barShopMusicChange", "barShopMusicStop", "barShopStartStripper", "barShopStopStripper",
	"shopOpenBankGUI", "shopBankDeposit", "shopBankWithdraw", "shopOnTattooSelection", "ammunationBuyItem", "onAmmunationAppOrder"
	}

	addEventHandler("foodShopBuyMenu", root, bind(self.foodShopBuyMenu, self))
	addEventHandler("shopBuyItem", root, bind(self.buyItem, self))
	addEventHandler("barBuyDrink", root, bind(self.barBuyDrink, self))
	addEventHandler("vehicleBuy", root, bind(self.vehicleBuy, self))

	addEventHandler("shopBuy", root, bind(self.buy, self))
	addEventHandler("shopSell", root, bind(self.sell, self))
	addEventHandler("shopOpenBankGUI", root, bind(self.openBankGui, self))
	addEventHandler("shopBankDeposit", root, bind(self.deposit, self))
	addEventHandler("shopBankWithdraw", root, bind(self.withdraw, self))
	addEventHandler("shopBuyClothes", root, bind(self.buyClothes, self))

	addEventHandler("ammunationBuyItem", root, bind(self.buyWeapon, self))
	addEventHandler("onAmmunationAppOrder",root, bind(self.onAmmunationAppOrder, self))

	addEventHandler("shopOnTattooSelection", root, bind(self.onTattooSelection, self))

	addEventHandler("barShopMusicChange", root, bind(self.barMusicChange, self))
	addEventHandler("barShopMusicStop", root, bind(self.barMusicStop, self))
	addEventHandler("barShopStartStripper", root, bind(self.barStartStripper, self))
	addEventHandler("barShopStopStripper", root, bind(self.barStopStripper, self))

	addEventHandler("gasStationFill", root, bind(self.onGasStationFill, self))

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
		if row.Blip and row.Blip ~= "" then
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

function ShopManager:onGasStationFill(shopId, drawFromBank)
	local shop = self:getFromId(shopId)
	if not shop then
		client:sendError(_("Internal Error! Shop not found!", client))
		return
	end

	local vehicle = getPedOccupiedVehicle(client)
	if not vehicle then return end
	if instanceof(vehicle, PermanentVehicle, true) or instanceof(vehicle, GroupVehicle, true) or instanceof(vehicle, FactionVehicle, true) or instanceof(vehicle, CompanyVehicle, true) then
		if (drawFromBank and client:getBankMoney() or client:getMoney()) >= 10 then
			if vehicle:getFuel() <= 100-10 then
				vehicle:setFuel(vehicle:getFuel() + 10)
				if drawFromBank then
					client:takeBankMoney(10, "Tanken")
				else
					client:takeMoney(10, "Tanken")
				end
				client:triggerEvent("gasStationUpdate", 10, 10)
				shop:giveMoney(5, "Betankung")
			else
				client:sendError(_("Dein Tank ist bereits voll", client))
			end
		else
			if drawFromBank then
				client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto!", client))
			else
				client:sendError(_("Du hast nicht genügend Geld auf der Hand!", client))
			end
		end
	else
		client:sendWarning(_("Nicht-permanente Fahrzeuge können nicht betankt werden!", client))
		return
	end
end

function ShopManager:buyItem(shopId, item, amount)
	if not item then return end
	if not amount then amount = 1 end
	local shop = self:getFromId(shopId)
	if shop.m_Items[item] then
		if ItemManager:getSingleton():getInstance(item) and ItemManager:getSingleton():getInstance(item).canBuy then
			local state, reason = ItemManager:getSingleton():getInstance(item):canBuy(client, item)
			if not state then
				client:sendError(tostring(reason))
				return false
			end
		end

		if client:getMoney() >= shop.m_Items[item]*amount then
			local value
			if item == "Kanne" then
				value = 10
			elseif item == "Mautpass" then
				value = getRealTime().timestamp + 7*24*60*60
			end

			if client:getInventory():giveItem(item, amount, value) then
				client:takeMoney(shop.m_Items[item]*amount, "Item-Einkauf")
				client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, shop.m_Name))
				shop:giveMoney(shop.m_Items[item]*amount, "Kunden-Einkauf")
			else
				--client:sendError(_("Die maximale Anzahl dieses Items beträgt %d!", client, client:getInventory():getMaxItemAmount(item)))
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

function ShopManager:buyClothes(shopId, typeId, clotheId)
	if not typeId then return end
	if not clotheId then return end
	local shop = self:getFromId(shopId)
	local clothesData = CJ_CLOTHES[CJ_CLOTHE_TYPES[typeId]][clotheId]
	if shop then
		if clothesData then
			if client:getMoney() >= clothesData.Price then
				client:removeClothes(typeId)
				if clotheId >= 0 then
					local texture, model = getClothesByTypeIndex(typeId, clotheId)
					client:addClothes(texture, model, typeId)
				end
				client:giveAchievement(23)
				client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, shop.m_Name))
				if clothesData.Price > 0 then
					client:takeMoney(clothesData.Price, "Kleidungs-Kauf")
					shop:giveMoney(clothesData.Price, "Kunden-Einkauf")
				end
			else
				client:sendError(_("Du hast nicht genug Geld dabei!", client))
				return
			end
		else
			client:sendError(_("Internal Error! Clothe not found!", client))
			return
		end
	else
		client:sendError(_("Internal Error! Shop not found!", client))
		return
	end
end

function ShopManager:buyWeapon(shopId, itemType, weaponId, amount)
	if not itemType then return end
	if not weaponId then return end
	local shop = self:getFromId(shopId)
	if shop then
		if MIN_WEAPON_LEVELS[weaponId] <= client:getWeaponLevel() then
			local price
			if itemType == "Weapon" or itemType == "Vest" then
				price = shop.m_Weapons[weaponId]
				amount = 1
			elseif itemType == "Magazine" then
				if not hasPedThisWeaponInSlots(client, weaponId) then
					client:sendError(_("Du hast nicht die passende Waffe für diese Munition!", client))
					return false
				end
				price = shop.m_Magazines[weaponId].price*amount
			end
			if client:getMoney() >= price then
				local weaponAmount = shop.m_Magazines[weaponId] and shop.m_Magazines[weaponId].amount*amount or 1

				if itemType == "Vest" then
					client:setArmor(100)
				else
					client:giveWeapon(weaponId, weaponAmount)
					reloadPedWeapon(client)
				end

				StatisticsLogger:addAmmunationLog(client, "Shop", toJSON({[weaponId] = weaponAmount}), price)
				client:takeMoney(price, "Ammunation-Einkauf")
				shop:giveMoney(price, "Kunden-Einkauf")
			else
				client:sendError(_("Du hast nicht genug Geld dabei!", client))
				return
			end
		else
			client:sendError(_("Dein Waffenlevel ist zu niedrig!",client))
		end
	else
		client:sendError(_("Internal Error! Shop not found!", client))
		return
	end
end

function ShopManager:onTattooSelection(shopId, typeId)
local shop = self:getFromId(shopId)
	if shop then
		shop:onTattoSelection(client, typeId)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
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

function ShopManager:barStartStripper(shopId)
	local shop = self:getFromId(shopId)
	if shop then
		shop:startStripper(client)
	else
		client:sendError(_("Internal Error! Shop not found!", client))
	end
end

function ShopManager:barStopStripper(shopId)
	local shop = self:getFromId(shopId)
	if shop then
		shop:stopStripper(client)
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
		shop.m_Owner:addLog(client, "Kasse", "hat "..toMoneyString(amount).." in die Shop-Kasse gelegt! ("..shop:getName()..")")
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
		shop.m_Owner:addLog(client, "Kasse", "hat "..toMoneyString(amount).." aus der Shop-Kasse genommen! ("..shop:getName()..")")
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

function ShopManager:getPlayerWeapons(player)
	local playerWeapons = {}
	for i=1, 12 do
		if getPedWeapon(player,i) > 0 then
			playerWeapons[getPedWeapon(player,i)] = true
		end
	end
	return playerWeapons
end

function ShopManager:onAmmunationAppOrder(weaponTable)
	if client:getInterior() > 0 or client:getDimension() > 0 or client.m_JailTime > 0 then
		client:sendError(_("Du kannst hier nicht bestellen!",client))
		return
	end

	local totalAmount = 0
	local canBuyWeapons = true
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					totalAmount = totalAmount + AmmuNationInfo[weaponID].Weapon * amount
				elseif typ == "Munition" then
					totalAmount = totalAmount + AmmuNationInfo[weaponID].Magazine.price * amount
				end
				if client:getWeaponLevel() < MIN_WEAPON_LEVELS[weaponID] then
					canBuyWeapons = false
				end
			end
		end
	end
	if canBuyWeapons then
		if client:getBankMoney() >= totalAmount then
			if totalAmount > 0 then
				client:takeBankMoney(totalAmount, "AmmuNation Bestellung")
				StatisticsLogger:getSingleton():addAmmunationLog(client, "Bestellung", toJSON(weaponTable), totalAmount)
				self:createOrder(client, weaponTable)
			else
				client:sendError(_("Du hast keine Artikel im Warenkorb!",client))
			end
		else
			client:sendError(_("Du hast nicht ausreichend Geld auf deinem Bankkonto! (%d$)",client, totalAmount))
		end
	else
		-- Possible Cheat attempt?
		client:sendError(_("An Internal Error occured!", client))
	end
end

function ShopManager:createOrder(player, weaponTable)
	local x, y, z = getElementPosition ( player )
	y = y - 2
	x = x - 2
	local dropObject = createObject ( 2903, x, y, z+6.3+15 )
	moveObject(dropObject, 9000, x, y, z+6.3 )
	setTimer(destroyElement, 10000, 1, dropObject )
	setTimer(function(x, y, z, weaponTable)
		local pickup = createPickup(x, y, z, 3, 1210)
		addEventHandler("onPickupHit", pickup, function(hitElement)
			if hitElement:getType() == "player" and not hitElement:getOccupiedVehicle() then
				self:giveWeaponsFromOrder(hitElement, weaponTable)
				StatisticsLogger:getSingleton():addAmmunationLog(hitElement, "Pickup", toJSON(weaponTable), 0)
				if source and isElement(source) then
					destroyElement(source)
				end
			end
		end)
	end, 10000, 1, x, y, z, weaponTable)

end

function ShopManager:giveWeaponsFromOrder(player, weaponTable)
	local playerWeapons = self:getPlayerWeapons(player)
	outputChatBox("Du hast folgende Waffen und Magazine erhalten:",player,255,255,255)
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				local mag = getWeaponProperty(weaponID, "pro", "maximum_clip_ammo") or 1
				if typ == "Waffe" then
					if weaponID > 0 then
						outputChatBox(amount.." "..WEAPON_NAMES[weaponID],player,255,125,0)
						giveWeapon(player, weaponID, mag)
					else
						outputChatBox("1 Schutzweste",player,255,125,0)
						player:setArmor(100)
					end
				elseif typ == "Munition" then
					playerWeapons = self:getPlayerWeapons(player)
					if playerWeapons[weaponID] then
						giveWeapon(player,weaponID,amount*mag)
						outputChatBox(amount.." "..WEAPON_NAMES[weaponID].." Magazin/e",player,255,125,0)
					else
						outputChatBox("Du hast keine "..WEAPON_NAMES[weaponID].." für ein Magazin!",player,255,0,0)
					end
				end
			end
		end
	end
end
