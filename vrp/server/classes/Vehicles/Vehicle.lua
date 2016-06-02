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

	self.m_BrokenHook = Hook:new()


	if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
		self.m_SpecialSmokeEnabled = false
		self.m_SpecialSmokeInternalToggle = bind(self.toggleInternalSmoke, self)
	end

	self.ms_CustomHornPlayBind = bind(self.playCustomHorn, self)
end

function Vehicle:virtual_destructor()
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
	if seat == 0 then
		if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
			bindKey(player, "sub_mission", "down", self.m_SpecialSmokeInternalToggle)
		end
		if self.m_CustomHorn and self.m_CustomHorn > 0 then
			player:sendShortMessage(_("Du kannst die Spezialhupe mit 'J' benutzen!", player))
			bindKey(player, "j", "down", self.ms_CustomHornPlayBind)
		end
	end
end

function Vehicle:onPlayerExit(player, seat)
	self.m_LastUseTime = getTickCount()

	if seat == 0 then
		if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
			self:toggleInternalSmoke()
			unbindKey(player, "sub_mission", "down", self.m_SpecialSmokeInternalToggle)
		end
		if isKeyBound(player, "j", "down", self.ms_CustomHornPlayBind) then
			unbindKey(player, "j", "down", self.ms_CustomHornPlayBind)
		end
	end
end

function Vehicle:playCustomHorn(player)
	if self.m_CustomHorn and self.m_CustomHorn > 0 then
		if player:getOccupiedVehicle() == self and player:getOccupiedVehicleSeat() == 0 then
			triggerClientEvent("vehiclePlayCustomHorn", self, self.m_CustomHorn)
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
	if getVehicleOverrideLights(self) == 1 then
		setVehicleOverrideLights(self, 2)
	else
		setVehicleOverrideLights(self, 1)
	end
end

function Vehicle:toggleEngine(player)
	if self:hasKey(player) or player:getRank() >= RANK.Moderator or not self:isPermanent() then
		local state = not getVehicleEngineState(self)
		if state == true then
			if self.m_Fuel <= 0 then
				player:sendError(_("Dein Tank ist leer!", player))
				return false
			end
			if self:isBroken() then
				player:sendError(_("Das Fahrzeug ist kaputt und muss erst repariert werden!", player))
				return false
			end
		else
			if VEHICLE_SPECIAL_SMOKE[self:getModel()] then
				self:toggleInternalSmoke()
			end
		end

		self:setEngineState(state)
		return true
	end

	player:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug!", player))
	return false
end

function Vehicle:setEngineState(state)
	setVehicleEngineState(self, state)
	self.m_EngineState = state

	local player = getVehicleOccupant(self, 0)
	if player and getVehicleEngineState(self) then
		player:triggerEvent("vehicleEngineStart")
	end
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
end

function Vehicle:getMileage()
	if not self.m_Mileage then
		outputDebug("Invalid mileage detected. Vehicle: "..self:getName())
		return 0
	end

	return self.m_Mileage
end

function Vehicle:setBroken(state)
	self:setHealth(301)
	if state then
		self:setEngineState(false)
		if self.m_BrokenHook then
			self.m_BrokenHook:call(vehicle)
		end
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

-- Override it
function Vehicle:getVehicleType()
	return getVehicleType(self)
end

Vehicle.isPermanent = pure_virtual
Vehicle.respawn = pure_virtual
