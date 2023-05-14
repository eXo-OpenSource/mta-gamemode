-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HouseManager.lua
-- *  PURPOSE:     House manager class
-- *
-- ****************************************************************************
HouseManager = inherit(Singleton)
HouseManager.Map = {}
addRemoteEvents{"enterHouse", "leaveHouse", "buyHouse", "sellHouse", "rentHouse", "unrentHouse",
"breakHouse","lockHouse",
"houseSetRent", "houseDeposit", "houseWithdraw", "houseRemoveTenant",
"tryRobHouse","playerFindRobableItem","playerRobTryToGiveWanted",
"houseAdminRequestData", "houseAdminChangeInterior", "houseAdminFree",
"houseRingDoor", "houseRequestGUI", "breakHouseDoor", "toggleGarageState", "setHouseForSale",
"buyHouseFromPlayer", "requestHousesForSale", "houseAdminEndSale"
}

local ROB_DELAY = DEBUG and 50 or 1000*60*15

function HouseManager:constructor()
	local st, count = getTickCount(), 0
	self.m_RobPlayers = {}
	self.m_Houses = {}

	local query = sql:queryFetch("SELECT * FROM ??_houses", sql:getPrefix())

	for key, value in pairs(query) do
		self.m_Houses[value["Id"]] = House:new(value["Id"], Vector3(value["x"], value["y"], value["z"]), value["interiorID"], value["keys"], value["owner"], value["price"], value["lockStatus"], value["rentPrice"], value["elements"], value["money"], value["skyscraperID"], value["buyPrice"], value["salePrice"])
		HouseManager.Map[value["Id"]] = self.m_Houses[value["Id"]]
		count = count + 1
	end

	local query = sql:queryFetch("SELECT * FROM ??_garage", sql:getPrefix())
	for key, v in pairs(query) do
		if self.m_Houses[v["HouseId"]] then
			HouseGarage.Map[key] = self.m_Houses[v["HouseId"]]:createGarage(key, v["GarageId"], v["PosX"], v["PosY"], v["PosZ"], v["RotX"], v["RotY"], v["RotZ"])
		end
	end

	addEventHandler("breakHouse",root,bind(self.breakHouse,self))
	addEventHandler("rentHouse",root,bind(self.rentHouse,self))
	addEventHandler("unrentHouse",root,bind(self.unrentHouse,self))
	addEventHandler("buyHouse",root,bind(self.buyHouse,self))
	addEventHandler("sellHouse",root,bind(self.sellHouse,self))
	addEventHandler("enterHouse",root,bind(self.enterHouse,self))
	addEventHandler("leaveHouse",root,bind(self.leaveHouse,self))
	addEventHandler("lockHouse",root,bind(self.lockHouse,self))
	addEventHandler("houseSetRent",root,bind(self.setRent,self))
	addEventHandler("houseDeposit",root,bind(self.deposit,self))
	addEventHandler("houseWithdraw",root,bind(self.withdraw,self))
	addEventHandler("houseRemoveTenant",root,bind(self.removeTenant,self))
	addEventHandler("tryRobHouse",root,bind(self.tryRob,self))
	addEventHandler("breakHouseDoor",root,bind(self.breakDoor,self))
	addEventHandler("houseRingDoor",root,bind(self.ringDoorBell,self))
	addEventHandler("playerFindRobableItem",root,bind(self.onFindRobItem,self))
	addEventHandler("playerRobTryToGiveWanted",root,bind(self.onTryToGiveWanted,self))
	addEventHandler("houseAdminRequestData", root, bind(self.requestAdminData,self))
	addEventHandler("houseAdminChangeInterior", root, bind(self.changeInterior,self))
	addEventHandler("houseAdminFree", root, bind(self.freeByAdmin,self))
	addEventHandler("houseRequestGUI", root, bind(self.Event_requestGUI, self))
	addEventHandler("toggleGarageState", root, bind(self.Event_toggleGarageState, self))
	addEventHandler("setHouseForSale", root, bind(self.Event_setHouseForSale, self))
	addEventHandler("buyHouseFromPlayer", root, bind(self.Event_buyHouseFromPlayer, self))
	addEventHandler("requestHousesForSale", root, bind(self.Event_requestHousesForSale, self))
	addEventHandler("houseAdminEndSale", root, bind(self.Event_endSale, self))
	addCommandHandler("createhouse", bind(self.createNewHouse,self))
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s houses in %sms"):format(count, getTickCount()-st)) end
end

function HouseManager:createNewHouse(player, cmd, ...)
	if select("#",...) < 2 then player:sendMessage("Syntax: interior, price",255,0,0) return false end
	if player:getRank() >= RANK.Administrator then
		local interior, price = ...
		interior, price = tonumber(interior), tonumber(price)
		if interior and price and HOUSE_INTERIOR_TABLE[interior] then
			local pos = player:getPosition()
			self:newHouse(pos, interior, price)
		end
	end
end

