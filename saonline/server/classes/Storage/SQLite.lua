-- ****************************************************************************
-- *
-- *  PROJECT:     	Open MTA:DayZ
-- *  FILE:        	server/classes/SQLite.lua
-- *  PURPOSE:     	Class specialization of SQL for SQLite database connections
-- *  DEPENDS ON:	SQL.lua
-- *
-- ****************************************************************************
SQLite = inherit(SQL)

function SQLite:constructor(database)
	self.m_DBHandle = dbConnect("sqlite", database, "", "", "share=1;batch=1;autoreconnect=1;log=0;tag=dayz")
	if not self.m_DBHandle then
		critical_error("SQLite - Could not etablish a database connection")
	end
end

function SQLite.dbPoll(qh, timeout)
	local result, numrows, errmsg = dbPoll ( qh, timeout)
	if result == nil then
		outputDebugString("[SQLite] dbPoll - result not ready yet" )
	elseif result == false then
	    outputDebugString("[SQLite] dbPoll failed. Error code: " .. tostring(numrows) .. "  Error message: " .. tostring(errmsg) )
	end
	return result
end

function SQLite:lastInsertId()
	return self:queryFetchSingle("SELECT LAST_INSERT_ROWID() AS ID;").ID 
end
