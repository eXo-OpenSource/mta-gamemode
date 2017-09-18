-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/TemporaryVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
TemporaryVehicle = inherit(Vehicle)

function TemporaryVehicle:constructor()
	self:setFuel(self.m_Fuel or 100)
	self.m_Temporary = true
	VehicleManager:getSingleton():addRef(self, true)
end

function TemporaryVehicle:destructor()
    --VehicleManager:getSingleton():removeRef(self, true) (Vehicle.lua:45)
end

function TemporaryVehicle.create(model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
	if vehicle then
		enew(vehicle, TemporaryVehicle)
	end
	return vehicle
end

function TemporaryVehicle:isPermanent()
	return false
end

function TemporaryVehicle:respawn()
	-- Remove
	if not self.m_disableRespawn == true then
		destroyElement(self)
	end
end

function TemporaryVehicle:disableRespawn(state)
	self.m_disableRespawn = state
end
