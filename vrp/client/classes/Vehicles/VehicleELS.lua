-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/Extensions/VehicleELS.lua
-- *  PURPOSE:     provide emergency light system for vehicles
-- *
-- ****************************************************************************

VehicleELS = inherit(Singleton) 
VehicleELS.Map = {}
VehicleELS.ActiveMap = {}
VehicleELS.LightStates ={
    full = {0,0,0,0},
    off = {1,1,1,1},
    r = {1,0,0,1},
    l = {0,1,1,0},
    d1 = {1,0,1,0},
    d2 = {0,1,0,1},
}
addRemoteEvents{"vehicleELSinit", "vehicleELSremove", "vehicleELStoggle"}

function VehicleELS:constructor()
    addEventHandler("vehicleELSinit", resourceRoot, bind(VehicleELS.initELS, self))
    addEventHandler("vehicleELSremove", resourceRoot, bind(VehicleELS.removeELS, self))
    addEventHandler("vehicleELStoggle", resourceRoot, bind(VehicleELS.toggleELS, self))

end

function VehicleELS:initELS(veh, preset, hasSiren, directionIndicatorData)
    VehicleELS.Map[veh] = {preset, hasSiren, directionIndicatorData}
    veh.m_ELSPreset = preset
end

function VehicleELS:removeELS(veh)
    if VehicleELS.Map[veh] then
        VehicleELS.Map[veh] = nil
    end
end


function VehicleELS:toggleELS(veh, state)
    if state ~= veh.m_ELSActive then
        if state then
            VehicleELS.ActiveMap[veh] = 1
            self:internalAddELSLights(veh)
        else
            self:internalRemoveELSLights(veh)
            VehicleELS.ActiveMap[veh] = nil
        end
        veh.m_ELSActive = state
    end
end

function VehicleELS:internalAddELSLights(veh)
    if not veh.m_ELSLights then
        veh.m_ELSLights = {}
        veh.m_ELSCache = {
            lights = veh:getOverrideLights(),
            lcolor = veh:getHeadLightColor(),
        }
        for name, data in pairs(ELS_PRESET[veh.m_ELSPreset].light) do
            veh.m_ELSLights[name] = createMarker(0, 0, 0, "corona", data[4], data[5], data[6], data[7], data[8] or 255)
            veh.m_ELSLights[name]:attach(veh, data[1], data[2], data[3])
        end
        veh.m_ELSTimer = setTimer(VehicleELS.update, ELS_PRESET[veh.m_ELSPreset].sequenceDuration, 0, veh)
    end
end

function VehicleELS:internalRemoveELSLights(veh)
    if veh.m_ELSLights then
        for name, cor in pairs(veh.m_ELSLights) do
            cor:destroy()
        end
        veh.m_ELSLights = nil
        if isTimer(veh.m_ELSTimer) then killTimer(veh.m_ELSTimer) end
    end
end

function VehicleELS.update(veh)
    if VehicleELS.ActiveMap[veh] then
        if not veh or not isElement(veh) then
            return VehicleELS:getSingleton():internalRemoveELSLights(veh)
        end
        local data = ELS_PRESET[veh.m_ELSPreset].sequence[VehicleELS.ActiveMap[veh]]
        if data then
            for name, tblChanges in pairs(data) do
                if name == "vehicle_light" then
                    local name, color = unpack(tblChanges)
                    if VehicleELS.LightStates[name] then
                        for i = 0, 3 do
                           setVehicleLightState(veh, i, VehicleELS.LightStates[name][i+1]) 
                        end
                    end
                    setVehicleHeadLightColor(veh, unpack(color))
                else
                    if tblChanges.fade ~= nil then
                        if not tblChanges.fade[2] then tblChanges.fade[2] = ELS_PRESET[VehicleELS.Map[veh]].sequenceDuration end
                        CoronaEffect.add(veh.m_ELSLights[name], "fade", tblChanges.fade)
                    end
                    if tblChanges.strobe ~= nil then
                        if not tblChanges.strobe or type(tblChanges.strobe) ~= "table" then
                            if CoronaEffect.Map[veh.m_ELSLights[name]] then
                                veh.m_ELSLights[name]:setColor(unpack(CoronaEffect.Map[veh.m_ELSLights[name]].color)) -- reset color
                            end
                            CoronaEffect.remove(veh.m_ELSLights[name])
                        else
                            if not tblChanges.strobe[3] then tblChanges.strobe[3] = 255 end
                            if not tblChanges.strobe[4] then tblChanges.strobe[4] = 0 end
                            CoronaEffect.add(veh.m_ELSLights[name], "strobe", tblChanges.strobe)
                        end
                    end
                    if tblChanges.color ~= nil then
                        veh.m_ELSLights[name]:setColor(unpack(tblChanges.color))
                    end
                    if tblChanges.alpha ~= nil then
                        local r,g,b = veh.m_ELSLights[name]:getColor()
                        veh.m_ELSLights[name]:setColor(r,g,b, tblChanges.alpha or 255)
                    end
                end
            end
        end
        VehicleELS.ActiveMap[veh] = VehicleELS.ActiveMap[veh] % ELS_PRESET[veh.m_ELSPreset].sequenceCount  + 1
    else
        self:internalRemoveELSLights(veh)
    end
end