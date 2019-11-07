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
CustomInteriorManager.OwnerMap = {}
function CustomInteriorManager:constructor()
	addRemoteEvents{"InteriorManager:onFall", "InteriorManager:onDetectLeave", "InteriorManager:onInteriorReady"}
	addEventHandler("InteriorManager:onFall", root, bind(self.Event_onAntiFall, self))
	addEventHandler("InteriorManager:onInteriorReady", root, bind(self.Event_onInteriorReady, self))
	addEventHandler("InteriorManager:onDetectLeave", root, bind(self.Event_onDetectLeave, self))
	InteriorLoadManager:new()
	InteriorMapManager:new():load()
	self.m_CurrentDimension = 1
	self.m_CurrentInterior = 20
	self.m_LoadedCount = 0
	self.m_FailLoads = {}
	self.m_Ready = false
	if not self:isPlayerColumnAvailable() then 
		self:createLogoutColumn()
	end
	if not self:isTableAvailable() then 
		print(("** [CustomInteriorManager] Checking if %s_interiors exists! Creating otherwise... **"):format(sql:getPrefix()))
		if self:createTable() then 
			self.m_Ready = true
			INTERIOR_HOUSE_MIGRATION = true 
			INTERIOR_SHOP_MIGRATION = true
			INTERIOR_COMPANY_MIGRATION = true
			print(("***************************************************"):format(sql:getPrefix())) 
			print(("** [CustomInteriorManager] Starting Migration... **"):format(sql:getPrefix())) 
			print(("***************************************************"):format(sql:getPrefix())) 
		end
	else 
		self.m_Ready = true
	end
	if self:isReady() then
		self:getLastGridPoint()
		PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))
		PlayerManager:getSingleton():getWastedHook():register(
			function(player)
				if player.m_Interior then
					player.m_Interior:remove(player)
				end
			end
		)
	end
end

function CustomInteriorManager:destructor()
	for instance, bool in pairs(CustomInteriorManager.Map) do 
		instance:delete()
	end
	delete(InteriorMapManager)
end

function CustomInteriorManager:load(id)
	local row = sql:queryFetchSingle("SELECT * FROM ??_interiors WHERE Id=?", sql:getPrefix(), id)
	if row then 
		if self:assertRow(row) then
			self.m_LoadedCount = self.m_LoadedCount + 1
			local packData = 
			{
				position = Vector3(row.PosX, row.PosY, row.PosZ), 
				interior = row.Interior, 
				dimension = row.Dimension,
			}
			local instance = Interior:new(InteriorMapManager.get(row.MapId), packData, row.Generated):setOwner(row.OwnerType, row.Owner):setId(row.Id)
			CustomInteriorManager:getSingleton():add(instance)
			return self
		else 
			self.m_FailLoads[row.Id] = true
		end
	end
end

function CustomInteriorManager:loadFromOwner(ownerType, owner)
	local row = sql:queryFetchSingle("SELECT * FROM ??_interiors WHERE OwnerType=? AND Owner=?", sql:getPrefix(), ownerType, owner)
	if row then 
		if row.Id then
			return CustomInteriorManager.getIdMap(row.Id, true)
		else 
			self.m_FailLoads[row.Id] = true
		end
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
		ON DUPLICATE KEY UPDATE MapId=?, PosX=?, PosY=?, PosZ=?, Interior=?, Dimension=?, Owner=?, OwnerType=?, Generated=?;
	]]

	local id, map, x, y, z, int, dim, owner, ownerType, generated = instance:getSerializeData()
	sql:queryExec(query, sql:getPrefix(), id, map, x, y, z, int, dim, owner, ownerType, map, x, y, z, int, dim, owner, ownerType, generated)

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

function CustomInteriorManager:getInteriorDimensionCount(interior) -- probe to get the highest dimension for any given gta-sa interior
	local query = [[
		SELECT Max(Dimension) as Dimension FROM ??_interiors WHERE Interior=?
	]]
	local result = sql:queryFetchSingle(query, sql:getPrefix(), interior)
	return (result and result.Dimension) or 0 
end


