GroupPropertyManager = inherit(Singleton)
GroupPropertyManager.Map = {}

function GroupPropertyManager:constructor( )
	outputServerLog("Loading group-propertys...")
	local result = sql:queryFetch("SELECT * FROM ??_group_property", sql:getPrefix())
	for k, row in ipairs(result) do
		GroupPropertyManager.Map[row.Id] = GroupProperty:new(row.Id, row.Name, row.GroupId, row.Type, row.Price, Vector3(unpack(split(row.Pickup, ","))), row.InteriorId,  Vector3(unpack(split(row.InteriorSpawn, ","))), row.Cam, row.open)
	end
end

function GroupPropertyManager:destructor()

end

function GroupPropertyManager:addNewProperty( )
	sqlLogs:queryExec("INSERT INTO ??_group_property (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end
