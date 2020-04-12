-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleTransportExtension.lua
-- *  PURPOSE:     extension for the Vehicle class to attach other vehicles to it
-- *
-- ****************************************************************************

VehicleTransportExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object
VehicleTransportExtension.RampMovementTime = 5000
VehicleTransportExtension.Presets = {
    [578] = {
        boundingBox = {-1.5, -5.6, 0, -1.5, 2.2, 1.5},
        rampId = 1874,
        doubleRamps = false,
        rampOffset = {
            {0, -5.59, -0.35}, -- ramp on dft
            {0, -2.02, 0} -- second ramp attached to first ramp
        },
        rampRotation = {
            open = {
                {15, 0, 0},
                {0, 0, 0}
            },
            closed = {
                {-90, 0, 0},
                {180, 0, 0}
            }
        }
    }
}


function VehicleTransportExtension:initTransportExtension()
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    if not tbl then return end
    if not tbl.rampId then return end
    self.m_RampData = {}

    self:setData("VehicleTransporterWithRamp", true, true)

    self:internalCreateRamps(tbl.rampId, tbl.rampOffset[1], tbl.rampRotation.closed[1], tbl.rampOffset[2], tbl.rampRotation.closed[2])
    if (tbl.doubleRamps) then
        local offs1 = table.copy(tbl.rampOffset[1])
        offs1[1] = -offs1[1]
        self:internalCreateRamps(tbl.rampId, offs1, tbl.rampRotation.closed[1], tbl.rampOffset[2], tbl.rampRotation.closed[2], true)
    end
    self:internalAttachRamps(false)
end


function VehicleTransportExtension:internalCreateRamps(rampId, rampPos1, rampRot1, rampPos2, rampRot2, doubleRamp)

    local ramp1 = createObject(rampId, 0, 0, 0)
    table.insert(self.m_RampData, ramp1)

    local ramp2 = createObject(rampId, 0, 0, 0)
    table.insert(self.m_RampData, ramp2)
end

function VehicleTransportExtension:internalAttachRamps(open, debug)
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    if not tbl then return end
    if not tbl.rampId then return end
    for i, v in ipairs(self.m_RampData) do
        local pos = tbl.rampOffset[(i + 1) % 2 + 1]
        local rot = open and tbl.rampRotation.open[(i + 1) % 2 + 1] or tbl.rampRotation.closed[(i + 1) % 2 + 1]
        detachElements(v)
        attachElements(v, (i == 2 or i == 4) and self.m_RampData[i-1] or self, (i == 3) and -pos[1] or pos[1], pos[2], pos[3] + (debug or 0), rot[1], rot[2], rot[3])
    end
end

function VehicleTransportExtension:internalDetachRamps()
    for i, v in pairs(self.m_RampData) do
        local x, y, z, rx, ry, rz = v:getAttachedOffsets()
        detachElements(v)

        if (i == 1 or i == 3) then -- main ramps
            setElementPosition(v, getPositionFromElementOffset(self, x, y, z))
            setElementRotation(v, self.rotation.x + rx, self.rotation.y + ry, self.rotation.z + rz)
        else -- secondary ramps
            local ramp = self.m_RampData[i-1]
            setElementPosition(v, getPositionFromElementOffset(ramp, x, y, z))
            setElementRotation(v, ramp.rotation.x + rx, ramp.rotation.y + ry, ramp.rotation.z + rz)
        end
    end
end


function VehicleTransportExtension:toggleLoadingMode()
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    if not tbl then return end
    if not tbl.rampId then return end
    if self:getVelocity().length > 1 then return end -- prevent loading in mid-driving
    local startRotation, endRotation
    if self.m_VehicleTransportLoadingMode then --close the ramps
        startRotation, endRotation = tbl.rampRotation.open, tbl.rampRotation.closed
        self:internalAttachRamps(true)
        setTimer(function()
            self:internalAttachRamps(false)
            self.m_DisableToggleHandbrake = false
            self:setFrozen(false)
            setVehicleHandling(self, "suspensionUpperLimit", nil, true)
		    setVehicleHandling(self, "suspensionLowerLimit", nil, true)
        end, VehicleTransportExtension.RampMovementTime + 100, 1) -- +100 to take lag into account
    else --open the ramps
    
        setVehicleHandling(self, "suspensionUpperLimit", 0.6)
        setVehicleHandling(self, "suspensionLowerLimit", 0.1)
        setElementVelocity(self, 0, 0, 0.005)
        setTimer(function() -- give the vehicle time to lower
            self:setFrozen(true)
            self.m_DisableToggleHandbrake = true
        end, 500, 1)
        startRotation, endRotation = tbl.rampRotation.closed, tbl.rampRotation.open
        setTimer(function()
            self:internalAttachRamps(true) -- attach to open state for correct position
            self:internalDetachRamps() -- detach ramps to prevent collision bugs
        end, VehicleTransportExtension.RampMovementTime + 100, 1) 
    end
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "vehicleTransportExtensionAnimateRamps", self, self.m_RampData, startRotation, endRotation, VehicleTransportExtension.RampMovementTime)
    self.m_VehicleTransportLoadingMode = not self.m_VehicleTransportLoadingMode
end

function VehicleTransportExtension:checkForTransporter(vehicleToTransport)
    --if 

end