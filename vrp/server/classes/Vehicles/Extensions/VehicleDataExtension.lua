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
    return VehicleCategory:getSingleton():getCategoryFuelType(self:getCategory())
end

function VehicleDataExtension:getTax()
    return VehicleCategory:getSingleton():getCategoryTax(self:getCategory())
end


