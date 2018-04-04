-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Shop.lua
-- *  PURPOSE:     Shop Super Class
-- *
-- ****************************************************************************
VehicleShop = inherit(Object)

function VehicleShop:constructor(id, name, marker, npc, spawn, image, owner, price, money)
	self.m_Id = id
	self.m_Name = name
	self.m_Image = image
	self.m_BuyAble = price > 0 and true or false
	self.m_OwnerId = owner
	self.m_Money = money
	self.m_BankAccountServer = BankServer.get("server.vehicle_shop")

	self.m_BankAccount = BankAccount.loadByOwner(self.m_Id, BankAccountTypes.VehicleShop)

	if not self.m_BankAccount then
		self.m_BankAccount = BankAccount.create(BankAccountTypes.VehicleShop, self.m_Id)
		self.m_BankAccountServer:transferMoney(self.m_BankAccount, self.m_Money, "Migration", "Shop", "Migration")
		self.m_Money = 0
		self.m_BankAccount:save()
	end

	self.m_VehicleList = {}

	local markerPos = split(marker,",")
	self.m_Marker = createMarker(markerPos[1], markerPos[2], markerPos[3]+0.5, "cylinder", 1, 255, 255, 0, 200)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onMarkerHit, self))

	self.m_Blip = Blip:new("CarShop.png", markerPos[1], markerPos[2],root,400)
	self.m_Blip:setDisplayText("Autohaus", BLIP_CATEGORY.Shop)
	self.m_Blip:setOptionalColor({37, 78, 108})

	local npcData = split(npc,",")
	self.m_Ped = NPC:new(npcData[1], npcData[2], npcData[3], npcData[4], npcData[5] or 0)
	self.m_Ped:setImmortal(true)
	self.m_Ped:setFrozen(true)
	local spawnPos = split(spawn,",")
	self.m_Spawn = {spawnPos[1], spawnPos[2], spawnPos[3], spawnPos[4]}
	self.m_NonCollissionCol = createColSphere(spawnPos[1], spawnPos[2], spawnPos[3], 10)
	self.m_NonCollissionCol:setData("NonCollidingSphere", true, true)

	self.m_Ped:setData("clickable",true,true)
	addEventHandler("onElementClicked", self.m_Ped, function(button, state, player)
		if button =="left" and state == "down" then
			self:onMarkerHit(player, true)
		end
	end)
end

function VehicleShop:getName()
	return self.m_Name
end

function VehicleShop:getVehiclePrice(model)
	if self.m_VehicleList[model] and self.m_VehicleList[model].price then
		return self.m_VehicleList[model].price
	else
		return false
	end
end

function VehicleShop:onMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement.vehicle then hitElement:sendWarning("Bitte steige erst aus dem Fahrzeug aus!") return end

		local vehicles = {}
		for model, vehicleData in pairs(self.m_VehicleList) do
			vehicles[model] = {vehicleData.vehicle, vehicleData.price, vehicleData.level}
		end

		hitElement:triggerEvent("showVehicleShopMenu", self.m_Id, self.m_Name, self.m_Image, vehicles)
	end
end

function VehicleShop:buyVehicle(player, vehicleModel)
	local price, requiredLevel = self.m_VehicleList[vehicleModel].price, self.m_VehicleList[vehicleModel].level
	if not price then return end

	if player:getVehicleLevel() < requiredLevel then
		player:sendError(_("Für dieses Fahrzeug brauchst du min. Fahrzeuglevel %d", player, requiredLevel))
		return
	end

	if player:getMoney() < price then
		player:sendError(_("Du hast nicht genügend Geld!", player))
		return
	end
	if #player:getVehicles() < math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel()) then
		local spawnX, spawnY, spawnZ, rotation = unpack(self.m_Spawn)
		local vehicle = VehicleManager:getSingleton():createNewVehicle(player, VehicleTypes.Player, vehicleModel, spawnX, spawnY, spawnZ, 0, 0, rotation)
		if vehicle then
			player:transferBankMoney(self.m_BankAccount, price, "Fahrzeug-Kauf", "Vehicle", "Sell")

			vehicle:setColor(self.m_VehicleList[vehicleModel].vehicle:getColor(true))
			vehicle.m_Tunings:saveColors()
			vehicle:save()
			setTimer(function(player, vehicle)
				player:warpIntoVehicle(vehicle)
				player:triggerEvent("vehicleBought")
			end, 100, 1, player, vehicle)
		else
			player:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", player), 255, 0, 0)
		end
	else
		player:sendError(_("Du hast keinen freien Fahrzeug-Slot! Erhöhe dein Fahrzeuglevel! (%d/%d)", player, #player:getVehicles(), math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel())))
	end
end

function VehicleShop:getMoney()
	return self.m_BankAccount:getMoney()
end

function VehicleShop:addVehicle(Id, Model, Name, Category, Price, Level, Pos, Rot)
	self.m_VehicleList[Model] = {}
	self.m_VehicleList[Model].price = Price
	self.m_VehicleList[Model].level = Level
	self.m_VehicleList[Model].vehicle = TemporaryVehicle.create(Model, Pos, Rot)

	local veh = self.m_VehicleList[Model].vehicle
	veh.m_DisableToggleEngine = true
	veh.m_DisableToggleHandbrake = true
	veh:setLocked(true)
	veh:setFrozen(true)
	veh:toggleRespawn(false)
	setVehicleDamageProof( veh , true)
end

function VehicleShop:save()

	if self.m_BankAccount:save() then
	else
		outputDebug(("Failed to save Vehicle-Shop '%s' (Id: %d)"):format(self.m_Name, self.m_Id))
	end
end
