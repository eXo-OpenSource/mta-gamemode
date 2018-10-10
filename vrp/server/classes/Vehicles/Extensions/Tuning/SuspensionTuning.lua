-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/SuspensionTuning.lua
-- *  PURPOSE:     Suspension-Kit Tune for Vehicles
-- *
-- ****************************************************************************


--[[
 suspension: Height of suspension
 damping: resistance of suspension
 steer: angle of steering
]]--

SuspensionTuning = inherit( Object )

function SuspensionTuning:constructor( vehicle, suspension, suspensionbias, damping, steer ) 
    self.m_Vehicle = vehicle
    self.m_Handling = vehicle:getHandling()
    self:setSuspension( suspension or 1 )
    self:setDamping( damping or 1 )
    self:setSteer( steer or 1 )
    self:setSuspensionBias( suspensionbias or 1)
end

function SuspensionTuning:setSuspension( suspension ) 
    local suspensionForce = self.m_Handling["suspensionForceLevel"]
    self.m_Suspension = math.clamp(0, suspensionForce*suspension, 100) 
    self.m_Vehicle:setHandling("suspensionForceLevel", self.m_Suspension)
end

function SuspensionTuning:setSuspensionBias( suspensionbias ) 
    local suspensionBiasValue = self.m_Handling["suspensionFrontRearBias"]
    self.m_SuspensionBias = math.clamp(0, suspensionBiasValue*suspensionbias, 1) 
    self.m_Vehicle:setHandling("suspensionFrontRearBias", self.m_SuspensionBias)
end

function SuspensionTuning:setDamping( damping ) 
    local suspensionDamping = self.m_Handling["suspensionDamping"]
    self.m_Damping = math.clamp(0, suspensionDamping*damping, 100) 
    self.m_Vehicle:setHandling("suspensionDamping", self.m_Damping)
end

function SuspensionTuning:setSteer( steerPercentage ) 
    local steer = self.m_Handling["steeringLock"]
    self.m_Steer = math.clamp(0, steer*steerPercentage, 360) 
    self.m_Vehicle:setHandling("steeringLock", self.m_Steer)
end

function SuspensionTuning:remove() 
    local steer = self.m_Handling["steeringLock"]
    local suspensionBiasValue = self.m_Handling["suspensionFrontRearBias"]
    local suspensionForce = self.m_Handling["suspensionForceLevel"]
    local suspensionDamping = self.m_Handling["suspensionDamping"]
    self.m_Vehicle:setHandling("steeringLock", steer)
    self.m_Vehicle:setHandling("suspensionFrontRearBias", suspensionBiasValue)
    self.m_Vehicle:setHandling("suspensionForceLevel", suspensionForce)
    self.m_Vehicle:setHandling("suspensionDamping", suspensionDamping)
end

function SuspensionTuning:save() 
    return {1, self.m_Suspension or 0, self.m_SuspensionBias or 0, self.m_Damping or 0, self.m_Steer or 0}
end

function SuspensionTuning:getFuelMultiplicator()
    return  0 
end