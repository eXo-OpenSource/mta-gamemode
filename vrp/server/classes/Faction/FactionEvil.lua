-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionEvil.lua
-- *  PURPOSE:     Evil Faction Class
-- *
-- ****************************************************************************

FactionEvil = inherit(Singleton)
  -- implement by children

function FactionEvil:constructor()
	outputDebugString("Faction Evil loaded")
	WeaponTruck:getSingleton():new()

end

function FactionEvil:destructor()
end
