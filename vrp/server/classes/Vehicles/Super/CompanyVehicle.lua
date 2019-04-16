-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/CompanyVehicle.lua
-- *  PURPOSE:     Company Vehicle class
-- *
-- ****************************************************************************
CompanyVehicle = inherit(PermanentVehicle)

-- This function converts a normal (User/PermanentVehicle) to an CompanyVehicle
function CompanyVehicle.convertVehicle(vehicle, Company)
	if vehicle:isPermanent() then
		if not vehicle:isInGarage() then
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local r, g, b = getVehicleColor(vehicle, true)
			local tunings = false
			if Company:canVehiclesBeModified() then
				tunings = getVehicleUpgrades(vehicle) or {}
			end

			if vehicle:purge() then
				local vehicle = CompanyVehicle.create(Company, model, position.x, position.y, position.z, rotation)
				vehicle:setHealth(health)
				vehicle:setColor(r, g, b)
				if Company:canVehiclesBeModified() then
					for k, v in pairs(tunings or {}) do
						addVehicleUpgrade(vehicle, v)
					end
				end
				return vehicle:save()
			end
		end
	end

	return false
end

function CompanyVehicle:constructor(data)
	self.m_Company = CompanyManager:getSingleton():getFromId(data.OwnerId)
	setElementData(self, "OwnerName", self.m_Company:getName())
	setElementData(self, "OwnerType", "company")
	
	if self.m_Company.m_Vehicles then
		table.insert(self.m_Company.m_Vehicles, self)
	end

	if self:getModel() == 560 and self:getCompany():getId() == 4 then
		PublicTransport:createTaxiSign(self)
	end

	addEventHandler("onVehicleExplode",self, function()
		setTimer(
			function(veh)
				veh:respawn(true)
			end,
		3000, 1, source)
	end)

	addEventHandler("onVehicleExit",self, bind(self.onExit, self))
	addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
	addEventHandler("onTrailerAttach", self, bind(self.onAttachTrailer, self))

	self:setPlateText((self.m_Company.m_ShorterName .. " " .. ("000000" .. tostring(self.m_Id)):sub(-5)):sub(0,8))

	self:setLocked(false) -- Unlock company vehicles
end

function CompanyVehicle:destructor()

end

function CompanyVehicle:getId()
	return self.m_Id
end

function CompanyVehicle:getCompany()
  return self.m_Company
end

function CompanyVehicle:onStartEnter(player,seat)
	if seat == 0 then
		--[[if (player:getCompany() == self.m_Company) or (self:getCompany():getId() == 1 and player:getPublicSync("inDrivingLession") == true) then
			if not player:isCompanyDuty() and not player:getPublicSync("inDrivingLession") then
				cancelEvent()
				player:sendError(_("Du bist nicht im Dienst!", player))
			end
		else
			cancelEvent()
			player:sendError(_("Du darfst dieses Fahrzeug nicht benutzen!", player))
		end]]
	else
		if self:getCompany():getId() == 4 then
			self:getCompany():onVehicleStartEnter(source, player, seat)
		end
	end
end

function CompanyVehicle:onAttachTrailer(truck)
	if source:getModel() == 591 then
		source:setFrozen(false)
	end
end

function CompanyVehicle:onEnter(player, seat)
	if self:isFrozen() then
		self:setFrozen(false)
	end

	if self:getCompany().onVehicleEnter then
		self:getCompany():onVehicleEnter(source, player, seat)
	end

	return true
end

function CompanyVehicle:onExit(player, seat)
	if self:getCompany():getId() == 4 then
		self:getCompany():onVehiceExit(source, player, seat)
	end
end
--[[
function CompanyVehicle:create(Company, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_company_vehicles (Company, Model, PosX, PosY, PosZ, Rotation, Health) VALUES(?, ?, ?, ?, ?, ?, 1000)", sql:getPrefix(), Company:getId(), model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, CompanyVehicle, sql:lastInsertId(), Company, nil, 1000)
    VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end
]]
function CompanyVehicle:purge()
	if sql:queryExec("UPDATE ??_vehicles SET Deleted = NOW() WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end
--[[
function CompanyVehicle:save()
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_company_vehicles SET Company = ?, Tunings = ?, Fuel = ?, Mileage = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, Rotation = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Company:getId(), toJSON(tunings), self:getFuel(), self:getMileage(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, self.m_Id)
end
]]
function CompanyVehicle:hasKey(player)
  if self:isPermanent() then
    if player:getCompany() == self:getCompany() then
      return true
    elseif self:getCompany():getId() == CompanyStaticId.DRIVINGSCHOOL then
		return player:getPublicSync("inDrivingLession") == true
	end
  end

  return false
end

function CompanyVehicle:addKey(player)
  return false
end

function CompanyVehicle:removeKey(player)
  return false
end

function CompanyVehicle:canBeModified()
  return self:getCompany():canVehiclesBeModified()
end

function CompanyVehicle:respawn(force, ignoreCooldown)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
		self:getCompany():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end

	if not ignoreCooldown then
		if self.m_LastDrivers[#self.m_LastDrivers] then
			local lastDriver = getPlayerFromName(self.m_LastDrivers[#self.m_LastDrivers])
			if lastDriver and (not lastDriver:getCompany() or lastDriver:getCompany() and lastDriver:getCompany() ~= self:getCompany()) then
				if self.m_LastUseTime and getTickCount() - self.m_LastUseTime < 300000 then
					return false
				end
			end
		end
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

	if self:getCompany():getId() == 4 then -- Public Transport
		if self:getCompany():isBusOnTour(self) then
			self:getCompany():stopBusTour(self)
		end
	end

	setVehicleOverrideLights(self, 1)
	self:setEngineState(false)
	self:setTaxiLightOn(false)
	self:toggleELS(false)
	self:toggleDI(false)
	self:setPosition(self.m_SpawnPos)
	self:setRotation(self.m_SpawnRot)
	self:fix()
	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	self:resetIndicator()

	if self.m_Magnet then
		detachElements(self.m_Magnet)
		self.m_Magnet:attach(self, 0, 0, -1.5)

		self.m_MagnetHeight = -1.5
		self.m_MagnetActivated = false
	end

	return true
end

function CompanyVehicle:sendOwnerMessage(msg)
	self:getCompany():sendShortMessage(msg)
end