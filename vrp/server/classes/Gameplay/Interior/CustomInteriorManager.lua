-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/CustomInteriorManager.lua
-- *  PURPOSE:     Manages custom interiors 
-- *
-- ****************************************************************************
CustomInteriorManager = inherit(Singleton)
CustomInteriorManager.Map = {}
CustomInteriorManager.IdMap = {}
CustomInteriorManager.MapByMapId = {}
CustomInteriorManager.KeepPositionMaps = {}
CustomInteriorManager.MapByInterior = {}
function CustomInteriorManager:constructor() 
	InteriorMapManager:new():load()
	self:houseMigrator()
	self.m_CurrentDimension = 1
	self.m_CurrentInterior = 20
	self.m_LoadedCount = 0
	self.m_FailLoads = {}
	self.m_Ready = false
	if not self:isTableAvailable() then 
		print(("** [CustomInteriorManager] Checking if %s_interiors exists! Creating otherwise... **"):format(sql:getPrefix()))
		if self:createTable() then 
			self.m_Ready = true
		end
	else 
		self.m_Ready = true
	end
	if self:isReady() then
		self:getLastGridPoint()
		PlayerManager:getSingleton():getQuitHook():register(bind(self.onQuit, self))
	end
end

function CustomInteriorManager:destructor()
	for instance, bool in pairs(CustomInteriorManager.Map) do 
		instance:delete()
	end
	delete(InteriorMapManager)
end

function CustomInteriorManager:load()
	local result = sql:queryFetch("SELECT * FROM ??_interiors", sql:getPrefix())
	if result then 
		for index, row in pairs(result) do 
			if self:assertRow(row) then
				self.m_LoadedCount = self.m_LoadedCount + 1
				local packData = 
				{
					position = Vector3(row.PosX, row.PosY, row.PosZ), 
					interior = row.Interior, 
					dimension = row.Dimension,
				}
				Interior:new(InteriorMapManager.get(row.MapId), packData, row.Generated):setOwner(row.Owner, row.OwnerType):setId(row.Id)
			else 
				self.m_FailLoads[row.Id] = true
			end
		end 
	end
	for k, player in pairs(Element.getAllByType("player")) do 
		self:onLogin(player)
	end
end

function CustomInteriorManager:save(instance, destroy) 
	local updateId
	if not destroy then
		updateId = not self:probe(instance:getId()) 
	end
	local query = [[
		INSERT INTO ??_interiors (`Id`, `MapId`, `PosX`, `PosY`, `PosZ`, `Interior`, `Dimension`, `Owner`, `OwnerType`) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) 
		ON DUPLICATE KEY UPDATE Interior=?, Dimension=?, Owner=?, OwnerType=?, Generated=?;
	]]

	outputChatBox(instance:getId())
	local id, map, x, y, z, int, dim, owner, ownerType, generated = instance:getSerializeData()
	sql:queryExec(query, sql:getPrefix(), id, map, x, y, z, int, dim, owner, ownerType, int, dim, owner, ownerType, generated)

	if not destroy then
		instance:setId(updateId and sql:lastInsertId() or instance:getId())

	end
			
	instance:setAnyChange(false)
end

function CustomInteriorManager:probe(id) -- probe to see if an id exists
	local query = [[
		SELECT Id FROM ??_interiors WHERE Id=?
	]]
	local result = sql:queryFetchSingle(query, sql:getPrefix(), id)
	return result and result.Id
end

function CustomInteriorManager:override(instance, oldmap)  -- used when an interior has changed its map
	local query = [[
		UPDATE ??_interiors SET MapId=?, PosX=?, PosY=?, PosZ=?, Interior=?, Dimension=?, Owner=?, OwnerType=?, Generated=? Date=NOW()
		WHERE Id=?;
	]]

	local id, map, x, y, z, int, dim, owner, ownerType, generated = instance:getSerializeData()
	sql:queryExec(query, sql:getPrefix(), map, x, y, z, int, dim, owner, ownerType, generated, id)
	
	if oldmap then 
		if CustomInteriorManager.MapByMapId[oldmap] then 
			CustomInteriorManager.MapByMapId[oldmap][instance] = nil
		end
	end

	self:add(instance)	-- re-add to name index
	self:setAnyChange(false)
