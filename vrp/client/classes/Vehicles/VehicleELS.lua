-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/Extensions/VehicleELS.lua
-- *  PURPOSE:     provide emergency light system for vehicles
-- *
-- ****************************************************************************

VehicleELS = inherit(Singleton) 
VehicleELS.updateInterval = 200 --ms
VehicleELS.Map = {}
VehicleELS.ActiveMap = {}
addRemoteEvents{"add", "remove", "toggle"}

function VehicleELS:constructor()

    addEventHandler("vehicleELSadd", resourceRoot, bind(VehicleELS.addVehicleELS, self))
    addEventHandler("vehicleELSremove", resourceRoot, bind(VehicleELS.removeVehicleELS, self))
    addEventHandler("vehicleELStoggle", resourceRoot, bind(VehicleELS.toggleVehicleELS, self))

end

function VehicleELS:setELSPreset(ELSPreset, hasSiren)
    self.m_ELSPreset = ELSPreset
    self.m_HasELS = true
    if hasSiren then
        --removeVehicleSirens(self)
       -- sefl:addSirens(1, 1)
    end
    VehicleELS.Map[self] = self
end

function VehicleELS:removeELS()
    self.m_ELSPreset = nil
    self.m_HasELS = nil
    VehicleELS.Map[self] = nil
end


function VehicleELS:toggleELS(state)
    if state ~= self.m_ELSActive then
        if state then
            VehicleELS.ActiveMap[self] = 1
            self:internalAddELSLights()
        else
            self:internalRemoveELSLights()
            VehicleELS.ActiveMap[self] = nil
        end
        self.m_ELSActive = state
    end
end

function VehicleELS:internalAddELSLights()
    if not self.m_ELSLights then
        self.m_ELSLights = {}
        for name, data in pairs(ELS_PRESET[self.m_ELSPreset].light) do
            self.m_ELSLights[name] = CustomCorona:new(data[1], data[2], data[3], data[4], data[5], data[6], data[7], 255)
            self.m_ELSLights[name]:attachTo(self, true)
        end
    end
end

function VehicleELS:internalRemoveELSLights()
    if self.m_ELSLights then
        self.m_ELSLights = nil
    end
end


function VehicleELS.init()
    setTimer(VehicleELS.update, VehicleELS.updateInterval, 0)
end

function VehicleELS.update()
    --for i, v in pairs() do

   -- end
end
VehicleELS.init()