function HouseManager:Event_toggleGarageState()
	for i, v in pairs(HouseGarage.Map) do
		local house = self.m_Houses[v.m_HouseId]
		if getDistanceBetweenPoints3D(v.m_GaragePosition, client:getPosition()) <= 10 then
			if house:isTenant(client:getId()) or house:getOwner() == client:getId() then
				HouseGarage.Map[i]:toggleGarage()
				break
			end
		end
	end
end

function HouseManager:addCharacterToRoblist(player)
	self.m_RobPlayers[player:getId()] = true
	setTimer ( function (id) self.m_RobPlayers[id] = nil end, ROB_DELAY, 1, player:getId() )
end

function HouseManager:isCharacterAllowedToRob (player)
	return self.m_RobPlayers[player:getId()] == nil and true or false
end

function HouseManager:lockHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:toggleLockState(client)
end

function HouseManager:setRent(rent)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:setRent(client, rent)
end

function HouseManager:deposit(amount)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:deposit(client, amount)
end

function HouseManager:withdraw(amount)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:withdraw(client, amount)
end

function HouseManager:removeTenant(id)
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:removeTenant(client, id)
end

function HouseManager:breakHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:breakHouse(client)
end

function HouseManager:enterHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:enterHouseTry(client)
end

function HouseManager:leaveHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:leaveHouse(client)
end

function HouseManager:ringDoorBell()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:ringDoorBell(client)
end

function HouseManager:tryRob()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:tryRob(client)
end

function HouseManager:onFindRobItem()
	if not client then return end
	if client.vehicle then return end
	if not client.m_CurrentHouse then return end
	client.m_CurrentHouse:giveRobItem(client)
end

function HouseManager:onTryToGiveWanted()
	if not client then return end
	if client.vehicle then return end
	if not client.m_CurrentHouse then return end
	client.m_CurrentHouse:tryToCatchRobbers(client)
end

function HouseManager:breakDoor()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:breakDoor(client)
end

function HouseManager:requestAdminData()
	if client:getRank() < ADMIN_RANK_PERMISSION.editHouseInterior then return end
	client:triggerEvent("getAdminHouseData", self.m_Houses[client.visitingHouse].m_InteriorID)
end

function HouseManager:changeInterior(interior)
	if client:getRank() < ADMIN_RANK_PERMISSION.editHouseInterior then return end
	self.m_Houses[client.visitingHouse].m_InteriorID = interior
	self.m_Houses[client.visitingHouse]:refreshInteriorMarker()
	client:sendInfo(_("Du hast den Haus-Interior erfolgreich in ID: %d geändert!", client, interior))
end

function HouseManager:freeByAdmin()
	if client:getRank() < ADMIN_RANK_PERMISSION.freeHouse then return end
	local ownerId = self.m_Houses[client.visitingHouse]:getOwner()
	if ownerId and ownerId > 0 then
		local target, isOffline = DatabasePlayer.get(ownerId)
		if target then
			local msg = ("Dein Haus (Hausnr. %s) wurde von %s enteignet!"):format(self.m_Houses[client.visitingHouse].m_Id, client:getName())
			if isOffline then
				target:addOfflineMessage(msg, 1)

				target.m_DoNotSave = true
				delete(target)
			else
				target:sendWarning(msg)
			end
			self.m_Houses[client.visitingHouse]:clearHouse()
			client:sendSuccess(_("Enteignung erfolgreich!", client))
		end
	else
		client:sendError(_("Dieses Haus hat keinen Eigentümer!", client))
	end
end

function HouseManager:teleportToAdmin(houseId, admin)
	local houseId = tonumber(houseId)
	if isElement(admin) and getElementType(admin) == "player" and houseId then
		if self.m_Houses[houseId] then
			self.m_Houses[houseId]:setPosition(admin:getPosition())
			sql:queryExec("UPDATE ??_houses SET x = ?, y = ?, z = ? WHERE id = ?;", sql:getPrefix(), admin:getPosition().x, admin:getPosition().y, admin:getPosition().z, houseId)
		else
			admin:sendError(_("Kein Haus mit der Nummer %s gefunden.", admin, houseId))
		end
	end
end

function HouseManager:buyHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:buyHouse(client)
	StatisticsLogger:getSingleton():addHouse( client, "BUY", client.visitingHouse)
end

function HouseManager:sellHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:sellHouse(client)
	StatisticsLogger:getSingleton():addHouse( client, "SELL", client.visitingHouse)
end

function HouseManager:rentHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:rentHouse(client)
end

function HouseManager:unrentHouse()
	if not client then return end
	if client.vehicle then return end
	self.m_Houses[client.visitingHouse]:unrentHouse(client)
end

function HouseManager:newHouse(pos, interiorID, price)
	sql:queryExec("INSERT INTO ??_houses (x,y,z,interiorID,`keys`,owner,price,lockStatus,rentPrice,elements) VALUES (?,?,?,?,?,?,?,?,?,?)",
		sql:getPrefix(), pos.x, pos.y, pos.z, interiorID, toJSON({}), 0, price, 0, 25, toJSON({}))

	local Id = sql:lastInsertId()

	self.m_Houses[Id] = House:new(Id, pos, interiorID, toJSON({}), 0, price, 0, 25, toJSON({}))
end

