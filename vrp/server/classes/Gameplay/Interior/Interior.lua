-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorManager.lua
-- *  PURPOSE:     provides custom interiors 
-- *
-- ****************************************************************************

Interior = inherit(Object)
Interior.Map = {}

function Interior:constructor(path, row)
	self:setPath(("%s%s"):format(DYNAMIC_INTERIOR_MAP_PATH, path))
	self:setName(path)
	self:setPlaceData(row)
	if File.Exists(self.m_Path) then 
		if self:create() == DYNAMIC_INTERIOR_SUCCESS then 
			self:initialise()
		end
	else 
		self:setStatus(DYNAMIC_INTERIOR_NOT_FOUND)
	end
	InteriorManager:getSingleton():add(self)
end

function Interior:create() 
	self.m_Map = MapParser:new(self:getPath())
	if self.m_Map then 
		self:setStatus(DYNAMIC_INTERIOR_SUCCESS)
	else 
		self:setStatus(DYNAMIC_INTERIOR_ERROR_MAP)
	end
	return self:getStatus()
end

function Interior:initialise() 
	self:getMap():create(DYNAMIC_INTERIOR_DUMMY_DIMENSION)
	if self:searchEntrance() then 
		self:createSphereOfInfluence()
	end
	if not self:getPlaceData() then -- if we have no supplied place find a place
		InteriorManager:getSingleton():findPlace(self)
	else 
		self:setPlace(self:getPlaceData().position, self:getPlaceData().interior, self:getPlaceData().dimension)
	end
end

function Interior:searchEntrance() 
	for index, object in pairs(self:getMap():getElements()) do 
		if object:getType() == "marker" and object:getMarkerType() == "cylinder" then 
			self:setEntrance(object)
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

function Interior:destructor()
	InteriorManager:getSingleton():remove(self)
end

function Interior:setStatus(status) self.m_Status = status end
function Interior:setEntrance(entrance) self.m_Entrance = entrance end 
function Interior:setPath(path) self.m_Path = path end

function Interior:setName(name) 
	self.m_Name = name:gsub("%.map", "") 
end

function Interior:setDimension(dimension)
	self:getMap():setDimension(dimension)
	self:getSphereOfInfluence():setDimension(self:getEntrance():getDimension())
end

function Interior:setInterior(interior)
	self:getMap():setInterior(interior)
	self:getSphereOfInfluence():setInterior(self:getEntrance():getInterior())
end

function Interior:setPlace(position, interior, dimension)
	self:move(position)
	self:setDimension(dimension)
	self:setInterior(interior)
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

function Interior:setPlaceData(bool)
	self.m_PlaceData = bool
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