end

function CustomInteriorManager:getLastGridPoint()
	local query = [[
		SELECT
			PosX, PosY, PosZ, Dimension, Interior, Mode 
		FROM
			??_interiors
		INNER JOIN ??_interiors_maps ON
			??_interiors.MapId = ??_interiors_maps.Id AND ??_interiors_maps.Mode = ?
		GROUP BY ??_interiors.Id DESC Limit 1;
	]]
	local row = sql:queryFetchSingle(query, sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), sql:getPrefix(), 
										DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE, sql:getPrefix())
	if row then 
		self:setMaxX(row.PosX) 
		self:setMaxY(row.PosY) 
		self:setCurrentInterior(row.Interior) 
		self:setCurrentDimension(row.Dimension)
	else 
		self:setMaxX(DYNAMIC_INTERIOR_GRID_START_X) 
		self:setMaxY(DYNAMIC_INTERIOR_GRID_START_Y)
		self:setCurrentDimension(DYNAMIC_INTERIOR_GRID_START_DIMENSION) 
		self:setCurrentInterior(DYNAMIC_INTERIOR_GRID_START_INTERIOR)
	end
end

function CustomInteriorManager:assertRow(row) 
	return row and row.MapId and row.PosX and row.PosY and row.PosZ and row.Interior and row.Dimension
end

function CustomInteriorManager:isLoadOnly(row) 
	return row.OwnerType and row.Owner == 1
end

function CustomInteriorManager:add(instance)
	CustomInteriorManager.Map[instance] = true
	if not CustomInteriorManager.MapByMapId[instance:getMap():getId()] then CustomInteriorManager.MapByMapId[instance:getMap():getId()] = {} end 
	CustomInteriorManager.MapByMapId[instance:getMap():getId()][instance] = true
end

function CustomInteriorManager:onInteriorLoad(instance)
	if instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION or instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION_ONE_DIMENSION then 
		local interior =  InteriorMapManager:getSingleton():getMapInterior(instance:getMap():getPath())
		if not CustomInteriorManager.MapByInterior[tostring(interior)] then 
			CustomInteriorManager.MapByInterior[tostring(interior)] = 1
		else 
			CustomInteriorManager.MapByInterior[tostring(interior)] = CustomInteriorManager.MapByInterior[tostring(interior)] + 1
		end
	end 
end

function CustomInteriorManager:onInteriorRebuild(instance)
	local interior =  InteriorMapManager:getSingleton():getMapInterior(instance:getMap():getPath()) 
	if instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION or  instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION_ONE_DIMENSION then 
		if CustomInteriorManager.MapByInterior[tostring(interior)] then 
			CustomInteriorManager.MapByInterior[tostring(interior)] = CustomInteriorManager.MapByInterior[tostring(interior)] - 1
			if CustomInteriorManager.MapByInterior[tostring(interior)] < 0 then 
				CustomInteriorManager.MapByInterior[tostring(interior)] = 0
			end
		end
	end
end

function CustomInteriorManager:onInteriorCreate(instance) 

end

function CustomInteriorManager:remove(instance) 
	CustomInteriorManager.Map[instance] = nil
	if CustomInteriorManager.MapByMapId[instance:getMap():getId()] then 
		CustomInteriorManager.MapByMapId[instance:getMap():getId()][instance] = nil
	end
end

function CustomInteriorManager:addId(instance) 
	CustomInteriorManager.IdMap[instance:getId()] = instance 
end


function CustomInteriorManager:removeId(instance) 
	CustomInteriorManager.IdMap[instance:getId()] = nil 
end


function CustomInteriorManager:getMapCount(id) 
	return (not CustomInteriorManager.MapByMapId[id] and 0) or table.size(CustomInteriorManager.MapByMapId[id])
end

