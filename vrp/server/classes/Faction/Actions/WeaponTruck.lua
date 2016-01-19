-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeaponTruck = inherit(Singleton)
  -- implement by children

function WeaponTruck:constructor()
	self:createStartPoint(-1869.14, 1421.49, 7.18)
	outputDebugString("WeaponTruck loaded")
end

function WeaponTruck:destructor()
end

function WeaponTruck:createStartPoint(x,y,z)
	self.m_startPickup = createPickup(x,y,z,3,1279,0,0)
	addEventHandler("onPickupHit", self.m_startPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction:isEvilFaction() == true then
					--ToDo
				end
			end
			cancelEvent()
		end
	)
end