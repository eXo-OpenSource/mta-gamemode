-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorMap.lua
-- *  PURPOSE:     Interior map object
-- *
-- ****************************************************************************
InteriorMap = inherit(Object)

function InteriorMap:constructor(id, path, mode, high)
	self:setPath(path)
	self:setName(path)
	self:setMode(mode) 
	self:setLastDimension(high) -- stores the last highest dimension so no expensive iteration is necessary
	self:setId(id)
	InteriorMapManager:getSingleton():add(self)
end

function InteriorMap:destructor()
	if self:anyChange() then InteriorMapManager:getSingleton():save(self) end
	InteriorMapManager:getSingleton():remove(self)
end

function InteriorMap:setName(path) 
	assert(path, "Bad argument @ InteriorMap.setName")
	self.m_Name = path:gsub("(.*[/\\])", ""):gsub("%.map", "") 
	return self
end

function InteriorMap:setPath(path) 
	assert(path, "Bad argument @ InteriorMap.setPath")
	self.m_Path = path
	return self
end

function InteriorMap:setMode(mode) 
	assert(mode, "Bad argument @ InteriorMap.setMode")
	self.m_Mode = mode 
	return self
end

function InteriorMap:setId(id) 
	assert(id, "Bad argument @ InteriorMap.setId")
	self.m_Id = id
	return self
end

function InteriorMap:setLastDimension(value) 
	assert(tonumber(value), "Bad argument @ InteriorMap.setLastDimension")
	self.m_High = value 
	self:setAnyChange(true)
	return self
end

function InteriorMap:setAnyChange(bool)
	self.m_AnyChange = bool 
	return self
end

function InteriorMap:getPath() return self.m_Path end
function InteriorMap:getName() return self.m_Name end 
function InteriorMap:getMode() return self.m_Mode end
function InteriorMap:getLastDimension() return self.m_High end
function InteriorMap:getId() return self.m_Id end
function InteriorMap:anyChange() return self.m_AnyChange end

