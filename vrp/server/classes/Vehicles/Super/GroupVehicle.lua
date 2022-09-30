-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/GroupVehicle.lua
-- *  PURPOSE:     Group Vehicle class
-- *
-- ****************************************************************************
GroupVehicle = inherit(PermanentVehicle)

-- This function converts a normal (User/PermanentVehicle) to an GroupVehicle
function GroupVehicle.convertVehicle(vehicle, group)

	-- don't convert them if they have occupants or are currently towed
	if (vehicle:getOccupants() and table.size(vehicle:getOccupants()) > 0) or vehicle.towingVehicle or vehicle:getData("towedByVehicle") or (vehicle.m_SeatExtensionPassengers and #vehicle.m_SeatExtensionPassengers ~= 0) then
		return false
	end

	if vehicle:isPermanent() then
		if vehicle:getPositionType() == VehiclePositionType.World then
			local id = vehicle:getId()
			local premium = vehicle.m_Premium and vehicle.m_Owner or 0

			sql:queryExec("UPDATE ??_vehicles SET SalePrice = 0, RentPrice = 0, Premium = ? WHERE Id = ?", sql:getPrefix(), premium, id)

			VehicleManager:getSingleton():removeRef(vehicle)
			vehicle.m_Owner = group:getId()
			vehicle.m_OwnerType = VehicleTypes.Group

			vehicle:save()
			destroyElement(vehicle)
			local veh = VehicleManager:getSingleton():createVehicle(id)

			return true, veh
			--[[
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local milage = vehicle:getMileage()
			local fuel = vehicle:getFuel()
			local tuningJSON = vehicle.m_Tunings:getJSON()
			local premium = vehicle:isPremiumVehicle() and vehicle:getOwner() or 0
			local dimension = 0
			local interior = 0
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()

			if vehicle:purge() then
				local vehicle = GroupVehicle.create(Group, model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, milage, fuel, trunkId, tuningJSON, premium, dimension, interior)
				vehicle:setHealth(health)

				return vehicle:save(), vehicle
			end]]
		end
	end

	return false
end

function GroupVehicle:constructor(data)
	self.m_Group = GroupManager:getFromId(data.OwnerId)
	setElementData(self, "OwnerName", self.m_Group:getName())
	setElementData(self, "OwnerType", "group")
	setElementData(self, "GroupType", self.m_Group:getType())

	if self.m_Group.m_Vehicles then
		table.insert(self.m_Group.m_Vehicles, self)
	end

	self.m_IsRented = false

	if data.SalePrice > 0 then
		self:setForSale(true, data.SalePrice)
	else
		self:setForSale(false, 0)
	end

	if data.RentPrice > 0 then
		self:setForRent(true, data.RentPrice)
	else
		self:setForRent(false)
	end

	addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			if isElement(veh) then
				veh:respawn(true)
			end
		end, 10000, 1, source)
	end)
	--[[
	self.m_Position = self:getPosition()
	self.m_Rotation = self:getRotation()
	]]
end

function GroupVehicle:destructor()

end

function GroupVehicle:getId()
	return self.m_Id
end

function GroupVehicle:getGroup()
  return self.m_Group
end
--[[
function GroupVehicle.create(Group, model, posX, posY, posZ, rotX, rotY, rotZ, milage, fuel, trunkId, tuningJSON, premium)
	if sql:queryExec("INSERT INTO ??_vehicles (OwnerId, OwnerType, Model, PosX, PosY, PosZ, RotX, RotY, RotZ, TrunkId, Tunings, Premium) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", sql:getPrefix(), Group:getId(), VehicleTypes.Group, model, posX, posY, posZ, rotX, rotY, rotZ, trunkId, tuningJSON, premium) then
		return VehicleManager:getSingleton():createVehicle(sql:lastInsertId())
	end
	return false
end]]

