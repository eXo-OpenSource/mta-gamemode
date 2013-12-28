-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Singleton.lua
-- *  PURPOSE:     Singleton class
-- *
-- ****************************************************************************
Singleton = {}

function Singleton:getSingleton()
	if not self.ms_Instance then
		outputDebug("createINST IS" ..tostring(self.ms_Instance))
		self.ms_Instance = self:new()
	end
	
	outputDebug("INST IS" ..tostring(self.ms_Instance))
	return self.ms_Instance
end

function Singleton:new(...)
	self.new = function() end
	local inst = new(self, ...)
	self.ms_Instance = inst
	return inst
end

function Singleton:derived_destructor()
	self.ms_Instance = nil
end
