-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleCategory.lua
-- *  PURPOSE:     categorise vehicles
-- *
-- ****************************************************************************
VehicleCategory = inherit(Singleton)

function VehicleCategory:constructor()
    self.m_CategoryData = {}
    self.m_ModelData = {}
    self.m_CustomModels = {
        [611] = { --small fuel trailer
            fuelTankSize = 500,
            fuelType = "universal"
        },
		[584] = { --large fuel trailer
			fuelTankSize = 1500,
			fuelType = "universal"
		}
    } --temporary until there is a useful database structure

    local result = sql:queryFetch("SELECT * FROM ??_vehicle_category_data", sql:getPrefix())
	for i, row in pairs(result) do
		self.m_CategoryData[row.Id] = {
            name = row.Name,
			tax = row.Tax,
            fuelType = row.FuelType,
            fuelTankSize = row.FuelTankSize,
            fuelConsumption = row.FuelConsumptionMultiplicator,
            vehicleType = row.VehicleType,
		}
	end
    local result = sql:queryFetch("SELECT * FROM ??_vehicle_model_data", sql:getPrefix())
	for i, row in pairs(result) do
		self.m_ModelData[row.Model] = {
            name = row.Name,
			category = row.Category,
			baseHeight = row.BaseHeight,
		}
	end
end

function VehicleCategory:syncWithClient(player)
    player:triggerEvent("onVehicleCategoryDataReceive", self.m_CategoryData, self.m_ModelData, self.m_CustomModels)
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
    return self.m_CategoryData[category].fuelTankSize
end

function VehicleCategory:getCategoryFuelConsumptionMultiplicator(category)
    if not self.m_CategoryData[category] then return false end
    return self.m_CategoryData[category].fuelConsumption
end

function VehicleCategory:hasCategoryLandVehicles(category)
    return self.m_CategoryData[category].vehicleType == 0
end

function VehicleCategory:hasCategoryAirVehicles(category)
    return self.m_CategoryData[category].vehicleType == 1
end

function VehicleCategory:hasCategoryWaterVehicles(category)
    return self.m_CategoryData[category].vehicleType == 2
end

function VehicleCategory:getModelName(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].name
end

function VehicleCategory:getModelCategory(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].category
end

function VehicleCategory:getModelBaseHeight(model)
    if not self.m_ModelData[model] then return false end
    return self.m_ModelData[model].baseHeight
end
