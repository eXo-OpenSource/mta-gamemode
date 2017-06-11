-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermanentVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)

addRemoteEvents{"clientMagnetGrabVehicle"}

Vehicle.constructor = pure_virtual -- Use PermanentVehicle / TemporaryVehicle instead
function Vehicle:virtual_constructor()
	addEventHandler("onVehicleEnter", self, bind(self.onPlayerEnter, self))
	addEventHandler("onVehicleExit", self, bind(self.onPlayerExit, self))

	self.m_LastUseTime = math.huge
	setVehicleOverrideLights(self, 1)
	setVehicleEngineState(self, false)
	self.m_EngineState = false
	self.m_Fuel = 100
	self.m_Mileage = 0
	self.m_RepairAllowed = true
	self.m_RespawnAllowed = true
	self.m_BrokenHook = Hook:new()

	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		self.m_SpecialSmokeEnabled = false
		self.m_SpecialSmokeInternalToggle = bind(self.toggleInternalSmoke, self)
	end

	self.ms_CustomHornPlayBind = bind(self.playCustomHorn, self)
	self.ms_CustomHornStopBind = bind(self.stopCustomHorn, self)

	addEventHandler("onVehicleRespawn", self, function()
		source:setEngineState(false)
		source:setSirensOn(false)
		setVehicleOverrideLights(self, 1)
	end)

	if self:getModel() == 417 then
		self:addMagnet()
		self.m_MagnetVehicleCheck = bind(Vehicle.magnetVehicleCheck, self)
		self.m_MagnetUp = bind(Vehicle.magnetMoveUp, self)
		self.m_MagnetDown = bind(Vehicle.magnetMoveDown, self)

		addEventHandler("clientMagnetGrabVehicle", root, self.m_MagnetVehicleCheck)
	end
end

function Vehicle:virtual_destructor()
	if self.m_CountdownDestroyTimer and isTimer(self.m_CountdownDestroyTimer) then
		self:countdownDestroyAbort(player)
	end
	VehicleManager:getSingleton():removeRef(self, not self:isPermanent())

	if self.m_Magnet then
		self.m_Magnet:destroy()
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

function Vehicle:playLockEffect()
	triggerClientEvent("vehicleCarlock", self)
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
			bindKey(player, "num_sub", "both", self.m_MagnetUp)
			bindKey(player, "num_add", "both", self.m_MagnetDown)
		end

		player.m_InVehicle = self
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

		if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
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
			unbindKey(player, "num_sub", "both", self.m_MagnetUp)
			unbindKey(player, "num_add", "both", self.m_MagnetDown)
		end

		player.m_InVehicle = nil
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
	else
		setVehicleOverrideLights(self, 1)
		if occ then
			occ:triggerEvent("playLightSFX",true)
		end
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
	if self:hasKey(player) or player:getRank() >= RANK.Moderator or not self:isPermanent() or (self.getCompany and self:getCompany():getId() == 1 and player:getPublicSync("inDrivingLession") == true) then
		local state = not getVehicleEngineState(self)
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
		else
			if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
				self:toggleInternalSmoke()
			end
		end
		if state == true then
			if player and not getVehicleEngineState(self) then
				if VEHICLE_BIKES[self:getModel()] then -- Bikes
					player:meChat(true, "öffnet sein Fahrradschloss!")
					self:setEngineState(state)
					setElementData(self, "syncEngine", state)
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
						setTimer(bind(self.setEngineState, self), 2000, 1, true)
						setTimer(setElementData, 2000, 1 , self, "syncEngine", true)
						return true
					end
				end
			end
			return false
		else
			if VEHICLE_BIKES[self:getModel()] then
				player:meChat(true, "verschließt sein Fahrradschloss!")
			end
			self:setEngineState(state)
			setElementData(self, "syncEngine", state)
			return true
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

	if self:hasKey(player) or player:getRank() >= RANK.Moderator then
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
				setElementFrozen(self, false)
			end
			player:triggerEvent("vehicleHandbrake" )
		end
		self:setData("Handbrake", self.m_HandBrake, true)
	else
		player:sendError(_("Du hast kein Schlüssel für das Fahrzeug!", player))
	end