function CustomInteriorManager:findPlace(instance) 
	local min, max = instance:getBounding()
	if not self:getMaxX() then 
		self:setMaxX(DYNAMIC_INTERIOR_GRID_START_X)
	end
	if not self:getCurrentY() then 
		self:setCurrentY(DYNAMIC_INTERIOR_GRID_START_Y) 
		self:setMaxY(self:getCurrentY() + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE)
	end
	if self:getMaxY() < (self:getCurrentY() + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE) then 
		self:setMaxY(self:getCurrentY() + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE)
	end
	local nextMaxX = self:getMaxX() + (max.x - min.x)  + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	if nextMaxX > DYNAMIC_INTERIOR_GRID_END_X then 
		self:setMaxX(DYNAMIC_INTERIOR_GRID_START_X)
		self:setCurrentY(self:getMaxY())
		if self:getMaxY() > DYNAMIC_INTERIOR_GRID_END_Y then 
			self:setMaxX(DYNAMIC_INTERIOR_GRID_START_X) 
			self:setCurrentY(DYNAMIC_INTERIOR_GRID_START_Y) 
			self:setMaxY(self:getCurrentY() + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE)
			self:setCurrentDimension(self:getCurrentDimension() + 1)
			if self:getCurrentDimension() > DYNAMIC_INTERIOR_MAX_DIMENSION then 
				self:setCurrentDimension(1)
				self:setCurrentInterior(self:getCurrentInterior() + 1)
			end
		end
	else 
		self:setMaxX(nextMaxX)
	end
	instance:setPlace(Vector3(self:getMaxX(), self:getMaxY(), DYNAMIC_INTERIOR_GRID_START_Z), self:getCurrentInterior(), self:getCurrentDimension())
end

function CustomInteriorManager:setMaxX(value)
	self.m_MaxX = math.floor(value)
end

function CustomInteriorManager:setMaxY(value) 
	self.m_MaxY = math.floor(value)
end

function CustomInteriorManager:setCurrentX(value)
	self.m_CurrentX = math.floor(value) 
end

function CustomInteriorManager:setCurrentY(value)
	self.m_CurrentY = math.floor(value) 
end

function CustomInteriorManager:setCurrentDimension(value)
	self.m_CurrentDimension = value
end

function CustomInteriorManager:setCurrentInterior(value) 
	self.m_CurrentInterior = value
end

function CustomInteriorManager:getMaxX() return self.m_MaxX end
function CustomInteriorManager:getMaxY() return self.m_MaxY end
function CustomInteriorManager:getCurrentX() return self.m_CurrentX end
function CustomInteriorManager:getCurrentY() return self.m_CurrentY end
function CustomInteriorManager:getCurrentDimension() return self.m_CurrentDimension end
function CustomInteriorManager:getCurrentInterior() return self.m_CurrentInterior end

function CustomInteriorManager:getHighestDimensionByInterior(instance)
	local interior =  InteriorMapManager:getSingleton():getMapInterior(instance:getMap():getPath())  
	outputChatBox(interior)
	if not CustomInteriorManager.MapByInterior[tostring(interior)] then 
		CustomInteriorManager.MapByInterior[tostring(interior)] = 1
	end
	instance:setDimension(CustomInteriorManager.MapByInterior[tostring(interior)])
	instance:updatePlace()
	return CustomInteriorManager.MapByInterior[tostring(interior)]
end

function CustomInteriorManager:createMapInAllDimensions(instance) 
	if instance:getMap() then
		if not CustomInteriorManager.KeepPositionMaps[instance:getMap():getId()] then
			instance:create(true) 
			CustomInteriorManager.KeepPositionMaps[instance:getMap():getId()] = {entrance = instance:getEntrance()}
		end
		if not instance:getPlaceData() then
			instance:clone(CustomInteriorManager.KeepPositionMaps[instance:getMap():getId()].entrance)
		else 
			instance:place(CustomInteriorManager.KeepPositionMaps[instance:getMap():getId()].entrance)
		end
	end
end

function CustomInteriorManager:onEnterInterior(element, instance) 
	if element:getType() == "player" and instance:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.MANUAL_INPUT then 
		element:setCustomInterior(instance)
	end
end

function CustomInteriorManager:onLeaveInterior(element, instance, quit) 
	if element:getType() == "player" then 
		if element:getCustomInterior() == instance and instance:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.MANUAL_INPUT then
			if not quit then
				element:setCustomInterior()
			end
		end
	end
