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
		if not vehicle:isInGarage() then
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local r, g, b = getVehicleColor(vehicle, true)
			local tunings = false
			if Group:canVehiclesBeModified() then
				tunings = getVehicleUpgrades(vehicle) or {}
			end

			if vehicle:purge() then
				local vehicle = GroupVehicle.create(Group, model, position.x, position.y, position.z, rotation)
				vehicle:setHealth(health)
				vehicle:setColor(r, g, b)
				if Group:canVehiclesBeModified() then
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

function GroupVehicle:constructor(Id, Group, color, health, posionType, tunings, mileage)
  self.m_Id = Id
  self.m_Group = Group
  self.m_PositionType = positionType or VehiclePositionType.World
  setElementData(self, "OwnerName", self.m_Group:getName())

  self:setHealth(health)
  self:setLocked(true)
  if color then
    local a, r, g, b = getBytesInInt32(color)
    setVehicleColor(self, r, g, b)
  end

  for k, v in pairs(tunings or {}) do
    addVehicleUpgrade(self, v)
  end

  if self.m_PositionType ~= VehiclePositionType.World then
    -- Move to unused dimension | Todo: That's probably a bad solution
    setElementDimension(self, PRIVATE_DIMENSION_SERVER)
  end
  self:setMileage(mileage)

	if self.m_Group.m_Vehicles then
		table.insert(self.m_Group.m_Vehicles, self)
	end
end

function GroupVehicle:destructor()

end

function GroupVehicle:getId()
	return self.m_Id
end

function GroupVehicle:getGroup()
  return self.m_Group
end

function GroupVehicle.create(Group, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_group_vehicles (Group, Model, PosX, PosY, PosZ, Rotation, Health, Color) VALUES(?, ?, ?, ?, ?, ?, 1000, 0)", sql:getPrefix(), Group:getId(), model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, GroupVehicle, sql:lastInsertId(), Group, nil, 1000)
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
	local posX, posY, posZ = getElementPosition(self)
	local rotX, rotY, rotZ = getElementRotation(self)
	local health = getElementHealth(self)
	local r, g, b = getVehicleColor(self, true)
	local color = setBytesInInt32(255, r, g, b) -- Format: argb
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_group_vehicles SET `Group` = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, PositionType = ?, Tunings = ?, Mileage = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Group:getId(), posX, posY, posZ, rotZ, health, color, self.m_PositionType, toJSON(tunings), self:getMileage(), self.m_Id)
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

function GroupVehicle:respawn()
	-- Set inGarage flag and teleport to private dimension
	self.m_LastUseTime = math.huge
end
