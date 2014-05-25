-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobBusDriver.lua
-- *  PURPOSE:     Bus driver job class
-- *
-- ****************************************************************************
JobBusDriver = inherit(Job)

function JobBusDriver:constructor()
	Job.constructor(self)
	
	createObject(9254, 1777.7, -1758.9, 13.2)
	removeWorldModel(4019, 77, 1777.8, -1773.9, 12.5)
	removeWorldModel(4025, 77, 1777.8, -1773.9, 12.5)
	for i = 0, 7 do
		AutomaticVehicleSpawner:new(437, 1799 - i * 6, -1766.2, 13.9, 0, 0, 0)
	end
	
end

function JobBusDriver:start(player)
	
end
