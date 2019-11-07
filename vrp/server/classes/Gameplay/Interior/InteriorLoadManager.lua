-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorLoadManager.lua
-- *  PURPOSE:     Handles loading of Interiors on demand
-- *
-- ****************************************************************************
InteriorLoadManager = inherit(Singleton)
InteriorLoadManager.Map = {}

function InteriorLoadManager.add(ownerType, owner, callback)
	if (not CustomInteriorManager.OwnerMap[ownerType] or not CustomInteriorManager.OwnerMap[ownerType][owner]) 
	or (InteriorLoadManager.Map[ownerType] and InteriorLoadManager.Map[ownerType][owner] and type(InteriorLoadManager.Map[ownerType][owner]) ~= "function") then 
		if not InteriorLoadManager.Map[ownerType] then InteriorLoadManager.Map[ownerType] = {} end 
		InteriorLoadManager.Map[ownerType][owner] = callback
	else
		InteriorLoadManager.Map[ownerType][owner](CustomInteriorManager.OwnerMap[ownerType][owner])
	end
end

function InteriorLoadManager.call(ownerType, owner, instance)
	if InteriorLoadManager.Map[ownerType] and InteriorLoadManager.Map[ownerType][owner] and type(InteriorLoadManager.Map[ownerType][owner]) == "function" then
		InteriorLoadManager.Map[ownerType][owner](instance)
	end 
end
