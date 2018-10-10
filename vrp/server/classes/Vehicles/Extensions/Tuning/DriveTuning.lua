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
    self.m_Handling = vehicle:getHandling()
    self:setType(type or self.m_Handling["driveType"])
end

function DriveTuning:setType( drive )
    if DriveTuning.Identifiers[drive] then
        self.m_Type = drive
        self.m_Vehicle:setHandling("driveType", drive)
    end
end

function DriveTuning:remove() 
    self.m_Vehicle:setHandling("driveType", self.m_Handling["driveType"])
end

function DriveTuning:save()
    return {1, self.m_Type or ""}
end

function DriveTuning:getFuelMultiplicator()
    return 0
end