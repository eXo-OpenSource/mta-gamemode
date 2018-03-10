-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleDataExtension.lua
-- *  PURPOSE:     extension for the Vehicle class to provide data getter
-- *
-- ****************************************************************************

VehicleDataExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object

function VehicleDataExtension:getCategory()
    return VehicleCategory:getSingleton():getModelCategory(self:getModel())
end

function VehicleDataExtension:getName()
    return VehicleCategory:getSingleton():getModelName(self:getModel())
end

function VehicleDataExtension:getCategoryName()
    return VehicleCategory:getSingleton():getCategoryName(self:getCategory())
end

function VehicleDataExtension:getFuelType()
    local custom = VehicleCategory:getSingleton():getCustomModelData(self:getModel())
    return custom and custom.fuelType or VehicleCategory:getSingleton():getCategoryFuelType(self:getCategory())
end

function VehicleDataExtension:getFuelTankSize()
    local custom = VehicleCategory:getSingleton():getCustomModelData(self:getModel())
    return custom and custom.fuelTankSize or VehicleCategory:getSingleton():getCategoryFuelTankSize(self:getCategory())
end

function VehicleDataExtension:getFuelConsumptionMultiplicator()
    return VehicleCategory:getSingleton():getCategoryFuelConsumptionMultiplicator(self:getCategory())
end

function VehicleDataExtension:getTax()
    return VehicleCategory:getSingleton():getCategoryTax(self:getCategory())
end

function VehicleDataExtension:getBaseHeight(asVector)
    if asVector then
        return Vector3(0, 0, VehicleCategory:getSingleton():getModelBaseHeight(self:getModel()))
    end
    return VehicleCategory:getSingleton():getModelBaseHeight(self:getModel())
end

