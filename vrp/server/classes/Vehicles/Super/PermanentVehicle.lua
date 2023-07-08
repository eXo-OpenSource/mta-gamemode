-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/PermanentVehicle.lua
-- * PURPOSE: Vehicle class
-- *
-- ****************************************************************************
PermanentVehicle = inherit(Vehicle)

-- This function converts a GroupVehicle into a normal vehicle (User/PermanentVehicle)
function PermanentVehicle.convertVehicle(vehicle, player, group)
	if #player:getVehicles() >= math.floor(MAX_VEHICLES_PER_LEVEL*player:getVehicleLevel()) then
		return false -- Apply vehilce limit
	end

	-- don't convert them if they have occupants or are currently towed 
	if (vehicle:getOccupants() and table.size(vehicle:getOccupants()) > 0) or vehicle.towingVehicle or vehicle:getData("towedByVehicle") or (vehicle.m_SeatExtensionPassengers and #vehicle.m_SeatExtensionPassengers ~= 0) then
		return false
	end

	if vehicle:isPermanent() then
		if vehicle:getPositionType() == VehiclePositionType.World then
			local id = vehicle:getId()
			local premium = vehicle.m_Premium and 1 or 0

			sql:queryExec("UPDATE ??_vehicles SET SalePrice = 0, RentPrice = 0, Premium = ? WHERE Id = ?", sql:getPrefix(), premium, id)

			VehicleManager:getSingleton():removeRef(vehicle)
			vehicle.m_Owner = player:getId()
			vehicle.m_OwnerType = VehicleTypes.Player

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
			local tuningJSON = vehicle.m_Tunings:getJSON() or {}
			local premium = vehicle:isGroupPremiumVehicle()

			-- get Vehicle Trunk
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()

			if vehicle:purge() then
				local vehicle = VehicleManager:getSingleton():createNewVehicle(player, VehicleTypes.Player, model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, premium)
				vehicle:setHealth(health)
				vehicle:setMileage(milage)
				vehicle:setFuel(fuel)

				if Group:canVehiclesBeModified() then
					vehicle.m_Tunings = VehicleTuning:new(vehicle, tuningJSON)
				end
				return vehicle:save(), vehicle


			end]]
		end
	end

	return false
end

--[[function PermanentVehicle:constructor(data)
	self.m_Id = data.Id
	self.m_Owner = data.OwnerId
	self.m_OwnerType = data.OwnerType
	self.m_Premium = data.Premium ~= 0
	self.m_PremiumId = data.Premium
	self.m_ShopIndex = data.ShopIndex
	self.m_BuyPrice = data.BuyPrice
	self.m_Template = data.TemplateId
	self:setCurrentPositionAsSpawn(data.PositionType)

	setElementData(self, "OwnerName", Account.getNameFromId(data.OwnerId) or "None") -- Todo: *hide*
	setElementData(self, "OwnerID", data.OwnerId) -- Todo: *hide*
	setElementData(self, "OwnerType", VehicleTypeName[self.m_OwnerType])
	setElementData(self, "ID", self.m_Id or -1)
	self:updateTemplate()
	self.m_Keys = data.Keys and fromJSON(data.Keys) or {} -- TODO: check if this works?
	self.m_PositionType = data.PositionType or VehiclePositionType.World

	if data.TrunkId == 0 or data.TrunkId == nil and (self.m_OwnerType == VehicleTypes.Player or self.m_OwnerType == VehicleTypes.Group) then
		data.TrunkId = Trunk.create()
	end

	if self.m_PositionType ~= VehiclePositionType.World then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	end

	if data.TrunkId ~= 0 then
		self.m_Trunk = Trunk.load(data.TrunkId)
		self.m_TrunkId = data.TrunkId
		self.m_Trunk:setVehicle(self)
	end

	if health and health <= 300 then
		health = 300
  end

	if data.ELSPreset and ELS_PRESET[data.ELSPreset] then
		self:setELSPreset(data.ELSPreset)
	end

	if data.Handling and data.Handling ~= "" then
		local handling = getOriginalHandling(getElementModel(self))
		local tHandlingTable = split(data.Handling, ";")
		for k,v in ipairs( tHandlingTable ) do
			local property,faktor = gettok( v, 1, ":"),gettok( v, 2, ":")
			local oldValue = handling[property]
			if oldValue then
				if type( oldValue) == "number" then
					setVehicleHandling(self,property,oldValue*faktor)
				else
					setVehicleHandling(self,property,faktor)
				end
			end
		end
	end

	self:setFrozen(true)
	self.m_HandBrake = true
	self:setData("Handbrake", self.m_HandBrake, true)
	self:setFuel(data.Fuel or 100)
	self:setLocked(true)
	self:setMileage(data.Mileage or 0)
	self.m_Tunings = VehicleTuning:new(self, data.Tunings)
	--self:tuneVehicle(color, color2, tunings, texture, horn, neon, special)

	self.m_HasBeenUsed = 0
	self:setPlateText(("SA " .. ("000000" .. tostring(self.m_Id)):sub(-5)):sub(0,8))
	self.m_SpawnDim = data.Dimension
	self.m_SpawnIn = data.Interior
end]]

