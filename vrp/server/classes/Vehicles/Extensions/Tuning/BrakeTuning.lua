-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/BrakeTuning.lua
-- *  PURPOSE:     Brake-Kit Tune for Vehicles
-- *
-- ****************************************************************************


--[[
    BrakeBias

    Increasing Front bias: Shown as a larger number, increasing brake bias to the front will put more braking force into the front tires. 
    This will stabilize the car in braking zones and increase understeer at corner entry. 
    The compromise is that with too much front bias the rear tires are being under‐utilized and overall braking efficiency will suffer. 
    This can also cause rapid front tire wear due to front tire lockup, especially of the inside tire which is the first to lock up.


    Reducing Front bias: This puts more braking on the rear tires, which, within limits, improves braking efficiency. Too much rear brake bias, though, hurts performance in two ways.
    First, it reduces overall braking efficiency. More seriously, too much rear brake bias, particularly if the driver is not braking in a straight line or has weak footwork on downshifts, 
    can cause the rear tires to lock up, which puts the car in a dynamically unstable condition that can easily result in loss of vehicle control. 
    Note that with a moderate amount of rear‐brake bias, the car will have a tendency to rotate (OVERsteer) at corner entry upon brake release.
        
]]--

BrakeTuning = inherit( Object )

function BrakeTuning:constructor( vehicle, strength, bias) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setBrake(strength)
    self:setBias(bias)
end

function BrakeTuning:destructor()
    local brake = self.m_Handling["brakeDeceleration"]
    self.m_Vehicle:setHandling("brakeDeceleration", brake)

    local bias = self.m_Handling["brakeBias"]
    self.m_Vehicle:setHandling("brakeBias", bias)

    self.m_Vehicle.m_Tunings:removeTuningKit( self )

end

function BrakeTuning:setBrake( brakeValue )
    if not brakeValue or not tonumber(brakeValue) then return end
    self.m_Brake = math.clamp(0.1, brakeValue, 100000)
    self.m_Vehicle:setHandling("brakeDeceleration", self.m_Brake)
end

function BrakeTuning:setBrakePercentage( brakePercentage )
    if not brakePercentage or not tonumber(brakePercentage) then return end
    local brake = self.m_Handling["brakeDeceleration"]
    self.m_Brake = math.clamp(0.1, brake * brakePercentage, 100000) 
    self.m_Vehicle:setHandling("brakeDeceleration", self.m_Brake)
end

function BrakeTuning:setBias( biasValue )
    if not biasValue or not tonumber(biasValue) then return end
    self.m_Bias = math.clamp(0, biasValue, 1) 
    self.m_Vehicle:setHandling("brakeBias", self.m_Bias)
end

function BrakeTuning:setBiasPercentage( biasPercentage ) -- bias is in percentage 0.5 means move it 50% more to the rear; 1.5 = 50% more to the front
    if not biasPercentage or not tonumber(biasPercentage) then return end
    local bias = self.m_Handling["brakeBias"]
    self.m_Bias = math.clamp(0, bias * biasPercentage, 1) -- 0.5 is the center; 1 front; 0 rear
    self.m_Vehicle:setHandling("brakeBias", self.m_Bias)
end

function BrakeTuning:save() 
    return {1, self.m_Brake or self.m_Handling["brakeDeceleration"], self.m_Bias or self.m_Handling["brakeBias"]}
end

function BrakeTuning:getFuelMultiplicator()
    return  0 
end