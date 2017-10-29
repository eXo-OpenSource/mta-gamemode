-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicles/Extensions/VehicleELS.lua
-- *  PURPOSE:     provide emergency light system for vehicles
-- *
-- ****************************************************************************

VehicleELS = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object
VehicleELS.updateInterval = 200 --ms
VehicleELS.Map = {}
VehicleELS.ActiveMap = {}

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
        for name, data in pairs(VehicleELS.preset[self.m_ELSPreset].light) do
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
VehicleELS.preset = {
    [411] = {
        sequenceCount = 2,
        light = {
            --name = {x, y, z, size, r, g, b}
            vl = {0.5, 2, 0, 0.2, 255, 0, 0},
            vr = {-0.5, 2, 0, 0.2, 0, 0, 255},
        },
        sequence = {
            [1] = {
                vl = {
                    enabled = true,
                },
                vr = {
                    enabled = false,
                },
            },
            [2] = {
                vl = {
                    enabled = false,
                },
                vr = {
                    enabled = true,
                },
            },
        },
    },


}