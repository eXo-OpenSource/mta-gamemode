-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/TurboTuning.lua
-- *  PURPOSE:     Turbo-Kit Tune for Vehicles
-- *
-- ****************************************************************************

--[[
    Turbokit

    Pro: Higher acceleration, Possibility to max endspeed

    Con: More fuel-loss
        
]]--
TurboTuning = inherit( Object )

function TurboTuning:constructor( vehicle, acceleration ) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setAcceleration(acceleration)
end

function TurboTuning:destructor()
    local acceleration = self.m_Handling["engineAcceleration"]
    self.m_Vehicle:setHandling("engineAcceleration", acceleration)
    self.m_Vehicle:setData("TurboKit", 0, true)
    self.m_Vehicle.m_Tunings:removeTuningKit( self )
end

function TurboTuning:setAcceleration( accelerationValue )
    if not accelerationValue or not tonumber(accelerationValue) then return end
    self.m_Acceleration = math.clamp( 0, accelerationValue, 100000.0)
    self.m_Vehicle:setHandling("engineAcceleration", self.m_Acceleration)

    if self.m_Handling["engineAcceleration"] - self.m_Acceleration > 0 then -- needed clientside for turbo effect but only if the acceleration has increased
        self.m_Vehicle:setData("TurboKit", self.m_Handling["engineAcceleration"] - self.m_Acceleration, true)
    end
end

function TurboTuning:setAccelerationPercentage( accelerationPercentage )
    if not accelerationPercentage or not tonumber(accelerationPercentage) then return end
    local acceleration = self.m_Handling["engineAcceleration"]
    self.m_Acceleration = math.clamp( 0, acceleration + acceleration*accelerationPercentage, 100000.0)
    self.m_Vehicle:setHandling("engineAcceleration", self.m_Acceleration)

    if self.m_Handling["engineAcceleration"] - self.m_Acceleration > 0 then -- needed clientside for turbo effect but only if the acceleration has increased
        self.m_Vehicle:setData("TurboKit", self.m_Handling["engineAcceleration"] - self.m_Acceleration, true)
    end
end

function TurboTuning:save() 
    return {1, self.m_Acceleration or self.m_Handling["engineAcceleration"]}
end

function TurboTuning:getFuelMultiplicator()
    return self.m_TurboScale*0.5 -- 100% acceleration means 50% more fuel-consumption
end