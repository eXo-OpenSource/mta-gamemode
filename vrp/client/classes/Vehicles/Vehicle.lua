-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
registerElementClass("vehicle", Vehicle)
addRemoteEvents{"vehicleEngineStart", "vehicleOnSmokeStateChange"}

function Vehicle:constructor()
	self.m_DiffMileage = 0

	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		self.m_SpecialSmokeEnabled = false
	end
end

function Vehicle:getFuel()
	return 100
end

function Vehicle:isSmokeEnabled()
	return self.m_SpecialSmokeEnabled
end

addEvent("vehicleEngineStart", true)
addEventHandler("vehicleEngineStart", root,
	function()
		if chance(10) then
			playSound("files/audio/Enginestart.mp3")
		end
	end
)

addEventHandler("vehicleOnSmokeStateChange", root,
	function (state)
		if VEHICLE_SPECIAL_SMOKE[source:getModel()] then
			source.m_SpecialSmokeEnabled = state
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
				if vehicle.m_DiffMileage > 10 then
					triggerServerEvent("vehicleSyncMileage", localPlayer, vehicle.m_DiffMileage)
				end

				counter = 0
				vehicle.m_DiffMileage = 0
			end
		end
	end,
	1000,
	0
)

-- The following code prevents vehicle from exploding "fully"
addEventHandler("onClientVehicleDamage", root,
	function(attacker, weapon, loss)
		if source:getHealth() - loss < 310 then
			cancelEvent()

			if isElementSyncer(source) and source:getHealth() >= 310 then
				triggerServerEvent("vehicleBreak", source)
				source.m_Broken = true

				if localPlayer:getOccupiedVehicle() == source then
					WarningBox:new(_"Dein Fahrzeug ist kaputt und muss repariert werden!")
				end
			end

			source:setHealth(301)
		end
	end
)
