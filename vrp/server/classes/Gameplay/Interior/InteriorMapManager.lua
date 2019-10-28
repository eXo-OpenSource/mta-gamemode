-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorMapManager.lua
-- *  PURPOSE:     Manages interior maps
-- *
-- ****************************************************************************
InteriorMapManager = inherit(Singleton)
InteriorMapManager.Map = {}
InteriorMapManager.PathMap = {}

function InteriorMapManager:constructor() 
end

function InteriorMapManager:destructor()

end

function InteriorMapManager:load()
	local result = sql:queryFetch("SELECT * FROM ??_interiors_maps", sql:getPrefix())
	for index, row in pairs(result) do 
		InteriorMap:new(row.Id, row.Path)
	end
end

function InteriorMapManager:insert(path)
	if File.Exists(path) then 
		local query = [[
			INSERT INTO ??_interiors_maps (Path) VALUES (?)
		]]
		if sql:queryExec(query, sql:getPrefix(), path) then 
			return InteriorMap:new(sql:lastInsertId(), path)
		end
	end
	return false
end

function InteriorMapManager:add(instance) 
	InteriorMapManager.Map[instance:getId()] = instance
	InteriorMapManager.PathMap[instance:getPath()] = instance
end

function InteriorMapManager:remove(instance) 
	InteriorMapManager.Map[instance:getId()] = nil
	InteriorMapManager.PathMap[instance:getPath()] = nil
end

function InteriorMapManager:get(id)
	return InteriorMapManager.IdMap[id]
end

function InteriorMapManager:getByPath(path, createNotExists)
	if not createNotExists then
		return InteriorMapManager.PathMap[path]
	else 
		if not InteriorMapManager.PathMap[path] then
			return self:insert(path)
		else 
			return InteriorMapManager.PathMap[path]
		end
	end
end
