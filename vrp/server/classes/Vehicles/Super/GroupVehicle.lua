-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/GroupVehicle.lua
-- *  PURPOSE:     Group Vehicle class
-- *
-- ****************************************************************************
GroupVehicle = inherit(PermanentVehicle)

-- This function converts a normal (User/PermanentVehicle) to an GroupVehicle
function GroupVehicle.convertVehicle(vehicle, Group)
	if vehicle:isPermanent() then
		if vehicle:getPositionType() == VehiclePositionType.World then
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
			-- get Vehicle Trunk
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()

			if vehicle:purge() then
				local vehicle = GroupVehicle.create(Group, model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, milage, fuel, trunkId, tuningJSON, premium, dimension, interior)
				vehicle:setHealth(health)

				return vehicle:save(), vehicle
			end
		end
	end

	return false
end

function GroupVehicle:constructor(Id, Group, health, positionType, mileage, fuel, trunkId, tuningJSON, premium, dimension, interior, forSale, salePrice)
	self.m_Id = Id
	self.m_Group = Group
	self.m_PositionType = positionType or VehiclePositionType.World
	self.m_Premium = premium
	self:setCurrentPositionAsSpawn(self.m_PositionType)

	self.m_Position = self:getPosition()
	self.m_Rotation = self:getRotation()
	setElementData(self, "OwnerName", self.m_Group:getName())
	setElementData(self, "OwnerType", "group")
	setElementData(self, "GroupType", self.m_Group:getType())
	if health and health <= 300 then
		health = 300
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

	if self.m_PositionType ~= VehiclePositionType.World then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
		self.m_Dimesion = dimension
	end

	if self.m_Group.m_Vehicles then
		table.insert(self.m_Group.m_Vehicles, self)
	end

	addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			veh:respawn(true)
		end, 10000, 1, source)
	end)

	-- load trunk
	self.m_Trunk = Trunk.load(trunkId)

	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	self:setHealth(health or 1000)
	self:setFuel(fuel or 100)
	self:setLocked(true)
	self:setMileage(mileage)
	self.m_Dimesion = dimension
	self.m_Interior = interior
	if self.m_Group:canVehiclesBeModified() then
		self.m_Tunings = VehicleTuning:new(self, tuningJSON)
	else
		self.m_Tunings = VehicleTuning:new(self)
	end

	if forSale and forSale == 1 then
		self:setForSale(true, salePrice)
	else
		self:setForSale(false, 0)
	end

	--self:tuneVehicle(color, color2, tunings, texture, horn, neon, special)
end

function GroupVehicle:destructor()

end

function GroupVehicle:getId()
	return self.m_Id
end

function GroupVehicle:getGroup()
  return self.m_Group
end

function GroupVehicle.create(Group, model, posX, posY, posZ, rotX, rotY, rotation, milage, fuel, trunkId, tuningJSON, premium)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_group_vehicles (`Group`, Model, PosX, PosY, PosZ, RotX, RotY, Rotation, Health, TrunkId, TuningsNew, Premium) VALUES(?, ?, ?, ?, ?, ?, ?, ?, 1000, ?, ?, ?)", sql:getPrefix(), Group:getId(), model, posX, posY, posZ, rotX, rotY, rotation, trunkId, tuningJSON, premium) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, GroupVehicle, sql:lastInsertId(), Group, 1000, VehiclePositionType.World, milage, fuel, trunkId, tuningJSON, premium)
    	VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function GroupVehicle:purge()
	if sql:queryExec("DELETE FROM ??_group_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		triggerClientEvent("groupSaleVehiclesDestroyBubble", root, self)
		destroyElement(self)
		return true
	end
	return false
end

function GroupVehicle:save()
	local health = getElementHealth(self)
	if self.m_Trunk then self.m_Trunk:save() end

	return sql:queryExec("UPDATE ??_group_vehicles SET `Group` = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, Rotation = ?, Health = ?, PositionType = ?, Mileage = ?, Fuel = ?, TrunkId = ?, TuningsNew = ?, ForSale = ?, SalePrice = ? WHERE Id = ?", sql:getPrefix(),
   		self.m_Group:getId(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, health, self.m_PositionType, self:getMileage(), self:getFuel(), self.m_Trunk and self.m_Trunk:getId() or 0, self.m_Tunings:getJSON(), self.m_ForSale and 1 or 0, self.m_SalePrice or 0, self.m_Id)
end

function GroupVehicle:isGroupPremiumVehicle()
	return self.m_Premium ~= 0
end

function GroupVehicle:hasKey(player)
  if self:isPermanent() then
    if player:getGroup() == self:getGroup() then
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

function GroupVehicle:respawn(force)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
		self:getGroup():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
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


	self:setEngineState(false)
	self:setPosition(self.m_SpawnPos)
	self:setRotation(self.m_SpawnRot)
	setElementDimension(self, self.m_Dimesion or 0)
	setElementInterior(self, self.m_Interior or 0)
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

	if self.m_Magnet then
		detachElements(self.m_Magnet)
		self.m_Magnet:attach(self, 0, 0, -1.5)

		self.m_MagnetHeight = -1.5
		self.m_MagnetActivated = false
	end

	return true
end

function GroupVehicle:setForSale(sale, price)
	if sale then
		self.m_ForSale = true
		self.m_SalePrice = tonumber(price)
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

function GroupVehicle:buy(player)
	if self.m_ForSale then
		if self.m_SalePrice >= 0 and player:getMoney() >= self.m_SalePrice then
			local group = self:getGroup()
			local price = self.m_SalePrice
			triggerClientEvent("groupSaleVehiclesDestroyBubble", root, self)
			local status, newVeh = PermanentVehicle.convertVehicle(self, player, group)
			if status then
				StatisticsLogger:getSingleton():addVehicleTradeLog(newVeh, player, 0, price, "group")
				player:takeMoney(price, "Firmen-Fahrzeug Kauf")
				group:giveMoney(price, "Firmen-Fahrzeug Verkauf")
				group:sendShortMessage(_("%s hat ein Fahrzeug für %d$ gekauft! (%s)", player, player:getName(), price, newVeh:getName()))
				player:sendInfo(_("Das Fahrzeug ist nun in deinem Besitz!", player))
				group:addLog(player, "Fahrzeugverkauf", "hat das Fahrzeug "..newVeh.getNameFromModel(newVeh:getModel()).." für "..price.." gekauft!")
				removeElementData(newVeh, "forSale")
				removeElementData(newVeh, "forSalePrice")
			else
				player:sendError(_("Es ist ein Fehler aufgetreten!", player))
			end
		else
			player:sendError(_("Du hast nicht genug Geld dabei! (%d$)", player, self.m_SalePrice))
		end
	else
		player:sendError(_("Dieses Fahrzeug steht nicht zum verkauf!", player))
	end
end

function GroupVehicle:onEnter()
	return true -- otherwise last driver will not added
end