end

function Vehicle:setEngineState(state)
	setVehicleEngineState(self, state)
	self.m_EngineState = state
	self.m_StartingEnginePhase = false
end

function Vehicle:getEngineState()
	return self.m_EngineState
end

function Vehicle:setFuel(fuel)
	self.m_Fuel = fuel

	-- Switch engine off in case of an empty fuel tank
	if self.m_Fuel <= 0 then
		self:setEngineState(false)
	else
		local driver = getVehicleOccupant(self, 0)
		if driver then
			driver:triggerEvent("vehicleFuelSync", fuel)
		end
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
	if state then
		self:setHealth(VEHICLE_TOTAL_LOSS_HEALTH)
		self:setEngineState(false)
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
		if self and isElement(self) then self:destroy() end
		player:triggerEvent("CountdownStop", "Fahrzeug")
	end, self.m_CountdownDestroy*1000, 1)
end

function Vehicle:countdownDestroyAbort(player)
	if not player then player = self.m_CountdownDestroyPlayer end
	if self.m_CountdownDestroyTimer and isTimer(self.m_CountdownDestroyTimer) then
		player:triggerEvent("CountdownStop", "Fahrzeug")
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

		local isHttp = string.find(texturePath,"http://")
		if isHttp == nil then
			self.m_Texture[textureName] = VehicleTexture:new(self, texturePath, textureName, true, isPreview, player)
		else
			self.m_Texture[textureName] = VehicleTexture:new(self, ("files/images/Textures/Custom/%s"):format(texturePath:sub(35, #texturePath)), textureName, true, isPreview, player)
		end
	end
end

function Vehicle:removeTexture(textureName)
	if textureName then
		delete(self.m_Texture[textureName])
		return
	end

	for i, v in pairs(self.m_Texture) do
		delete(v)
	end
end

function Vehicle:setCurrentPositionAsSpawn(type)
  self.m_PositionType = type
  self.m_SpawnPos = self:getPosition()
  self.m_SpawnRot = self:getRotation()
end

function Vehicle:respawnOnSpawnPosition()
	if self.m_PositionType == VehiclePositionType.World then
		self:setPosition(self.m_SpawnPos)
		self:setRotation(self.m_SpawnRot)
		self:fix()
		self:setEngineState(false)
		self:setLocked(true)
		setVehicleOverrideLights(self, 1)
		self:setFrozen(true)
		self.m_HandBrake = true
		self:setData("Handbrake",  self.m_HandBrake , true )
		self:setSirensOn(false)
		self:resetIndicator()

		if self.despawned then
			self.despawned = false
			self:setDimension(0)
		end

		if self.m_Magnet then
			detachElements(self.m_Magnet)
			self.m_Magnet:attach(self, 0, 0, -1.5)
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
		else
			client:sendError("Das Fahrzeug kann nur auf dem Boden abgestellt werden!")
		end
	else
		local colShape = createColSphere(self.m_Magnet.matrix:transformPosition(Vector3(0, 0, -0.5)), 2)
		local vehicles = getElementsWithinColShape(colShape, "vehicle")
		colShape:destroy()

		for _, vehicle in pairs(vehicles) do
			if vehicle ~= self then
				if vehicle:isRespawnAllowed() then
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
					if not isElement(player) or player.vehicle ~= self then killTimer(self.m_MoveDownTimer) end

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
				if not isElement(player) or player.vehicle ~= self then killTimer(self.m_MoveDownTimer) end

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
		player:triggerEvent("vehicleReceiveTuningList", self, false)
	end
end

-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

function Vehicle:getFaction() end


Vehicle.isPermanent = pure_virtual
Vehicle.respawn = pure_virtual
