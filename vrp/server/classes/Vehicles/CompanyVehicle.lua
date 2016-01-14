-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/CompanyVehicle.lua
-- *  PURPOSE:     Company Vehicle class
-- *
-- ****************************************************************************
CompanyVehicle = inherit(PermanentVehicle)

-- HACK :P
CompanyManager = {}
function CompanyManager.getFromId(Id)
	return {getId = function () return Id end}
end

function CompanyVehicle:constructor(Id, company, color, health, posionType, tunings, mileage)
  self.m_Id = Id
  self.m_Company = company
  self.m_PositionType = positionType or VehiclePositionType.World
  setElementData(self, "OwnerName", "asdh") -- Todo: *hide*

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
end

function CompanyVehicle:destructor()

end

function CompanyVehicle:getId()
	return self.m_Id
end

function CompanyVehicle:getCompany()
  return self.m_Company
end

function CompanyVehicle.create(Company, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_company_vehicles (Company, Model, PosX, PosY, PosZ, Rotation, Health, Color) VALUES(?, ?, ?, ?, ?, ?, 1000, 0)", sql:getPrefix(), Company:getId(), model, posX, posY, posZ, rotation) then
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
	local posX, posY, posZ = getElementPosition(self)
	local rotX, rotY, rotZ = getElementRotation(self)
	local health = getElementHealth(self)
	local r, g, b = getVehicleColor(self, true)
	local color = setBytesInInt32(255, r, g, b) -- Format: argb
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_company_vehicles SET Company = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, PositionType = ?, Tunings = ?, Mileage = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Company:getId(), posX, posY, posZ, rotZ, health, color, self.m_PositionType, toJSON(tunings), self:getMileage(), self.m_Id)
end

function CompanyVehicle:hasKey(player)
  if self:isPermanent() then
    --if player:getCompany() == self.m_Company then
    --  return true
    --end
  end

  --return false
  return true
end

function CompanyVehicle:addKey(player)
  return false
end

function CompanyVehicle:removeKey(player)
  return false
end

function CompanyVehicle:canBeModified()
  --return self:getCompany():canVehiclesBeModified()
  return false
end

function CompanyVehicle:respawn()
	-- Set inGarage flag and teleport to private dimension
	self.m_LastUseTime = math.huge
end
