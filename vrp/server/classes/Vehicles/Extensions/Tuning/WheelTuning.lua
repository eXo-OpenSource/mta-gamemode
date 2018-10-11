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
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setTraction( traction or 1 )
    self:setTractionBias( tractionBias or 1 )
end

function WheelTuning:destructor()
    local tractionBiasValue = self.m_Handling["tractionBias"]
    self.m_Vehicle:setHandling("tractionBias", tractionBiasValue)

    local tractionMultiply = self.m_Handling["tractionMultiplier"]
    self.m_Vehicle:setHandling("tractionMultiplier", tractionMultiply)

    self.m_Vehicle.m_Tunings:removeTuningKit( self )
end

function WheelTuning:setTraction( tractionValue  ) 
    self.m_Traction = math.clamp(-100000.0, tractionValue, 100000.0) 
    self.m_Vehicle:setHandling("tractionMultiplier", self.m_Traction)
end

function WheelTuning:setTractionPercentage( tractionPercentage  ) 
    if not tractionPercentage or not tonumber(tractionPercentage) then return end
    local tractionMultiply = self.m_Handling["tractionMultiplier"]
    self.m_Traction = math.clamp(-100000.0, tractionMultiply*tractionPercentage, 100000.0) 
    self.m_Vehicle:setHandling("tractionMultiplier", self.m_Traction)
end

function WheelTuning:setTractionBias( tractionBiasValue ) 
    if not tractionBiasValue or not tonumber(tractionBiasValue) then return end
    self.m_TractionBias = math.clamp(0, tractionBiasValue, 1) 
    self.m_Vehicle:setHandling("tractionBias", self.m_TractionBias)
end

function WheelTuning:setTractionBiasPercentage( tractionBiasPercentage ) 
    if not tractionBiasPercentage or not tonumber(tractionBiasPercentage) then return end
    local tractionBiasValue = self.m_Handling["tractionBias"]
    self.m_TractionBias = math.clamp(0, tractionBiasValue*tractionBiasPercentage, 1) 
    self.m_Vehicle:setHandling("tractionBias", self.m_TractionBias)
end

function WheelTuning:save() 
    return {1, self.m_Traction or self.m_Handling["tractionMultiplier"], self.m_TractionBias or self.m_Handling["tractionBias"]}
end

function WheelTuning:getFuelMultiplicator()
    return  0 
end