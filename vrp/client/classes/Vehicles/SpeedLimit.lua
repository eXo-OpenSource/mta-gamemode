-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/SpeedLimit.lua
-- *  PURPOSE:     Vehicle cruise control
-- *
-- ****************************************************************************
SpeedLimit = inherit(Singleton)
local SPEED_VECTOR_RELATION = 195
local DEFAULT_CRUISE_SPEED = 80

function SpeedLimit:constructor()
	self.m_Enabled = false
	self.m_Speed = false

	self.m_CruiseTimer = false
end

function SpeedLimit:setEnabled(enabled)
	if self.m_Enabled == enabled then
		return
	end

	self.m_Enabled = enabled

	if enabled then
		self.m_CruiseTimer = setTimer(bind(self.Tick_CruiseTimer, self), 50, 0)
		self.m_Speed = localPlayer.vehicle:getVelocity():getLength() -- self:getDefaultSpeed()
	else
		killTimer(self.m_CruiseTimer)
		self.m_CruiseTimer = false

		self.m_Speed = false
	end
end

function SpeedLimit:isEnabled()
	return self.m_Enabled
end

function SpeedLimit:setSpeed(speed)
	self.m_Speed = speed / SPEED_VECTOR_RELATION
end

function SpeedLimit:getSpeed()
	return self.m_Speed and self.m_Speed * SPEED_VECTOR_RELATION
end

function SpeedLimit:getDefaultSpeed()
	return DEFAULT_CRUISE_SPEED / SPEED_VECTOR_RELATION
end

function SpeedLimit:Tick_CruiseTimer()
	local vehicle = localPlayer:getOccupiedVehicle()
	if not vehicle then
		-- Disable cruise control
		self:setEnabled(false)
		return
	end

	-- Reset speed if it is bigger than our treshold
	local speed = vehicle:getVelocity():getLength()
	if speed > self.m_Speed then
		vehicle:setVelocity(vehicle:getVelocity():getNormalized() * self.m_Speed)
	end
end
