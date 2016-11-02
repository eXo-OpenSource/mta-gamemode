GroupPropertyManager = inherit(Singleton)

function GroupPropertyManager:constructor( )
	
end

function GroupPropertyManager:destructor()

end

function GroupPropertyManager:addNewProperty( )
	sqlLogs:queryExec("INSERT INTO ??_group_property (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end