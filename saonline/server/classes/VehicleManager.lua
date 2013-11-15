-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleManager.lua
-- *  PURPOSE:     Vehicle manager class
-- *
-- ****************************************************************************
VehicleManager = inherit(Singleton)

function VehicleManager:constructor()
	self.m_Vehicles = {}

	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	outputServerLog(("Loading %d vehicles"):format(#result))
	for i, rowData in ipairs(result) do
		local vehicle = createVehicle(rowData.Model, rowData.PosX, rowData.PosY, rowData.PosZ, 0, 0, rowData.Rotation)
		enew(vehicle, Vehicle, tonumber(rowData.Id), rowData.Owner, fromJSON(rowData.Keys))
		table.insert(self.m_Vehicles, vehicle)
	end
end

function VehicleManager:destructor()
	for k, vehicle in ipairs(self.m_Vehicles) do
		vehicle:save()
	end
end
