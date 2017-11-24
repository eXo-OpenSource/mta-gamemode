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
VehicleELS.ActiveDIMap = {}
VehicleELS.DIUpdateTime = 200
VehicleELS.LightStates = {
    full = {0,0,0,0},
    off = {1,1,1,1},
    r = {1,0,0,1},
    l = {0,1,1,0},
    d1 = {1,0,1,0},
    d2 = {0,1,0,1},
}
addRemoteEvents{"vehicleELSinitAll", "vehicleELSinit", "vehicleELSremove", "vehicleELStoggle", "vehicleELStoggleDI"}

function VehicleELS:constructor()
    addEventHandler("vehicleELSinit", resourceRoot, bind(VehicleELS.initELS, self))
    addEventHandler("vehicleELSremove", resourceRoot, bind(VehicleELS.removeELS, self))
    addEventHandler("vehicleELStoggle", resourceRoot, bind(VehicleELS.toggleELS, self))
    addEventHandler("vehicleELStoggleDI", resourceRoot, bind(VehicleELS.toggleDI, self))
end

function VehicleELS:loadServerELS(allVehs, activeVehs, diVehs)
    for veh, preset in pairs(allVehs) do
        self:initELS(veh, preset)
    end
    for veh, state in pairs(activeVehs) do
        self:toggleELS(veh, state)
    end
    for veh, mode in pairs(diVehs) do
        self:toggleDI(veh, mode)
    end
end

function VehicleELS:initELS(veh, preset)
    VehicleELS.Map[veh] = preset
    veh.m_ELSPreset = preset
    veh.m_HasDI = ELS_PRESET[preset].directionIndicator
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
            lcolor = {veh:getHeadLightColor()},
        }
        for name, data in pairs(ELS_PRESET[veh.m_ELSPreset].light) do
            veh.m_ELSLights[name] = createMarker(0, 0, 0, "corona", data[4], data[5], data[6], data[7], data[8] or 255)
            veh.m_ELSLights[name]:attach(veh, data[1], data[2], data[3])
        end
        if ELS_PRESET[veh.m_ELSPreset].headlightSequence then veh:setOverrideLights(2) end
        VehicleELS.update(veh)
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

        veh:setOverrideLights(veh.m_ELSCache.lights)
        veh:setHeadLightColor(unpack(veh.m_ELSCache.lcolor))
        for i = 0, 3 do
            setVehicleLightState(veh, i, VehicleELS.LightStates["full"][i+1]) 
         end
        veh.m_ELSCache = nil
    end
end


--Direction Indicator

function VehicleELS:toggleDIRequest(veh, state)
    if state ~= VehicleELS.ActiveDIMap[veh] then 
        triggerServerEvent("vehicleDirectionIndicatorToggleRequest", veh, state)
    end
end 

function VehicleELS:toggleDI(veh, mode)
    if not veh.m_HasDI then return false end
    if mode ~= veh.m_DIMode then
        if mode then
            VehicleELS.ActiveDIMap[veh] = mode
            self:internalRemoveDILights(veh)
            self:internalAddDILights(veh)
        else
            self:internalRemoveDILights(veh)
            VehicleELS.ActiveDIMap[veh] = nil
        end
        veh.m_DIMode = mode
    end
end

function VehicleELS:internalAddDILights(veh)
    if not veh.m_HasDI then return false end
    if not veh.m_DILights then
        local x, y, z = unpack(veh.m_HasDI)
        veh.m_DILights = {}
        
        veh.m_DILights.r = createMarker(0, 0, 0, "corona", 0, 255, 145, 0, 255)
        veh.m_DILights.r:attach(veh, x, y, z)
        veh.m_DILights.m = createMarker(0, 0, 0, "corona", 0, 255, 145, 0, 255)
        veh.m_DILights.m:attach(veh, 0, y, z)
        veh.m_DILights.l = createMarker(0, 0, 0, "corona", 0, 255, 145, 0, 255)
        veh.m_DILights.l:attach(veh, -x, y, z)

        VehicleELS.updateDI(veh)
        veh.m_DITimer = setTimer(VehicleELS.updateDI, VehicleELS.DIUpdateTime, 0, veh)
    end
end

function VehicleELS:internalRemoveDILights(veh)
    if veh.m_DILights then
        for name, cor in pairs(veh.m_DILights) do
            cor:destroy()
        end
        veh.m_DILights = nil
        if isTimer(veh.m_DITimer) then killTimer(veh.m_DITimer) end
    end
end


--general update function

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
                        if not tblChanges.fade[2] then tblChanges.fade[2] = ELS_PRESET[veh.m_ELSPreset].sequenceDuration end
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
        VehicleELS:getSingleton():internalRemoveELSLights(veh)
    end
end

function VehicleELS.updateDI(veh)
    local mode = VehicleELS.ActiveDIMap[veh]
    if mode == "left" then
        if veh.m_DILights.r:getSize() < 0.15 then 
            CoronaEffect.add(veh.m_DILights.r, "fade", {0.3, VehicleELS.DIUpdateTime})
        elseif veh.m_DILights.m:getSize() < 0.15 then 
            CoronaEffect.add(veh.m_DILights.m, "fade", {0.3, VehicleELS.DIUpdateTime})
        elseif veh.m_DILights.l:getSize() < 0.15 then 
            CoronaEffect.add(veh.m_DILights.l, "fade", {0.3, VehicleELS.DIUpdateTime})
        else
            CoronaEffect.add(veh.m_DILights.r, "fade", {0, VehicleELS.DIUpdateTime})
            CoronaEffect.add(veh.m_DILights.m, "fade", {0, VehicleELS.DIUpdateTime})
            CoronaEffect.add(veh.m_DILights.l, "fade", {0, VehicleELS.DIUpdateTime})
        end
    elseif mode == "right" then
        if veh.m_DILights.l:getSize() < 0.15 then 
            CoronaEffect.add(veh.m_DILights.l, "fade", {0.3, VehicleELS.DIUpdateTime})
        elseif veh.m_DILights.m:getSize() < 0.15 then 
            CoronaEffect.add(veh.m_DILights.m, "fade", {0.3, VehicleELS.DIUpdateTime})
        elseif veh.m_DILights.r:getSize() < 0.15 then 
            CoronaEffect.add(veh.m_DILights.r, "fade", {0.3, VehicleELS.DIUpdateTime})
        else
            CoronaEffect.add(veh.m_DILights.r, "fade", {0, VehicleELS.DIUpdateTime})
            CoronaEffect.add(veh.m_DILights.m, "fade", {0, VehicleELS.DIUpdateTime})
            CoronaEffect.add(veh.m_DILights.l, "fade", {0, VehicleELS.DIUpdateTime})
        end
    else
        VehicleELS:getSingleton():internalRemoveELSLights(veh)
    end
end



addEventHandler("vehicleELSinitAll", root, function(allVehs, activeVehs, diVehs)
    VehicleELS:getSingleton():loadServerELS(allVehs, activeVehs, diVehs)
end)