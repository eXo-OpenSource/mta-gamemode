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
	self:setPath(path)
	self:setName(path)
	self:setPlaceData(row) -- if we got already existing coordinates on this map use them
	self:setPlaceMode(placeMode or DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE) -- either if a best place should be found / or we shuld prioritize keeping the position that originally came with the interior
	self:setLoadOnly(loadOnly) -- in case the map has to/can be created later
	if File.Exists(self.m_Path) then 
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
	if self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.FIND_BEST_PLACE then
		CustomInteriorManager:getSingleton():findPlace(self)
	elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION then
		CustomInteriorManager:getSingleton():findDimension(self)
	elseif self:getPlaceMode() == DYANMIC_INTERIOR_PLACE_MODES.USE_DATA then
		self:setPlace(self:getPlaceData().position, self:getPlaceData().interior, self:getPlaceData().dimension)
	end
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
		local entrancePosition = self:getEntrance():getPosition()
		self.m_SphereOfInfluence = ColShape.Cuboid(
		entrancePosition.x - (((max.x - min.x)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2), 
		entrancePosition.y - (((max.y - min.y)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2),
		entrancePosition.z - (((max.z-min.z)/2) + DYNAMIC_INTERIOR_HEIGHT_TOLERANCE/4),
		DYNAMIC_INTERIOR_EDGE_TOLERANCE+(max.x - min.x), 
		DYNAMIC_INTERIOR_EDGE_TOLERANCE+(max.y - min.y), 
		DYNAMIC_INTERIOR_HEIGHT_TOLERANCE+(max.z - min.z))
		self:getSphereOfInfluence():setDimension(self:getEntrance():getDimension())
		self:getSphereOfInfluence():setInterior(self:getEntrance():getInterior())
	end
end

function Interior:move(pos)
	local parentClone = createObject(1337, self:getEntrance():getPosition())
	parentClone:setInterior(self:getEntrance():getInterior())
	parentClone:setDimension(self:getEntrance():getDimension())
	parentClone:setAlpha(0)
	parentClone:setCollisionsEnabled(false)
	self:getMap():move(parentClone, pos)
	parentClone:destroy()
	self:updateSphereOfInfluence()
end

function Interior:updateSphereOfInfluence()
	if self:getSphereOfInfluence() then 
		local entrancePosition = self:getEntrance():getPosition()
		local min, max = self:getBounding()
		self:getSphereOfInfluence():setPosition(
			entrancePosition.x - (((max.x - min.x)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2), 
			entrancePosition.y - (((max.y - min.y)/2) + DYNAMIC_INTERIOR_EDGE_TOLERANCE/2),
			entrancePosition.z - (((max.z-min.z)/2) + DYNAMIC_INTERIOR_HEIGHT_TOLERANCE/4))
	end
end

function Interior:forceSave() 
	CustomInteriorManager:getSingleton():save(self)
	self:setPlaceMode(DYANMIC_INTERIOR_PLACE_MODES.USE_DATA)
end

function Interior:destructor()
	self:getMap():delete()
	CustomInteriorManager:getSingleton():remove(self)
	if not self:isTemporary() then
		if self:getPlaceMode() ~= DYANMIC_INTERIOR_PLACE_MODES.USE_DATA then
			InteriorManager:getSingleton():save(self)
		end
	end
end

function Interior:setStatus(status) 
	self.m_Status = status 
	return self
end

function Interior:setEntrance(entrance) 
	self.m_Entrance = entrance 
	return self
end 

function Interior:setPath(path) 
	self.m_Path = path 
	return self
end

function Interior:setPlaceData(bool) 
	self.m_PlaceData = bool 
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

function Interior:setOwner(owner, type) 
	self.m_Owner = owner
	self.m_OwnerType = type 
	return self
end

function Interior:setName(name) 
	self.m_Name = name:gsub("(.*[/\\])", ""):gsub("%.map", "") 
	return self
end

function Interior:setDimension(dimension)
	self:getMap():setDimension(dimension)
	self:getSphereOfInfluence():setDimension(self:getEntrance():getDimension())
	return self
end

function Interior:setInterior(interior)
	self:getMap():setInterior(interior)
	self:getSphereOfInfluence():setInterior(self:getEntrance():getInterior())
	return self
end

function Interior:setPlace(position, interior, dimension)
	self:move(position)
	self:setDimension(dimension)
	self:setInterior(interior)
	return self
end

function Interior:setPlaceMode(mode) 
	if not self:getPlaceData() then 
		self.m_PlaceMode = mode
	else 
		self.m_PlaceMode  = DYANMIC_INTERIOR_PLACE_MODES.USE_DATA
	end
	return self
end

function Interior:setTemporary(bool) 
	self.m_IsTemporary = bool
	return self
end

function Interior:getStatus() return self.m_Status end
function Interior:getPath() return self.m_Path end
function Interior:getMap() return self.m_Map end
function Interior:getEntrance() return self.m_Entrance end
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