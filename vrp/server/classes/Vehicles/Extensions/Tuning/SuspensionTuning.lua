-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/SuspensionTuning.lua
-- *  PURPOSE:     Suspension-Kit Tune for Vehicles
-- *
-- ****************************************************************************


--[[
 suspension: stretch of suspension
 damping: resistance of suspension
 steer: angle of steering
 suspension-height: length of suspension
]]--

SuspensionTuning = inherit( Object )

function SuspensionTuning:constructor( vehicle, suspension, suspensionbias, damping, steer ) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setSuspension( suspension or 1 )
    self:setDamping( damping or 1 )
    self:setSteer( steer or 1 )
    self:setSuspensionBias( suspensionbias or 1)
end

function SuspensionTuning:destructor()
    local steer = self.m_Handling["steeringLock"]
    local suspensionBiasValue = self.m_Handling["suspensionFrontRearBias"]
    local suspensionForce = self.m_Handling["suspensionForceLevel"]
    local suspensionDamping = self.m_Handling["suspensionDamping"]
    local suspensionHeight =  self.m_Handling["suspensionLowerLimit"]
    self.m_Vehicle:setHandling("steeringLock", steer)
    self.m_Vehicle:setHandling("suspensionFrontRearBias", suspensionBiasValue)
    self.m_Vehicle:setHandling("suspensionForceLevel", suspensionForce)
    self.m_Vehicle:setHandling("suspensionDamping", suspensionDamping)
    self.m_Vehicle:setHandling("suspensionLowerLimit", suspensionHeight)

    self.m_Vehicle.m_Tunings:removeTuningKit( self )
end

function SuspensionTuning:setSuspension( suspensionValue ) 
    if not suspensionValue or not tonumber(suspensionValue) then return end
    self.m_Suspension = math.clamp(0, suspensionValue, 100) 
    self.m_Vehicle:setHandling("suspensionForceLevel", self.m_Suspension)
end

function SuspensionTuning:setSuspensionPercentage( suspensionPercentage) 
    if not suspensionPercentage or not tonumber(suspensionPercentage) then return end
    local suspensionForce = self.m_Handling["suspensionForceLevel"]
    self.m_Suspension = math.clamp(0, suspensionForce*suspensionPercentage, 100) 
    self.m_Vehicle:setHandling("suspensionForceLevel", self.m_Suspension)
end

function SuspensionTuning:setSuspensionBias( suspensionBiasValue )
    if not suspensionBiasValue or not tonumber(suspensionBiasValue) then return end
    self.m_SuspensionBias = math.clamp(0, suspensionBiasValue, 1) 
    self.m_Vehicle:setHandling("suspensionFrontRearBias", self.m_SuspensionBias)
end

function SuspensionTuning:setSuspensionBiasPercentage( suspensionBiasPercentage )
    if not suspensionBiasPercentage or not tonumber(suspensionBiasPercentage) then return end
    local suspensionBiasValue = self.m_Handling["suspensionFrontRearBias"]
    self.m_SuspensionBias = math.clamp(0, suspensionBiasValue*suspensionBiasPercentage, 1) 
    self.m_Vehicle:setHandling("suspensionFrontRearBias", self.m_SuspensionBias)
end

function SuspensionTuning:setDamping( dampingValue ) 
    if not dampingValue or not tonumber(dampingValue) then return end 
    self.m_Damping = math.clamp(0, dampingValue, 100) 
    self.m_Vehicle:setHandling("suspensionDamping", self.m_Damping)
end

function SuspensionTuning:setDampingPercentage( dampingPercentage ) 
    if not dampingPercentage or not tonumber(dampingPercentage) then return end
    local suspensionDamping = self.m_Handling["suspensionDamping"]
    self.m_Damping = math.clamp(0, suspensionDamping*dampingPercentage, 100) 
    self.m_Vehicle:setHandling("suspensionDamping", self.m_Damping)
end

function SuspensionTuning:setSteer( steerValue )
    if not steerValue or not tonumber(steerValue) then return end   
    self.m_Steer = math.clamp(0, steerValue, 360) 
    self.m_Vehicle:setHandling("steeringLock", self.m_Steer)
end

function SuspensionTuning:setSteerPercentage( steerPercentage ) 
    if not steerPercentage or not tonumber(steerPercentage) then return end
    local steer = self.m_Handling["steeringLock"]
    self.m_Steer = math.clamp(0, steer*steerPercentage, 360) 
    self.m_Vehicle:setHandling("steeringLock", self.m_Steer)
end

function SuspensionTuning:setSuspensionHeight( suspensionValue )
    if not suspensionValue or not tonumber(suspensionValue) then return end
    self.m_SuspensionHeight = math.clamp(-50, steerValue, 50) 
    self.m_Vehicle:setHandling("suspensionLowerLimit", self.m_SuspensionHeight)
end

function SuspensionTuning:setSuspsnesionHeightPercentage( suspensionPercentage )
    if not suspensionPercentage or not tonumber(suspensionPercentage) then return end
    local suspensionHeight =  self.m_Handling["suspensionLowerLimit"]
    self.m_SuspensionHeight = math.clamp(-50, suspensionPercentage*suspensionHeight, 50) 
    self.m_Vehicle:setHandling("suspensionLowerLimit", self.m_SuspensionHeight)
end

function SuspensionTuning:save() 
    return {1, self.m_Suspension or self.m_Handling["suspensionForceLevel"], self.m_SuspensionBias or self.m_Handling["suspensionFrontRearBias"], 
                self.m_Damping or self.m_Handling["suspensionDamping"], self.m_Steer or self.m_Handling["steeringLock"], self.m_SuspensionHeight or self.m_Handling["suspensionLowerLimit"]}
end

function SuspensionTuning:getFuelMultiplicator()
    return  0 
end