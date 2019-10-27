-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/CustomInteriorManager.lua
-- *  PURPOSE:     Manages custom interiors 
-- *
-- ****************************************************************************
CustomInteriorManager = inherit(Singleton)
CustomInteriorManager.Map = {}
CustomInteriorManager.MapByName = {}

function CustomInteriorManager:constructor() 
	self.m_CurrentDimension = 1
	self.m_CurrentInterior = 20
	self.m_LoadedCount = 0
	self.m_FailLoads = {}
	self.m_Ready = false
	if not self:isDatabaseAvaialble() then 
		print(("** [CustomInteriorManager] Checking if %s_interiors exists! If not it will be created... **"):format(sql:getPrefix()))
		if self:createDatabase() then 
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
				Interior:new(row.Path, packData, self:isLoadOnly(row), DYANMIC_INTERIOR_PLACE_MODES.USE_DATA):setOwner(row.Owner, row.OwnerType):setId(row.Id)
			else 
				self.m_FailLoads[row.Id] = true
			end
		end 
	end
	for k, player in pairs(Element.getAllByType("player")) do 
		self:onLogin(player)
	end
end

function CustomInteriorManager:save(instance) 
	local query = [[
		INSERT INTO ??_interiors (`Name`, `Path`, `PosX`, `PosY`, `PosZ`, `Interior`, `Dimension`, `Mode`, `Owner`, `OwnerType`) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) 
		ON DUPLICATE KEY UPDATE Owner=?, OwnerType=?;
	]]
	
	sql:queryExec(query, sql:getPrefix(), instance:getName(), instance:getPath(), 
	instance:getEntrance():getPosition().x, instance:getEntrance():getPosition().y, instance:getEntrance():getPosition().z,
	instance:getEntrance():getInterior(), instance:getEntrance():getDimension(),
	instance:getPlaceMode(), instance:getOwner(), instance:getOwnerType(), instance:getOwner(), instance:getOwnerType())
end

function CustomInteriorManager:getLastGridPoint()
	local query = [[
		SELECT PosX, PosY, PosZ, Interior, Dimension FROM ??_interiors
		WHERE Mode = ? GROUP BY Id DESC LIMIT 1;
	]]
	local row = sql:queryFetchSingle(query, sql:getPrefix(), DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE)
	if row then 
		self.m_MaxX = row.PosX 
		self.m_MaxY = row.PosY 
		self.m_CurrentInterior = row.Interior 
		self.m_CurrentDimension = row.Dimension
	end
end

function CustomInteriorManager:assertRow(row) 
	return row and row.Name and row.Path and row.PosX and row.PosY and row.PosZ and row.Interior and row.Dimension and row.Mode
end

function CustomInteriorManager:isLoadOnly(row) 
	return row.OwnerType and row.Owner == 1
end

function CustomInteriorManager:add(instance)
	CustomInteriorManager.Map[instance] = true
	if not CustomInteriorManager.MapByName[instance:getName()] then CustomInteriorManager.MapByName[instance:getName()] = {} end 
	table.insert(CustomInteriorManager.MapByName[instance:getName()], instance)
end

function CustomInteriorManager:remove(instance) 
	CustomInteriorManager.Map[instance] = nil
	if CustomInteriorManager.MapByName[instance:getName()] then 
		local found = table.find( CustomInteriorManager.MapByName[instance:getName()], instance)
		if found then 
			table.remove( CustomInteriorManager.MapByName[instance:getName()], found)
		end
	end
end

function CustomInteriorManager:getMapCount(name) 
	return (not CustomInteriorManager.MapByName[name] and 0) or #CustomInteriorManager.MapByName[name]
end

