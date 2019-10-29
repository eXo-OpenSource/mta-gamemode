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
	if not self:isTableAvailable() then 
		print(("** [InteriorMapManager] Checking if %s_interiors_maps exists! Creating otherwise... **"):format(sql:getPrefix()))
		if self:createTable() then 
			self.m_Ready = true
		end
	else 
		self.m_Ready = true
	end
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

function InteriorMapManager.get(id)
	return InteriorMapManager.Map[id]
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


function InteriorMapManager:isTableAvailable()
	return sql:queryFetch("SELECT 1 FROM ??_interiors_maps;", sql:getPrefix())
end

function InteriorMapManager:createTable() 
	local queryMap = [[
		CREATE TABLE IF NOT EXISTS ??_interiors_maps (
		`Id` INT(11) NOT NULL AUTO_INCREMENT,
		`Path` VARCHAR(256) NOT NULL,
		`Category` INT(11) NOT NULL DEFAULT 0, 
		PRIMARY KEY (`Id`),
		UNIQUE INDEX `Path` (`Path`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1;
	]]

	if sql:queryExec(queryMap, sql:getPrefix()) then 
		print ("*** [InteriorMapManager] Table for Interior-Maps was created! ***")
		return true
	end
end

function InteriorMapManager:rebuild(map, newmap)
	if InteriorMapManager.Map[map:getId()] then 
		if CustomInteriorManager.MapByMapId[map:getId()] then 
			for index, instance in ipairs(CustomInteriorManager.MapByMapId[map:getId()]) do 
				instance:rebuild(newmap)
			end
			if CustomInteriorManager.KeepPositionMaps[map:getId()] then 
				CustomInteriorManager.KeepPositionMaps[map:getId()].mapNode:delete() 
				CustomInteriorManager.KeepPositionMaps[map:getId()].entrance:destroy()
				CustomInteriorManager.KeepPositionMaps[map:getId()] = nil
			end
		end
	end
end
