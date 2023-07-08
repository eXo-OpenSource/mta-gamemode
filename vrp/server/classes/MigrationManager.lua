MigrationManager = inherit(Singleton)

MigrationManager.DATABASES = {
    GAME = "sql",
    LOGS = "sqlLogs",
    PREMIUM = "sqlPremium"
}

function MigrationManager:constructor()
    self.m_Prefix = "Migration_"

    self:createMigrationTableIfNeeded()

    self.m_Migrations = {}
    self.m_MigrationKeys = {}

    for name, object in pairs(_G) do
        if name:sub(0, #self.m_Prefix) == self.m_Prefix then
            self.m_Migrations[name] = object
            table.insert(self.m_MigrationKeys, name)
        end
    end

    table.sort(self.m_MigrationKeys)

    for _, name in pairs(self.m_MigrationKeys) do
        local migration = self.m_Migrations[name]

    	if not sql:queryFetchSingle("SELECT `Name` FROM ??_game_migrations WHERE `Name` = ?;", sql:getPrefix(), name) then
            outputServerLog(("Executing migration %s"):format(name))
            local connection = self:getConnection(migration.Database)
            
            if connection:queryFetch(migration.Up(sql.m_Database, sqlLogs.m_Database, sqlPremium.m_Database)) then
                sql:queryExec("INSERT INTO ??_game_migrations (`Name`) VALUES (?);", sql:getPrefix(), name)
                outputServerLog(("Executed migration %s"):format(name))
            else
                critical_error("Migration failed")
            end
        end
    end

    outputServerLog(("Found %s migrations"):format(table.size(self.m_Migrations)))
end


function MigrationManager:createMigrationTableIfNeeded()
	if not sql:queryFetchSingle("SHOW TABLES LIKE ?;", ("%s_%s"):format(sql:getPrefix(), "game_migrations")) then
		sql:queryExec([[
			CREATE TABLE ??_game_migrations  (
				`Name` varchar(64) NOT NULL,
				PRIMARY KEY (`Name`)
			);
		]], sql:getPrefix())
	end
end

function MigrationManager:getConnection(database)
    local connection = nil
        
    if database == MigrationManager.DATABASES.GAME then
        connection = sql
    elseif database == MigrationManager.DATABASES.LOGS then
        connection = sqlLogs
    elseif database == MigrationManager.DATABASES.PREMIUM then
        connection = sqlPremium
    end

    return connection
end