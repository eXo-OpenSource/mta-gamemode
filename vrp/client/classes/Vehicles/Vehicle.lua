-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
registerElementClass("vehicle", Vehicle)

function Vehicle:constructor()
	self.m_DiffMileage = 0
end

function Vehicle:getFuel()
	return 100
end


addEvent("vehicleEngineStart", true)
addEventHandler("vehicleEngineStart", root,
	function()
		if chance(10) then
			playSound("files/audio/Enginestart.mp3")
		end
	end
)

local counter = 0
setTimer(
	function()
		local vehicle = localPlayer:getOccupiedVehicle()
		if vehicle then
			if not vehicle.m_LastPosition then
				vehicle.m_LastPosition = vehicle:getPosition()
			end

			local position = vehicle:getPosition()
			vehicle.m_DiffMileage = vehicle.m_DiffMileage + (position - vehicle.m_LastPosition).length
			vehicle.m_LastPosition = position

			-- Send current mileage every minute to the server
			counter = counter + 1
			if counter >= 60 then
				triggerServerEvent("vehicleSyncMileage", localPlayer, vehicle.m_DiffMileage)

				counter = 0
				vehicle.m_DiffMileage = 0
			end
		end
	end,
	1000,
	0
)
