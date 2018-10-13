-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/SuspensionTuning.lua
-- *  PURPOSE:     Wheel-Kit Tune for Vehicles
-- *
-- ****************************************************************************


WheelTuning = inherit( Object )
WheelTuning.Properties = 
{
    ["tractionMultiplier"] = true, 
    ["tractionBias"] = true,
    ["tractionLoss"] = true,
}

function WheelTuning:constructor( vehicle, traction, tractionBias, tractionLoss ) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setTraction( traction)
    self:setTractionBias(tractionBias)
    self:setTractionLoss(tractionLoss)
end

function WheelTuning:destructor()
    for property, bool in pairs(WheelTuning.Properties) do 
        self.m_Vehicle:setHandling(property, self.m_Handling[property])
    end
end

function WheelTuning:setTraction( tractionValue  ) 
    if not tractionValue or not tonumber(tractionValue) then return end
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
    self.m_TractionBias = math.clamp(0, tractionBiasValue + tractionBiasValue*tractionBiasPercentage, 1) 
    self.m_Vehicle:setHandling("tractionBias", self.m_TractionBias)
end

function WheelTuning:setTractionLoss( tractionLossValue ) 
    if not tractionLossValue or not tonumber(tractionLossValue) then return end
    self.m_TractionLoss = math.clamp(0, tractionLossValue, 100) 
    self.m_Vehicle:setHandling("tractionLoss", self.m_TractionLoss)
end

function WheelTuning:setTractionLossPercentage( tractionLossPercentage ) 
    if not tractionLossPercentage or not tonumber(tractionLossPercentage) then return end
    local tractionLoss = self.m_Handling["tractionLoss"]
    self.m_TractionLoss = math.clamp(0, tractionLoss + tractionLoss*tractionLossPercentage, 1) 
    self.m_Vehicle:setHandling("tractionBias", self.m_TractionBias)
end

function WheelTuning:save() 
    return {1, self.m_Traction or self.m_Handling["tractionMultiplier"], self.m_TractionBias or self.m_Handling["tractionBias"], 
            self.m_TractionLoss or self.m_Handling["tractionLoss"]}
end

function WheelTuning:getFuelMultiplicator()
    return  0 
end