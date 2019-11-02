-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorManager.lua
-- *  PURPOSE:     provides custom interiors 
-- *
-- ****************************************************************************
Interior = inherit(Object)
Interior.Map = {}

function Interior:constructor(map, row)
	assert(map, "Bad argument @ Interior.constructor")
	self.m_Clients = {} -- all clients currently using this 
	self:setMap(map)
	self:setId(DYNAMIC_INTERIOR_TEMPORARY_ID)
	self:setOwner(DYANMIC_INTERIOR_SERVER_OWNER, DYNAMIC_INTERIOR_SERVER_OWNER_TYPE)
	self:setTemporary(not row)
	self:setPlaceData(row) -- if we got already existing coordinates on this map use them
	self:setLoadOnly(true) -- every instance is load only and will only be created when someone enters it
	if File.Exists(self:getMap():getPath()) then 
		if self:load() == DYNAMIC_INTERIOR_SUCCESS then 
			if not self:isLoadOnly() then
				self:create()
				if self:getCreateCallback() then 
					self:getCreateCallback()()
				end
			end
		end
	else 
		self:setStatus(DYNAMIC_INTERIOR_NOT_FOUND)
	end
	CustomInteriorManager:getSingleton():add(self)
end

function Interior:load() 
	if self:isLoaded() then return end
	self:setMapNode(InteriorMapManager.getCached(self:getMap():getPath()))
	if self:getMapNode() then 
		self:setStatus(DYNAMIC_INTERIOR_SUCCESS)
		self:setLoaded(true)
	else 
		self:setStatus(DYNAMIC_INTERIOR_ERROR_MAP)
	end
	return self:getStatus()
end

function Interior:create(allDimension) 
	if allDimension or self:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
		self:search()  
	else 
		CustomInteriorManager:getSingleton():createMapInAllDimensions(self)
		return self
	end
	if self:getPlaceData() then
		if not allDimension then
			self:setPlace(self:getPlaceData().position, self:getPlaceData().interior, self:getPlaceData().dimension)
		end
	else 
		if self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION_ONE_DIMENSION then 
			CustomInteriorManager:getSingleton():findDimension(self)
		elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE then 
			CustomInteriorManager:getSingleton():findPlace(self)
		elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.MANUAL_INPUT then 
			-- do nothing
		end
	end
	self:setCreated(not allDimension and true)
	return self
end

function Interior:search() 
	for index, object in pairs(self:getMapNode():getData()) do 
		if object.markertype == DYNAMIC_INTERIOR_ENTRANCE_OBJECT_TYPE then 
			self:setEntrance(InteriorEntrance:new(self, Vector3(object.x, object.y, object.z), object.interior))
			break
		end
	end
	if not self:getEntrance() then
		self:setStatus(DYNAMIC_INTERIOR_INFO_ENTRANCE)
	end
	return self:getEntrance()
end

function Interior:clone(entrance) 
	local assignDimension = CustomInteriorManager:getSingleton():getHighestDimensionByName(self:getMap()) + 1
	self:getMap():setLastDimension(assignDimension)
	self:setEntrance(InteriorEntrance:new(self, entrance:getPosition(), entrance:getInterior(), assignDimension))
	self:updatePlace()
end

function Interior:place(entrance)
	self:setEntrance(InteriorEntrance:new(self, self:getPlaceData().position, self:getPlaceData().interior, self:getPlaceData().dimension))
	self:updatePlace()
end

function Interior:forceSave() 
	CustomInteriorManager:getSingleton():save(self)
	return self
end

function Interior:rebuild(map)
	assert(map, "Bad argument @ Interior.rebuild")
	local previousMap = self:getMap():getId() 
	self:setCreated(false)
	self:setMap(map)
	self:setPlaceData(nil)
	self:setLoaded(false)
	if File.Exists(self:getMap():getPath()) then 
		if self:load() == DYNAMIC_INTERIOR_SUCCESS then 
			if not self:isLoadOnly() then
				self:create()
				if self:getCreateCallback() then 
					self:getCreateCallback()()
				end
			end
		end
	else
		self:setStatus(DYNAMIC_INTERIOR_NOT_FOUND)
	end
	if not self:isTemporary() and self:getStatus() ~= DYNAMIC_INTERIOR_NOT_FOUND then 
		CustomInteriorManager:getSingleton():override(self, previousName)
	end
	return self
end

function Interior:enter(player) 
	if not self:isCreated() then 
		self:create()
		if self:getCreateCallback() then 
			self:getCreateCallback()()
		end
	end
	self:send(player)
	player:setDimension(self:getDimension())
	player:setInterior(self:getInterior())
	player:setPosition(self:getPosition())
	self.m_Clients[player] = true
	CustomInteriorManager:getSingleton():onEnterInterior(player, self)
end

function Interior:exit(player) 
	if self:getExit() then 
		player:setDimension(self:getExit().dimension)
		player:setInterior(self:getExit().interior)
		player:setPosition(self:getExit().position)
		self.m_Clients[player] = nil
		CustomInteriorManager:getSingleton():onLeaveInterior(player, self)
	end
end

