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

function CompanyVehicle:constructor(Id, company, color, health, positionType, tunings, mileage)
	self.m_Id = Id
	self.m_Company = company
	self.m_PositionType = positionType or VehiclePositionType.World
	self.m_SpawnPos = self:getPosition()
	self.m_SpawnRot = self:getRotation()
	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	setElementData(self, "OwnerName", self.m_Company:getName())
	setElementData(self, "OwnerType", "company")
	if health then
		if health <= 300 then
			self:setHealth(health)
		end
	end
	self:setLocked(false)
	self:setPlateText(self:getPlateText():sub(0,5)..self.m_Id)

	if color and fromJSON(color) then	
		self:setColor(fromJSON(color))
	elseif companyColors[self.m_Company:getId()] then
		local color = companyColors[self.m_Company:getId()]
		self:setColor(color.r, color.g, color.b, color.r, color.g, color.b)
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

	if self.m_PositionType ~= VehiclePositionType.World then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	end
	self:setMileage(mileage)

	if self.m_Company.m_Vehicles then
		table.insert(self.m_Company.m_Vehicles, self)
	end

	addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))
	addEventHandler("onVehicleExit",self, bind(self.onExit, self))
	addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
	addEventHandler("onTrailerAttach", self, bind(self.onAttachTrailer, self))

	addEventHandler("onVehicleExplode",self, function()
		setTimer(
			function(veh)
				veh:respawn(true)
			end,
		3000, 1, source)
	end)

	if self.m_Company.m_VehicleTexture then
		if self.m_Company.m_VehicleTexture[self:getModel()] and self.m_Company.m_VehicleTexture[self:getModel()] then
			local textureData = self.m_Company.m_VehicleTexture[self:getModel()]
			if textureData.shaderEnabled then
				local texturePath, textureName = textureData.texturePath, textureData.textureName
				if texturePath and #texturePath > 3 then
					self:setTexture(texturePath, textureName)
				end
			end
		end
	end
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
		if (player:getCompany() == self.m_Company) or (self:getCompany():getId() == 1 and player:getPublicSync("inDrivingLession") == true) then
			if not player:isCompanyDuty() and not player:getPublicSync("inDrivingLession") then
				cancelEvent()
				player:sendError(_("Du bist nicht im Dienst!", player))
			end
		else
			cancelEvent()
			player:sendError(_("Du darfst dieses Fahrzeug nicht benutzen!", player))
		end
	else
		if self:getCompany():getId() == 4 then
			self:getCompany():onVehiceStartEnter(source, player, seat)
		end
	end
end

function CompanyVehicle:onAttachTrailer(truck)
	if source:getModel() == 591 then
		source:setFrozen(false)
	end
end

function CompanyVehicle:onEnter(player, seat)
	if self:isFrozen() == true then
		self:setFrozen(false)
	end
	if self:getCompany():getId() == 4 then
		self:getCompany():onVehiceEnter(source, player, seat)
	end

end

function CompanyVehicle:onExit(player, seat)
	if self:getCompany():getId() == 4 then
		self:getCompany():onVehiceExit(source, player, seat)
	end
end


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

function CompanyVehicle:purge()
	if sql:queryExec("DELETE FROM ??_company_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end

function CompanyVehicle:save()
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_company_vehicles SET Company = ?, Tunings = ?, Mileage = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, Rotation = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Company:getId(), toJSON(tunings), self:getMileage(),
		self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, self.m_Id)
end

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

function CompanyVehicle:respawn(force)
    local vehicleType = self:getVehicleType()
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat and self:getHealth() <= 310 and not force then
		self:getCompany():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end

	-- Teleport to Spawnlocation
	self.m_LastUseTime = math.huge

	if self:getOccupants() then -- For Trailers
		for _, player in pairs(self:getOccupants()) do
			return false
		end
	end

	setVehicleOverrideLights(self, 1)
	self:setEngineState(false)
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
