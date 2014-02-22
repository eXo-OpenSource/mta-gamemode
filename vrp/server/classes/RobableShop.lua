-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NPC.lua
-- *  PURPOSE:     Robable shop class
-- *
-- ****************************************************************************
RobableShop = inherit(Object)

function RobableShop:constructor(entryPosition, interiorPosition, interiorId, pedPosition, pedSkin)
	self.m_EntryMarker = createMarker(entryPosition.X, entryPosition.Y, entryPosition.Z, "corona", 2, 255, 255, 255, 200)
	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.X, pedPosition.Y, pedPosition.Z, 180)
	setElementInterior(self.m_Ped, interiorId)
	
	addEventHandler("onMarkerHit", self.m_EntryMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) then
				setElementInterior(hitElement, interiorId, interiorPosition.X, interiorPosition.Y, interiorPosition.Z)
			end
		end
	)
end

addEventHandler("onResourceStart", resourceRoot,
	function()
		RobableShop:new(Vector(2104.8, -1806.5, 13.5), Vector(372, -133.5, 1001.5), 5, Vector(374.76, -117.26, 1001.5), 155)
	end
)