function Interior:send(player)
	player:triggerEvent("InteriorManager:onStartMap", #self:getMapNode():getData())
	triggerLatentClientEvent(player, "InteriorManager:onEnter",
		DOWNLOAD_SPEED, false, root,		
		{
			map = self:getMapNode():getData(), 
			position = {x = self:getPlaceData().position.x, y = self:getPlaceData().position.y, z = self:getPlaceData().position.z}, 
			interior = self:getPlaceData().interior, 
			dimension = self:getPlaceData().dimension
		}
	)
end


function Interior:Event_OnElementEnter(element) 
	if self:getDimension() == element:getDimension() then 
		if self:getInterior() == element:getInterior() then 
			CustomInteriorManager:getSingleton():onEnterInterior(element, self)
		end
	end
end

function Interior:Event_OnElementLeave(element) 
	CustomInteriorManager:getSingleton():onLeaveInterior(element, self)
end

function Interior:destructor()
	if not self:isTemporary() then
		if not self:getPlaceData() or self:hasAnyChange() then
			CustomInteriorManager:getSingleton():save(self)
		end
	end
	CustomInteriorManager:getSingleton():remove(self)
end

function Interior:setStatus(status) 
	assert(status, "Bad argument @ Interior.setStatus")
	self.m_Status = status 
	return self
end

function Interior:setEntrance(entrance) 
	assert(entrance, "Bad argument @ Interior.setEntrance")
	self.m_Entrance = entrance 
	return self
end 

function Interior:setMap(map) 
	assert(map, "Bad argument @ Interior.setMap")
	self.m_InteriorMap = map 
	return self
end

function Interior:setPlaceData(data) 
	assert(not data or type(data) == "table", "Bad argument @ Interior.setPlaceData")
	self.m_PlaceData = data
	return self
end

function Interior:setLoadOnly(bool) 
	self.m_LoadOnly = bool 
	return self
end

function Interior:setLoaded(bool)
	self.m_Loaded = bool 
	return self	
end 

function Interior:setOwner(owner, ownerType) 
	assert(owner and ownerType, "Bad argument @ Interior.setOwner")
	self.m_Owner = owner
	self.m_OwnerType = ownerType 
	return self
end

function Interior:setDimension(dimension)
	assert(dimension, "Bad argument @ Interior.setDimension")
	self:getMapNode():setDimension(dimension)
	return self
end

function Interior:setInterior(interior)
	assert(interior, "Bad argument @ Interior.setInterior")
	self:getMapNode():setInterior(interior)
	return self
end

function Interior:setPlace(position, interior, dimension)
	assert(position and interior and dimension, "Bad argument @ Interior.setPlace")
	self:getEntrance():setDimension(dimension)
	self:getEntrance():setInterior(interior)
	self:getEntrance():setPosition(position)
	self:updatePlace()
	return self
end

function Interior:updatePlace() 
	self:setPlaceData({position = self:getPosition(), interior = self:getInterior(), dimension = self:getDimension()})
	return self
end

function Interior:setExit(position, interior, dimension)
	assert(position and interior and dimension, "Bad argument @ Interior.setExit")
	self.m_Exit = {position = position, interior = interior or 0, dimension = dimension or 0}
	return self
end

function Interior:setCreated(bool) 
	self.m_IsCreated = bool
end

function Interior:setTemporary(bool) 
	self.m_IsTemporary = bool
	return self
end

function Interior:setId(id)
	assert(id and type(id) == "number", "Bad argument @ Interior.setId")
	if self:getId() and self:getId() > 0 then 
		CustomInteriorManager:getSingleton():removeId(self)
	end
	self.m_Id = id
	if self:getId() and self:getId() > 0 then 
		CustomInteriorManager:getSingleton():addId(self)
	end
	return self
end

function Interior:setMapNode(map)
	self.m_Map = map
end

function Interior:setAnyChange(bool) 
	self.m_AnyChange = bool
	return self
end 

function Interior:setRebuildCallback(callback) 
	assert(callback and type(callback) == "function", "Bad argument @ Interior.setRebuildCallback")
	self.m_RebuildCallback = callback
	return self
end

function Interior:setCreateCallback(callback) 
	assert(callback and type(callback) == "function", "Bad argument @ Interior.setCreateCallback")
	self.m_CreateCallback = callback
	return self
end

function Interior:getStatus() return self.m_Status end
function Interior:getMap() return self.m_InteriorMap end
function Interior:getEntrance() return self.m_Entrance end
function Interior:getInterior() 
	return self:getEntrance() and self:getEntrance():getInterior()
end
function Interior:getDimension() 
	return self:getEntrance() and self:getEntrance():getDimension()
end
function Interior:getPosition() 
	return self:getEntrance() and self:getEntrance():getPosition()
end
function Interior:getMapNode() return self.m_Map end
function Interior:getBounding() return  self:getMapNode():getBoundingBox() end
function Interior:getSphereOfInfluence() return self.m_SphereOfInfluence end
function Interior:getPlaceData() return self.m_PlaceData end
function Interior:isLoaded() return self.m_Loaded end
function Interior:isLoadOnly() return self.m_LoadOnly end
function Interior:getPlaceMode() return self:getMap():getMode() end
function Interior:getOwner() return self.m_Owner end 
function Interior:getOwnerType() return self.m_OwnerType end
function Interior:isCreated() return self.m_IsCreated end
function Interior:getId() return self.m_Id end
function Interior:isTemporary() return self.m_IsTemporary end
function Interior:getExit() return self.m_Exit end
function Interior:hasAnyChange() return self.m_AnyChange end
function Interior:getPlayerSerialize(player) 
	if not self:isTemporary() then
		return self:getId()
	else 
		return 0
	end
end
function Interior:getSerializeData()
	return self:getId(), self:getMap():getId(), self:getPosition():getX(), self:getPosition():getY(), self:getPosition():getZ(), 
	self:getInterior(), self:getDimension(), self:getOwner() or 0, self:getOwnerType() or 0
end
function Interior:getRebuildCallback() return self.m_RebuildCallback end
function Interior:getCreateCallback() return self.m_CreateCallback end