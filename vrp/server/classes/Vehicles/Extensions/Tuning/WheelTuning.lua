-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/SuspensionTuning.lua
-- *  PURPOSE:     Wheel-Kit Tune for Vehicles
-- *
-- ****************************************************************************


WheelTuning = inherit( Object )

function WheelTuning:constructor( vehicle, traction, tractionBias ) 
    self.m_Vehicle = vehicle
    self.m_Handling = vehicle:getHandling()
    self:setTraction( traction or 1 )
    self:setTractionBias( tractionBias or 1 )
end

function WheelTuning:setTraction( traction  ) 
    local tractionMultiply = self.m_Handling["tractionMultiplier"]
    self.m_Traction = math.clamp(-100000.0, tractionMultiply*traction, 100000.0) 
    self.m_Vehicle:setHandling("tractionMultiplier", self.m_Traction)
end

function WheelTuning:setTractionBias( tractionBias ) 
    local tractionBiasValue = self.m_Handling["tractionBias"]
    self.m_TractionBias = math.clamp(0, tractionBiasValue*tractionBias, 1) 
    self.m_Vehicle:setHandling("tractionBias", self.m_TractionBias)
end

function WheelTuning:remove()
    local tractionBiasValue = self.m_Handling["tractionBias"]
    self.m_Vehicle:setHandling("tractionBias", tractionBiasValue)

    local tractionMultiply = self.m_Handling["tractionMultiplier"]
    self.m_Vehicle:setHandling("tractionMultiplier", tractionMultiply)
end

function WheelTuning:save() 
    return {1, self.m_Traction or 0, self.m_TractionBias or 0}
end

function WheelTuning:getFuelMultiplicator()
    return  0 
end