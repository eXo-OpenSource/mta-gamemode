-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Log.lua
-- *  PURPOSE:     Logging class
-- *
-- ****************************************************************************
Log = inherit(Object)

function Log:constructor(name)
	assert(type(name) == "string")
	
	self.m_File = name
	
	-- Open / Create
	if not fileExists(self.m_File) then
		self.m_FileHandle = fileCreate(self.m_File)
	else
		self.m_FileHandle = fileOpen(self.m_File)
	end
	
	assert(self.m_FileHandle)
	
	-- Seek to end
	fileSetPos(self.m_FileHandle, fileGetSize(self.m_FileHandle))
end

function Log:destructor()
	if self.m_FileHandle then
		fileClose(self.m_FileHandle)
	end
end

function Log:log(line, ...)
	assert(self.m_FileHandle)
	
	line = line:format(...)
	
	local time = getRealTime()
	
	
	-- Log format:
	-- [03.09.13 - 16:30:27] Actual logging line
	-- Note: "year - 100" is used as getRealTime() returns the number of years passed since 1900. 
	--		 For 2013 this would be 113. To achieve a nice year indicator we subtract 100 from this
	--		 value. This should be faster than string manipulation. Someone will need to fix this in 2100.
	fileWrite(self.m_FileHandle, ("[%02d.%02d.%02d - %02d:%02d:%02d] %s\n"):format(time.day, time.month, time.year-100, time.hour, time.minute, time.second, line))
end
