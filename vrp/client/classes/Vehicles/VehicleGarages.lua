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

	NonCollidingArea:new(1872.6, -2108, 10, 22)
	NonCollidingArea:new(999.5, -1372.1, 24, 35)
	NonCollidingArea:new(411.5, -1332.5, 8, 10)
	NonCollidingArea:new(2794.7-27, -1603.3-25, 27, 25)
	NonCollidingArea:new(1813, -1091, 17, 27)

end

function VehicleGarages:updateTextures()
	local mapElements = self.m_MapParser:getElements(self.m_CurrentMapIndex)
	if mapElements then
		for index, element in pairs(mapElements) do
			if type(element) == "table" then
				for index2, element2 in pairs(element) do
					if isElement(element2) and element2:getModel() == 2885 then
						FileTextureReplacer:new(element2, "files/images/Other/garage.jpg", "alleydoor9b", {})
					end
				end
			else
				if element:getModel() == 2885 then
					FileTextureReplacer:new(element, "files/images/Other/garage.jpg", "alleydoor9b", {})
				end
			end

		end
	end
end
