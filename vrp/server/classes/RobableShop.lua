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
	self.m_ExitMarker = createMarker(interiorPosition.X, interiorPosition.Y, interiorPosition.Z, "corona", 2, 255, 255, 255, 200)
	setElementInterior(self.m_ExitMarker, interiorId)
	self.m_Ped = ShopNPC:new(pedSkin, pedPosition.X, pedPosition.Y, pedPosition.Z, 180)
	setElementInterior(self.m_Ped, interiorId)
	
	addEventHandler("onMarkerHit", self.m_EntryMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, interiorId, interiorPosition.X, interiorPosition.Y, interiorPosition.Z)
				setTimer(function() hitElement.m_DontTeleport = false end, 500, 1) -- Todo: this is a temp fix
			end
		end
	)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension  and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, 0, entryPosition.X, entryPosition.Y, entryPosition.Z)
				setTimer(function() hitElement.m_DontTeleport = false end, 500, 1) -- Todo: this is a temp fix
			end
		end
	)
end

function RobableShop.initalizeShops()
	RobableShop:new(Vector(2104.8, -1806.5, 13.5), Vector(372, -133.5, 1001.5), 5, Vector(374.76, -117.26, 1001.5), 155)
end
