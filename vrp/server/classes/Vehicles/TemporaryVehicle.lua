-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/TemporaryVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
TemporaryVehicle = inherit(Vehicle)

function TemporaryVehicle:constructor()
	VehicleManager:getSingleton():addRef(self, true)
end

function TemporaryVehicle:destructor()
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
	destroyElement(self)
end
