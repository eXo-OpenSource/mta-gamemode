-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleGarage.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *
-- ****************************************************************************
VehicleGarage = inherit(Object)
VehicleGarage.Map = {}
addEvent("vehicleGarageSessionOpen", true)
addEvent("vehicleGarageSessionClose", true)

function VehicleGarage:constructor()
	self.m_Id = #VehicleGarage.Map + 1
	self.m_CurrentMapIndex = false
	
	addEventHandler("vehicleGarageSessionOpen", root,
		function(Id, dimension)
			if self.m_Id == Id and not self.m_CurrentMapIndex then
				self.m_CurrentMapIndex = VehicleGarage.ms_MapParser:create(dimension)
			end
		end
	)
	addEventHandler("vehicleGarageSessionClose", root,
		function(Id)
			if self.m_Id == Id and self.m_CurrentMapIndex then
				VehicleGarage.ms_MapParser:destroy(self.m_CurrentMapIndex)
				self.m_CurrentMapIndex = false
			end
		end
	)
end

function VehicleGarage.initializeAll()
	VehicleGarage.ms_MapParser = MapParser:new("files/maps/Garages.parsed_map")
	
	VehicleGarage.Map = {
		VehicleGarage:new(GarageData);
	}
end