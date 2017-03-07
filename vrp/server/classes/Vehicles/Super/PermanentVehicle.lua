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
	if vehicle:isPermanent() then
		if vehicle:getPositionType() == VehiclePositionType.World then
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local milage = vehicle:getMileage()
			local r, g, b = getVehicleColor(vehicle, true)
			local tunings = false
			local texture = false
			if Group:canVehiclesBeModified() then
				texture = vehicle:getTexture() -- get texture replace instance
				tunings = getVehicleUpgrades(vehicle) or {}
			end

			-- get Vehicle Trunk
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()
			trunk = nil

			if vehicle:purge() then
				local vehicle = PermanentVehicle.create(player, model, position.x, position.y, position.z, rotation.z, trunkId)
				vehicle:setHealth(health)
				vehicle:setColor(r, g, b)
				vehicle:setMileage(milage)
				if Group:canVehiclesBeModified() then
					if texture and instanceof(texture, VehicleTexture) then
						vehicle:setTexture(texture:getPath(), texture:getTexturePath(), true)
					end

					for k, v in pairs(tunings or {}) do
						addVehicleUpgrade(vehicle, v)
					end
				end
				return vehicle:save(), vehicle
			end
		end
	end

	return false
end

function PermanentVehicle:constructor(Id, owner, keys, color, color2, health, positionType, tunings, mileage, fuel, lightColor, trunkId, texture, horn, neon, special, premium)
	self.m_Id = Id
	self.m_Owner = owner
	self.m_Premium = premium and toboolean(premium) or false

	self:setCurrentPositionAsSpawn(positionType)

	setElementData(self, "OwnerName", Account.getNameFromId(owner) or "None") -- Todo: *hide*
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
	self:setMileage(mileage)
	self:tuneVehicle(color, color2, tunings, texture, horn, neon, special)
end

function PermanentVehicle:destructor()

end

function PermanentVehicle.create(owner, model, posX, posY, posZ, rotation, trunkId)
  rotation = tonumber(rotation) or 0
  if type(owner) == "userdata" then
    owner = owner:getId()
  end
  if sql:queryExec("INSERT INTO ??_vehicles (Owner, Model, PosX, PosY, PosZ, Rotation, Health, Color, TrunkId) VALUES(?, ?, ?, ?, ?, ?, 1000, 0, ?)", sql:getPrefix(), owner, model, posX, posY, posZ, rotation, trunkId) then
    local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
    enew(vehicle, PermanentVehicle, sql:lastInsertId(), owner, {}, nil, nil, 1000, VehiclePositionType.World, nil, nil, nil, nil, trunkId)
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
  local health = getElementHealth(self)
  local r, g, b, r2, g2, b2 = getVehicleColor(self, true)
  local color = setBytesInInt32(255, r, g, b) -- Format: argb
  local color2 = setBytesInInt32(255, r2, g2, b2) -- Format: argb
  local rLight, gLight, bLight = getVehicleHeadLightColor(self)
  local lightColor = setBytesInInt32(255, rLight, gLight, bLight)
  local tunings = getVehicleUpgrades(self) or {}
  local texture = ""
  if self.m_Texture and self.m_Texture:getPath() then
  		texture = self.m_Texture:getPath()
  end

  if self.m_Trunk then self.m_Trunk:save() end
  return sql:queryExec("UPDATE ??_vehicles SET Owner = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, Color2 = ?, `Keys` = ?, PositionType = ?, Tunings = ?, Mileage = ?, Fuel = ?, LightColor = ?, TrunkId = ?, TexturePath = ?, Horn = ?, Neon = ?, Special = ? WHERE Id = ?", sql:getPrefix(),
    self.m_Owner, self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot, health, color, color2, toJSON(self.m_Keys), self.m_PositionType, toJSON(tunings), self:getMileage(), self:getFuel(), lightColor, self.m_TrunkId, texture, self.m_CustomHorn, toJSON(self.m_Neon) or 0, self.m_Special or 0, self.m_Id)
end

function PermanentVehicle:getId()
  return self.m_Id
end

function PermanentVehicle:setSpecial(special)
  self.m_Special = special
  self:setData("Special", special, true)
  if special == VehicleSpecial.Soundvan then
    if self:getModel() == 535 then
      self.speakers = {}
      self.speakers["Left"] = createObject(2229, 0, 0, 0)
      self.speakers["Right"] = createObject(2229, 0, 0, 0)
      self.speakers["Middle"] = createObject(1841, 0, 0, 0)
      self.speakers["Middle"]:setScale(1.5)

      self.speakers["Left"]:attach(self, -0.3, -1.5, 0, -55, 0, 0)
      self.speakers["Right"]:attach(self, 1, -1.5, 0, -55, 0, 0)
      self.speakers["Middle"]:attach(self, 0, -0.8, 0.4, 0, 0, 90)

      for index, element in pairs(self.speakers) do
        element:setCollisionsEnabled(false)
      end

      local refreshSpeaker = function()
        for index, element in pairs(self.speakers) do
          if isElement(self) then
            element:setDimension(self:getDimension())
            element:setInterior(self:getInterior())
            if self.m_SoundURL then
              triggerClientEvent("soundvanChangeURLClient", source, self.m_SoundURL)
            end
          else
            element:destroy()
            if self.m_SoundURL then
              triggerClientEvent("soundvanStopSoundClient", self, url)
            end
          end
        end
      end

      refreshSpeaker()

      addEventHandler("onElementDimensionChange", self, refreshSpeaker)
      addEventHandler("onElementInteriorChange", self, refreshSpeaker)
      addEventHandler("onVehicleExplode", self, refreshSpeaker)
      addEventHandler("onVehicleRespawn", self, refreshSpeaker)
      addEventHandler("onElementDestroy", self, refreshSpeaker)
    end
  end
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
			fixVehicle(self)
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

