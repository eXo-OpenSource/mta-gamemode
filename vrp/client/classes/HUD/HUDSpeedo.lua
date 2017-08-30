-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDSpeedo.lua
-- *  PURPOSE:     HUD speedometer class
-- *
-- ****************************************************************************
HUDSpeedo = inherit(Singleton)


function HUDSpeedo:constructor()
	self.m_Size = 256
	self.m_FuelSize = 128
	self.m_Draw = bind(self.draw, self)
	self.m_Fuel = 100
	self.m_Indicator = {["left"] = 0, ["right"] = 0}

	-- Add event handlers
	addEventHandler("onClientPlayerVehicleEnter", localPlayer,
		function(vehicle, seat)
			if seat == 0 then
				if VEHICLE_BIKES[vehicle:getModel()] then
					ShortMessage:new(_"Öffne das Fahrradschloss mit 'X'!")
					ShortMessage:new(_"Löse die Bremse mit 'G'!")
				else
					self:show()
				end
			end
			self:playSeatbeltAlarm(true)
		end
	)
	addEventHandler("onClientPlayerVehicleExit", localPlayer,
		function(vehicle, seat)
			if seat == 0 then
				if vehicle then
					if not VEHICLE_BIKES[vehicle:getModel()] then
						self:hide()
					end
				end
			end
			self:playSeatbeltAlarm(false)
		end
	)
	addEvent("vehicleFuelSync", true)
	addEventHandler("vehicleFuelSync", root,
		function(fuel)
			self.m_Fuel = fuel
		end
	)
	addEvent("vehicleTrailerFuelSync", true)
	addEventHandler("vehicleTrailerFuelSync", root,
		function(fuel)
			self.m_TrailerFuel = fuel
		end
	)
	addEvent("playSeatbeltAlarm", true)
	addEventHandler("playSeatbeltAlarm", root,
		function(state)
			self:playSeatbeltAlarm(state)
		end
	)
end

function HUDSpeedo:show()
	addEventHandler("onClientRender", root, self.m_Draw, true, "high+10")
end

function HUDSpeedo:hide()
	removeEventHandler("onClientRender", root, self.m_Draw)
end

function HUDSpeedo:setIndicatorAlpha(direction, alpha)
	self.m_Indicator[direction] = alpha
end

