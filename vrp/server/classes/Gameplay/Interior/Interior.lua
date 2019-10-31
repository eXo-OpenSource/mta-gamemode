-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorManager.lua
-- *  PURPOSE:     provides custom interiors 
-- *
-- ****************************************************************************
Interior = inherit(Object)

local LOCAL_DYNAMIC_INTERIOR_ENTRANCE_CREATE_FUNC = DYNAMIC_INTERIOR_ENTRANCE_CREATE_FUNC -- since we will call the function for creating entrances a lot we can assign it locally to save some time
Interior.Map = {}

TIME_CREATE = 0
TIME_SEARCH = 0
TIME_CLONE = 0
TIME_LOAD = 0
function Interior:constructor(map, row, loadOnly)
	assert(map, "Bad argument @ Interior.constructor")
	self:setMap(map)
	self:setId(DYNAMIC_INTERIOR_TEMPORARY_ID)
	self:setOwner(DYANMIC_INTERIOR_SERVER_OWNER, DYNAMIC_INTERIOR_SERVER_OWNER_TYPE)
	self:setTemporary(not row)
	self:setPlaceData(row) -- if we got already existing coordinates on this map use them
	self:setLoadOnly(loadOnly) -- in case the map has to/can be created later
	if File.Exists(self:getMap():getPath()) then 
		if self:load() == DYNAMIC_INTERIOR_SUCCESS then 
			if not self:isLoadOnly() then
				self:create()
			end
		end
	else 
		self:setStatus(DYNAMIC_INTERIOR_NOT_FOUND)
	end
	CustomInteriorManager:getSingleton():add(self)
end

function Interior:load() 
	local now = getTickCount()
	if self:isLoaded() then return end
	self:setMapNode(InteriorMapManager.getCached(self:getMap():getPath()))
	if self.m_Map then 
		self:setStatus(DYNAMIC_INTERIOR_SUCCESS)
		self:setLoaded(true)
	else 
		self:setStatus(DYNAMIC_INTERIOR_ERROR_MAP)
	end
	TIME_LOAD = TIME_LOAD + (getTickCount() - now)
	return self:getStatus()
end

function Interior:create(allDimension) 
	local now = getTickCount()
	if allDimension or self:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
		self:getMapNode():create(not allDimension and DYNAMIC_INTERIOR_DUMMY_DIMENSION or -1)
		self:searchEntrance()  
		if not allDimension then 
			self:createSphereOfInfluence()
		end
	else 
		CustomInteriorManager:getSingleton():createMapInAllDimensions(self)
		return self
	end
	if self:getPlaceData() then
		if not allDimension then
			self:setPlace(self:getPlaceData().position, self:getPlaceData().interior, self:getPlaceData().dimension)
			if self:getMap():getMode() ~= DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
				self:createSphereOfInfluence()
			end
		end
	else 
		if self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE then
			CustomInteriorManager:getSingleton():findPlace(self)
		elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION_ONE_DIMENSION then 
			CustomInteriorManager:getSingleton():findDimension(self)
		elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.MANUAL_INPUT then 
			-- do nothing
		end
	end
	self:setCreated(not allDimension and true)
	TIME_CREATE = TIME_CREATE + (getTickCount() - now)
	return self
end

function Interior:searchEntrance() 
	local now = getTickCount()
	for index, object in pairs(self:getMapNode():getElements()) do 
		if object:getType() == DYNAMIC_INTERIOR_ENTRANCE_OBJECT and object:getMarkerType() == DYNAMIC_INTERIOR_ENTRANCE_OBJECT_TYPE then 
			self:setEntrance(object)
			if not DEBUG then
				self:getEntrance():setVisibleTo(root, false)
			end
			if self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then 
				self:getEntrance():setColor(200, 0, 0, 200)
			end
		end
	end
	if not self:getEntrance() then 
		self:setStatus(DYNAMIC_INTERIOR_INFO_ENTRANCE)
	end 
	TIME_SEARCH = TIME_SEARCH + (getTickCount() - now)
	return self:getEntrance()
