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
    self.m_CustomModels = {}
end

function VehicleCategory:loadData(categoryData, modelData, customModels)
    self.m_CategoryData = categoryData
    self.m_ModelData = modelData
    self.m_CustomModels = customModels 
end

function VehicleCategory:getCustomModelData(id)
    return self.m_CustomModels[id]
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

function VehicleCategory:getCategoryFuelTankSize(category)
    if not self.m_CategoryData[category] then return false end
    return self.m_CategoryData[category].fuelTankSize
end

function VehicleCategory:getCategoryFuelConsumptionMultiplicator(category)
    if not self.m_CategoryData[category] then return false end
    return self.m_CategoryData[category].fuelConsumption
end


function VehicleCategory:getModelName(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].name
end

function VehicleCategory:getModelCategory(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].category
end


addEventHandler("onVehicleCategoryDataReceive", root, function(categoryData, modelData, customModels)
    VehicleCategory:getSingleton():loadData(categoryData, modelData, customModels)
end)