function HUDSpeedo:draw()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/Speedo") end
	if not isPedInVehicle(localPlayer) or localPlayer.vehicleSeat ~= 0 then
		self:hide()
		return
	end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then  -- death in veh fix
		self:hide()
		return
	end
	local vehicleType = getVehicleType(vehicle)
	local handbrake = getElementData( vehicle, "Handbrake" )
	local speed = vehicle:getSpeed()
	local drawX, drawY = screenWidth - self.m_Size, screenHeight - self.m_Size - 10
	local mileage = localPlayer:getPrivateSync("vehicleMileage")

	-- Set maximum
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter then
		if speed > 240 then
			speed = 240
		end
	else
		if speed > 220 then
			speed = 220
		end
	end

	--dxSetBlendMode("add")
	-- draw the main speedo
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main.png", 0, 0, 0, tocolor(255, 255, 255, 150))
	else
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main_aviation.png", 0, 0, 0, tocolor(255, 255, 255, 150))
	end

	-- draw the engine icon
	if getVehicleEngineState(vehicle) then
		dxDrawImage(drawX, drawY + 15, self.m_Size, self.m_Size, "files/images/Speedo/engine.png", 0, 0, 0, Color.Green)
	elseif vehicle.EngineStart then
		dxDrawImage(drawX, drawY + 15, self.m_Size, self.m_Size, "files/images/Speedo/engine.png")
	end

	if handbrake or getPedControlState("handbrake") or vehicle:isFrozen() then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/handbrake.png")
	else
		local cruiseSpeed = CruiseControl:getSingleton():getSpeed()
		dxDrawText(cruiseSpeed and math.floor(cruiseSpeed) or "-", drawX+128, drawY+60, nil, nil, Color.Orange, 1, VRPFont(30, Fonts.Digital), "center")
	end

	dxDrawText(("%.1f km"):format(vehicle:getMileage() and vehicle:getMileage()/1000 or 0), drawX+128, drawY+155, nil, nil, tocolor(255, 255, 255, 150), 1, VRPFont(20), "center")

	if vehicle:getVehicleType() == VehicleType.Automobile then
		if not self:allOccupantsBuckeled() and getVehicleEngineState(vehicle) then
			if getTickCount()%1000 > 500 then
				dxDrawImage(drawX + 128 - 48, drawY + 120, 24, 24, "files/images/Speedo/seatbelt.png", 0, 0, 0, Color.Red)
			end
		elseif getVehicleEngineState(vehicle) then
			dxDrawImage(drawX + 128 - 48, drawY + 120, 24, 24, "files/images/Speedo/seatbelt.png", 0, 0, 0, Color.Green)
		end
	end

	if self.m_Indicator["left"] > 0 and getElementData(vehicle, "i:left") then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/indicator_left.png", 0, 0, 0, tocolor(255, 255, 255, self.m_Indicator["left"]))
	end

	if self.m_Indicator["right"] > 0 and getElementData(vehicle, "i:right") then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/indicator_right.png", 0, 0, 0, tocolor(255, 255, 255, self.m_Indicator["right"]))
	end

	-- Draw needle
	dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main_needle.png", speed * 270/240)

	-- draw the fuel-o-meter
	dxDrawImage(drawX-100, drawY+115, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel.png", 0, 0, 0, tocolor(255, 255, 255, 150))
	dxDrawImage(drawX-100, drawY+115, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel_needle.png", self.m_Fuel * 180/100)

	if localPlayer.vehicle.towedByVehicle and self.m_TrailerFuel then
		dxDrawImage(drawX-100, drawY+115, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel_needle_trailer.png", self.m_TrailerFuel * 180/100)
	end
	--dxSetBlendMode("blend")
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Speedo", 1, 1) end
end

function HUDSpeedo:allOccupantsBuckeled()
	if not localPlayer.vehicle or localPlayer.vehicleSeat > 0 then return end

	for _, player in pairs(localPlayer.vehicle.occupants) do
		if not getElementData(player, "isBuckeled") then
			return false
		end
	end

	return true
end

function HUDSpeedo:playSeatbeltAlarm(state)
	if state then
		if not localPlayer.m_SeatbeltSoundEnabled then
			if localPlayer.vehicle and localPlayer.vehicle:getVehicleType() == VehicleType.Automobile and localPlayer.vehicle:getData("syncEngine") and not localPlayer:getData("isBuckeled") and not VEHICLE_BIKES[localPlayer.vehicle:getModel()] then
				if core:get("Vehicles", "seatbeltWarning", true) then
					localPlayer.m_SeatbeltSound = playSound("files/audio/car_seatbelt_warning.mp3")
					localPlayer.m_SeatbeltSoundEnabled = true
				end
			end
		end
	else
		if isElement(localPlayer.m_SeatbeltSound) then stopSound(localPlayer.m_SeatbeltSound) end
		localPlayer.m_SeatbeltSoundEnabled = false
	end
end

function HUDSpeedo:Bind_CruiseControl(key, state)
	-- Don't do anything if we're in a vehicle
	if not localPlayer:getOccupiedVehicle() or localPlayer:getOccupiedVehicleSeat() > 0 then
		return
	end

	if state == "down" then
		-- Tell the player that we enable cruise control
		if not CruiseControl:getSingleton():isEnabled() then
			ShortMessage:new(_"Limiter aktiviert!")
		end

		-- Enable cruise control and its adjustment
		self.m_CruiseSpeedChanged = not CruiseControl:getSingleton():isEnabled()
		CruiseControl:getSingleton():setEnabled(true)

		-- Disable radio channel switching for a moment
		RadioGUI:getSingleton():setControlEnabled(false)

		-- Bind mouse wheel to change the cruise speed
		bindKey("mouse_wheel_up", "down", self.Bind_CruiseControlChange, 2)
		bindKey("mouse_wheel_down", "down", self.Bind_CruiseControlChange, -2)
	else
		-- Disable if the cruise speed hasn't changed
		if not self.m_CruiseSpeedChanged then
			CruiseControl:getSingleton():setEnabled(false)
			ShortMessage:new(_"Limiter deaktiviert!")
		end

		-- Enable radio channel switching again
		RadioGUI:getSingleton():setControlEnabled(true)

		-- Remove mouse wheel binds
		unbindKey("mouse_wheel_up", "down", self.Bind_CruiseControlChange)
		unbindKey("mouse_wheel_down", "down", self.Bind_CruiseControlChange)
	end
end

function HUDSpeedo.Bind_CruiseControlChange(key, state, change)
	-- Don't do anything if we're in a vehicle
	if not localPlayer:getOccupiedVehicle() or localPlayer:getOccupiedVehicleSeat() > 0 then
		return
	end
	-- Update cruise speed
	local newSpeed = math.max(CruiseControl:getSingleton():getSpeed() + change, 0)
	CruiseControl:getSingleton():setSpeed(newSpeed)

	-- Give achievement if the player reached 5000
	if newSpeed > 100000 then
		localPlayer:giveAchievement(85)
	elseif newSpeed > 5000 then
		localPlayer:giveAchievement(84)
	end

	-- Mark the cruise speed being changed
	HUDSpeedo:getSingleton().m_CruiseSpeedChanged = true
end