end

function Interior:cloneEntrance(entrance) 
	local now = getTickCount()
	local assignDimension = CustomInteriorManager:getSingleton():getHighestDimensionByName(self:getMap()) + 1
	self:getMap():setLastDimension(assignDimension)
	local clone = cloneElement(entrance)
	clone:setColor(0, 0, 200, 200)
	clone:setDimension(assignDimension)
	self:setEntrance(clone)
	self:setCreated(true)
	TIME_CLONE = TIME_CLONE + (getTickCount() - now)
end

function Interior:cloneEntranceAtPlace(entrance) -- do not use clone element when we can use create since cloneElement was somewhat very slow 
	local now = getTickCount()
	local clone = LOCAL_DYNAMIC_INTERIOR_ENTRANCE_CREATE_FUNC(self:getPlaceData().position, DYNAMIC_INTERIOR_ENTRANCE_OBJECT_TYPE, 1)
	clone:setInterior(self:getPlaceData().interior)
	clone:setColor(0, 0, 200, 200)
	clone:setDimension(self:getPlaceData().dimension)
	self:setEntrance(clone)
	if not DEBUG then
		self:getEntrance():setVisibleTo(root, false)
	end
	self:setCreated(true)
	TIME_CLONE = TIME_CLONE + (getTickCount() - now)
end


