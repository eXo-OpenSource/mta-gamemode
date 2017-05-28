-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)

VEHICLE_ALT_SOUND =
{
	[568] = true,
	[411] = true,
	[477] = true,
	[451] = true,
	[560] = true,
	[598] = true,
	[522] = true,
	[603] = true,
}
registerElementClass("vehicle", Vehicle)
addRemoteEvents{"vehicleEngineStart", "vehicleOnSmokeStateChange", "vehicleCarlock", "vehiclePlayCustomHorn", "vehicleHandbrake", "vehicleStopCustomHorn",
"soundvanChangeURLClient", "soundvanStopSoundClient", "playLightSFX"}

function Vehicle:constructor()
	self.m_DiffMileage = 0

	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		self.m_SpecialSmokeEnabled = false
	end

	bindKey("handbrake", "up", function() if isPedInVehicle(localPlayer) and getElementData(localPlayer.vehicle, "Handbrake") then setControlState("handbrake", true) end end)
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
	local speed = (vx^2 + vy^2 + vz^2) ^ 0.5 * 195
	return speed
end

function Vehicle:getMileage()
	return (getElementData(self, "mileage") or 0) + self.m_DiffMileage
end

-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

function Vehicle:magnetVehicleCheck()
	local vehicle = self:getData("MagnetGrabbedVehicle")
	local groundPosition = vehicle and getGroundPosition(vehicle.position)

	triggerServerEvent("clientMagnetGrabVehicle", localPlayer, groundPosition)
end

addEventHandler("vehicleEngineStart", root,
	function(veh)
		local sound = "files/audio/Enginestart.ogg"
		if VEHICLE_ALT_SOUND[getElementModel(veh)] then
			sound = "files/audio/Enginestart2.ogg"
		end
		local sound = playSound3D(sound, veh.position)
		sound:setMinDistance(0)
		sound:setMaxDistance(30)
		sound:attach(veh)
		veh.EngineStart = true
		setTimer(function()
			veh.EngineStart = false
		end, 2050 ,1)
	end
)

addEventHandler("vehicleCarlock", root,
	function()
		playSound3D("files/audio/carlock.mp3", source:getPosition())
	end
)

local handbrakeWorkaroundTimer
addEventHandler("vehicleHandbrake", root,
	function()
		local vehicle = localPlayer.vehicle
		if vehicle then
			local bstate = getElementData(vehicle, "Handbrake")

			if bstate then
				playSound3D("files/audio/hb_off.mp3", source:getPosition())
				if isTimer(handbrakeWorkaroundTimer) then killTimer(handbrakeWorkaroundTimer) end
			else
				playSound3D("files/audio/hb_on.mp3", source:getPosition())

				--Workaround to fix handbrake if player minimze/restore (onClientRestore will not always triggered)
				if not isTimer(handbrakeWorkaroundTimer) then
					handbrakeWorkaroundTimer = setTimer(
						function(vehicle)
							if not isPedInVehicle(localPlayer) then
								killTimer(handbrakeWorkaroundTimer)
								return
							end

							if getElementData(vehicle, "Handbrake") then
								setControlState("handbrake", true)
							end
						end, 1000, 0, vehicle)
				end
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
	function(attacker, weapon, loss, dx, dy, dz, tId)
		local occ = getVehicleOccupants(source)
		local counter = 0
		for seat, player in pairs(occ) do
			counter = counter + 1
		end
		if not getElementData(source, "syncEngine") and not tId then cancelEvent() end
		if source:getData("disableVehicleDamageSystem") then return end
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
				setVehicleEngineState(source, false)
				source:setHealth(301)
			end
		end
		if getVehicleOccupant(source,0) == localPlayer then
			if not weapon then
				triggerServerEvent("onVehicleCrash", localPlayer,source, loss)
			end
		end
	end
)

if EVENT_EASTER then
	addEventHandler("onClientVehicleCollision", root,
		function(hitElement, force)
			if not localPlayer.vehicle then return end
			if localPlayer.vehicle ~= source then return end
			if localPlayer.vehicleSeat ~= 0 then return end

			if hitElement and hitElement:getModel() == 1933 and force > 500 then
				localPlayer:giveAchievement(92)
			end
		end
	)
end

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

local renderLeviathanRope = {}
addEventHandler("onClientElementStreamIn", root,
	function()
		if getElementType(source) == "vehicle" and source:getModel() == 417 then
			renderLeviathanRope[source] = true
		end
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		if renderLeviathanRope[source] then
			renderLeviathanRope[source] = nil
		end
	end
)

addEventHandler("onClientRender", root,
	function()
		for vehicle in pairs(renderLeviathanRope) do
			if not isElement(vehicle) then renderLeviathanRope[vehicle] = nil break end

			local magnet = getElementData(vehicle, "Magnet")
			if magnet then
				dxDrawLine3D(vehicle.position, magnet.position, tocolor(100, 100, 100, 255), 10)
			end
		end
	end
)
