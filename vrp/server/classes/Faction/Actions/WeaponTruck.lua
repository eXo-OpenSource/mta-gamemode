-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeaponTruck = inherit(Object)

function WeaponTruck:constructor(truck, driver)
	outputDebug(driver)

	self.m_WeaponTruck = truck
	self.m_Driver = driver
	self.m_Weapons = {}

	self:createStartPoint(-1869.14, 1421.49, 7.18)
end

function WeaponTruck:destructor()
end

function WeaponTruck:createStartPoint(x, y, z)
	self.m_Blip = Blip:new("Waypoint.png", x, y, self.m_Driver)
	self.m_StartMarker = createMarker(x, y, z, "cylinder")
	addEventHandler("onMarkerHit", self.m_StartMarker, bind(self.onStartPointHit, self))
end

function WeaponTruck:onStartPointHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local Truck = hitElement:getOccupiedVehicle()
		if Truck then
			if Truck == self.m_WeaponTruck then
				if hitElement:getFaction():isEvilFaction() then

				end
			end
		end
	end
end