function PermanentVehicle:destructor()
	self:save()
end

function PermanentVehicle:virtual_destructor()
	PermanentVehicle.destructor(self)
end

function PermanentVehicle:virtual_constructor(data)
	if data and type(data) == "table" then
		self.m_Id = data.Id
		self.m_Owner = data.OwnerId
		self.m_OwnerType = data.OwnerType
		self.m_Premium = data.Premium ~= 0
		self.m_PremiumId = data.Premium
		self.m_ShopIndex = data.ShopIndex
		self.m_BuyPrice = data.BuyPrice
		self.m_Template = data.TemplateId
		self:setDimension(data.Dimension or 0)
		self:setInterior(data.Interior or 0)
		self:setCurrentPositionAsSpawn(data.PositionType)
		
		if data.LastDriver ~= 0 then
			table.insert(self.m_LastDrivers, Account.getNameFromId(data.LastDriver))
			setElementData(self, "lastDrivers", self.m_LastDrivers)
		end
		
		setElementData(self, "OwnerName", Account.getNameFromId(data.OwnerId) or "None") -- Todo: *hide*
		setElementData(self, "OwnerID", data.OwnerId) -- Todo: *hide*
		setElementData(self, "OwnerType", VehicleTypeName[self.m_OwnerType])
		setElementData(self, "ID", self.m_Id or -1)

		self.m_Keys = data.Keys and fromJSON(data.Keys) or {} -- TODO: check if this works?
		setElementData(self, "VehicleKeys", self.m_Keys)
		self.m_PositionType = data.PositionType or VehiclePositionType.World

		if data.TrunkId == 0 or data.TrunkId == nil and (self.m_OwnerType == VehicleTypes.Player or self.m_OwnerType == VehicleTypes.Group) then
			data.TrunkId = Trunk.create()
		end

		if self.m_PositionType ~= VehiclePositionType.World then
			-- Move to unused dimension | Todo: That's probably a bad solution
			setElementDimension(self, PRIVATE_DIMENSION_SERVER)
		end

		if data.TrunkId ~= 0 then
			self.m_Trunk = Trunk.load(data.TrunkId)
			self.m_TrunkId = data.TrunkId
			self.m_Trunk:setVehicle(self)
		end

		if data.ELSPreset and ELS_PRESET[data.ELSPreset] then
			self:setELSPreset(data.ELSPreset)
		end

		if data.Handling and data.Handling ~= "" then
			local handling = getOriginalHandling(getElementModel(self))
			local tHandlingTable = split(data.Handling, ";")
			for k,v in ipairs( tHandlingTable ) do
				local property,faktor = gettok( v, 1, ":"),gettok( v, 2, ":")
				local oldValue = handling[property]
				if oldValue then
					if type( oldValue) == "number" and property ~= "dragCoeff" then
						setVehicleHandling(self,property,oldValue*faktor)
					else
						setVehicleHandling(self,property,faktor)
					end
				end
			end
		end

		self:setFrozen(true)
		self.m_HandBrake = true
		self:setData("Handbrake", self.m_HandBrake, true)
		self:setFuel(data.Fuel or 100)
		self:setLocked(true)
		self:setMileage(data.Mileage or 0)
		self.m_Tunings = VehicleTuning:new(self, data.Tunings)
		--self:tuneVehicle(color, color2, tunings, texture, horn, neon, special)

		self.m_HasBeenUsed = 0
		self:setPlateText(("SA " .. ("000000" .. tostring(self.m_Id)):sub(-5, -1)):sub(0,8))

		if VEHICLE_MAX_PASSENGER[data.Model] then
			self:initVehicleSeatExtension()
		end
		if data.Model == 459 then
			self:initRcVanExtension()
		end

		self.m_Unregistered = data.Unregistered
	end
end

function PermanentVehicle:purge()
  	if sql:queryExec("UPDATE ??_vehicles SET Deleted = NOW() WHERE Id = ?", sql:getPrefix(), self.m_Id) then
    	VehicleManager:getSingleton():removeRef(self)
    	destroyElement(self)
    	return true
  	end
  	return false
end

