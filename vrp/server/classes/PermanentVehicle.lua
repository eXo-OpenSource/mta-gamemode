-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermanentVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
PermanentVehicle = inherit(Vehicle)

function PermanentVehicle:constructor(Id, owner, keys, color, health, inGarage)
	self.m_Id = Id
	self.m_Owner = owner
	setElementData(self, "OwnerName", Account.getNameFromId(owner) or "None") -- *hide*
	self.m_Keys = keys or {}
	self.m_InGarage = inGarage or false
	
	setElementHealth(self, health)
	setVehicleLocked(self, true)
	if color then
		local a, r, g, b = getBytesInInt32(color)
		setVehicleColor(self, r, g, b)
	end
	
	if self.m_InGarage then
		-- Move to unused dimension | Todo: That's probably a bad solution
		setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	end
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
		enew(vehicle, Vehicle, sql:lastInsertId(), owner, nil, nil, 1000)
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
	
	return sql:queryExec("UPDATE ??_vehicles SET Owner = ?, PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Health = ?, Color = ?, `Keys` = ?, IsInGarage = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Owner, posX, posY, posZ, rotZ, health, color, toJSON(self.m_Keys), self.m_InGarage and 1 or 0, self.m_Id)
end

function PermanentVehicle:getId()
	return self.m_Id
end

function PermanentVehicle:isPermanent()
	return true
end

function PermanentVehicle:isInGarage()
	return self.m_InGarage
end

function PermanentVehicle:setInGarage(state)
	self.m_InGarage = state
end

function PermanentVehicle:respawn()
outputDebug("Respawning...")
	
	-- Todo: Check if slot limit is reached
	-- Set inGarage flag and teleport to private dimension
	self:setInGarage(true)
	fixVehicle(self)
	setElementDimension(self, PRIVATE_DIMENSION_SERVER)
end
