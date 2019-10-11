-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermanentVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
inherit(VehicleDataExtension, Vehicle)
inherit(VehicleObjectLoadExtension, Vehicle)
inherit(VehicleELS, Vehicle)
Vehicle.constructor = pure_virtual -- Use PermanentVehicle / TemporaryVehicle instead
function Vehicle:virtual_constructor()
	addEventHandler("onVehicleEnter", self, bind(self.onPlayerEnter, self))
	addEventHandler("onVehicleExit", self, bind(self.onPlayerExit, self))
	addEventHandler("onElementInteriorChange", self, bind(self.onInteriorChange, self))
	addEventHandler("onElementDimensionChange", self, bind(self.onDimensionChange, self))

	self.m_LastUseTime = math.huge
	setVehicleOverrideLights(self, 1)
	setVehicleEngineState(self, false)
	self.m_EngineState = false
	self.m_Fuel = 100
	self.m_Mileage = 0
	self.m_RepairAllowed = true
	self.m_RespawnAllowed = true
	self.m_BrokenHook = Hook:new()

	self.m_LastDrivers = {}

	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		self.m_SpecialSmokeEnabled = false
		self.m_SpecialSmokeInternalToggle = bind(self.toggleInternalSmoke, self)
	end

	self.ms_CustomHornPlayBind = bind(self.playCustomHorn, self)
	self.ms_CustomHornStopBind = bind(self.stopCustomHorn, self)

	addEventHandler("onVehicleRespawn", self, function()
		source:setEngineState(false)
		source:setSirensOn(false)
		source:toggleELS(false)
		source:toggleDI(false)
		setVehicleOverrideLights(self, 1)
	end)

	if ELS_PRESET[self:getModel()] then
		self:setELSPreset(self:getModel())
	end

	if self:getModel() == 417 then
		self:addMagnet()
		self.m_MagnetUp = bind(Vehicle.magnetMoveUp, self)
		self.m_MagnetDown = bind(Vehicle.magnetMoveDown, self)
	end
end

function Vehicle:virtual_destructor()
	if self.m_CountdownDestroyTimer and isTimer(self.m_CountdownDestroyTimer) then
		self:countdownDestroyAbort(player)
	end
	VehicleManager:getSingleton():removeRef(self, not self:isPermanent())

	if self.m_Magnet and self.m_Magnet.type == "object" then
		self.m_Magnet:destroy()
	end

	local occs = getVehicleOccupants(self)
	if occs then
		for seat, player in pairs(occs) do
			if player then
				player.m_SeatBelt = false
				setElementData(player, "isBuckeled", false)
			end
		end
	end
end

function Vehicle:setOwner(owner)
	if type(owner) == "userdata" then
		self.m_Owner = owner:getId()
	elseif type(owner) == "number" then
		self.m_Owner = owner
	else
		return false
	end
	self:save()
	return true
end

function Vehicle:getOwner()
	return self.m_Owner
end

function Vehicle:getOccupantsCount()
	if not self:getOccupants() then return 0 end

	local i = 0
	for seat, player in pairs(self:getOccupants()) do
		i = i+1
	end
	return i
end

