-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Faction/Factions/FactionPD.lua
-- *  PURPOSE:     Police Departement Class
-- *
-- ****************************************************************************

FactionPD = inherit(FactionState)
  
function FactionPD:constructor(Id)
	outputServerLog("Police Departement loaded")
	
	
	
end

function FactionPD:destructor()
end

function FactionPD:getClassId()
  return 1
end
