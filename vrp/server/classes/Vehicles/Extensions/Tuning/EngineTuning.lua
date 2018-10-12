-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/EngineTuning.lua
-- *  PURPOSE:     Engine-Kit Tune for Vehicles
-- *
-- ****************************************************************************

--[[
    Enginekit

    Pro: Higher acceleration, Possibility to max endspeed

    Con: More fuel-loss
        
]]--
EngineTuning = inherit( Object )
EngineTuning.Identifiers = {
    ["rwd"] = true,
    ["awd"] = true,
    ["fwd"] = true,
}
EngineTuning.Properties = 
{
    ["engineAcceleration"] = true, 
    ["driveType"] = true,
}

function EngineTuning:constructor( vehicle, acceleration, type ) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setAcceleration(acceleration)
    self:setType(type)
end

function EngineTuning:destructor()
    local acceleration = self.m_Handling["engineAcceleration"]
    local driveType = self.m_Handling["driveType"]
    self.m_Vehicle:setHandling("engineAcceleration", acceleration)
    self.m_Vehicle:setHandling("driveType", driveType)
    self.m_Vehicle:setData("TurboKit", 0, true)
    self.m_Vehicle.m_Tunings:removeTuningKit( self )
end

function EngineTuning:setAcceleration( accelerationValue )
    if not accelerationValue or not tonumber(accelerationValue) then return end
    self.m_Acceleration = math.clamp( 0, accelerationValue, 100000.0)
    self.m_Vehicle:setHandling("engineAcceleration", self.m_Acceleration)

    if self.m_Handling["engineAcceleration"] - self.m_Acceleration > 0 then -- needed clientside for turbo effect but only if the acceleration has increased
        self.m_Vehicle:setData("TurboKit", self.m_Handling["engineAcceleration"] - self.m_Acceleration, true)
    end
end

function EngineTuning:setType( drive )
    if EngineTuning.Identifiers[drive] then
        self.m_Type = drive
        self.m_Vehicle:setHandling("driveType", drive)
    end
end

function EngineTuning:setAccelerationPercentage( accelerationPercentage )
    if not accelerationPercentage or not tonumber(accelerationPercentage) then return end
    local acceleration = self.m_Handling["engineAcceleration"]
    self.m_Acceleration = math.clamp( 0, acceleration + acceleration*accelerationPercentage, 100000.0)
    self.m_Vehicle:setHandling("engineAcceleration", self.m_Acceleration)

    if self.m_Handling["engineAcceleration"] - self.m_Acceleration > 0 then -- needed clientside for turbo effect but only if the acceleration has increased
        self.m_Vehicle:setData("TurboKit", self.m_Handling["engineAcceleration"] - self.m_Acceleration, true)
    end
end

function EngineTuning:save() 
    return {1, self.m_Acceleration or self.m_Handling["engineAcceleration"], self.m_Type or self.m_Handling["driveType"]}
end

function EngineTuning:getFuelMultiplicator()
    return self.m_Acceleration*0.05 -- 5% more fuel-consumption
end