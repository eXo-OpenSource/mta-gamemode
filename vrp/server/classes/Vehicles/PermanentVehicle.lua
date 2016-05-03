-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermanentVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
PermanentVehicle = inherit(Vehicle)

function PermanentVehicle:constructor(Id, owner, keys, color, health, positionType, tunings, mileage, lightColor, trunkId)
	self.m_Id = Id
	self.m_Owner = owner
	setElementData(self, "OwnerName", Account.getNameFromId(owner) or "None") -- Todo: *hide*
	self.m_Keys = keys or {}
	self.m_PositionType = positionType or VehiclePositionType.World

	if trunkId == 0 then
		trunkId = Trunk.create()
	end

	self.m_Trunk = Trunk.load(trunkId)
	self.m_TrunkId = trunkId

	self:setHealth(health)
	self:setLocked(true)
	if color then
		local a, r, g, b = getBytesInInt32(color)
		setVehicleColor(self, r, g, b)
	end
	if lightColor then
		local a, r, g, b = getBytesInInt32(lightColor)
		setVehicleHeadLightColor(self, r, g, b)
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

	--[[ Todo: Maybe add Custom Tunings
	for i, v in pairs(custom_tunings) do

	end
	]]

	if self.m_PositionType ~= VehiclePositionType.World then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	end
	self:setMileage(mileage)
end

function PermanentVehicle:destructor()

end

function PermanentVehicle.create(owner, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if type(owner) == "userdata" then
		owner = owner:getId()
	end
	if sql:queryExec("INSERT INTO ??_vehicles (Owner, Model, PosX, PosY, PosZ, Rotation, Health, Color) VALUES(?, ?, ?, ?, ?, ?, 1000, 0)", sql:getPrefix(), owner, model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, PermanentVehicle, sql:lastInsertId(), owner, nil, nil, 1000)
		VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function PermanentVehicle:purge()
	if sql:queryExec("DELETE FROM ??_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end

function PermanentVehicle:save()
	local posX, posY, posZ = getElementPosition(self)
	local rotX, rotY, rotZ = getElementRotation(self)
	local health = getElementHealth(self)
	local r, g, b = getVehicleColor(self, true)
	local color = setBytesInInt32(255, r, g, b) -- Format: argb
	local r2, g2, b2 = getVehicleHeadLightColor(self)
	local lightColor = setBytesInInt32(255, r2, g2, b2)
	local tunings = getVehicleUpgrades(self) or {}
	if self.m_Trunk then self.m_Trunk:save() end
	return sql:queryExec("UPDATE ??_vehicles SET Owner = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, `Keys` = ?, PositionType = ?, Tunings = ?, Mileage = ?, LightColor = ?, TrunkId = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Owner, posX, posY, posZ, rotZ, health, color, toJSON(self.m_Keys), self.m_PositionType, toJSON(tunings), self:getMileage(), lightColor, self.m_TrunkId, self.m_Id)
end

function PermanentVehicle:getId()
	return self.m_Id
end

function PermanentVehicle:getTrunk()
	if self.m_Trunk then return self.m_Trunk end
	return false
end

function PermanentVehicle:isPermanent()
	return true
end

function PermanentVehicle:getKeyNameList()
	local names = {}
	for k, v in ipairs(self.m_Keys) do
		local name = Account.getNameFromId(v)
		if name then
			names[v] = name
		end
	end
	return names
end

function PermanentVehicle:addKey(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	table.insert(self.m_Keys, player)
end

function PermanentVehicle:removeKey(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	local index = table.find(self.m_Keys, player)
	if not index then
		return false
	end
	table.remove(self.m_Keys, index)
	return true
end

function PermanentVehicle:isInGarage()
	return self.m_PositionType == VehiclePositionType.Garage
end

function PermanentVehicle:setInGarage(state)
	self.m_PositionType = VehiclePositionType.Garage
end

function PermanentVehicle:isInHangar()
	return self.m_PositionType == VehiclePositionType.Hangar
end

function PermanentVehicle:setInHangar(state)
	self.m_PositionType = VehiclePositionType.Hangar
end

function PermanentVehicle:getPositionType()
	return self.m_PositionType
end

function PermanentVehicle:setPositionType(type)
	self.m_PositionType = type
end

function PermanentVehicle:respawn()
	-- Set inGarage flag and teleport to private dimension
	self.m_LastUseTime = math.huge
	local vehicleType = self:getVehicleType()

	-- Add to active garage session if there is one
	local owner = Player.getFromId(self.m_Owner)
	if owner and isElement(owner) then
		-- Is the vehicle allowed to spawn in the garage
		if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat then
			-- Does the player have a garage
			if owner:getGarageType() > 0 then
				-- Is there a slot available?
				local maxSlots = VehicleGarages:getSingleton():getMaxSlots(owner:getGarageType())
				local playerVehicles = VehicleManager:getSingleton():getPlayerVehicles(owner)
				local numVehiclesInGarage = 0
				for k, v in pairs(playerVehicles) do
					if v:isInGarage() then numVehiclesInGarage = numVehiclesInGarage + 1 end
				end

				if maxSlots > numVehiclesInGarage then
					self:setInGarage(true)
					self:setDimension(PRIVATE_DIMENSION_SERVER)
					fixVehicle(self)

					local garageSession = owner.m_GarageSession
					if garageSession then
						garageSession:addVehicle(self)
					end

					owner:sendShortMessage(_("Dein Fahrzeug (%s) wurde in deiner Garage respawnt", owner, self:getName()))
					return
				end
			end
		end
	end

	-- Respawn at mechanic base
	if vehicleType ~= VehicleType.Boat and vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter then
		CompanyManager:getSingleton():getFromId(2):respawnVehicle(self)
		if owner and isElement(owner) then
			owner:sendShortMessage(_("Dein Fahrzeug (%s) wurde in der Mechaniker-Base respawnt", owner, self:getName()))
		end
		return
	end

	-- Respawn at Harbor
	if vehicleType == VehicleType.Boat or (vehicleType == VehicleType.Plane and self:getModel() == 460) or (vehicleType == VehicleType.Helicopter and self:getModel() == 447) then
		VehicleHarbor:getSingleton():respawnVehicle(self)
		if owner and isElement(owner) then
			owner:sendShortMessage(_("Dein Fahrzeug (%s) wurde im Industrie-Hafen (Logistik-Job) respawnt", owner, self:getName()))
		end
		return
	end
end
