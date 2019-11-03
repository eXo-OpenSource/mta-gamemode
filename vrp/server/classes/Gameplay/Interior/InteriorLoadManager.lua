-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorLoadManager.lua
-- *  PURPOSE:     Handles loading of Interiors on demand
-- *
-- ****************************************************************************
InteriorLoadManager = inherit(Singleton)
InteriorLoadManager.Map = {}

function InteriorLoadManager.add(id, callback)
	if not CustomInteriorManager.IdMap[id] or type(InteriorLoadManager.Map[id]) ~= "function" then 
		InteriorLoadManager.Map[id] = callback
	else
		InteriorLoadManager.Map[id](CustomInteriorManager.IdMap[id])
	end
end

function InteriorLoadManager.call(instance)
	if InteriorLoadManager.Map[instance:getId()] and type(InteriorLoadManager.Map[instance:getId()]) == "function" then 
		InteriorLoadManager.Map[instance:getId()](instance)
	end 
end