function GroupVehicle:purge()
	if sql:queryExec("UPDATE ??_vehicles SET Deleted = NOW() WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		triggerClientEvent("groupSaleVehiclesDestroyBubble", root, self)
		triggerClientEvent("groupRentVehiclesDestroyBubble", root, self)
		destroyElement(self)
		return true
	end
	return false
end

--[[ -> use save function of PermanentVehicle
function GroupVehicle:save()
	local health = getElementHealth(self)
	if self.m_Trunk then self.m_Trunk:save() end

	return sql:queryExec("UPDATE ??_vehicles SET `Group` = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, RotT = ?, Health = ?, PositionType = ?, Mileage = ?, Fuel = ?, TrunkId = ?, TuningsNew = ?, ForSale = ?, SalePrice = ? WHERE Id = ?", sql:getPrefix(),
   		self.m_Group:getId(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, health, self.m_PositionType, self:getMileage(), self:getFuel(), self.m_Trunk and self.m_Trunk:getId() or 0, self.m_Tunings:getJSON(), self.m_ForSale and 1 or 0, self.m_SalePrice or 0, self.m_Id)
end
]]

function GroupVehicle:isGroupPremiumVehicle()
	return self:isPremiumVehicle()
end

function GroupVehicle:hasKey(player)
	if self:isPermanent() then
    	if player:getGroup() == self:getGroup() then
    		return true
		end

		if self.m_RentedBy == player:getId() then
			return true
		end
	end

	return false
end

function GroupVehicle:addKey(player)
	return false
end

function GroupVehicle:removeKey(player)
	return false
end

function GroupVehicle:canBeModified()
  return self:getGroup():canVehiclesBeModified()
end

function GroupVehicle:respawn(force, suppressMessage)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
		self:getGroup():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end

	if self.m_RespawnHook:call(self) then
		return false
	end

	-- Teleport to Spawnlocation
	self.m_LastUseTime = math.huge

	if self:getOccupants() then
		if table.size(self:getOccupants()) > 0 then
			return false
		end
	else -- Trailers don't have occupants and will return false. If the trailer is towed by a vehicle do not respawn the trailer
		if self.towingVehicle and table.size(self.towingVehicle:getOccupants()) > 0 then
			return false
		end
	end

	if self:hasSeatExtension() then
		self:vseRemoveAttachedPlayers()
	end

	if self.m_RcVehicleUser then
		for i, player in pairs(self.m_RcVehicleUser) do
			self:toggleRC(player, player:getData("RcVehicle"), false, true)
			player:removeFromVehicle()
		end
	end

	self:setEngineState(false)
	self:setPosition(self.m_SpawnPos)
	self:setRotation(self.m_SpawnRot)
	setElementDimension(self, self.m_SpawnDim or 0)
	setElementInterior(self, self.m_SpawnInt or 0)
	setVehicleOverrideLights(self, 1)
	self:setSirensOn(false)
	self:setFrozen(true)
	self:toggleELS(false)
	self:toggleDI(false)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	self:resetIndicator()
	self:fix()
	self:setForSale(self.m_ForSale, self.m_SalePrice)
	if not suppressMessage then
		if not force then
			self:getGroup():sendShortMessage("Euer Fahrzeug ["..self.getNameFromModel(self:getModel()).."] wurde respawnt!")
		else
			self:getGroup():sendShortMessage("Euer Fahrzeug ["..self.getNameFromModel(self:getModel()).."] wurde respawnt (administrativ)!")
		end
	end
	if self.m_Magnet then
		detachElements(self.m_Magnet)
		self.m_Magnet:attach(self, 0, 0, -1.5)

		self.m_MagnetHeight = -1.5
		self.m_MagnetActivated = false
	end

	return true
end

function GroupVehicle:isForSale()
	return self.m_ForSale
end

function GroupVehicle:setForSale(sale, price)
	if sale then
		self.m_ForSale = true
		self.m_SalePrice = tonumber(price)
		self.m_HandBrake = true
		self:setData("Handbrake", true, true)
		self.m_DisableToggleEngine = true
		self.m_DisableToggleHandbrake = true
		self:setFrozen(true)
	else
		self.m_ForSale = false
		self.m_SalePrice = 0
		self.m_DisableToggleEngine = false
		self.m_DisableToggleHandbrake = false
	end
	setElementData(self, "forSale", self.m_ForSale, true)
	setElementData(self, "forSalePrice", tonumber(self.m_SalePrice), true)
end

function GroupVehicle:setForRent(state, rate)
	if state then
		self.m_ForRent = true
		self.m_RentRate = tonumber(rate)
		self.m_HandBrake = true
		self:setData("Handbrake", true, true)
		self.m_DisableToggleEngine = true
		self.m_DisableToggleHandbrake = true
		self:setFrozen(true)
	else
		self.m_ForRent = false
		self.m_RentRate = 0
		self.m_DisableToggleEngine = false
		self.m_DisableToggleHandbrake = false
	end
	setElementData(self, "forRent", self.m_ForRent, true)
	setElementData(self, "forRentRate", tonumber(self.m_RentRate), true)
end

function GroupVehicle:getVehicleTaxForGroup() -- some vehicles may not need taxation in groups, but if owned private
	if self:isGroupPremiumVehicle() then return 0 end
	if self:isForSale() and self:getSalePrice() <= 500000 then return 0 end
	if self:getPositionType() == VehiclePositionType.Mechanic then
		return math.floor(self:getTax() / 2), true
	end
	return self:getTax()
end

function GroupVehicle:getSalePrice()
	return self.m_SalePrice
end

function GroupVehicle:buy(player)
	if self.m_IsRented then
		player:sendInfo(_("Es ist ein Fehler aufgetreten!", player))
		return
	end

	if self.m_ForSale then
		if self.m_SalePrice >= 0 and player:getBankMoney() >= self.m_SalePrice then
			if #player:getVehicles() < math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel()) then
				local group = self:getGroup()
				local price = self.m_SalePrice
				if player:transferBankMoney(group, price, "Firmen-Fahrzeug Kauf", "Group", "VehicleSell") then
					triggerClientEvent("groupSaleVehiclesDestroyBubble", root, self)
					local status, newVeh = PermanentVehicle.convertVehicle(self, player, group)
					StatisticsLogger:getSingleton():addVehicleTradeLog(newVeh, player, 0, price, "group")
					group:sendShortMessage(_("%s hat ein Fahrzeug für %d$ gekauft! (%s)", player, player:getName(), price, newVeh:getName()))
					player:sendInfo(_("Das Fahrzeug ist nun in deinem Besitz!", player))
					group:addLog(player, "Fahrzeugverkauf", "hat das Fahrzeug "..newVeh.getNameFromModel(newVeh:getModel()).." für "..price.." gekauft!")
					removeElementData(newVeh, "forSale")
					removeElementData(newVeh, "forSalePrice")
				else
					player:sendError(_("Es ist ein Fehler aufgetreten!", player))
				end
			else
				player:sendError(_("Du hast keinen freien Fahrzeug-Slot! Erhöhe dein Fahrzeuglevel! (%d/%d)", player, #player:getVehicles(), math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel())))
			end
		else
			player:sendError(_("Du hast nicht genug Geld dabei! (%d$)", player, self.m_SalePrice))
		end
	else
		player:sendError(_("Dieses Fahrzeug steht nicht zum verkauf!", player))
	end
end

function GroupVehicle:rent(player, duration)
	if self.m_IsRented then
		player:sendInfo(_("Es ist ein Fehler aufgetreten!", player))
		return
	end

	local duration = math.ceil(duration)
	local currentHour = getRealTime().hour
	local endHour = currentHour + duration
	if endHour >= 24 then
		endHour = endHour - 24
		if endHour > 5 then
			duration = duration - (endHour - 5)
		end
	end

	if duration == 0 or duration > 24 then
		player:sendInfo(_("Ungültige Dauer!", player))
		return
	end

	if self.m_ForRent and self.m_RentRate >= 0 then
		local rental = self.m_RentRate * duration
		if player:getBankMoney() >= rental + 1000 then
			local group = self:getGroup()

			if player:transferBankMoney(group, rental, "Firmen-Fahrzeug Vermietung", "Group", "VehicleRent") then
				player:transferBankMoney(BankServer.get("group.deposit"), 1000, "Firmen-Fahrzeug Vermietung: Kaution", "Group", "VehicleDeposit")
				self:setForRent(false)

				self.m_IsRented = true
				self.m_RentedBy = player:getId()
				self.m_RentedByName = player:getName()
				self.m_RentedSince = getRealTime().timestamp
				self.m_RentedUntil = getRealTime().timestamp + duration * 60 * 60
				self.m_RentedFuel = self:getFuel()

				setElementData(self, "isRented", self.m_IsRented, true)
				setElementData(self, "rentedBy", self.m_RentedBy, true)
				setElementData(self, "rentedByName", self.m_RentedByName, true)
				setElementData(self, "rentedSince", self.m_RentedSince, true)
				setElementData(self, "rentedUntil", self.m_RentedUntil, true)

				group:sendShortMessage(_("%s hat ein Fahrzeug für %d$ gemietet! (%s)", player, player:getName(), rental, self:getName()))
				group:addLog(player, "Fahrzeugverleih", "hat das Fahrzeug "..self.getNameFromModel(self:getModel()).." für "..rental.." gemietet!")
				player:sendInfo(_("Das Fahrzeug erfolgreich gemietet!", player))
				GroupManager:getSingleton():addRentedVehicle(self)
				StatisticsLogger:getSingleton():addVehicleRentLog(group:getId(), player:getId(), self:getId(), rental, duration)
			else
				player:sendError(_("Es ist ein Fehler aufgetreten!", player))
			end
		else
			player:sendError(_("Du hast nicht genug Geld! (%d$)", player, rental))
		end
	else
		player:sendError(_("Dieses Fahrzeug kann nicht gemietet werden!", player))
	end
end

function GroupVehicle:rentEnd()
	if self.m_IsRented then
		local player = DatabasePlayer.Map[self.m_RentedBy]
		if player and isElement(player) then
			outputChatBox(_("Die Mietzeit deines gemieteten Fahrzeuges ist nun vorbei.", player), player, 244, 182, 66)
		end

		local deposit = 1000

		if self:getPositionType() == VehiclePositionType.Mechanic then
			deposit = deposit - 500
			BankServer.get("group.deposit"):transferMoney(CompanyManager.Map[2], 500, "Fahrzeug freigekauft", "Company", "VehicleFreeBought")
			self:getPositionType(VehiclePositionType.World)
		end

		if self:getFuelType() ~= "nofuel" then
			local currentFuel = self:getFuel()
			if currentFuel < self.m_RentedFuel then
				local needFuel = self.m_RentedFuel - currentFuel
				local price = (GasStationManager.Shops["Idlewood"].m_FuelTypePrices[self:getFuelType()] or 1)
				local tankSize = self:getFuelTankSize()
				local opticalFuelRequired = tankSize * needFuel
				local maxFuelWithMoney = deposit / price

				if opticalFuelRequired > maxFuelWithMoney then
					deposit = 0
					self:setFuel(self:getFuel() + maxFuelWithMoney / tankSize)
				else
					deposit = math.floor(deposit - opticalFuelRequired * price)
					self:setFuel(self:getFuel() + opticalFuelRequired / tankSize)
				end
			end
		end

		if deposit > 0 then
			BankServer.get("group.deposit"):transferMoney({"player", self.m_RentedBy}, deposit, "Firmen-Fahrzeug Vermietung: Kaution", "Group", "VehicleDeposit")
		end

		removeElementData(self, "isRented")
		removeElementData(self, "rentedBy")
		removeElementData(self, "rentedByName")
		removeElementData(self, "rentedSince")
		removeElementData(self, "rentedUntil")

		self.m_IsRented = false
		self.m_RentedBy = nil
		self.m_RentedByName = nil
		self.m_RentedSince = nil
		self.m_RentedUntil = nil
		self.m_RentedFuel = nil

		for k, player in pairs(self:getOccupants()) do
			player:removeFromVehicle()
		end

		GroupManager:getSingleton():removeRentedVehicle(self)
		self:respawn(true, true)

		if not self:getGroup().m_VehiclesSpawned then
			VehicleManager:getSingleton():destroyGroupVehicles(self:getGroup())
		end
	end
end

function GroupVehicle:sendOwnerMessage(msg)
	self.m_Group:sendShortMessage(msg)
end