function HouseManager:getPlayerHouse(player)
	local playerId = player:getId()
	for key, house in pairs(self.m_Houses) do
		if house:getOwner() == playerId then
			return house
		end
	end
	return false
end

function HouseManager:getPlayerRentedHouses(player)
	local houses = {}
	local playerId = player:getId()
	for key, house in pairs(self.m_Houses) do
		if house:isTenant(playerId) then
			houses[#houses+1] = house
		end
	end
	return houses
end

function HouseManager:loadBlips(player)
	local house = self:getPlayerHouse(player)
	if house then
		if #house.m_Garage > 0 then
			for i, garage in pairs(house.m_Garage) do
				player:triggerEvent("addGarageBlip", garage.m_Id, garage.m_GaragePosition.x, garage.m_GaragePosition.y)
			end
		end
		player:triggerEvent("addHouseBlip", house.m_Id, house.m_Pos.x, house.m_Pos.y)
	end
	for index, rentHouse in pairs(self:getPlayerRentedHouses(player)) do
		if rentHouse then
			if #rentHouse.m_Garage > 0 then
				for i, garage in pairs(rentHouse.m_Garage) do
					player:triggerEvent("addGarageBlip", garage.m_Id, garage.m_GaragePosition.x, garage.m_GaragePosition.y)
				end
			end
			player:triggerEvent("addHouseBlip", rentHouse.m_Id, rentHouse.m_Pos.x, rentHouse.m_Pos.y)
		end
	end
end

function HouseManager:Event_requestGUI( )
	if client.visitingHouse and client.lastHousePickup and isElement(client.lastHousePickup) then
		if Vector3(client:getPosition() - client.lastHousePickup:getPosition()):getLength() < 5 then
			self.m_Houses[client.visitingHouse]:showGUI(client)
		end
	end
end

function HouseManager:Event_setHouseForSale(forSale, amount, showInTownhall)
	local house = self.m_Houses[client.visitingHouse]
	if not client then return end
	if not house then return end
	if not house:isPlayerNearby(client) then 
		return client:sendError(_("Du bist zu weit entfernt!", client))
	end
	if not tonumber(amount) then
		return client:sendError(_("Ungültiger Preis!", client))
	end
	if house.m_Owner ~= client:getId() then
		return client:sendError(_("Das Haus gehört dir nicht!", client))
	end
	if showInTownhall then
		if not client:transferBankMoney(house.m_BankAccountServer2, 5000, "Gebühr", "House", "ShowInTownhall") then
			return client:sendError(_("Du hast nicht genügend Geld auf der Bank (5.000$)", client))
		end
	end

	amount = tonumber(amount)
	house:setForSale(forSale, amount, showInTownhall)
	house:showGUI(client)
end

function HouseManager:getHousesForSale()
	local housesForSale = {}
	for houseId, instance in pairs(self.m_Houses) do
		if instance:isForSale() then
			housesForSale[houseId] = instance
		end
	end
	return housesForSale
end

function HouseManager:Event_buyHouseFromPlayer()
	local house = self.m_Houses[client.visitingHouse]
	if not client then return end
	if not house:isPlayerNearby(client) then 
		return client:sendError(_("Du bist zu weit entfernt!", client))
	end
	if self:getPlayerHouse(client) then
		return client:sendWarning(_("Du hast bereits ein Haus!", client))
	end
	if not house.m_Owner or house.m_Owner == 0 then
		return client:sendError(_("Das Haus hat keinen Besitzer", client)) 
	end

	local price = house:getSalePrice()
	local forSale = house:isForSale()
	local housePrice = house.m_Price
	if price > 0 and forSale then
		if price + housePrice <= client:getBankMoney() then
			house:sellToPlayer(house.m_Owner, client)
		else
			return client:sendError(_("Du hast nicht genug Geld auf der Bank. (%s)", client, toMoneyString(housePrice + price)))
		end
	else
		return client:sendError(_("Das Haus steht nicht zum Verkauf!", client))
	end
end

function HouseManager:Event_requestHousesForSale()
	local temp = {}
	for houseId, instance in pairs(self:getHousesForSale()) do
		if instance.m_ShowSaleInTownhall then
			local ownerName = Account.getNameFromId(instance:getOwner())
			local pos = instance:getPosition()
			local zoneName = getZoneName(pos)
			local garageCount = instance:getGarageCount()
			local housePrice = instance.m_Price
			local salePrice = instance:getSalePrice()
			temp[houseId] = {["OwnerName"] = ownerName, ["ZoneName"] = zoneName, ["GarageCount"] = garageCount, ["HousePrice"] = housePrice, ["SalePrice"] = salePrice, ["Position"] = serialiseVector(pos)}
		end
	end
	client:triggerEvent("sendHousesForSale", temp)
end

function HouseManager:Event_endSale()
	if client:getRank() >= ADMIN_RANK_PERMISSION["endHouseSale"] then
		local house = self.m_Houses[client.visitingHouse]
		if house:isForSale() then
			house:setForSale(false, false)
			house:showGUI(client)
		end
	end
end

function HouseManager:destructor()
	for key, house in pairs(self.m_Houses) do
		house:save()
	end
end