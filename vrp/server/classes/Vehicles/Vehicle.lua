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
	addEventHandler("onVehicleExit", self, bind(self.onPlayerExit, self))
	
	self.m_LastUseTime = math.huge
	setVehicleOverrideLights(self, 1)
	setVehicleEngineState(self, false)
	self.m_EngineState = false
	self.m_Fuel = 100
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

function Vehicle:setLocked(state)
	-- Todo: Play lock animation (flashing lights)

	return setVehicleLocked(self, state)
end

function Vehicle:isLocked()
	return isVehicleLocked(self)
end

function Vehicle:onPlayerExit(player)
	self.m_LastUseTime = getTickCount()
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
	if self:hasKey(player) or not self:isPermanent() then
		local state = not getVehicleEngineState(self)
		if state == true and self.m_Fuel <= 0 then
			player:sendError(_("Dein Tank ist leer!", player))
			return false
		end
		
		self:setEngineState(state)
		return true
	end
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
		setVehicleEngineState(self, false)
		self.m_EngineState = false
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

Vehicle.isPermanent = pure_virtual
Vehicle.respawn = pure_virtual
