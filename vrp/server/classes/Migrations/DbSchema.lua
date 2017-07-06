-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Migrations/DbSchema.lua
-- *  PURPOSE:     Database Schema class
-- *
-- ****************************************************************************
DbSchema = {}

function DbSchema:hasTable(tableName)

end

function DbSchema:hasColumn(tableName, column)

end

function DbSchema:hasColumns(tableName, columns)

end

function DbSchema:getColumnType(tableName, column)

end

function DbSchema:getColumnListing(tableName)

end

-- Modify table
function DbSchema:table(tableName, callback)

end

function DbSchema:create(tableName, callback)

end

function DbSchema:drop(tableName)

end

function DbSchema:dropIfExists(tableName)

end

function DbSchema:rename(from, to)

end

function DbSchema:setConnection(connection)

end