function PermanentVehicle:save()
  	local health = getElementHealth(self)
 	local lastDriver = 0
  	if self.m_Trunk then self.m_Trunk:save() end
  	if self.m_LastDrivers[#self.m_LastDrivers] and Account.getIdFromName(self.m_LastDrivers[#self.m_LastDrivers]) then
		lastDriver = Account.getIdFromName(self.m_LastDrivers[#self.m_LastDrivers])
	end
	return sql:queryExec("UPDATE ??_vehicles SET OwnerId = ?, OwnerType = ?, PosX = ?, PosY = ?, PosZ = ?, RotX = ?, RotY = ?, RotZ = ?, Interior=?, Dimension=?, Health = ?, `Keys` = ?, PositionType = ?, Tunings = ?, LastDriver = ?, Mileage = ?, Fuel = ?, TrunkId = ?, SalePrice = ?, RentPrice = ?, TemplateId = ?, Unregistered = ? WHERE Id = ?", sql:getPrefix(),
    self.m_Owner, self.m_OwnerType, self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot.x, self.m_SpawnRot.y, self.m_SpawnRot.z, self.m_SpawnInt, self.m_SpawnDim, health, toJSON(self.m_Keys, true), self.m_PositionType, self.m_Tunings:getJSON(),  lastDriver, self:getMileage(), self:getFuel(), self.m_TrunkId, self.m_SalePrice or 0, self.m_RentRate or 0, self.m_Template or 0, self.m_Unregistered or 0, self.m_Id)
end

function PermanentVehicle:saveAdminChanges() -- add changes to this query for everything that got changed by admins (and isn't saved anywhere else)
	return sql:queryExec("UPDATE ??_vehicles SET Model = ?, BuyPrice = ?, ELSPreset = ? WHERE Id = ?", sql:getPrefix(),
    self:getModel(), self.m_BuyPrice, self.m_ELSPreset, self.m_Id)
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

function PermanentVehicle:getTunings()
	return self.m_Tunings
end

function PermanentVehicle:getShopIndex()
	return self.m_ShopIndex or 1
end

function PermanentVehicle:getBuyPrice()
	if self.m_BuyPrice == -1 then
		return OLD_VEHICLE_PRICES[self:getModel()] or 0
	end
	return self.m_BuyPrice
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
  setElementData(self, "VehicleKeys", self.m_Keys)
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
  setElementData(self, "VehicleKeys", self.m_Keys)
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

  if self.m_RespawnHook:call(self) then
	return false
  end

  -- Add to active garage session if there is one
  local owner = Player.getFromId(self.m_Owner)
  if owner and isElement(owner) then
    -- Is the vehicle allowed to spawn in the garage
    if self:getModel() == 539 or (vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter and vehicleType ~= VehicleType.Boat) then
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

			if self.m_RcVehicleUser then
				for i, player in pairs(self.m_RcVehicleUser) do
					self:toggleRC(player, player:getData("RcVehicle"), false, true)
					player:removeFromVehicle()
				end
			end

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

function PermanentVehicle:sendOwnerMessage(msg)
	local delTarget, isOffline = DatabasePlayer.get(self.m_Owner)
	if delTarget then
		if isOffline then
			delTarget:addOfflineMessage(msg)
			delete(delTarget)
		else
			delTarget:sendInfo(_(msg, client))
		end
	end
end

function PermanentVehicle:isUnregistered()
	return self.m_Unregistered ~= 0
end

function PermanentVehicle:toggleRegister(player)
	if self:isUnregistered() then
		self.m_Unregistered = 0
		self:setPositionType(VehiclePositionType.World)
		self:setDimension(0)
		local x, y, z, rotation = unpack(Randomizer:getRandomTableValue(VehicleSpawnPositionAfterRegister))
		local pickUpText = "Du kannst es hinter der Stadthalle abholen."
		if self:isAirVehicle() and self:getModel() ~= 460 then
			pickUpText = "Du kannst es am Flughafen in Los Santos abholen."
			x, y, z, rotation = 2008.82, -2453.75, 13, 120 -- ls airport east
		elseif self:isWaterVehicle() or self:getModel() == 460 then
			pickUpText = "Du kannst es an den Ocean Docks abholen"
			x, y, z, rotation = 2350.26, -2523.06, 0, 180 -- ls docks
		end
		self:setPosition(x, y, z + self:getBaseHeight())
		self:setRotation(0, 0, rotation)
		player:sendInfo(_("Dein Fahrzeug ist nun wieder angemeldet! \n%s", player, pickUpText))
	else
		self:removeAttachedPlayers()
		self:setPositionType(VehiclePositionType.Unregistered)
		self:setDimension(PRIVATE_DIMENSION_SERVER)
		self:fix()
		self.m_Unregistered = getRealTime().timestamp
	end
end

function PermanentVehicle:hasRadarDetector()
	if self:getTunings().m_Tuning["RadarDetector"] == 1 or self:getTunings().m_Tuning["RadarDetector"] == true then
		return true
	else
		return false
	end
end

function PermanentVehicle:onEnter()
	return true -- otherwise last driver will not added
end