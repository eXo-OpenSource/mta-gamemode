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
InteriorMapManager.Cache = {}
InteriorMapManager.Interior = {}
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
	for id, instance in pairs(InteriorMapManager.Map) do 
		instance:delete()
	end
end

function InteriorMapManager:load()
	local result = sql:queryFetch("SELECT * FROM ??_interiors_maps", sql:getPrefix())
	for index, row in pairs(result) do 
		InteriorMap:new(row.Id, row.Path, row.Mode, row.Interior)
	end
end

function InteriorMapManager:save(instance) 
	local query = [[
		UPDATE ??_interiors_maps SET LastDimension = ? WHERE Id = ?
	]]
	sql:queryExec(query, sql:getPrefix(), instance:getLastDimension(), instance:getId())
end

function InteriorMapManager:insert(path, mode)
	if File.Exists(path) then 
		local query = [[
			INSERT INTO ??_interiors_maps (Path, Mode) VALUES (?, ?)
		]]
		if sql:queryExec(query, sql:getPrefix(), path, mode or 3) then 
			return InteriorMap:new(sql:lastInsertId(), path, mode or 3, 0)
		end
	end
	return false
end

function InteriorMapManager:add(instance) 
	InteriorMapManager.Map[instance:getId()] = instance
	if not InteriorMapManager.PathMap[instance:getPath()] then InteriorMapManager.PathMap[instance:getPath()]={} end
	InteriorMapManager.PathMap[instance:getPath()][instance:getMode()] = instance
end

function InteriorMapManager:remove(instance) 
	InteriorMapManager.Map[instance:getId()] = nil
	if InteriorMapManager.PathMap[instance:getPath()] then
		InteriorMapManager.PathMap[instance:getPath()][instance:getMode()] = nil
	end
end

function InteriorMapManager:getByPath(path, createNotExists, mode)
	if not createNotExists then
		return self:getPathWithMode(path, mode)
	else 
		if not self:getPathWithMode(path, mode) then
			return self:insert(path, mode)
		else 
			return self:getPathWithMode(path, mode)
		end
	end
end

function InteriorMapManager:getPathWithMode(path, searchMode) 
	for mode, instance in pairs(InteriorMapManager.PathMap[path]) do 
		if not searchMode then return instance end -- get the first instance if no mode is provided
		if instance:getMode() == searchMode then 
			return instance
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
		`Mode` TINYINT NOT NULL DEFAULT 3,
		`Interior` INT(11) NULL DEFAULT '0',
		`Category` INT(11) NOT NULL DEFAULT 0, 
		PRIMARY KEY (`Id`),
		UNIQUE INDEX `Path` (`Path`, `Mode`)
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

function InteriorMapManager.get(id)
	return InteriorMapManager.Map[id]
end

function InteriorMapManager.getCached(path)
	if not InteriorMapManager.Cache[path] then 
		InteriorMapManager.Cache[path] = MapParser:new(path)
		return InteriorMapManager.Cache[path]
	else 
		return InteriorMapManager.Cache[path]
	end
end

