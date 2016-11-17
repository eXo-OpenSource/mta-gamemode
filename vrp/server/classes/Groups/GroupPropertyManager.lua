GroupPropertyManager = inherit(Singleton)
GroupPropertyManager.Map = {}
GroupPropertyManager.ChangeMap = {}
addRemoteEvents{"GroupPropertyClientInput", "GroupPropertyBuy", "GroupPropertySell", "RequestImmoForSale"}
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

	addEventHandler("GroupPropertyBuy", root, bind( GroupPropertyManager.BuyProperty, self))
	addEventHandler("GroupPropertySell", root, bind( GroupPropertyManager.SellProperty, self))
	addEventHandler("RequestImmoForSale", root, bind( GroupPropertyManager.OnRequestImmo, self))
end

function GroupPropertyManager:destructor()
	local propCount = 0
	for id, owner in pairs( GroupPropertyManager.ChangeMap ) do
		if not owner then
			owner = 0
		end
		propCount = propCount + 1
		outputChatBox(id..","..owner.m_Id)
		sql:queryExec("UPDATE ??_group_property SET GroupId=? WHERE Id=?", sql:getPrefix(), owner.m_Id, id)
	end
	outputDebugString("[GroupProperties] Saved properties #"..propCount.."!")
end

function GroupPropertyManager:addNewProperty( )
	sql:queryExec("INSERT INTO ??_group_property (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sql:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end

function GroupPropertyManager:OnRequestImmo()
	client:triggerEvent("GetImmoForSale", GroupPropertyManager.Map )
end

function GroupPropertyManager:BuyProperty( Id )
	local property = GroupPropertyManager.Map[Id]
	if property then
		local price = property.m_Price
		if price <= client:getMoney() then
			local oldOwner = property.m_Owner
			local newOwner = client:getGroup()
			if not oldOwner then
				property.m_Owner = newOwner or false
				property.m_OwnerID = newOwner.m_Id or false
				GroupPropertyManager.ChangeMap[Id] = newOwner
				client:takeMoney(price, "Immobilie "..property.m_Name.." gekauft!")
				client:sendInfo("Du hast die Immobilie geklaut!")
				client:triggerEvent("ForceClose")
			end
		end
	end
end

function GroupPropertyManager:SellProperty( Id )
	local property = GroupPropertyManager.Map[Id]
	if property then
		local price = property.m_Price
		local sellMoney = math.floor(price * 0.66)
		local pOwner = property.m_Owner
		local clientGroup = client:getGroup()
		if pOwner == clientGroup then
			property.m_Owner = false
			GroupPropertyManager.ChangeMap[Id] = 0
			client:giveMoney(sellMoney, "Immobilie "..property.m_Name.." verkauft!")
		end
	end
end

function GroupPropertyManager:getPropsForPlayer( player )
	local playerProps = {}
	if player:getGroup() then
		for k,v in pairs(GroupPropertyManager:getSingleton().Map) do
			if v.m_OwnerID == player:getGroup():getId() then
				playerProps[#playerProps+1] = v
			end
		end
	end
	return playerProps
end
