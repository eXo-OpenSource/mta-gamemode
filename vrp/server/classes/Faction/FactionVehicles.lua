-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionVehicles.lua
-- *  PURPOSE:     Faction Vehicle Class
-- *
-- ****************************************************************************

FactionVehicles = inherit(Object)

-- implement by children
FactionVehicles.constructor = pure_virtual
FactionVehicles.destructor = pure_virtual

function FactionVehicles:constructor(id)
  local result = sql:queryFetch("SELECT Id, Model, Pos FROM ??_factionsVehicles WHERE FactionId = ?", sql:getPrefix(),id)
	for k, row in ipairs(result) do
	
	end
end

function FactionVehicles:destructor()
end