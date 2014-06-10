-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleGarages.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *
-- ****************************************************************************
VehicleGarages = inherit(Singleton)
addEvent("vehicleGarageSessionOpen", true)
addEvent("vehicleGarageSessionClose", true)

function VehicleGarages:constructor()
	self.m_MapParser = MapParser:new("files/maps/Garages.parsed_map")
	self.m_CurrentMapIndex = false
	
	addEventHandler("vehicleGarageSessionOpen", root,
		function(dimension)
			if not self.m_CurrentMapIndex then
				self.m_CurrentMapIndex = self.m_MapParser:create(dimension)
			end
		end
	)
	addEventHandler("vehicleGarageSessionClose", root,
		function()
			if self.m_CurrentMapIndex then
				self.m_MapParser:destroy(self.m_CurrentMapIndex)
				self.m_CurrentMapIndex = false
			end
		end
	)
	
	NonCollidingArea:new(999.5, -1372.1, 24, 35)
end