function CustomInteriorManager:findPlace(instance) 
	local min, max = instance:getBounding()
	if not self.m_MaxX then 
		self.m_MaxX = DYNAMIC_INTERIOR_GRID_START_X
	end
	if not self.m_CurrentY then 
		self.m_CurrentY = DYNAMIC_INTERIOR_GRID_START_Y 
		self.m_MaxY = self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	end
	if self.m_MaxY < (self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE) then 
		self.m_MaxY = self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	end
	local nextMaxX = self.m_MaxX + (max.x - min.x)  + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	if nextMaxX > DYNAMIC_INTERIOR_GRID_END_X then 
		self.m_MaxX = DYNAMIC_INTERIOR_GRID_START_X 
		self.m_CurrentY = self.m_MaxY
		if self.m_MaxY > DYNAMIC_INTERIOR_GRID_END_Y then 
			self.m_MaxX = DYNAMIC_INTERIOR_GRID_START_X 
			self.m_CurrentY = DYNAMIC_INTERIOR_GRID_START_Y 
			self.m_MaxY = self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE
			self.m_CurrentDimension = self.m_CurrentDimension + 1
			if self.m_CurrentDimension > DYNAMIC_INTERIOR_MAX_DIMENSION then 
				self.m_CurrentDimension = 1
				self.m_CurrentInterior = self.m_CurrentInterior + 1
			end
		end
	else 
		self.m_MaxX = nextMaxX
	end

	self.m_MaxX = math.floor(self.m_MaxX) 
	self.m_MaxY = math.floor(self.m_MaxY)

	instance:setPlace(Vector3(self.m_MaxX, self.m_MaxY, DYNAMIC_GRID_START_Z), self.m_CurrentInterior, self.m_CurrentDimension)
end

function CustomInteriorManager:findDimension(instance) 
	if not CustomInteriorManager.MapByName[instance:getName()] then 
		instance:setDimension(1)
		instance:setInterior(instance:getEntrance():getInterior())
	else 
		instance:setDimension(self:getHighestDimensionByName(instance:getName())+1)
		instance:setInterior(instance:getEntrance():getInterior())
	end 
end

function CustomInteriorManager:onEnterInterior(element, instance) 
	if element:getType() == "player" then 
		element:setCustomInterior(instance)
	end
end


function CustomInteriorManager:onLeaveInterior(element, instance, quit) 
	if element:getType() == "player" then 
		if element:getCustomInterior() == instance then
			if not quit then
				element:setCustomInterior()
			end
		end
	end
end

function CustomInteriorManager:onLogin(player) 
	if player.m_LogoutInterior then 
		local data = fromJSON(player.m_LogoutInterior)
		if data and table.size(data) > 0 then 
			if CustomInteriorManager.MapByName[data.name] then 
				for index, instance in ipairs(CustomInteriorManager.MapByName[data.name]) do 
					if instance:getId() == data.id then 
						if not instance:isCreated() then 
							instance:create()
						end
						self:onEnterInterior(player, instance)
					end
				end
			end 
		end
	end
end

function CustomInteriorManager:onQuit(player) 
	if player:getCustomInterior() then 
		self:onLeaveInterior(player, player:getCustomInterior(), true)
	end
end

function CustomInteriorManager:getHighestDimensionByName(name) 
	local lastInstance
	if CustomInteriorManager.MapByName[name] then
		for index, instance in pairs(CustomInteriorManager.MapByName[name]) do 
			if instance:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then 
				lastInstance = instance
			end
		end
		if lastInstance then 
			return lastInstance:getEntrance():getDimension()
		else 
			return 1
		end
	else 
		return 1
	end
end

function CustomInteriorManager:isReady() return self.m_Ready end

function CustomInteriorManager:isDatabaseAvaialble()
	return sql:queryFetch("SELECT 1 FROM ??_Interiors;", sql:getPrefix())
end

function CustomInteriorManager:createDatabase() 
	local query = [[
	CREATE TABLE IF NOT EXISTS `vrp_interiors` (
	 	`Id` int(11) NOT NULL AUTO_INCREMENT,
		`Name` VARCHAR(50) NOT NULL,	
  		`Path` VARCHAR(75) NOT NULL,	
  		`PosX` float NOT NULL DEFAULT 0,
  		`PosY` float NOT NULL DEFAULT 0,
  		`PosZ` float NOT NULL DEFAULT 0,
  		`Interior` int(11) NOT NULL DEFAULT 0,
  		`Dimension` int(11) NOT NULL DEFAULT 0,
  		`Mode` int(11) NOT NULL DEFAULT 0,
  		`Owner` int(11) DEFAULT 0,
  		`OwnerType` int(11) DEFAULT 0,
  		`Date` datetime NOT NULL DEFAULT current_timestamp(),
  		PRIMARY KEY (`Id`)
	) ENGINE=InnoDB DEFAULT CHARSET=latin1;
	]]
	if sql:queryExec(query) then 
		print("** [CustomInteriorManager] Database for Interiors was created **")
		return true
	end
	return false
end