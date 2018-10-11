-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/vehicles/extensions/tuning/DriveTuning.lua
-- *  PURPOSE:     Drive-Kit Tune for Vehicles
-- *
-- ****************************************************************************

DriveTuning = inherit( Object )
DriveTuning.Identifiers = {
    ["rwd"] = true,
    ["awd"] = true,
    ["fwd"] = true,
}
function DriveTuning:constructor( vehicle, type ) 
    self.m_Vehicle = vehicle
    self.m_Handling = getOriginalHandling(vehicle:getModel())
    self:setType(type or self.m_Handling["driveType"])
end

function DriveTuning:destructor()
    self.m_Vehicle:setHandling("driveType", self.m_Handling["driveType"])
    self.m_Vehicle.m_Tunings:removeTuningKit( self )
end


function DriveTuning:setType( drive )
    if DriveTuning.Identifiers[drive] then
        self.m_Type = drive
        self.m_Vehicle:setHandling("driveType", drive)
    end
end

function DriveTuning:save()
    return {1, self.m_Type or self.m_Handling["driveType"]}
end

function DriveTuning:getFuelMultiplicator()
    return 0
end