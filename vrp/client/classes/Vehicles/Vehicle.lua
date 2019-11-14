-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
inherit(VehicleDataExtension, Vehicle)

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
"soundvanChangeURLClient", "soundvanStopSoundClient", "playLightSFX", "vehicleReceiveTuningList", "vehicleAdminReceiveTextureList"}

function Vehicle:constructor()
	self.m_DiffMileage = 0
	self.m_DiffMileagePassenger = 0

	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		self.m_SpecialSmokeEnabled = false
	end
	
end

function Vehicle:getMaxHealth()
	return self:getData("customMaxHealth") or 1000
end

function Vehicle:getHealthInPercent()
	return math.clamp(0, math.ceil((self.health - VEHICLE_TOTAL_LOSS_HEALTH)/(self:getMaxHealth() - VEHICLE_TOTAL_LOSS_HEALTH)*100), 100)
end

function Vehicle:isAlwaysDamageable()
	return self:getData("alwaysDamageable")
end

function Vehicle:isBroken()
	return self:getData("vehicleEngineBroken")
end

function Vehicle:getBulletArmorLevel()
	return self:getData("vehicleBulletArmorLevel") or 1
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
	if not localPlayer.vehicle then
		return (getElementData(self, "mileage") or 0)
	end

	return (getElementData(self, "mileage") or 0) + (localPlayer.vehicleSeat == 0 and self.m_DiffMileage or self.m_DiffMileagePassenger)
end

function Vehicle:getFuel()
	return self:getData("fuel")
end

function Vehicle:isEmpty()
	return self.occupants and table.size(self.occupants) == 0
end

-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

function Vehicle:isTurboVehicle()
	return getElementData(self, "Turbo")
end

function Vehicle:magnetVehicleCheck()
	local vehicle = self:getData("MagnetGrabbedVehicle")
	local groundPosition = vehicle and getGroundPosition(getElementPosition(vehicle))

	triggerServerEvent("clientMagnetGrabVehicle", self, groundPosition)
end

function Vehicle:toggleEngine()
	if localPlayer.vehicleSeat ~= 0 then return end
	triggerServerEvent("clientToggleVehicleEngine", localPlayer)
end

function Vehicle:toggleLight()
	if localPlayer.vehicleSeat ~= 0 then return end
	triggerServerEvent("clientToggleVehicleLight", localPlayer)
end

function Vehicle:toggleHandbrake()
	if localPlayer.vehicleSeat ~= 0 then return end
	triggerServerEvent("clientToggleHandbrake", localPlayer)
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
			if localPlayer.vehicle == veh then
				HUDSpeedo:playSeatbeltAlarm(true)
				toggleControl("brake_reverse", true)
				toggleControl("accelerate", true)
			end
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
								setPedControlState("handbrake", true)
							end
						end, 1000, 0, vehicle)
				end
			end
		end
	end
)

addEventHandler("vehiclePlayCustomHorn", root,
	function (horn)
		if not source.m_HornSound and core:get("Vehicles", "customHorn", true) then
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

			local posDelta = (position - vehicle.m_LastPosition).length
			vehicle.m_LastPosition = position
			if posDelta > 100 then return end -- over 100m in 1 sec = teleport (most likely)

			local deltaTimeH =  1/60/60 -- 1sec in h
			local kmh = (posDelta/1000)/deltaTimeH
			if kmh > vehicle:getHandling()["maxVelocity"] then -- diff is higher than diff with max velocity of this vehicle, so crop it
				kmh = vehicle:getHandling()["maxVelocity"]
				posDelta = kmh*deltaTimeH*1000
			end

			vehicle.m_DiffMileage = vehicle.m_DiffMileage + posDelta

			if localPlayer.vehicleSeat ~= 0 then
				vehicle.m_DiffMileagePassenger = vehicle.m_DiffMileage
				return
			end

			-- Send current mileage every minute to the server
			counter = counter + 1
			if counter >= 60 or vehicle:getData("EPT_Taxi") or localPlayer:getPublicSync("inDrivingLession") then
				if vehicle.m_DiffMileage > 10 then
					triggerServerEvent("vehicleSyncMileage", localPlayer, vehicle.m_DiffMileage)
					vehicle.m_DiffMileage = 0
				end

				counter = 0
			end
		end
	end, 1000, 0
)

-- The following code prevents vehicle from exploding "fully"
local totalLossVehicleTypes = {
	[VehicleType.Automobile] = true,
	[VehicleType.Bike] = true,
}

addEventHandler("onClientVehicleDamage", root,
	function(attacker, weapon, loss, dx, dy, dz, tId)
		if (not getElementData(source, "syncEngine") and not tId) and not (source.isAlwaysDamageable and source:isAlwaysDamageable()) and (table.size(source:getOccupants()) < 1 or (source:getVehicleType() == 1 or source:getVehicleType() == 3)) then return cancelEvent() end
		if not tId and (source.isBroken and source:isBroken()) then return cancelEvent() end
		--calculate vehicle armor
		if not tId and weapon and source.getBulletArmorLevel then
			cancelEvent()
			local newLoss = loss / source:getBulletArmorLevel()
			source:setHealth(math.max(0, source:getHealth()-newLoss))
		end
		if weapon == 16 or weapon == 19 or weapon == 35 or weapon == 36 or weapon == 39 or weapon == 51 or weapon == 59 then
			if source:getHealth() < 300 then
				triggerServerEvent("vehicleBlow", source, weapon)
				return
			end		
		end
		if totalLossVehicleTypes[source:getVehicleType()] then
			if source:getHealth() - loss <= VEHICLE_TOTAL_LOSS_HEALTH and source:getHealth() > 0 then
				if isElementSyncer(source) and (source.m_LastBroken and (getTickCount() - source.m_LastBroken > 500) or true ) then
					source.m_LastBroken = getTickCount()
					triggerServerEvent("vehicleBreak", source, weapon)
				end
				setVehicleEngineState(source, false)
				source:setHealth(VEHICLE_TOTAL_LOSS_HEALTH)
			end
		end
		if getVehicleOccupant(source,0) == localPlayer then
			if not weapon then
				triggerServerEvent("onVehicleCrash", source, loss)
			end
		end

	end
)

