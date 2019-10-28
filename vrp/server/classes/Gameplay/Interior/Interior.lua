-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorManager.lua
-- *  PURPOSE:     provides custom interiors 
-- *
-- ****************************************************************************
Interior = inherit(Object)
Interior.Map = {}

function Interior:constructor(path, row, loadOnly, placeMode)
	assert(path, "Bad argument @ Interior.constructor")
	self:setId(DYNAMIC_INTERIOR_TEMPORARY_ID)
	self:setOwner(DYANMIC_INTERIOR_SERVER_OWNER, DYNAMIC_INTERIOR_SERVER_OWNER_TYPE)
	self:setPath(path)
	self:setName(path)
	self:setTemporary(not row)
	self:setPlaceData(row) -- if we got already existing coordinates on this map use them
	self:setPlaceMode(placeMode or DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE) -- either if a best place should be found / or we shuld prioritize keeping the position that originally came with the interior
	self:setLoadOnly(loadOnly) -- in case the map has to/can be created later
	if File.Exists(self:getPath()) then 
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
	if self:isLoaded() then return end
	self.m_Map = MapParser:new(self:getPath())
	if self.m_Map then 
		self:setStatus(DYNAMIC_INTERIOR_SUCCESS)
		self:setLoaded(true)
	else 
		self:setStatus(DYNAMIC_INTERIOR_ERROR_MAP)
	end
	return self:getStatus()
end

function Interior:create() 
	self:getMap():create(DYNAMIC_INTERIOR_DUMMY_DIMENSION)
	if self:searchEntrance() then 
		self:createSphereOfInfluence()
	end
	if self:getPlaceData() then
		self:setPlace(self:getPlaceData().position, self:getPlaceData().interior, self:getPlaceData().dimension)
	else 
		if self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE then
			CustomInteriorManager:getSingleton():findPlace(self)
		elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
			CustomInteriorManager:getSingleton():findDimension(self)
		elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.MANUAL_INPUT then 
			-- do nothing
		end
	end
	self:setCreated(true)
end

function Interior:searchEntrance() 
	for index, object in pairs(self:getMap():getElements()) do 
		if object:getType() == DYNAMIC_INTERIOR_ENTRANCE_OBJECT and object:getMarkerType() == DYNAMIC_INTERIOR_ENTRANCE_OBJECT_TYPE then 
			self:setEntrance(object)
			if not DEBUG then
				self:getEntrance():setVisibleTo(root, false)
			end
		end
	end
	if not self:getEntrance() then 
		self:setStatus(DYNAMIC_INTERIOR_INFO_ENTRANCE)
	end 
	return self:getEntrance()
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
	self:getMap():move(parentClone, pos)
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

function Interior:rebuild(path, placeMode)
	assert(path, "Bad argument @ Interior.rebuild")
	local previousName = self:getName() 
	self:clean(self:isLoadOnly())
	self:setCreated(false)
	self:setPath(path)
	self:setName(path)
	self:setPlaceData(nil)
	self:setPlaceMode(placeMode or self:getPlaceMode())
	self:setLoaded(false)
	if File.Exists(self:getPath()) then 
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
end

function Interior:clean(setLoadOnly) -- incase the map needs to be destroyed
	self:getMap():delete()
	if isValidElement(self:getSphereOfInfluence()) then self:getSphereOfInfluence():destroy() end
	self:setLoadOnly(setBackToLoad)
end

function Interior:enter(player) 
	if self:isCreated() then 
		player:setDimension(self:getDimension())
		player:setInterior(self:getInterior())
		player:setPosition(self:getPosition())
	end
end

function Interior:exit(player) 
	if self:getExit() then 
		self:setDimension(self:getExit().dimension)
		self:setInterior(self:getExit().interior)
		self:setPosition(self:getExit().position)
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
	self:getMap():delete()
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

function Interior:setPath(path) 
	assert(path, "Bad argument @ Interior.setPath")
	self.m_Path = path 
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

function Interior:setName(name) 
	assert(name, "Bad argument @ Interior.setName")
	self.m_Name = name:gsub("(.*[/\\])", ""):gsub("%.map", "") 
	return self
end

function Interior:setDimension(dimension)
	assert(dimension, "Bad argument @ Interior.setDimension")
	self:getMap():setDimension(dimension)
	self:getSphereOfInfluence():setDimension(self:getDimension())
	return self
end

function Interior:setInterior(interior)
	assert(interior, "Bad argument @ Interior.setInterior")
	self:getMap():setInterior(interior)
	self:getSphereOfInfluence():setInterior(self:getInterior())
	return self
end

function Interior:setPlace(position, interior, dimension)
	assert(position and interior and dimension, "Bad argument @ Interior.setPlace")
	self:move(position)
	self:setDimension(dimension)
	self:setInterior(interior)
	return self
end

function Interior:setExit(position, interior, dimension)
	assert(position and interior and dimension, "Bad argument @ Interior.setExit")
	self.m_Exit = {position = position, interior or 0, dimension or 0}
	return self
end

function Interior:setPlaceMode(mode) 
	assert(mode and type(mode) == "number", "Bad argument @ Interior.setPlaceMode")
	self.m_PlaceMode = mode
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

function Interior:setAnyChange(bool) 
	self.m_AnyChange = bool
	return self
 end 

function Interior:getStatus() return self.m_Status end
function Interior:getPath() return self.m_Path end
function Interior:getMap() return self.m_Map end
function Interior:getEntrance() return self.m_Entrance end
function Interior:getInterior() return self:getEntrance() and isValidElement(self:getEntrance()) and self:getEntrance():getInterior() end 
function Interior:getDimension() return self:getEntrance() and isValidElement(self:getEntrance()) and self:getEntrance():getDimension() end 
function Interior:getPosition() return self:getEntrance() and isValidElement(self:getEntrance()) and self:getEntrance():getPosition() end 
function Interior:getName() return self.m_Name end
function Interior:getPath() return self.m_Path end
function Interior:getBounding() return self:getMap():getBoundingBox() end
function Interior:getSphereOfInfluence() return self.m_SphereOfInfluence end
function Interior:getPlaceData() return self.m_PlaceData end
function Interior:isLoaded() return self.m_Loaded end
function Interior:isLoadOnly() return self.m_LoadOnly end
function Interior:getPlaceMode() return self.m_PlaceMode end
function Interior:getOwner() return self.m_Owner end 
function Interior:getOwnerType() return self.m_OwnerType end
function Interior:isCreated() return self.m_IsCreated end
function Interior:getId() return self.m_Id end
function Interior:isTemporary() return self.m_IsTemporary end
function Interior:getExit() return self.m_Exit end
function Interior:hasAnyChange() return self.m_AnyChange end
function Interior:getPlayerSerialize(player) 
	if not self:isTemporary() then
		return toJSON({name = self:getName(), id = self:getId()})
	else 
		return ""
	end
end
function Interior:getSerializeData()
	return self:getId(), self:getName(), self:getPath(), self:getPosition():getX(), self:getPosition():getY(), self:getPosition():getZ(), 
	self:getInterior(), self:getDimension(), self:getPlaceMode(), self:getOwner() or 0, self:getOwnerType() or 0
end