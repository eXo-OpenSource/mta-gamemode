-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        client/classes/Vehicles/Extensions/VehicleCategory.lua
-- *  PURPOSE:     categorise vehicles
-- *
-- ****************************************************************************
VehicleCategory = inherit(Singleton)
addRemoteEvents{"onVehicleCategoryDataReceive"}

function VehicleCategory:constructor()
    self.m_CategoryData = {}
    self.m_ModelData = {}
end

function VehicleCategory:loadData(categoryData, modelData)
    self.m_CategoryData = categoryData
    self.m_ModelData = modelData
end

function VehicleCategory:syncWithClient(player)
    player:triggerEvent("onVehicleCategoryDataReceive", self.m_CategoryData, self.m_ModelData)
end

function VehicleCategory:getCategoryName(category)
    if not self.m_CategoryData[category] then return false end
    return self.m_CategoryData[category].name
end

function VehicleCategory:getCategoryTax(category)
    if not self.m_CategoryData[category] then return false end
    return self.m_CategoryData[category].tax
end

function VehicleCategory:getCategoryFuelType(category)
    if not self.m_CategoryData[category] then return false end
    return self.m_CategoryData[category].fuelType
end


function VehicleCategory:getModelName(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].name
end

function VehicleCategory:getModelCategory(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].category
end


addEventHandler("onVehicleCategoryDataReceive", root, function(categoryData, modelData)
    VehicleCategory:getSingleton():loadData(categoryData, modelData)
end)