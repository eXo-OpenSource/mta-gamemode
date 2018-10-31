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
VehicleELS.DIActiveMap = {} -- direction indicator
addRemoteEvents {"vehicleELSToggleRequest", "vehicleDirectionIndicatorToggleRequest"}

function VehicleELS:setELSPreset(ELSPreset)
    if ELS_PRESET[ELSPreset] then
        self.m_HasELS = true
        self.m_ELSPreset = ELSPreset
        if ELS_PRESET[ELSPreset].hasSiren then
            removeVehicleSirens(self)
            self:addSirens(1, 1)
        end
        if ELS_PRESET[ELSPreset].lightBar then
            local l = ELS_PRESET[ELSPreset].lightBar
            local obj = createObject(1921, 0, 0, 0)
            obj:attach(self, l[1], l[2], l[3])
            obj:setCollisionsEnabled(false)
            if l[5] == "red" then
                VehicleTexture:new(obj, "files/images/Textures/Faction/Rescue/Rescue_Copcar.png", "copcarla92interior128", true)
            elseif l[5] == "orange" then
                VehicleTexture:new(obj, "files/images/Textures/Faction/State/MBT_Copcar.png", "copcarla92interior128", true)
            end
            if l[4] then obj:setScale(l[4]) end
            obj:setInterior(self:getInterior())
            obj:setDimension(self:getDimension())
            self.m_LightBarObject = obj
        end
        VehicleELS.Map[self] = ELSPreset
        self:updateClient("init", ELSPreset)

        self.m_ToggleELSFunc = bind(VehicleELS.toggleELS, self)
        self.m_ToggleDIFunc = bind(VehicleELS.toggleDI, self)
        self.m_InteriorChangeFunc = bind(VehicleELS.Event_OnVehicleInteriorChange, self)
        self.m_DimensionChangeFunc = bind(VehicleELS.Event_OnVehicleDimensionChange, self)
        addEventHandler("vehicleELSToggleRequest", self, self.m_ToggleELSFunc)
        addEventHandler("vehicleDirectionIndicatorToggleRequest", self, self.m_ToggleDIFunc)
        if self.m_LightBarObject then
            addEventHandler("onElementInteriorChange", self, self.m_InteriorChangeFunc)
            addEventHandler("onElementDimensionChange", self, self.m_DimensionChangeFunc)
        end
    end
end

function VehicleELS:removeELS()
    if self.m_HasELS then
        self.m_ELSPreset = nil
        self.m_HasELS = nil
        self.m_ELSActive = nil
        VehicleELS.Map[self] = nil
        self:updateClient("remove")
        removeVehicleSirens(self)
        removeEventHandler("vehicleELSToggleRequest", self, self.m_ToggleELSFunc)
        removeEventHandler("vehicleDirectionIndicatorToggleRequest", self, self.m_ToggleDIFunc)
        if self.m_LightBarObject then
            if isElement(self.m_LightBarObject) then self.m_LightBarObject:destroy() end
            removeEventHandler("onElementInteriorChange", self, self.m_InteriorChangeFunc)
            removeEventHandler("onElementDimensionChange", self, self.m_DimensionChangeFunc)
        end
    end
end

function VehicleELS:toggleELS(state)
    if state ~= self.m_ELSActive and self.m_HasELS then
        if state then
            VehicleELS.ActiveMap[self] = true
        else
            VehicleELS.ActiveMap[self] = nil
        end
        self.m_ELSActive = state
        self:updateClient("toggle", state)
    end
end

function VehicleELS:toggleDI(mode)
    if mode ~= VehicleELS.DIActiveMap[self] then
        VehicleELS.DIActiveMap[self] = (mode == false and nil or mode)
        self:updateClient("toggleDI", mode)
    end
end

function VehicleELS:Event_OnVehicleInteriorChange()
    self.m_LightBarObject:setInterior(self:getInterior())
end

function VehicleELS:Event_OnVehicleDimensionChange()
    self.m_LightBarObject:setDimension(self:getDimension())
end

function VehicleELS:updateClient(type, data)
	triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "vehicleELS"..type, resourceRoot, self, data)
end

function VehicleELS.sendAllToClient(player)
    player:triggerEvent("vehicleELSinitAll", VehicleELS.Map, VehicleELS.ActiveMap, VehicleELS.DIActiveMap)
end