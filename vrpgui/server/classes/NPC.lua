-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NPC.lua
-- *  PURPOSE:     NPC class
-- *
-- ****************************************************************************
NPC = inherit(MTAElement)

function NPC:new(skinId, x, y, z, rotation)
	local ped = createPed(skinId, x, y, z)
	setElementRotation(ped, 0, 0, rotation)
	return enew(ped, self, skinId, x, y, z, rotation)
end

function NPC:constructor(skinId, x, y, z, rotation)
	
end
