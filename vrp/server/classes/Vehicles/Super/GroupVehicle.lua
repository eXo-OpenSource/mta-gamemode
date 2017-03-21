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
			local r, g, b = getVehicleColor(vehicle, true)
			local tunings = false
			local texture = false

			-- get Vehicle Trunk
			local trunk = vehicle:getTrunk()
			trunk:save()
			local trunkId = trunk:getId()
			trunk = nil

			if Group:canVehiclesBeModified() then
				texture = vehicle:getTexture() -- get texture replace instance
				tunings = getVehicleUpgrades(vehicle) or {}
			end

			if vehicle:purge() then
				local vehicle = GroupVehicle.create(Group, model, position.x, position.y, position.z, rotation.z, trunkId)
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

function GroupVehicle:constructor(Id, Group, color, color2, health, positionType, tunings, mileage, fuel, lightColor, trunkId, texture, horn, neon, special)
	self.m_Id = Id
	self.m_Group = Group
	self.m_PositionType = VehiclePositionType.World
	self:setCurrentPositionAsSpawn(self.m_PositionType)

	self.m_Position = self:getPosition()
	self.m_Rotation = self:getRotation()
	setElementData(self, "OwnerName", self.m_Group:getName())
	setElementData(self, "OwnerType", "group")
	if health and health <= 300 then
		health = 300
	end

	for k, v in pairs(tunings or {}) do
		addVehicleUpgrade(self, v)
	end

	if self.m_PositionType ~= VehiclePositionType.World then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	end

	if self.m_Group.m_Vehicles then
		table.insert(self.m_Group.m_Vehicles, self)
	end

	addEventHandler("onVehicleExplode",self, function()
		setTimer(function(veh)
			veh:setHealth(1000)
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
	--self.m_Tunings = VehicleTuning:new(self, tuningJSON)
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


function GroupVehicle.create(Group, model, posX, posY, posZ, rotation, trunkId)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_group_vehicles (`Group`, Model, PosX, PosY, PosZ, Rotation, Health, Color, TrunkId) VALUES(?, ?, ?, ?, ?, ?, 1000, 0, ?)", sql:getPrefix(), Group:getId(), model, posX, posY, posZ, rotation, trunkId) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, GroupVehicle, sql:lastInsertId(), Group, nil, nil, 1000, VehiclePositionType.World, nil, nil, nil, nil, trunkId)
    	VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function GroupVehicle:purge()
	if sql:queryExec("DELETE FROM ??_group_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end

function GroupVehicle:save()
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
	if self.m_Trunk then
	  self.m_Trunk:save()
	end

	return sql:queryExec("UPDATE ??_group_vehicles SET `Group` = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, Color2 = ?, Tunings = ?, Mileage = ?, Fuel = ?, LightColor = ?, TexturePath = ?, Horn = ?, Neon = ?, TrunkId = ? WHERE Id = ?", sql:getPrefix(),
   		self.m_Group:getId(), self.m_SpawnPos.x, self.m_SpawnPos.y, self.m_SpawnPos.z, self.m_SpawnRot, health, color, color2, toJSON(tunings), self:getMileage(), self:getFuel(), lightColor, texture, self.m_CustomHorn, toJSON(self.m_Neon) or 0, self.m_Trunk:getId(), self.m_Id)
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

	if self:getOccupants() then -- For Trailers
		for _, player in pairs(self:getOccupants()) do
			return false
		end
	end

	self:setEngineState(false)
	self:setPosition(self.m_SpawnPos)
	self:setRotation(0, 0, self.m_SpawnRot)
	setVehicleOverrideLights(self, 1)
	self:setSirensOn(false)
	self:resetIndicator()
	self:fix()

	return true
end
