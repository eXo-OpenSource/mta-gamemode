-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/FileLogger.lua
-- *  PURPOSE:     Logs statistics/debug stuff to the database (helps us to find money lacks, balancing, etc.)
-- *
-- ****************************************************************************
FileLogger = inherit(Singleton)

function FileLogger:constructor()
	self:getSqlLogFile()
end

function FileLogger:destructor()
	if self.m_SqlLogFile then
		fileClose(self.m_SqlLogFile)
	end
end

function FileLogger:getSqlLogFile()
	local date = (getRealTime().year + 1900) .. (getRealTime().month + 1) .. getRealTime().monthday

	local file = false
	if fileExists("server/logs/" .. date .. ".log") then
		file = fileOpen("server/logs/" .. date .. ".log")
	else
		file = fileCreate("server/logs/" .. date .. ".log")
		fileWrite(file, "time;database;type;query\n")
		fileFlush(file)
	end

	self.m_SqlLogFile = file
	self.m_SqlLogFileOpendAt = getRealTime().monthday
end

function FileLogger:addSqlLog(query, database, time, type)
	if getRealTime().monthday ~= self.m_SqlLogFileOpendAt then
		if self.m_SqlLogFile then
			fileClose(self.m_SqlLogFile)
		end
		self:getSqlLogFile()
	end

	if self.m_SqlLogFile then
		fileSetPos(self.m_SqlLogFile, fileGetSize(self.m_SqlLogFile))
		query = query:gsub(";", " ")
		fileWrite(self.m_SqlLogFile, time .. ";" .. database .. ";" .. type .. ";" .. query .. "\n")
		fileFlush(self.m_SqlLogFile)
	end
end
