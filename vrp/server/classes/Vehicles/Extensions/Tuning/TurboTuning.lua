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

function TurboTuning:constructor( vehicle, percentage ) 
    self.m_Vehicle = vehicle
    self.m_Handling = vehicle:getHandling()
    self:setTurboScale(percentage or 0)
end

function TurboTuning:setTurboScale( percentage )
    self.m_TurboScale = percentage
    local acceleration = self.m_Handling["engineAcceleration"]
    self.m_Turbo = math.clamp( 0, acceleration + self.m_TurboScale*percentage, 100000.0)
    self.m_Vehicle:setHandling("engineAcceleration", self.m_Turbo)
    self.m_Vehicle:setData("TurboKit", self.m_TurboScale, true)
end

function TurboTuning:remove() 
    local acceleration = self.m_Handling["engineAcceleration"]
    self.m_Vehicle:setHandling("engineAcceleration", acceleration)
    self.m_Vehicle:setData("TurboKit", 0, true)
end

function TurboTuning:save() 
    return {1, self.m_TurboScale or 0}
end

function TurboTuning:getFuelMultiplicator()
    return self.m_TurboScale*0.5 -- 100% acceleration means 50% more fuel-consumption
end