function Vehicle:hasKey(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	if self.m_Owner == player then
		return true
	end
	if self:isPermanent() then
		return table.find(self.m_Keys, player)
	else
		return false
	end
end

function Vehicle:playLockEffect(locked)
	triggerClientEvent("vehicleCarlock", self, locked)
	setVehicleOverrideLights(self, 2)
	setTimer(setVehicleOverrideLights, 500, 1, self, 1)
	setTimer(setVehicleOverrideLights, 1000, 1, self, 2)
	setTimer(setVehicleOverrideLights, 1500, 1, self, 1)
end

function Vehicle:setLocked(state)
	return setVehicleLocked(self, state)
end

function Vehicle:isLocked()
	return isVehicleLocked(self)
end

function Vehicle:onPlayerEnter(player, seat)
	if player:getType() ~= "player" then return end

	if self.onEnter and self:onEnter(player, seat) then
		if seat == 0 then
			self:setDriver(player)
		end
	end

	if seat == 0 then
		if not player:hasCorrectLicense(source) then
			player:sendShortMessage(_("Achtung: Du hast keinen Führerschein für dieses Fahrzeug!", player))
		end

		if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
			bindKey(player, "sub_mission", "down", self.m_SpecialSmokeInternalToggle)
		end

		if self.m_CustomHorn and self.m_CustomHorn > 0 then
			player:sendShortMessage(_("Du kannst die Spezialhupe mit 'J' benutzen!", player))
			bindKey(player, "j", "down", self.ms_CustomHornPlayBind)
		end

		if self.m_HandBrake then
			setControlState( player, "handbrake", true)
		end

		if self.m_CountdownDestroy then
			self:countdownDestroyAbort(player)
		end

		if self.m_Magnet then
			if not isKeyBound(player, "special_control_up", "both", self.m_MagnetUp) then
				bindKey(player, "special_control_up", "both", self.m_MagnetUp)
				bindKey(player, "special_control_down", "both", self.m_MagnetDown)
			end
		end
	end

	if self.m_HasBeenUsed then
		if self.m_HasBeenUsed == 0 then
			self.m_HasBeenUsed = 1
		end
	end
end

function Vehicle:onPlayerExit(player, seat)
	self.m_LastUseTime = getTickCount()
	local hbState = getControlState( player, "handbrake")
	if player:getType() ~= "player" then return end

	if seat == 0 then
		if hbState then
			setControlState( player, "handbrake", false)
		end

		if VEHICLE_SPECIAL_SMOKE[source:getModel()] then
			self:toggleInternalSmoke()
			unbindKey(player, "sub_mission", "down", self.m_SpecialSmokeInternalToggle)
		end

		if isKeyBound(player, "j", "down", self.ms_CustomHornPlayBind) then
			triggerClientEvent("vehicleStopCustomHorn", self)
			unbindKey(player, "j", "down", self.ms_CustomHornPlayBind)
			unbindKey(player, "j", "up", self.ms_CustomHornStopBind)
		end

		player.m_SeatBelt = false
		setElementData(player,"isBuckeled", false)

		if self.m_HandBrake then
			local ground = isVehicleOnGround( self )
			if ground then
				setElementFrozen(self, true)
				self:switchObjectLoadingMarker(true)
				setVehicleDoorOpenRatio(self, 2, 0, 350)
			else
				self.m_HandBrake = false
				self:setData( "Handbrake",  self.m_HandBrake , true )
			end
		end

		if self.m_CountdownDestroy then
			self:countdownDestroyStart(player)
		end

		if self.m_Magnet then
			unbindKey(player, "special_control_up", "both", self.m_MagnetUp)
			unbindKey(player, "special_control_down", "both", self.m_MagnetDown)
		end
	end
end

function Vehicle:onInteriorChange()
	self:removeAttachedPlayers()
	self:refreshLoadedObjects()
end

function Vehicle:onDimensionChange()
	self:removeAttachedPlayers()
	self:refreshLoadedObjects()
end

function Vehicle:removeAttachedPlayers()
	for i,v in pairs(getAttachedElements(self)) do
		if v and getElementType(v) == "player" then -- I really don't know why we have to check if there even is a 'v'... but there were warnings with some async stuff - MasterM
			v:attachToVehicle(true)
		end
	end
end

function Vehicle:playCustomHorn(player)
	if self.m_CustomHorn and self.m_CustomHorn > 0 then
		if player:getOccupiedVehicle() == self and player:getOccupiedVehicleSeat() == 0 then
			triggerClientEvent("vehiclePlayCustomHorn", self, self.m_CustomHorn)
			bindKey(player, "j", "up", self.ms_CustomHornStopBind)
			return
		end
	end
	unbindKey(player, "j", "down", self.ms_CustomHornPlayBind)
end

function Vehicle:stopCustomHorn(player)
	if self.m_CustomHorn and self.m_CustomHorn > 0 then
		if player:getOccupiedVehicle() == self and player:getOccupiedVehicleSeat() == 0 then
			triggerClientEvent("vehicleStopCustomHorn", self)
			unbindKey(player, "j", "up", self.ms_CustomHornStopBind)
			return
		end
	end
	unbindKey(player, "j", "down", self.ms_CustomHornPlayBind)
end

function Vehicle:getLastUseTime()
	return self:isBeingUsed() and getTickCount() or self.m_LastUseTime
end

function Vehicle:isBeingUsed()
	for k, v in pairs(getVehicleOccupants(self) or {}) do
		return true
	end
	return false
end

function Vehicle:toggleLight()
	local occ = getVehicleOccupant(self)
	if getVehicleOverrideLights(self) == 1 then
		setVehicleOverrideLights(self, 2)
		if occ then
			occ:triggerEvent("playLightSFX",false)
		end
		self.m_Lights = true
	else
		setVehicleOverrideLights(self, 1)
		if occ then
			occ:triggerEvent("playLightSFX",true)
		end
		self.m_Lights = false
	end
end

function Vehicle:setCustomHorn(id)
	self.m_CustomHorn = id
	if self:getOccupant() then
		local player = self:getOccupant()
		if id > 0 then
			bindKey(player, "j", "down", self.ms_CustomHornPlayBind)
		else
			if isKeyBound(player, "j", "down", self.ms_CustomHornPlayBind) then
				unbindKey(player, "j", "down", self.ms_CustomHornPlayBind)
			end
		end
	end
end

function Vehicle:toggleEngine(player)
	if self.m_DisableToggleEngine then
		if self.m_ForSale then
			player:sendError(_("Das Fahrzeug steht zum Verkauf und kann daher nicht gestartet werden!", player))
		end
		return
	end

	local state = not getVehicleEngineState(self)
	if not state then
		self:setEngineState(state)

		if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
			self:toggleInternalSmoke()
		end

		if VEHICLE_BIKES[self:getModel()] then
			player:meChat(true, "verschließt sein Fahrradschloss!")
		end

		local occs = self:getOccupants()
		if occs then
			for i, v in pairs(occs) do
				triggerClientEvent(v, "playSeatbeltAlarm", v, false)
			end
		end

		return true
	end

	if self:hasKey(player) or player:getRank() >= ADMIN_RANK_PERMISSION["toggleVehicleHandbrake"] or not self:isPermanent() or (self.getCompany and self:getCompany():getId() == 1 and player:getPublicSync("inDrivingLession") == true) then
		if state == true then
			if not VEHICLE_BIKES[self:getModel()] then
				if self.m_Fuel <= 0 then
					player:sendError(_("Dein Tank ist leer!", player))
					return false
				end
				if self:isBroken() then
					player:sendError(_("Das Fahrzeug ist kaputt und muss erst repariert werden!", player))
					return false
				end
			end

			if player and not getVehicleEngineState(self) then
				if VEHICLE_BIKES[self:getModel()] then -- Bikes
					player:meChat(true, "öffnet sein Fahrradschloss!")
					self:setEngineState(state)
					return true
				else
					if not self.m_StartingEnginePhase then
						self.m_StartingEnginePhase = true
						local colshape = createColSphere(self:getPosition(), CHAT_SCREAM_RANGE)
						local rangeElements = getElementsWithinColShape(colshape)
						colshape:destroy()
						for key, other in ipairs(rangeElements) do
							if getElementType(other) == "player" then
								other:triggerEvent("vehicleEngineStart", self)
							end
						end
						setTimer(
							function()
								if not isElement(self) then return end
								self:setEngineState(true)
								local occs = self:getOccupants()
								if occs then
									nextframe(function() --this might not work because of ping resons
										for i, v in pairs(occs) do
											triggerClientEvent(v, "playSeatbeltAlarm", v, true)
										end
									end)
								end
							end,
						2000, 1)
						return true
					end
				end
			end
			return false
		end
	end

	if VEHICLE_BIKES[self:getModel()] then -- Bikes
		player:sendError(_("Du hast kein Schlüssel für das Fahrradschloss!", player))
	else
		player:sendError(_("Du hast kein Schlüssel für das Fahrzeug!", player))
	end

	return false
end

function Vehicle:toggleHandBrake(player, preferredState)
	if self.m_DisableToggleHandbrake then return end
	if preferredState ~= nil and preferredState == self.m_HandBrake then return false end

	if not self.m_HandBrake or preferredState then
		if self:isOnGround() then
			setControlState(player, "handbrake", true)
			self.m_HandBrake = true
			player:triggerEvent("vehicleHandbrake", true)
		end
	else
		self.m_HandBrake = false
		setControlState(player, "handbrake", false)
		if isElementFrozen(self) then
			self:switchObjectLoadingMarker(false)
			setElementFrozen(self, false)
		end
		player:triggerEvent("vehicleHandbrake")
	end
	self:setData("Handbrake", self.m_HandBrake, true)

	local ownerType = ""
	local owner = 0

	if self.m_Faction then
		ownerType = 'Faction'
		owner = self.m_Faction
	elseif self.m_Company then
		ownerType = 'Company'
		owner = self.m_Company
	elseif self.m_Group then
		ownerType = 'Group'
		owner = self.m_Group
	elseif self.m_Temporary then
		ownerType = 'Temporary'
		owner = self.m_Owner
	else
		ownerType = 'Player'
		owner = self.m_Owner
	end

	StatisticsLogger:getSingleton():addVehicleLog(player, owner, ownerType, self.m_Id, self:getModel(), self.m_HandBrake and "Handbremse gezogen" or "Handbremse gelöst")
end

function Vehicle:setEngineState(state)
	setVehicleEngineState(self, state)

	if self:getFuelType() ~= "nofuel" then
		VehicleManager:getSingleton().m_VehiclesWithEngineOn[self] = state and self:getMileage() or nil -- toggle fuel consumption
	end
	
	self:setData("syncEngine", state, true)
	self.m_EngineState = state
	self.m_StartingEnginePhase = false

	if instanceof(self, PermanentVehicle, true) then return end
	if self.controller and self.controller:getType() == "player" then
		self:setDriver(self.controller)
	end
end

function Vehicle:getEngineState()
	return self.m_EngineState
end

function Vehicle:setFuel(fuel)
	self.m_Fuel = math.clamp(0, fuel, 100)
	self:setData("fuel", self.m_Fuel, true)

	-- Switch engine off in case of an empty fuel tank
	if self.m_Fuel == 0 then
		self:setEngineState(false)
	end
end

function Vehicle:getFuel()
	return self.m_Fuel
end

function Vehicle:setMileage(mileage)
	self.m_Mileage = mileage
	setElementData(self, "mileage", self:getMileage())
end

function Vehicle:getMileage()
	if not self.m_Mileage then
		outputDebug("Invalid mileage detected. Vehicle: "..self:getName())
		return 0
	end

	return self.m_Mileage
end

function Vehicle:getSpeed()
	local vx, vy, vz = getElementVelocity(self)
	local speed = (vx^2 + vy^2 + vz^2) ^ 0.5 * 195
	return speed
end

function Vehicle:setBroken(state)
	if state and VEHICLE_BIKES[self:getModel()] then return end -- disable total loss for bycicles
	if state then
		self:setHealth(VEHICLE_TOTAL_LOSS_HEALTH)
		self:setEngineState(false)
		self:toggleELS(false)
		self:toggleDI(false)
	end
	self:setData("vehicleEngineBroken", state, true)
	self:setDamageProof(state)
	if self.m_BrokenHook then
		self.m_BrokenHook:call(vehicle)
		return
	end
end

function Vehicle:isBroken()
	return self:getData("vehicleEngineBroken")
end

function Vehicle:toggleInternalSmoke()
	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		if self:getEngineState() then
			self.m_SpecialSmokeEnabled = not self.m_SpecialSmokeEnabled
			triggerClientEvent("vehicleOnSmokeStateChange", self, self.m_SpecialSmokeEnabled)
		end
	end
end

function Vehicle:isSmokeEnabled()
	return self.m_SpecialSmokeEnabled
end

function Vehicle:addCountdownDestroy(seconds)
	self.m_CountdownDestroy = seconds
end

function Vehicle:removeCountdownDestroy()
	self.m_CountdownDestroy = nil
end

function Vehicle:countdownDestroyStart(player)
	if self.m_CountdownDestroyTimer and isTimer(self.m_CountdownDestroyTimer) then
		killTimer(self.m_CountdownDestroyTimer)
	end
	self.m_CountdownDestroyPlayer = player
	player:sendWarning(_("Vorsicht: Steig innerhalb von %d Sekunden wieder ein, oder das Fahrzeug wird gelöscht!", player, self.m_CountdownDestroy))
	player:triggerEvent("Countdown", self.m_CountdownDestroy, "Fahrzeug")
	self.m_CountdownDestroyTimer = setTimer(function()
		player:sendInfo(_("Zeit abgelaufen! Das Fahrzeug wurde gelöscht!", player))
		if self and isElement(self) then
			local occs = getVehicleOccupants(self)
			if occs then
				for i,v in pairs(occs) do
					removePedFromVehicle(v)
				end
			end
			self:destroy()
		end
		player:triggerEvent("CountdownStop", "Fahrzeug")
	end, self.m_CountdownDestroy*1000, 1)
end

function Vehicle:countdownDestroyAbort(player)
	if not player then player = self.m_CountdownDestroyPlayer end
	if self.m_CountdownDestroyTimer and isTimer(self.m_CountdownDestroyTimer) then
		if isElement(player) then player:triggerEvent("CountdownStop", "Fahrzeug") end
		killTimer(self.m_CountdownDestroyTimer)
	end
	self.m_CountdownDestroyPlayer = nil
end

function Vehicle:setRepairAllowed(state)
	self.m_RepairAllowed = state
end

function Vehicle:isRepairAllowed()
	return self.m_RepairAllowed
end

function Vehicle:fix()
	if self.m_RepairAllowed then
		fixVehicle(self)
		if self:getMaxHealth() ~= 1000 then
			self:setHealth(self:getMaxHealth())
		end
		self:setBroken(false)
	end
end

function Vehicle:setAlwaysDamageable(state) -- trigger damage event even if engine is off
	self:setData("alwaysDamageable", state, true)
end

function Vehicle:isAlwaysDamageable()
	return self:getData("alwaysDamageable")
end

function Vehicle:setMaxHealth(health, giveHealth)
	if type(health) == "number" then
		health = math.clamp(VEHICLE_TOTAL_LOSS_HEALTH, health, 2000)
		self:setData("customMaxHealth", health, true)
		if giveHealth then
			self:setHealth(health) -- possible duplicate of :fix(), but only for repairable vehicles
			self:setBroken(false)
		end
		return true
	end
	return false
end

function Vehicle:getMaxHealth()
	return self:getData("customMaxHealth") or 1000
end

function Vehicle:getHealthInPercent()
	return math.clamp(0, math.ceil((self.health - VEHICLE_TOTAL_LOSS_HEALTH)/(self:getMaxHealth() - VEHICLE_TOTAL_LOSS_HEALTH)*100), 100)
end

function Vehicle:setBulletArmorLevel(level)
	if type(level) == "number" then
		level = math.clamp(0, level, 4)
		self:setData("vehicleBulletArmorLevel", level, true)
		return true
	end
	return false
end

function Vehicle:getBulletArmorLevel()
	return self:getData("vehicleBulletArmorLevel") or 1
end

function Vehicle:toggleRespawn(state)
	self.m_RespawnAllowed = state
end

function Vehicle:isRespawnAllowed()
	return self.m_RespawnAllowed
end

function Vehicle:getTexture(textureName)
	return textureName and self.m_Texture[textureName] or self.m_Texture
end

function Vehicle:setTexture(texturePath, textureName, force, isPreview, player)
	if texturePath and #texturePath > 3 then
		if not self.m_Texture then
			self.m_Texture = {}
		end
		if self.m_Texture[textureName] then
			delete(self.m_Texture[textureName])
			self.m_Texture[textureName] = nil
		end

		self.m_Texture[textureName] = VehicleTexture:new(self, texturePath, textureName, true, isPreview, player)

	end
end

function Vehicle:removeTexture(textureName)
	if not self.m_Texture then return false end
	if textureName then
		if self.m_Texture and self.m_Texture[textureName] then
			delete(self.m_Texture[textureName])
			self.m_Texture[textureName] = nil
			return
		end
	end

	for i, v in pairs(self.m_Texture) do
		delete(v)
	end
	self.m_Texture = {}
end

function Vehicle:setCurrentPositionAsSpawn(type)
  self.m_PositionType = type
  self.m_SpawnPos = self:getPosition()
  self.m_SpawnRot = self:getRotation()
  self.m_SpawnDim = self:getDimension()
  self.m_SpawnInt = self:getInterior()
end

function Vehicle:respawnOnSpawnPosition()  
	if self.m_PositionType == VehiclePositionType.World then
		self:setPosition(self.m_SpawnPos)
		self:setRotation(self.m_SpawnRot)
		self:fix()
		self:setInterior(self.m_SpawnInt or 0)
		self:setDimension(self.m_SpawnDim or 0)
		self:setEngineState(false)
		self:setLocked(true)
		setVehicleOverrideLights(self, 1)
		self:setFrozen(true)
		self.m_HandBrake = true
		self:setData("Handbrake",  self.m_HandBrake , true )
		self:setSirensOn(false)
		self:toggleELS(false)
		self:toggleDI(false)
		self:resetIndicator()
		self.m_HasBeenUsed = 0

		if self.despawned then
			self.despawned = false
			self:setDimension(self.m_SpawnDim or 0)
		end

		if self.m_Magnet then
			detachElements(self.m_Magnet)
			self.m_Magnet:attach(self, 0, 0, -1.5)

			self.m_MagnetHeight = -1.5
			self.m_MagnetActivated = false
		end

		local owner = Player.getFromId(self.m_Owner)
		if owner and isElement(owner) then
			owner:sendInfo(_("Dein Fahrzeug wurde in %s/%s respawnt!", owner, getZoneName(self.m_SpawnPos), getZoneName(self.m_SpawnPos, true)))
		end
	end
end

function Vehicle:getTrunk()
  return self.m_Trunk or false
end

function Vehicle:resetIndicator()
	setElementData(self, "i:left", false)
	setElementData(self, "i:right", false)
	setElementData(self, "i:warn", false)
end

function Vehicle:addMagnet()
	self.m_Magnet = createObject(1301, self.position)
	self.m_Magnet:attach(self, 0, 0, -1.5)

	self.m_MagnetHeight = -1.5
	self.m_MagnetActivated = false

	setElementData(self, "Magnet", self.m_Magnet)
end

function Vehicle:magnetVehicleCheck(groundPosition)
	if self.m_MagnetActivated then
		local groundDiff = self.m_GrabbedVehicle.position.z - groundPosition

		if groundDiff > 0.8 and groundDiff < 4 then
			self.m_MagnetActivated = false
			detachElements(self.m_GrabbedVehicle)

			setElementData(self, "MagnetGrabbedVehicle", nil)

			if client.m_InTowLot and client:getCompany() and client:getCompany():getId() == CompanyStaticId.MECHANIC then
				client:getCompany():checkLeviathanTowing(client, self.m_GrabbedVehicle)
			end
		else
			client:sendError("Das Fahrzeug kann nur auf dem Boden abgestellt werden!")
		end
	else
		if not self.m_Magnet and not isElement(self.m_Magnet) then
			client:sendError("INTERNAL ERROR: Funktioniert immer noch nicht...")
			return
		end
		local colShape = createColSphere(self.m_Magnet.matrix:transformPosition(Vector3(0, 0, -0.5)), 2)
		local vehicles = getElementsWithinColShape(colShape, "vehicle")
		colShape:destroy()

		for _, vehicle in pairs(vehicles) do
			if vehicle ~= self then
				if vehicle:isRespawnAllowed() and (vehicle:getVehicleType() == VehicleType.Automobile or vehicle:getVehicleType() == VehicleType.Bike) then
					if vehicle.m_HandBrake and (client:getCompany() and (client:getCompany():getId() ~= CompanyStaticId.MECHANIC or not client:isCompanyDuty())) then
						client:sendWarning("Bitte löse erst die Handbremse von diesem Fahrzeug!")
					else
						if table.size(getVehicleOccupants(vehicle)) == 0 then
							self.m_MagnetActivated = true
							self.m_GrabbedVehicle = vehicle
							vehicle:attach(self.m_Magnet, 0, 0, -1, 0, 0, vehicle.rotation.z - self.m_Magnet.rotation.z)
							setElementData(self, "MagnetGrabbedVehicle", vehicle)
							break
						else
							client:sendWarning("Das Fahrzeug ist nicht leer!")
						end
					end
				end
			end
		end
	end
end

function Vehicle:magnetMoveUp(player, _, state)
	if player.vehicle ~= self then return end

	if state == "down" then
		self.m_MoveUpTimer = setTimer(
			function()
				if self.m_MagnetHeight < -1.5 then
					if not self.controller then killTimer(sourceTimer) return end

					detachElements(self.m_Magnet)
					self.m_MagnetHeight = self.m_MagnetHeight + 0.1
					self.m_Magnet:attach(self, 0, 0, self.m_MagnetHeight)
				end
			end, 50, 0
		)
	else
		if isTimer(self.m_MoveUpTimer) then killTimer(self.m_MoveUpTimer) end
	end
end

function Vehicle:magnetMoveDown(player, _, state)
	if player.vehicle ~= self then return end

	if state == "down" then
		self.m_MoveDownTimer = setTimer(
			function()
				if not self.controller then killTimer(sourceTimer) return end

				if self.m_MagnetHeight > -15 then
					detachElements(self.m_Magnet)
					self.m_MagnetHeight = self.m_MagnetHeight - 0.1
					self.m_Magnet:attach(self, 0, 0, self.m_MagnetHeight)
				end
			end, 50, 0
		)
	else
		if isTimer(self.m_MoveDownTimer) then killTimer(self.m_MoveDownTimer) end
	end
end

function Vehicle:getTuningList(player)
	if self.m_Tunings and self.m_Tunings.getList then
		player:triggerEvent("vehicleReceiveTuningList", self, self.m_Tunings:getList())
	else
		player:triggerEvent("vehicleReceiveTuningList", self, {"(keine)"}, {"(keine)"})
	end
end

-- Not used but maybe useful?
function Vehicle:isPlayerSurfOnCar(player)
	local colShape1 = createColSphere(self.matrix:transformPosition(Vector3(0, 2, 3)), 2.6)
	local colShape2 = createColSphere(self.matrix:transformPosition(Vector3(0, -2, 3)), 2.6)
	local players = table.append(colShape1:getElementsWithin"player", colShape2:getElementsWithin"player")
	colShape1:destroy()
	colShape2:destroy()

	for _, p in pairs(players) do
		if p == player then
			return true
		end
	end

	return false
end

function Vehicle:isEmpty()
	return self.occupants and table.size(self.occupants) == 0
end

function Vehicle:setDriver(player)
	if not self:getEngineState() then return end

	if self.m_LastDrivers[#self.m_LastDrivers] == player:getName() then
		return
	end

	table.insert(self.m_LastDrivers, player:getName())
	self:setData("lastDrivers", self.m_LastDrivers, true)
end


-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

function Vehicle:getFaction() end

function Vehicle:updateTemplate()
	if self.m_Template then
		self.m_TemplateName = TuningTemplateManager:getSingleton():getNameFromId( self.m_Template ) or ""
		setElementData(self, "TemplateName", self.m_TemplateName)
	end
end

function Vehicle:setTemplate(template)
	self.m_Template = template
end

function Vehicle:getTemplateName()
	return self.m_TemplateName
end

Vehicle.isPermanent = pure_virtual
Vehicle.respawn = pure_virtual
