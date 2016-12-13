-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Object.lua
-- *  PURPOSE:     Base class of everything
-- *
-- ****************************************************************************
Object = {}

function Object:new(...)
	return new(self, ...)
end

function Object:delete(...)
	return delete(self, ...)
end

function Object:load(...)
	return load(self, ...)
end

function Object:getId()
	return self.m_Id
end