function CustomInteriorManager:override(instance, oldmap)  -- used when an interior has changed its map
	local query = [[
		UPDATE ??_interiors SET MapId=?, PosX=?, PosY=?, PosZ=?, Interior=?, Dimension=?, Owner=?, OwnerType=?, Generated=?, Date=NOW()
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
	instance:setAnyChange(false)
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

function CustomInteriorManager:add(instance)
	CustomInteriorManager.Map[instance] = true
	if not CustomInteriorManager.MapByMapId[instance:getMap():getId()] then CustomInteriorManager.MapByMapId[instance:getMap():getId()] = {} end 
	CustomInteriorManager.MapByMapId[instance:getMap():getId()][instance] = true
	if instance:getOwner() > 0 then
		InteriorLoadManager.call(instance:getOwnerType(), instance:getOwner(), instance)
		if not CustomInteriorManager.OwnerMap[instance:getOwnerType()] then 
			CustomInteriorManager.OwnerMap[instance:getOwnerType()]  = {}
		end
		CustomInteriorManager.OwnerMap[instance:getOwnerType()][instance:getOwner()] = instance
	end
end

function CustomInteriorManager:remove(instance) 
	CustomInteriorManager.Map[instance] = nil
	if CustomInteriorManager.MapByMapId[instance:getMap():getId()] then 
		CustomInteriorManager.MapByMapId[instance:getMap():getId()][instance] = nil
		CustomInteriorManager.OwnerMap[instance:getOwnerType()][instance:getOwner()] = nil
	end
end

function CustomInteriorManager:addId(instance) 
	CustomInteriorManager.IdMap[instance:getId()] = instance 
end


function CustomInteriorManager:removeId(instance) 
	CustomInteriorManager.IdMap[instance:getId()] = nil 
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


function CustomInteriorManager:onInteriorLoad(instance)
	if not instance:isGenerated() and instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION or instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION_ONE_DIMENSION then 
		local findInterior = InteriorMapManager:getSingleton():getMapInterior(instance:getMap():getPath())
		if not CustomInteriorManager.MapByInterior[tostring(findInterior)] then 
			CustomInteriorManager.MapByInterior[tostring(findInterior)] = self:getInteriorDimensionCount(findInterior) + 1 
		else 
			CustomInteriorManager.MapByInterior[tostring(findInterior)] = CustomInteriorManager.MapByInterior[tostring(findInterior)] + 1
		end
	end 
end

function CustomInteriorManager:onInteriorRebuild(instance, previousMap, newMap)
	local newInterior =  InteriorMapManager:getSingleton():getMapInterior(newMap:getPath()) 
	if instance:getPlaceMode() ~= previousMap:getMode() or InteriorMapManager:getSingleton():getMapInterior(previousMap:getPath()) ~= newInterior then
		if instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION or instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION_ONE_DIMENSION then 
			if not CustomInteriorManager.MapByInterior[tostring(newInterior)] then 
				CustomInteriorManager.MapByInterior[tostring(newInterior)] = self:getInteriorDimensionCount(newInterior) + 1 
			else 
				CustomInteriorManager.MapByInterior[tostring(newInterior)] = CustomInteriorManager.MapByInterior[tostring(newInterior)] + 1
			end
			if CustomInteriorManager.MapByInterior[tostring(newInterior)] then 
				CustomInteriorManager.MapByInterior[tostring(newInterior)] = CustomInteriorManager.MapByInterior[tostring(newInterior)] - 1
				if CustomInteriorManager.MapByInterior[tostring(newInterior)] < 0 then 
					CustomInteriorManager.MapByInterior[tostring(newInterior)] = 0
				end
			end
		end
	end
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

function CustomInteriorManager:onInteriorCreate(instance) 

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

function CustomInteriorManager:onPlayerLogin(player) 
	if player.m_LogoutInterior and tonumber(player.m_LogoutInterior)  then 
		local instance = CustomInteriorManager.getIdMap(player.m_LogoutInterior, true)
		if instance then 
			instance:enter(player, true)
		end
	end
end

function CustomInteriorManager:onPlayerQuit(player) 
	if player:getCustomInterior() then 
		self:onLeaveInterior(player, player:getCustomInterior(), true)
	end
end

function CustomInteriorManager:Event_onAntiFall() 
	if client.m_Interior then 
		client.m_Interior:antifall(client)
	end
end

function CustomInteriorManager:Event_onDetectLeave(interior, dimension) 
	if client.m_Interior and client.m_Interior:getInterior() == interior and client.m_Interior:getDimension() == dimension then 
		client.m_Interior:exit(client, true)
	end
end

function CustomInteriorManager:Event_onInteriorReady() 
	if client.m_Interior then 
		client.m_Interior:warp(client)
	end
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

function CustomInteriorManager:getMapCount(id) 
	return (not CustomInteriorManager.MapByMapId[id] and 0) or table.size(CustomInteriorManager.MapByMapId[id])
end

function CustomInteriorManager:getHighestDimensionByInterior(instance)
	local findInterior =  InteriorMapManager:getSingleton():getMapInterior(instance:getMap():getPath()) 
	if not CustomInteriorManager.MapByInterior[tostring(findInterior)] then 
		CustomInteriorManager.MapByInterior[tostring(findInterior)] = 1
	end
	instance:setDimension(CustomInteriorManager.MapByInterior[tostring(findInterior)])
	instance:updatePlace()
	return CustomInteriorManager.MapByInterior[tostring(findInterior)]
end

function CustomInteriorManager:isReady() return self.m_Ready end

function CustomInteriorManager:isTableAvailable()
	return sql:queryFetch("SELECT 1 FROM ??_interiors;", sql:getPrefix())
end

function CustomInteriorManager:isPlayerColumnAvailable() 
	local query = 
	[[
		SHOW COLUMNS FROM ??_character WHERE Field LIKE "LogoutInterior"
	]]
	return sql:queryFetchSingle(query, sql:getPrefix())
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
		`Generated` INT(1) NOT NULL DEFAULT '0',
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

function CustomInteriorManager:createLogoutColumn() 
	local query = 
	[[
		ALTER TABLE ??_character
		ADD COLUMN `LogoutInterior` INT NULL;
	]]

	if sql:queryExec(query, sql:getPrefix()) then 
		print("** [CustomInteriorManager] Player-Field LogoutInterior was created! **")
		return true
	end
	return false
end

function CustomInteriorManager.getIdMap(id, load) 
	if not load then
		return CustomInteriorManager.IdMap[id]
	else 
		if CustomInteriorManager.IdMap[id] then 
			return CustomInteriorManager.IdMap[id]
		else 
			CustomInteriorManager:getSingleton():load(id)
			return CustomInteriorManager.IdMap[id]
		end
	end
end
