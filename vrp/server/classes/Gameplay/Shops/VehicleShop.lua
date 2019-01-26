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
	self.m_NonCollissionCol:setData("NonCollisionArea", {players = true}, true)

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

--[[
function VehicleShop:getVehiclePrice(model, index)
	if self.m_VehicleList[model] and self.m_VehicleList[model][index] and self.m_VehicleList[model][index].price then
		return self.m_VehicleList[model][index].price
	else
		return false
	end
end
--]]

function VehicleShop:onMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement.vehicle then hitElement:sendWarning("Bitte steige erst aus dem Fahrzeug aus!") return end

		local vehicles = {}
		for model, vehicleData in pairs(self.m_VehicleList) do
			if not vehicles[model] then
				vehicles[model] = {}
			end
			for i = 1, #self.m_VehicleList[model] do
				vehicles[model][i] = {vehicleData[i].vehicle, vehicleData[i].price, vehicleData[i].level}
			end
		end
		hitElement:triggerEvent("showVehicleShopMenu", self.m_Id, self.m_Name, self.m_Image, vehicles)
	end
end

function VehicleShop:buyVehicle(player, vehicleModel, index)
	local price, requiredLevel, shopIndex = self.m_VehicleList[vehicleModel][index].price, self.m_VehicleList[vehicleModel][index].level, self.m_VehicleList[vehicleModel][index].id
	local template = self.m_VehicleList[vehicleModel][index].templateId
	if not price then return end

	if player:getVehicleLevel() < requiredLevel then
		player:sendError(_("Für dieses Fahrzeug brauchst du min. Fahrzeuglevel %d", player, requiredLevel))
		return
	end

	if player:getBankMoney() < price then
		player:sendError(_("Du hast nicht genügend Geld!", player))
		return
	end
	if #player:getVehicles() < math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel()) then
		local spawnX, spawnY, spawnZ, rotation = unpack(self.m_Spawn)
		local vehicle = VehicleManager:getSingleton():createNewVehicle(player, VehicleTypes.Player, vehicleModel, spawnX, spawnY, spawnZ, 0, 0, rotation, false, shopIndex, price, template)
		if vehicle then
			if player:transferBankMoney(self.m_BankAccount, price, "Fahrzeug-Kauf", "Vehicle", "Sell") then
				vehicle:setColor(self.m_VehicleList[vehicleModel][index].vehicle:getColor(true))
				vehicle.m_Tunings:saveColors()
				vehicle:save()
				setTimer(function(player, vehicle)
					player:warpIntoVehicle(vehicle)
					player:triggerEvent("vehicleBought")
				end, 100, 1, player, vehicle)
			else
				StatisticsLogger:getSingleton():addVehicleTradeLog(veh, source, 0, price, "server")
				veh:purge()
				VehicleManager:getSingleton().m_BankAccountServer:transferMoney(source, math.floor(price * 0.75), "Fahrzeug-Verkauf", "Vehicle", "SellToServer")
				VehicleManager:getSingleton():Event_vehicleRequestInfo(source)
				player:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin (2)!", player), 255, 0, 0)
			end
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

function VehicleShop:addVehicle(Id, Model, Name, Category, Price, Level, Pos, Rot, TemplateId)
	if not self.m_VehicleList[Model] then
		self.m_VehicleList[Model] = {}
	end
	local index = #self.m_VehicleList[Model]+1
	self.m_VehicleList[Model][index] = {}
	self.m_VehicleList[Model][index].price = Price
	self.m_VehicleList[Model][index].id = Id
	self.m_VehicleList[Model][index].templateId = TemplateId or 0
	self.m_VehicleList[Model][index].template =  TuningTemplateManager:getSingleton():getNameFromId( TemplateId ) or ""
	self.m_VehicleList[Model][index].level = Level
	self.m_VehicleList[Model][index].vehicle = TemporaryVehicle.create(Model, Pos, Rot)

	local veh = self.m_VehicleList[Model][index].vehicle
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

function VehicleShop:setProperty(model, index, property, value, player)
	if self.m_VehicleList[model][index] then
		if property == "model" then
			if self.m_VehicleList[model][index].vehicle and isElement(self.m_VehicleList[model][index].vehicle) then
				self.m_VehicleList[model][index].vehicle:setModel(value)
				self.m_VehicleList[model][index].templateId = 0
				self.m_VehicleList[model][index].template =  ""
			end
		elseif property == "template-add" then
			if TuningTemplateManager:getSingleton():getVehicleFromId( value ) ==  self.m_VehicleList[model][index].vehicle:getModel() then
				self.m_VehicleList[model][index].templateId = value
				self.m_VehicleList[model][index].template =  TuningTemplateManager:getSingleton():getNameFromId( value ) or ""
			else
				player:sendError(_("Die angegebene Vorlage ist nicht kompatibel mit dem Modell oder nicht gefunden worden!", player))
				return
			end
		elseif property == "template-remove" then
			self.m_VehicleList[model][index].templateId = 0
			self.m_VehicleList[model][index].template =  ""
		else
			self.m_VehicleList[model][index][property] = value
		end
		player:sendInfo(_("Das Fahrzeug im Shop %s wurde aktualisiert!", player,  self.m_Name))
		sql:queryExec("UPDATE ??_vehicle_shop_veh SET Price=?, Level=?, Model=?, TemplateId=? WHERE Id = ?", sql:getPrefix(), self.m_VehicleList[model][index].price,
		self.m_VehicleList[model][index].level, self.m_VehicleList[model][index].vehicle:getModel(), self.m_VehicleList[model][index].templateId, self.m_VehicleList[model][index].id)
	end
end
