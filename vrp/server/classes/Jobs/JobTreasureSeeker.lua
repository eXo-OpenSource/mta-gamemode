-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobTreasureSeeker.lua
-- *  PURPOSE:     JobTreasureSeeker job
-- *
-- ****************************************************************************
JobTreasureSeeker = inherit(Job)

function JobTreasureSeeker:constructor()
	Job.constructor(self)
	local availableVehicles = {"Reefer"}
	self.m_VehicleSpawner = VehicleSpawner:new(715.41, -1706.50, 1.8, availableVehicles, 135, bind(Job.requireVehicle, self), bind(self.onVehicleSpawn, self))
	self.m_VehicleSpawner:setSpawnPosition(Vector3(719.79, -1705.18, -0.34), 180)
end

function JobTreasureSeeker:start(player)

end

function JobTreasureSeeker:onVehicleSpawn(player, vehicleModel, vehicle)
	vehicle.Magnet = createObject(1301, 0, 0, 0)
	vehicle.Magnet:setScale(0.5)
	vehicle.Magnet:attach(vehicle, 0, -6.2, 2)
end
