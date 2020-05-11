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
        boundingBox = {-1.5, -5.6, 0, 1.5, 2.2, 1.5},
        rampId = 1874,
        doubleRamps = false,
        rampOffset = {
            {0, -5.58, -0.36}, -- ramp on dft
            {0, -2.03, 0} -- second ramp attached to first ramp
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
        },
        extraObjects = {
            {18074, -1.42, -1.55, -0.18, 0, 0, 0, 0.75},
            {18074, 1.42, -1.55, -0.18, 0, 0, 0, 0.75}
        }
    }
}


function VehicleTransportExtension:initTransportExtension()
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    if not tbl then return end

    self.vehicleTransportVehicle = true
    self.m_LoadingZoneHitFunc = bind(self.Event_OnLoadingZoneHit, self)
    self.m_LoadingZoneLeaveFunc = bind(self.Event_OnLoadingZoneLeave, self)
    self.m_LoadingZoneVehicleHandBrakeFunc = bind(self.internalCheckVehicleLoading, self)

    self.m_TransportVehicleEnterFunc = bind(self.internalTransportVehicleOnEnter, self)
    self.m_TransportVehicleExitFunc = bind(self.internalTransportVehicleOnExit, self)
    addEventHandler("onVehicleEnter", self, self.m_TransportVehicleEnterFunc)
    addEventHandler("onVehicleExit", self, self.m_TransportVehicleExitFunc)

    if tbl.extraObjects then
        self.m_TransportExtensionExtraObjects = {}
        for i, v in pairs(tbl.extraObjects) do
            local obj = createObject(v[1], 0, 0, 0)
            obj:attach(self, v[2], v[3], v[4], v[5], v[6], v[7])
            obj:setScale(v[8])
            table.insert(self.m_TransportExtensionExtraObjects, obj)
        end
    end

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

function VehicleTransportExtension:Event_OnLoadingZoneHit(hitElement, matchingDim)
    if instanceof(hitElement, Vehicle) then
        hitElement:getHandbrakeHook():register(self.m_LoadingZoneVehicleHandBrakeFunc)
    end
end

function VehicleTransportExtension:Event_OnLoadingZoneLeave(hitElement, matchingDim)
    if instanceof(hitElement, Vehicle) then
        hitElement:getHandbrakeHook():unregister(self.m_LoadingZoneVehicleHandBrakeFunc)
    end
end


function VehicleTransportExtension:internalTransportVehicleOnEnter(player, seat)
    assert(source.vehicleTransportVehicle, "vehicle is not a transport vehicle")
    player:triggerEvent("vehicleTransportExtensionSetCameraNoClip", true)
end

function VehicleTransportExtension:internalTransportVehicleOnExit(player, seat)
    assert(source.vehicleTransportVehicle, "vehicle is not a transport vehicle")
    player:triggerEvent("vehicleTransportExtensionSetCameraNoClip", false)
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
        setElementCollisionsEnabled(v, false)
    end
end

function VehicleTransportExtension:internalDetachRamps()
    for i, v in pairs(self.m_RampData) do
        local x, y, z, rx, ry, rz = v:getAttachedOffsets()
        detachElements(v)
        setElementCollisionsEnabled(v, true)

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

function VehicleTransportExtension:internalToggleLoadingZone()
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    if not tbl then return end
    if not tbl.boundingBox then return end
    if self.m_VehicleTransportLoadingMode and not self.m_VehicleTransportLoadingCol then
        self.m_VehicleTransportLoadingCol = createColSphere(self.position.x, self.position.y, self.position.z, 15)
        --self.m_VehicleTransportLoadingCol:attach(self)
        addEventHandler("onColShapeHit", self.m_VehicleTransportLoadingCol, self.m_LoadingZoneHitFunc)
        addEventHandler("onColShapeLeave", self.m_VehicleTransportLoadingCol, self.m_LoadingZoneLeaveFunc)
        for i, v in pairs(getElementsWithinColShape(self.m_VehicleTransportLoadingCol, "vehicle")) do
            if v ~= self then
                v:getHandbrakeHook():register(self.m_LoadingZoneVehicleHandBrakeFunc)
            end
        end
        VehicleImportManager:getSingleton():addLoadingCol(self.m_VehicleTransportLoadingCol)
    elseif not self.m_VehicleTransportLoadingMode and self.m_VehicleTransportLoadingCol then
        for i, v in pairs(getElementsWithinColShape(self.m_VehicleTransportLoadingCol, "vehicle")) do
            if v ~= self then
                v:getHandbrakeHook():unregister(self.m_LoadingZoneVehicleHandBrakeFunc)
            end
        end
        VehicleImportManager:getSingleton():removeLoadingCol(self.m_VehicleTransportLoadingCol)
        self.m_VehicleTransportLoadingCol:destroy()
        self.m_VehicleTransportLoadingCol = nil
    end
end