end

function CustomInteriorManager:onLogin(player) 
	if player.m_LogoutInterior and tonumber(player.m_LogoutInterior)  then 
		local instance = CustomInteriorManager.getIdMap(player.m_LogoutInterior)
		if instance then 
			if not instance:isCreated() then 
				instance:create()
			end
			self:onEnterInterior(player, instance)
		end
	end
end

function CustomInteriorManager:onQuit(player) 
	if player:getCustomInterior() then 
		self:onLeaveInterior(player, player:getCustomInterior(), true)
	end
end

function CustomInteriorManager:isReady() return self.m_Ready end

function CustomInteriorManager:isTableAvailable()
	return sql:queryFetch("SELECT 1 FROM ??_interiors;", sql:getPrefix())
end

function CustomInteriorManager:createTable() 
	local query = [[
	CREATE TABLE IF NOT EXISTS ??_interiors (
	 	`Id` int(11) NOT NULL AUTO_INCREMENT,
		`MapId` INT(11) NULL,
  		`PosX` float NOT NULL DEFAULT 0,
  		`PosY` float NOT NULL DEFAULT 0,
  		`PosZ` float NOT NULL DEFAULT 0,
  		`Interior` int(11) NOT NULL DEFAULT 0,
  		`Dimension` int(11) NOT NULL DEFAULT 0,
		`Generated` INT(1) NOT NULL DEFAULT '0'
  		`Owner` int(11) NOT NULL DEFAULT 0,
  		`OwnerType` int(11) NOT NULL DEFAULT 0,
  		`Date` datetime NOT NULL DEFAULT current_timestamp(),
  		PRIMARY KEY (`Id`),
		INDEX `MapId_FK` (`MapId`),
		CONSTRAINT `MapId_FK` FOREIGN KEY (`MapId`) REFERENCES ??_interiors_maps (`Id`) ON UPDATE CASCADE ON DELETE SET NULL
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;
	]]

	if sql:queryExec(query, sql:getPrefix(), sql:getPrefix()) then 
		print("** [CustomInteriorManager] Database for Interiors  was created **")
		return true
	end
	return false
end

function CustomInteriorManager:houseMigrator() 
	local probeQuery = [[
		SHOW COLUMNS FROM ??_houses WHERE Field LIKE "interiorID" AND Type LIKE "%tiny%"
	]]
	if sql:queryFetchSingle(probeQuery, sql:getPrefix()) then 
		print (("** [InteriorManager] %s_houses needs to be altered! (Copying %s_houses to %s_houses_old and altering structure!) **"):format(sql:getPrefix(), sql:getPrefix(), sql:getPrefix()))
		local copyQuery = [[
			CREATE TABLE ??_houses_old AS SELECT * FROM ??_houses
		]]
		if sql:queryExec(copyQuery, sql:getPrefix(), sql:getPrefix()) then 
			local alterQuery = [[
				ALTER TABLE ??_houses
				CHANGE COLUMN `interiorID` `oldHouseID` TINYINT(4) NULL DEFAULT NULL AFTER `z`;
			]]
			if sql:queryExec(alterQuery, sql:getPrefix()) then 
				local addQuery = [[
					ALTER TABLE ??_houses
					ADD COLUMN `interiorID` INT NULL DEFAULT 0 AFTER `oldHouseID`;
				]]
				if sql:queryExec(addQuery, sql:getPrefix()) then
					print ("** [InteriorManager] Houses-Structure altered! **")
					HouseManager.Migrated = true
				end
			end
		end
	end 
end

function CustomInteriorManager:endHouseMigration() 
	local probeQuery = [[
		SHOW COLUMNS FROM ??_houses WHERE Field LIKE "oldHouseID"
	]]	
	if sql:queryFetchSingle(probeQuery, sql:getPrefix()) then 
		local dropQuery = [[
			ALTER TABLE ??_houses
  				DROP COLUMN `oldHouseID`;
		]]
		sql:queryExec(dropQuery, sql:getPrefix())
	end
	print("** [InteriorManager] House-Migration is done! **")
end

function CustomInteriorManager.getIdMap(id) 
	return CustomInteriorManager.IdMap[id]
end
