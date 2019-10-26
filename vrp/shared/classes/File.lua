-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/File.lua
-- *  PURPOSE:     Base file class
-- *
-- ****************************************************************************
File = inherit(Object)

function File.Open(filepath)
	if not fileExists(filepath) then return false end
	local fh = fileOpen(filepath)
	if not fh then return false end
	return File:new(fh)
end

function File.Create(filepath)
	local fh = fileCreate(filepath)
	if not fh then return false end
	return File:new(fh)
end

function File.Exists(filepath) 
	return fileExists(filepath)
end

function File.Close(fh)
	fh:delete()
end

function File:close()
	self:delete()
end

function File:constructor(fh)
	self.m_Handle = fh
end

function File:destructor(fh)
	fileClose(self.m_Handle)
	self.m_Handle = nil
end

function File:read(count)
	if not count then count = self:getSize() end
	
	-- MTA yields a warning if count == 0, this is annoying.
	if count == 0 then return "" end
	
	return fileRead(self.m_Handle, count)
end

function File:getContent()
	fileSetPos(self.m_Handle, 0)
	return self:read(self:getSize())
end

function File:write(data)
	fileWrite(self.m_Handle, data)
end

function File:md5()
	return md5(self:read(self:getSize()))
end

function File:getSize()
	return fileGetSize(self.m_Handle)
end