-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleELS.lua
-- *  PURPOSE:     provide emergency light system for vehicles
-- *
-- ****************************************************************************


VehicleELS = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object
VehicleELS.Map = {}
VehicleELS.ActiveMap = {}

function VehicleELS:setELSPreset(ELSPreset, hasSiren)
    if ELS_PRESET[ELSPreset] then     
        self.m_HasELS = true
        if hasSiren then
            removeVehicleSirens(self)
            self:addSirens(1, 1)
        end
        VehicleELS.Map[self] = self
        self:updateClient("init", ELSPreset, hasSiren)
    end
end

function VehicleELS:removeELS()
    self.m_ELSPreset = nil
    self.m_HasELS = nil
    VehicleELS.Map[self] = nil
    self:updateClient("remove")
end


function VehicleELS:toggleELS(state)
    if state ~= self.m_ELSActive then
        if state then
            VehicleELS.ActiveMap[self] = true
        else
            VehicleELS.ActiveMap[self] = nil
        end
        self.m_ELSActive = state
        self:updateClient("toggle", state)
    end
end

function VehicleELS:updateClient(type, data)
	triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "vehicleELS"..type, resourceRoot, self, data)
end