-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/Extensions/VehicleTransportExtension.lua
-- *  PURPOSE:     extension for the Vehicle class to attach other vehicles to it
-- *
-- ****************************************************************************

VehicleTransportExtension = inherit(Object)

addRemoteEvents {"vehicleTransportExtensionAnimateRamps", "vehicleTransportExtensionSetCameraNoClip"}

function VehicleTransportExtension:virtual_constructor()
    self.m_RampMoveFunc = bind(self.moveRamps, self)
    addEventHandler("vehicleTransportExtensionAnimateRamps", self, self.m_RampMoveFunc)
end


function VehicleTransportExtension:moveRamps(rampData, startData, endData, animTime)
    self.m_RampAnimateBind = bind(self.internalAnimateRamps, self)

    self.m_StartTime    = getTickCount()
    self.m_RampData     = rampData
    self.m_StartData    = startData
    self.m_EndData      = endData
    self.m_AnimTime     = animTime

    if not self.m_Rendering then
        addEventHandler("onClientRender", root, self.m_RampAnimateBind)
        self.m_Rendering = true
    end
end

function VehicleTransportExtension:internalAnimateRamps()
    local prog = (getTickCount()-self.m_StartTime)/self.m_AnimTime

    --first ramp
    local startData = self.m_StartData[1]
    local endData = self.m_EndData[1]
    local p = interpolateBetween(startData[1], startData[2], startData[3], endData[1], endData[2], endData[3], prog, "InOutQuad")
   
    local x, y, z, rx, ry, rz = getElementAttachedOffsets(self.m_RampData[1])
    setElementAttachedOffsets(self.m_RampData[1], x, y, z, p, ry, rz)

    --second ramp
    local startData = self.m_StartData[2]
    local endData = self.m_EndData[2]
    local p = interpolateBetween(startData[1], startData[2], startData[3], endData[1], endData[2], endData[3], prog, "InOutQuad")
   
    local x, y, z, rx, ry, rz = getElementAttachedOffsets(self.m_RampData[2])
    setElementAttachedOffsets(self.m_RampData[2], x, y, z, p, ry, rz)

    if prog >= 1 then
        removeEventHandler("onClientRender", root, self.m_RampAnimateBind)
        self.m_Rendering = false
	end
end

addEventHandler("vehicleTransportExtensionSetCameraNoClip", root, function(state)
    local objClip = getCameraClip()
    setCameraClip(objClip, not state) 
end)