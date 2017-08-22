-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/PermanentVehicle.lua
-- * PURPOSE: Vehicle class
-- *
-- ****************************************************************************
PermanentVehicle = inherit(Vehicle)

-- This function converts a GroupVehicle into a normal vehicle (User/PermanentVehicle)
function PermanentVehicle.convertVehicle(vehicle, player, Group)
	if #player:getVehicles() >= math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel()) then
		return false -- Apply vehilce limit
	end

	if vehicle:isPermanent() then
		if vehicle:getPositionType() == VehiclePositionType.World then
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local milage = vehicle:getMileage()
			local fuel = vehicle:getFuel()
			local tuningJSON = vehicle.m_Tunings:getJSON() or {}
			local premium = vehicle:isGroupPremiumVehicle()

			-- get Vehicle Trunk
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()

			if vehicle:purge() then
				local vehicle = PermanentVehicle.create(player, model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, trunkId, premium)
				vehicle:setHealth(health)
				vehicle:setMileage(milage)
				vehicle:setFuel(fuel)

				if Group:canVehiclesBeModified() then
					vehicle.m_Tunings = VehicleTuning:new(vehicle, tuningJSON)
				end
				return vehicle:save(), vehicle
			end
		end
	end

	return false
end

function PermanentVehicle.create(owner, model, posX, posY, posZ, rotX, rotY, rotation, trunkId, premium)
	rotation = tonumber(rotation) or 0
	if type(owner) == "userdata" then
		owner = owner:getId()
	end

	if trunkId == 0 or trunkId == nil then
		trunkId = Trunk.create()
	end

	if sql:queryExec("INSERT INTO ??_vehicles (Owner, Model, PosX, PosY, PosZ, RotX, RotY, Rotation, Health, Color, TrunkId, Premium) VALUES(?, ?, ?, ?, ?, ?, ?, ?, 1000, 0, ?, ?)", sql:getPrefix(), owner, model, posX, posY, posZ, rotX, rotY, rotation, trunkId, premium) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, PermanentVehicle, sql:lastInsertId(), owner, nil, 1000, VehiclePositionType.World, nil, nil, trunkId, premium)
		VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function PermanentVehicle:constructor(Id, owner, keys, health, positionType, mileage, fuel, trunkId, premium, tuningJSON)
	self.m_Id = Id
	self.m_Owner = owner
	self.m_Premium = premium and toboolean(premium) or false

	self:setCurrentPositionAsSpawn(positionType)

	setElementData(self, "OwnerName", Account.getNameFromId(owner) or "None") -- Todo: *hide*
	setElementData(self, "OwnerType", "player")
	self.m_Keys = keys or {}
	self.m_PositionType = positionType or VehiclePositionType.World

	if trunkId == 0 or trunkId == nil then
		trunkId = Trunk.create()
	end

	if self.m_PositionType ~= VehiclePositionType.World then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	end

	self.m_Trunk = Trunk.load(trunkId)
	self.m_TrunkId = trunkId

	if health and health <= 300 then
		health = 300
  	end

	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData( "Handbrake",  self.m_HandBrake , true )
	self:setFuel(fuel or 100)
	self:setLocked(true)
	self:setMileage(mileage or 0)
	self.m_Tunings = VehicleTuning:new(self, tuningJSON, true)
	--self:tuneVehicle(color, color2, tunings, texture, horn, neon, special)

	self.m_HasBeenUsed = 0
end

function PermanentVehicle:destructor()

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
  local health = getElementHealth(self)
  if self.m_Trunk then self.m_Trunk:save() end

  return sql:queryExec("UPDATE ??_vehicles SET Owner = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, Rotation = ?, Health = ?, `Keys` = ?, PositionType = ?, TuningsNew = ?, Mileage = ?, Fuel = ?, TrunkId = ? WHERE Id = ?", sql:getPrefix(),
    self.m_Owner, self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, health, toJSON(self.m_Keys), self.m_PositionType, self.m_Tunings:getJSON(), self:getMileage(), self:getFuel(), self.m_TrunkId, self.m_Id)
end

function PermanentVehicle:getId()
  return self.m_Id
end

function PermanentVehicle:isPremiumVehicle()
	return self.m_Premium
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

function PermanentVehicle:respawn(garageOnly)
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
			self:fix()
			setVehicleOverrideLights(self, 1)
			self:setEngineState(false)
			self:setSirensOn(false)
         	local garageSession = owner.m_GarageSession
          	if garageSession then
            	garageSession:addVehicle(self)
          	end

          	owner:sendShortMessage(_("Dein Fahrzeug (%s) wurde in deiner Garage respawnt", owner, self:getName()))
          	return true
        end
      end
    end
  end

  if garageOnly then
	if owner then
		owner:sendShortMessage(_("Du hast keinen Platz in deiner Garage!", owner))
	end
	return false

  	else
		if self:respawnOnSpawnPosition() then
			return true
		else
		-- Respawn at mechanic base
			if vehicleType ~= VehicleType.Boat and vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter then
				CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC):respawnVehicle(self)
				if owner and isElement(owner) then
				owner:sendShortMessage(_("Dein Fahrzeug (%s) wurde in der Mechaniker-Base respawnt", owner, self:getName()))
				end
				return true
			end

			-- Respawn at Harbor
			if vehicleType == VehicleType.Boat or (vehicleType == VehicleType.Plane and self:getModel() == 460) or (vehicleType == VehicleType.Helicopter and self:getModel() == 447) then
				VehicleHarbor:getSingleton():respawnVehicle(self)
				if owner and isElement(owner) then
				owner:sendShortMessage(_("Dein Fahrzeug (%s) wurde im Industrie-Hafen (Logistik-Job) respawnt", owner, self:getName()))
				end
				return true
			end
		end
	end
	return false

end

