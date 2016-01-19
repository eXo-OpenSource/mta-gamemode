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
	outputDebugString("WeaponTruck loaded")
end

function WeaponTruck:destructor()
end
