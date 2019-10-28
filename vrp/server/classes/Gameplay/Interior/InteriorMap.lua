-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorMap.lua
-- *  PURPOSE:     Interior map object
-- *
-- ****************************************************************************
InteriorMap = inherit(Object)

function InteriorMap:constructor(id, path)
	self:setPath(path)
	self:setName(path) 
	self:setId(id)
	InteriorMapManager:getSingleton():add(self)
end

function InteriorMap:destructor()
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

function InteriorMap:setId(id) 
	assert(id, "Bad argument @ InteriorMap.setId")
	self.m_Id = id
	return self
end

function InteriorMap:getPath() return self.m_Path end
function InteriorMap:getName() return self.m_Name end 
function InteriorMap:getId() return self.m_Id end


