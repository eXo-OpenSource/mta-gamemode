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
    ["engineInertia"] = true,
    ["maxVelocity"] = true,
}

function EngineTuning:constructor( vehicle, acceleration, speed, type, inertia ) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setAcceleration(acceleration)
    self:setTopSpeed(speed)
    self:setType(type)
    self:setInertia(inertia)
end

function EngineTuning:destructor()
    for property, bool in pairs(EngineTuning.Properties) do 
        self.m_Vehicle:setHandling(property, self.m_Handling[property])
    end

    self.m_Vehicle:setHandling("engineAcceleration", acceleration)
    self.m_Vehicle:setHandling("driveType", driveType)
    self.m_Vehicle:setData("TurboKit", 0, true)
end

function EngineTuning:setAcceleration( accelerationValue )
    if not accelerationValue or not tonumber(accelerationValue) then return end
    self.m_Acceleration = math.clamp( 0, accelerationValue, 100000.0)
    self.m_Vehicle:setHandling("engineAcceleration", self.m_Acceleration)

    if self.m_Handling["engineAcceleration"] - self.m_Acceleration > 0 then -- needed clientside for turbo effect but only if the acceleration has increased
        self.m_Vehicle:setData("TurboKit", self.m_Handling["engineAcceleration"] - self.m_Acceleration, true)
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

function EngineTuning:setType( drive )
    if EngineTuning.Identifiers[drive] then
        self.m_Type = drive
        self.m_Vehicle:setHandling("driveType", drive)
    end
end

function EngineTuning:setTopSpeed( speedValue )
    if not speedValue or not tonumber(speedValue) then return end
    speedValue = speedValue - VEHICLE_SPEEDO_MAXVELOCITY_OFFSET
    self.m_TopSpeed = math.clamp( 0.1, speedValue, 200000.0)
    self.m_Vehicle:setHandling("maxVelocity", self.m_TopSpeed)
end

function EngineTuning:setTopSpeedPercentage( speedPercentage )
    if not speedPercentage or not tonumber(speedPercentage) then return end
    local maxVelocity = self.m_Handling["maxVelocity"]
    self.m_TopSpeed = math.clamp( 0.1, (maxVelocity + speedPercentage*maxVelocity) - VEHICLE_SPEEDO_MAXVELOCITY_OFFSET, 200000.0)
    self.m_Vehicle:setHandling("maxVelocity", self.m_Speed)
end


function EngineTuning:setInertia( inertiaValue )
    if not inertiaValue or not tonumber(inertiaValue) then return end
    self.m_Inertia = math.clamp( -1000, inertiaValue, 1000)
    self.m_Vehicle:setHandling("engineInertia", self.m_Inertia)
end

function EngineTuning:setInertiaPercentage( inertiaPercentage )
    if not inertiaPercentage or not tonumber(inertiaPercentage) then return end
    local inertia = self.m_Handling["engineInertia"]
    self.m_Inertia = math.clamp( -1000, inertia + inertiaPercentage*inertia, 1000)
    self.m_Vehicle:setHandling("engineInertia", self.m_Inertia)
end

function EngineTuning:save() 
    return {1, self.m_Acceleration or self.m_Handling["engineAcceleration"], self.m_TopSpeed or self.m_Handling["maxVelocity"], 
            self.m_Type or self.m_Handling["driveType"], self.m_Inertia or self.m_Handling["engineInertia"]}
end

function EngineTuning:getFuelMultiplicator()
    return self.m_Acceleration*0.05 -- 5% more fuel-consumption
end