addEventHandler("onClientVehicleCollision", root, function()
	if source:getData("disableCollisionCheck") then return end
	if totalLossVehicleTypes[source:getVehicleType()] then
		local rx, ry, rz = getElementRotation(source)
		source:setDamageProof(rx > 160 and rx < 200) -- to disable burning
		if source:getHealth() <= VEHICLE_TOTAL_LOSS_HEALTH and source:getHealth() > 0 then -- Crashfix
			source:setHealth(VEHICLE_TOTAL_LOSS_HEALTH)
		end
	end
end)

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

addEventHandler("vehicleReceiveTuningList", localPlayer,
function (vehicle, tuning, specialTuning)
	VehicleTuningShowGUI:new(tuning, specialTuning)
end)

addEventHandler("vehicleAdminReceiveTextureList", localPlayer,
function (vehicle, texture)
	AdminVehicleTextureEditGUI:new(vehicle, texture)
end)


local renderLeviathanRope = {}


addEventHandler("onClientElementStreamIn", root,
	function()
		if getElementType(source) == "vehicle" then
			if source:getModel() == 417 then
				renderLeviathanRope[source] = true
			elseif source:getModel() == 544 then
				setVehicleComponentVisible(source, "misc_a", false)
				setVehicleComponentVisible(source, "misc_b", false)
				setVehicleComponentVisible(source, "misc_c", false)
				triggerEvent("rescueLadderUpdateCollision", source, false)
			end
			GroupSaleVehicles.VehiclestreamedIn(source)
			Indicator:getSingleton():onVehicleStreamedIn(source)
			VehicleELS:getSingleton():onVehicleStreamedIn(source)
			Neon.VehiclestreamedIn(source)
		end
	end
)


addEventHandler("onClientElementStreamOut", root,
	function()
		if renderLeviathanRope[source] then
			renderLeviathanRope[source] = nil
		end
		if getElementType(source) == "vehicle" then
			GroupSaleVehicles.VehiclestreamedOut(source)
			Indicator:getSingleton():onVehicleStreamedOut(source)
			VehicleELS:getSingleton():onVehicleStreamedOut(source)
			Neon.VehiclestreamedOut(source)
		end
	end
)

addEventHandler("onClientElementDataChange", root,
	function(dataName)
		if not localPlayer.vehicle then return end
		if localPlayer.vehicle ~= source then return end
		if localPlayer.vehicleSeat == 0 then return end

		if dataName == "mileage" then
			localPlayer.vehicle.m_DiffMileage = 0
			localPlayer.vehicle.m_DiffMileagePassenger = 0
		end
	end
)

addEventHandler("onClientRender", root,
	function()
		if DEBUG then ExecTimeRecorder:getSingleton():startRecording("3D/VehicleRopes") end
		for vehicle in pairs(renderLeviathanRope) do
			if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/VehicleRopes") end
			if not isElement(vehicle) then renderLeviathanRope[vehicle] = nil break end

			local magnet = getElementData(vehicle, "Magnet")
			if magnet then
				if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/VehicleRopes", true) end
				local x, y, z = getElementPosition(vehicle)
				local mx, my, mz = getElementPosition(magnet)
				dxDrawLine3D(x, y, z, mx, my, mz, tocolor(100, 100, 100, 255), 10)
			end
		end
		for engine, magnet in pairs(JobTreasureSeeker.Rope) do
			if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/VehicleRopes") end
			if isElement(engine) and isElement(magnet) then
				if isElementStreamedIn(engine) then
					local pos1 = engine:getPosition()
					local pos2 = magnet:getPosition()
					if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/VehicleRopes", true) end
					dxDrawLine3D(pos1, pos2, tocolor(0, 0, 0), 2)
				end
			else
				JobTreasureSeeker.Rope[engine] = nil
			end
		end
		if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/VehicleRopes") end
	end
)

local VehiclesToDisableShooting = {
	[476] = true, -- Rustler
	[447] = true, -- Seasparrow
}
local function disableShootingOfVehicles()
	toggleControl("vehicle_secondary_fire", false)
end

addEventHandler("onClientVehicleStartEnter", root, function(player, seat)
	if localPlayer.m_Entrance and player == localPlayer then 
		if localPlayer.m_Entrance:check() and localPlayer.m_Entrance:isCancelEnter() then 
			cancelEvent()
		end
	end
	if seat == 0 and player == localPlayer then
		if VehiclesToDisableShooting[source:getModel()] then
			if not isEventHandlerAdded("onClientRender", root, disableShootingOfVehicles) then
				addEventHandler("onClientRender", root, disableShootingOfVehicles)
			end
		elseif isEventHandlerAdded("onClientRender", root, disableShootingOfVehicles) then
			removeEventHandler("onClientRender", root, disableShootingOfVehicles)
			toggleControl("vehicle_secondary_fire", true)
		end
	end
end)

addEventHandler("onClientVehicleExit", root, function(player, seat)
	if seat == 0 and VehiclesToDisableShooting[source:getModel()] and player == localPlayer then
		if isEventHandlerAdded("onClientRender", root, disableShootingOfVehicles) then
			removeEventHandler("onClientRender", root, disableShootingOfVehicles)
			toggleControl("vehicle_secondary_fire", true)
		end
	end
end)