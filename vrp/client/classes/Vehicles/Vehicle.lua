-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
registerElementClass("vehicle", Vehicle)
addRemoteEvents{"vehicleEngineStart", "vehicleOnSmokeStateChange", "vehicleCarlock", "vehiclePlayCustomHorn", "vehicleHandbrake", "vehicleStopCustomHorn",
"soundvanChangeURLClient", "soundvanStopSoundClient", "playLightSFX"}

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

function Vehicle:getTextureName()
	return VEHICLE_SPECIAL_TEXTURE[self:getModel()] or "vehiclegrunge256"
end

function Vehicle:getSpeed()
	local vx, vy, vz = getElementVelocity(self)
	local speed = (vx^2 + vy^2 + vz^2) ^ 0.5 * 161
	return speed
end

-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

addEventHandler("vehicleEngineStart", root,
	function()
		if chance(10) then
			playSound("files/audio/Enginestart.mp3")
		end
	end
)

addEventHandler("vehicleCarlock", root,
	function()
		playSound3D("files/audio/carlock.mp3", source:getPosition())
	end
)

addEventHandler("vehicleHandbrake", root,
	function()
		local vehicle = getPedOccupiedVehicle( localPlayer )
		local bstate = getElementData( vehicle, "Handbrake")
		if vehicle then
			if bstate then
				playSound3D("files/audio/hb_off.mp3", source:getPosition())
			else
				playSound3D("files/audio/hb_on.mp3", source:getPosition())
			end
		end
	end
)

addEventHandler("vehiclePlayCustomHorn", root,
	function (horn)
		if not source.m_HornSound then
			source.m_HornSound = playSound3D(("files/audio/Horns/%s.mp3"):format(horn), source:getPosition(), true)
			source.m_HornSound:setMinDistance(0)
			source.m_HornSound:setMaxDistance(70)
			source.m_HornSound:attach(source)
		end
	end
)

addEventHandler("vehicleStopCustomHorn", root,
	function (horn)
		if source.m_HornSound then
			source.m_HornSound:destroy()
			source.m_HornSound = false
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
			if counter >= 60 or vehicle:getModel() == 420 or vehicle:getModel() == 438 then
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
		if source:getVehicleType() == VehicleType.Automobile or source:getVehicleType() == VehicleType.Bike then
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
	end
)


addEventHandler("soundvanChangeURLClient", root,
	function(url)
		if isElement(source.Sound) then
			source.Sound:destroy()
		end
		if url then
			local sound = Sound3D.create(url, source:getPosition())
			sound:setInterior(source:getInterior())
			sound:setDimension(source:getDimension())
			sound:attach(source)
			source.Sound = sound
		end
	end
)

addEventHandler("soundvanStopSoundClient", root,
	function()
		if isElement(source.Sound) then
			source.Sound:destroy()
		end
	end
)


addEventHandler("playLightSFX", localPlayer,
function( dir )
	if dir then
		playSound("files/audio/headlight_up.mp3")
	else
		playSound("files/audio/headlight_down.mp3")
	end
end)
