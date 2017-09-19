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
    local result = sql:queryFetch("SELECT * FROM ??_vehicle_category_data", sql:getPrefix())
	for i, row in pairs(result) do
		self.m_CategoryData[row.Id] = {
            name = row.Name,
			tax = row.Tax,
            fuelType = row.FuelType,
		}
	end
    local result = sql:queryFetch("SELECT * FROM ??_vehicle_model_data", sql:getPrefix())
	for i, row in pairs(result) do
		self.m_ModelData[row.Model] = {
            name = row.Name,
			category = row.Category,
		}
	end
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