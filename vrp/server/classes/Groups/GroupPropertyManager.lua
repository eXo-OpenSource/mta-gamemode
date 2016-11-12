GroupPropertyManager = inherit(Singleton)
GroupPropertyManager.Map = {}
addRemoteEvents{"GroupPropertyClientInput"}

function GroupPropertyManager:constructor( )
	outputServerLog("Loading group-propertys...")
	local result = sql:queryFetch("SELECT * FROM ??_group_property", sql:getPrefix())
	for k, row in ipairs(result) do
		GroupPropertyManager.Map[row.Id] = GroupProperty:new(row.Id, row.Name, row.GroupId, row.Type, row.Price, Vector3(unpack(split(row.Pickup, ","))), row.InteriorId,  Vector3(unpack(split(row.InteriorSpawn, ","))), row.Cam, row.open)
	end
	
	addEventHandler("GroupPropertyClientInput",root,function() 
		if client.m_LastPropertyPickup then 
			client.m_LastPropertyPickup:openForPlayer(client)
		end
	end)
end

function GroupPropertyManager:destructor()

end

function GroupPropertyManager:addNewProperty( )
	sql:queryExec("INSERT INTO ??_group_property (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sql:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end


