-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermanentVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)

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
end

function Vehicle:virtual_destructor()
	if self.m_CountdownDestroyTimer and isTimer(self.m_CountdownDestroyTimer) then
		self:countdownDestroyAbort(player)
	end
	VehicleManager:getSingleton():removeRef(self, not self:isPermanent())
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
	if self.m_DisableToggleEngine then return end
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
			if VEHICLE_BIKES[self:getModel()] then -- Bikes
				player:meChat(true, "verschließt sein Fahrradschloss!")
			end
			self:setEngineState(state)
			setElementData(self, "syncEngine", state)
			return true
		end
	end
	if VEHICLE_BIKES[self:getModel()] then -- Bikes
		player:sendError(_("Du hast keinen Schlüssel für das Fahrradschloss!", player))
	else
		player:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug!", player))
	end
	return false
end

function Vehicle:toggleHandBrake( player )
	if self.m_DisableToggleHandbrake then return end
	if not self.m_HandBrake then
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
end

function Vehicle:setEngineState(state)
	--local player = getVehicleOccupant(self, 0)
	--if player then
		setVehicleEngineState(self, state)
		self.m_EngineState = state
	--end
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
	local speed = (vx^2 + vy^2 + vz^2) ^ 0.5 * 161
	return speed
end

function Vehicle:setBroken(state)
	self:setHealth(301)
	if state then
		self:setEngineState(false)
	end

	if self.m_BrokenHook then
		self.m_BrokenHook:call(vehicle)
		return
	end
end

function Vehicle:isBroken()
	return self:getHealth() <= 301.01
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

function Vehicle:toggleRespawn(state)
	self.m_RespawnAllowed = state
end

function Vehicle:isRespawnAllowed()
	return self.m_RespawnAllowed
end

function Vehicle:getTexture()
	return self.m_Texture
end

function Vehicle:setTexture(texturePath, textureName, force)
	if texturePath and #texturePath > 3 then

		local isPng = string.find(texturePath,".png")
		local isJpg = string.find(texturePath,".jpg")
		local isHttp = string.find(texturePath,"http://")
		if isHttp == nil then
			self.m_Texture = VehicleTexture:new(self, texturePath, textureName, force)
		elseif isHttp then
			self.m_Texture = VehicleTexture:new(self, ("files/images/Textures/Custom/%s"):format(texturePath:sub(35, #texturePath)), textureName, force)
		end
	end
end

function Vehicle:removeTexture()
	delete(self.m_Texture)
end

function Vehicle:setCurrentPositionAsSpawn(type)
  self.m_PositionType = type
  self.m_SpawnPos = self:getPosition()
  local rot = self:getRotation()
  self.m_SpawnRot = rot.z
end

function Vehicle:respawnOnSpawnPosition()
	if self.m_PositionType == VehiclePositionType.World then
		self:setPosition(self.m_SpawnPos)
		self:setRotation(0, 0, self.m_SpawnRot)
		fixVehicle(self)
		self:setEngineState(false)
		self:setLocked(true)
		setVehicleOverrideLights(self, 1)
		self:setFrozen(true)
		self.m_HandBrake = true
		self:setData( "Handbrake",  self.m_HandBrake , true )
		self:setSirensOn(false)
		self:resetIndicator()
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

-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

Vehicle.isPermanent = pure_virtual
Vehicle.respawn = pure_virtual