function Interior:createSphereOfInfluence() -- the hypothetical bounds (including tolerance) of the custom interior
	if self:getEntrance() then 
		local min, max = self:getBounding()
		local entrancePosition = self:getPosition()
		self.m_SphereOfInfluence = ColShape.Cuboid(
		entrancePosition.x - (((max.x - min.x)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2), 
		entrancePosition.y - (((max.y - min.y)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2),
		entrancePosition.z - (((max.z-min.z)/2) + DYNAMIC_INTERIOR_HEIGHT_TOLERANCE/4),
		DYNAMIC_INTERIOR_EDGE_TOLERANCE+(max.x - min.x), 
		DYNAMIC_INTERIOR_EDGE_TOLERANCE+(max.y - min.y), 
		DYNAMIC_INTERIOR_HEIGHT_TOLERANCE+(max.z - min.z))
		self:getSphereOfInfluence():setDimension(self:getDimension())
		self:getSphereOfInfluence():setInterior(self:getInterior())
		addEventHandler("onColShapeHit", self:getSphereOfInfluence(), bind(self.Event_OnElementEnter, self))
		addEventHandler("onColShapeLeave", self:getSphereOfInfluence(), bind(self.Event_OnElementLeave, self))
	end
end

function Interior:move(pos)
	local parentClone = createObject(1337, self:getPosition())
	parentClone:setInterior(self:getInterior())
	parentClone:setDimension(self:getDimension())
	parentClone:setAlpha(0)
	parentClone:setCollisionsEnabled(false)
	self:getMapNode():move(parentClone, pos)
	parentClone:destroy()
	self:updateSphereOfInfluence()
end

function Interior:updateSphereOfInfluence()
	if self:getSphereOfInfluence() then 
		local entrancePosition = self:getPosition()
		local min, max = self:getBounding()
		self:getSphereOfInfluence():setPosition(
			entrancePosition.x - (((max.x - min.x)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2), 
			entrancePosition.y - (((max.y - min.y)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2),
			entrancePosition.z - (((max.z-min.z)/2) + DYNAMIC_INTERIOR_HEIGHT_TOLERANCE/4))
	end
end

function Interior:forceSave() 
	CustomInteriorManager:getSingleton():save(self)
	return self
end

function Interior:rebuild(map)
	assert(map, "Bad argument @ Interior.rebuild")
	local previousMap = self:getMap():getId() 
	self:clean(self:isLoadOnly())
	self:setCreated(false)
	self:setMap(map)
	self:setPlaceData(nil)
	self:setLoaded(false)
	if File.Exists(self:getMap():getPath()) then 
		if self:load() == DYNAMIC_INTERIOR_SUCCESS then 
			if not self:isLoadOnly() then
				self:create()
			end
		end
	else
		self:setStatus(DYNAMIC_INTERIOR_NOT_FOUND)
	end
	if not self:isTemporary() and self:getStatus() ~= DYNAMIC_INTERIOR_NOT_FOUND then 
		CustomInteriorManager:getSingleton():override(self, previousName)
	end
	if self:getRebuildCallback() then 
		self:getRebuildCallback()(previousMap, map)
	end
	return self
end

function Interior:clean(setLoadOnly) -- incase the map needs to be destroyed
	if self:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
		self:getMapNode():delete()
		if isValidElement(self:getEntrance()) then self:getEntrance():destroy() end 
	end
	if isValidElement(self:getEntrance()) then self:getEntrance():destroy() end 
	if isValidElement(self:getSphereOfInfluence()) then self:getSphereOfInfluence():destroy() end
	self:setLoadOnly(setBackToLoad)
end

function Interior:enter(player) 
	if not self:isCreated() then 
		self:create()
	end
	CustomInteriorManager:getSingleton():onEnterInterior(player, self) 
	player:fadeCamera(false, .5)
	setTimer(function() 
		player:setDimension(self:getDimension())
		player:setInterior(self:getInterior())
		player:setPosition(self:getPosition())
		setTimer(function() 
			player:fadeCamera(true, .5)
		end, 500, 1) 
	end, 1000, 1)
end

function Interior:exit(player) 
	if self:getExit() then 
		CustomInteriorManager:getSingleton():onLeaveInterior(player, self) 
		player:fadeCamera(false, .5)
		setTimer(function() 
			player:setDimension(self:getExit().dimension)
			player:setInterior(self:getExit().interior)
			player:setPosition(self:getExit().position)
			setTimer(function() 
				player:fadeCamera(true) 
			end, 500, 1)
		end, 1000, 1)
	end
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
	self:getMapNode():delete()
	if isValidElement(self:getEntrance()) then self:getEntrance():destroy() end 
	if isValidElement(self:getSphereOfInfluence()) then self:getSphereOfInfluence():destroy() end
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
	self:getSphereOfInfluence():setDimension(self:getDimension())
	return self
end

function Interior:setInterior(interior)
	assert(interior, "Bad argument @ Interior.setInterior")
	self:getMapNode():setInterior(interior)
	self:getSphereOfInfluence():setInterior(self:getInterior())
	return self
end

function Interior:setPlace(position, interior, dimension)
	assert(position and interior and dimension, "Bad argument @ Interior.setPlace")
	if self:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
		self:setDimension(dimension):setInterior(interior):move(position)
	else 
		self:getEntrance():setDimension(dimension)
		self:getEntrance():setInterior(interior)
		self:getEntrance():setPosition(position)
	end
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

function Interior:getStatus() return self.m_Status end
function Interior:getMap() return self.m_InteriorMap end
function Interior:getEntrance() return self.m_Entrance end
function Interior:getInterior() 
	if self:getEntrance() and isValidElement(self:getEntrance()) then
		return self:getEntrance():getInterior() 
	elseif self:getPlaceData() then 
		return self:getPlaceData().interior
	end
end
function Interior:getDimension() 
	if self:getEntrance() and isValidElement(self:getEntrance()) then
		return self:getEntrance():getDimension() 
	elseif self:getPlaceData() then 
		return self:getPlaceData().dimension
	end
end
function Interior:getPosition() 
	if self:getEntrance() and isValidElement(self:getEntrance()) then
		return self:getEntrance():getPosition() 
	elseif self:getPlaceData() then 
		return self:getPlaceData().position
	end
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