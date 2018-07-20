-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/FileLogger.lua
-- *  PURPOSE:     Logs statistics/debug stuff to the database (helps us to find money lacks, balancing, etc.)
-- *
-- ****************************************************************************
FileLogger = inherit(Singleton)

function FileLogger:constructor()
	self.m_LogFiles = {}
	self.m_LogFilesOpendAt = {}

	self.m_LogFileHeader = {
		["sql"] = "timestamp;time;database;type;query\n",
		["perf"] = "timestamp;time;func;extra\n"
	}

	self:getLogFile("sql")
	self:getLogFile("perf")
end

function FileLogger:destructor()
	for k, file in pairs(self.m_LogFiles) do
		fileClose(file)
	end
end

function FileLogger:getLogFile(type)
	local date = (getRealTime().year + 1900) .. (getRealTime().month + 1) .. getRealTime().monthday

	local file = false
	if fileExists("server/logs/" .. type .. "_" .. date .. ".log") then
		file = fileOpen("server/logs/" .. type .. "_" .. date .. ".log")
	else
		file = fileCreate("server/logs/" .. type .. "_" .. date .. ".log")
		fileWrite(file, self.m_LogFileHeader[type])
		fileFlush(file)
	end

	self.m_LogFiles[type] = file
	self.m_LogFilesOpendAt[type]  = getRealTime().monthday
end

function FileLogger:writeLog(type, text)
	if getRealTime().monthday ~= self.m_LogFilesOpendAt[type] then
		if self.m_LogFiles[type] then
			fileClose(self.m_LogFiles[type])
		end
		self:getLogFile(type)
	end

	if self.m_LogFiles[type] then
		fileSetPos(self.m_LogFiles[type], fileGetSize(self.m_LogFiles[type]))
		fileWrite(self.m_LogFiles[type], text)
		fileFlush(self.m_LogFiles[type])
	end
end


function FileLogger:addSqlLog(query, database, time, type)
	query = query:gsub(";", " ")
	self:writeLog("sql", getRealTime().timestamp .. ";" .. time .. ";" .. database .. ";" .. type .. ";" .. query .. "\n")
end

function FileLogger:addPerfLog(time, func, data)
	data = data:gsub(";", " ")
	self:writeLog("perf", getRealTime().timestamp .. ";" .. time .. ";" .. func .. ";" .. data .. "\n")
end