function VehicleTransportExtension:internalGetOffsetForVehicle(veh) -- stolen from ped to veh glue system
    local px, py, pz = getElementPosition(veh)
    local vx, vy, vz = getElementPosition(self)
    local sx = px - vx
    local sy = py - vy
    local sz = pz - vz

    local rotpX, rotpY, rotpZ = getElementRotation(veh)
    local rotvX, rotvY, rotvZ = getVehicleRotation(self)

    local t, p, f = math.rad(self.rotation.x), math.rad(self.rotation.y), math.rad(self.rotation.z)
    local ct, st, cp, sp, cf, sf = math.cos(t), math.sin(t), math.cos(p), math.sin(p), math.cos(f), math.sin(f)

    local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
    local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
    local y = st*sz - sf*ct*sx + cf*ct*sy

    local rotX = rotpX - rotvX
    local rotY = rotpY - rotvY
    local rotZ = rotpZ - rotvZ
    return x, y, z, rotX, rotY, rotZ
end

function VehicleTransportExtension:internalCheckVehicleLoading(vehicleToLoad)
    if not isElementWithinColShape(vehicleToLoad, self.m_VehicleTransportLoadingCol) then --garbage collection
        hitElement:getHandbrakeHook():unregister(self.m_LoadingZoneVehicleHandBrakeFunc)
        return false 
    end

    if (vehicleToLoad.m_CurrentlyAttachedToTransporter) then
        vehicleToLoad:detach()
        vehicleToLoad.m_CurrentlyAttachedToTransporter = nil
        if vehicleToLoad.controller then triggerClientEvent(vehicleToLoad.controller, "playSFX", vehicleToLoad.controller, "script", 204, 3, false) end
        return
    end

    if (vehicleToLoad:isAttached()) then return end -- cancel if the vehicle is already attached

    local driver = vehicleToLoad.controller
    if not driver or not isElement(driver) then return false end
    
    local x, y, z, rx, ry, rz = self:internalGetOffsetForVehicle(vehicleToLoad)

    
    --check if vehicle offsets are inside bounding box
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    local function inside(value, min, max) return value >= min and value <= max end
    if inside(x, tbl.boundingBox[1], tbl.boundingBox[4]) and inside(y, tbl.boundingBox[2], tbl.boundingBox[5]) and inside(z, tbl.boundingBox[3], tbl.boundingBox[6]) then

        local function onSlope(rot) return math.abs(math.abs(math.abs(rot)-180)-180) > 1 end
        if onSlope(rx) or onSlope(ry) then
            driver:sendWarning("Stelle dein Fahrzeug gerade auf die Ladefläche.")
            return false 
        end
        if vehicleToLoad:getVelocity().length > 0.001 then 
            driver:sendWarning("Fahre langsamer um das Fahrzeug auf den Transporter zu laden.")
            return false 
        end
        vehicleToLoad:attach(self, x, y, z, rx, ry, rz)
        vehicleToLoad.m_CurrentlyAttachedToTransporter = self
        triggerClientEvent(driver, "playSFX", driver, "script", 198, 2, false)
        return true
    end
    return false
end

function VehicleTransportExtension:isInVehicleLoadingMode()
    return self.m_VehicleTransportLoadingMode
end

function VehicleTransportExtension:toggleVehicleLoadingMode()
    local tbl = VehicleTransportExtension.Presets[self:getModel()]
    if not tbl then return end
    if not tbl.rampId then return end
    if self:getVelocity().length > 0.001 then return end -- prevent loading in mid-driving
    if isTimer(self.m_AnimationTimer) then return end -- prevent toggling mode when it is already toggling
    local startRotation, endRotation
    if self.m_VehicleTransportLoadingMode then --close the ramps
        startRotation, endRotation = tbl.rampRotation.open, tbl.rampRotation.closed
        self:internalAttachRamps(true)
        self.m_AnimationTimer = setTimer(function()
            self:internalAttachRamps(false)
            self.m_DisableToggleHandbrake = false
            self:setFrozen(false)
            setVehicleHandling(self, "suspensionUpperLimit", nil, true)
		    setVehicleHandling(self, "suspensionLowerLimit", nil, true)
        end, VehicleTransportExtension.RampMovementTime + 100, 1) -- +100 to take lag into account
    else --open the ramps
        setVehicleHandling(self, "suspensionUpperLimit", 0.6)
        setVehicleHandling(self, "suspensionLowerLimit", 0.1)
        setElementVelocity(self, 0, 0, -0.05)
        setTimer(function() -- give the vehicle time to lower
            self:setFrozen(true)
            self.m_DisableToggleHandbrake = true
        end, 500, 1)
        startRotation, endRotation = tbl.rampRotation.closed, tbl.rampRotation.open
        self.m_AnimationTimer = setTimer(function()
            self:internalAttachRamps(true) -- attach to open state for correct position
            self:internalDetachRamps() -- detach ramps to prevent collision bugs
        end, VehicleTransportExtension.RampMovementTime + 100, 1) 
    end
    triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "vehicleTransportExtensionAnimateRamps", self, self.m_RampData, startRotation, endRotation, VehicleTransportExtension.RampMovementTime)
    self.m_VehicleTransportLoadingMode = not self.m_VehicleTransportLoadingMode
    self:internalToggleLoadingZone()
end
