-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleGarages.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *
-- ****************************************************************************
VehicleGarages = inherit(Singleton)
addRemoteEvents{"vehicleGarageSessionOpen", "vehicleGarageSessionClose"}

VehicleGarages.NonCollidingAreas = {
	{colType = "Cuboid", args = {Vector3(1873, -2103, 12.2), 8, 16, 5}},	-- El Corona
	{colType = "Cuboid", args = {Vector3(1000, -1371, 12.2), 15, 15, 5}},	-- Market (Donut Laden)
	{colType = "Cuboid", args = {Vector3(410, -1332, 13.5), 8, 9, 5}},		-- Rodeo
	{colType = "Cuboid", args = {Vector3(2768, -1628, 9.8), 21, 18, 5}},	-- East Beach
	{colType = "Cuboid", args = {Vector3(1816, -1086, 23), 15, 15, 5}},		-- Glen Park
}

function VehicleGarages:constructor()
	self.m_MapParser = MapParser:new("files/maps/Garages.parsed_map")
	self.m_CurrentMapIndex = false

	addEventHandler("vehicleGarageSessionOpen", root,
		function(dimension)
			if not self.m_CurrentMapIndex then
				self.m_CurrentMapIndex = self.m_MapParser:create(dimension)
				self:updateTextures()
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

	for _, value in pairs(VehicleGarages.NonCollidingAreas) do
		NonCollisionArea:new(value.colType, value.args, {vehicles = false, players = true})
	end
end

function VehicleGarages:updateTextures()
	local mapElements = self.m_MapParser:getElements(self.m_CurrentMapIndex)
	if mapElements then
		for index, element in pairs(mapElements) do
			if type(element) == "table" then
				for index2, element2 in pairs(element) do
					if isElement(element2) and element2:getModel() == 2885 then
						FileTextureReplacer:new(element2, "Other/garage.jpg", "alleydoor9b", {}):load()
					end
				end
			else
				if element:getModel() == 2885 then
					FileTextureReplacer:new(element, "Other/garage.jpg", "alleydoor9b", {}):load()
				end
			end

		end
	end
end
