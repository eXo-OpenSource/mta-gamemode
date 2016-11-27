GroupPropertyManager = inherit(Singleton)
addRemoteEvents{"GroupPropertyClientInput", "GroupPropertyBuy", "GroupPropertySell", "RequestImmoForSale","KeyChangeAction","requestRefresh","switchGroupDoorState","requestImmoPanel","updatePropertyText","requestImmoPanelClose","requestPropertyItemDepot"}
function GroupPropertyManager:constructor( )
	self.Map = {}
	self.ChangeMap = {}
	outputServerLog("Loading group-propertys...")
	local result = sql:queryFetch("SELECT * FROM ??_group_property", sql:getPrefix())
	for k, row in ipairs(result) do
		self.Map[row.Id] = GroupProperty:new(row.Id, row.Name, row.GroupId, row.Type, row.Price, Vector3(unpack(split(row.Pickup, ","))), row.InteriorId,  Vector3(unpack(split(row.InteriorSpawn, ","))), row.Cam, row.open, row.Message, row.DepotId)
	end

	addEventHandler("GroupPropertyClientInput",root,function()
		if client.m_LastPropertyPickup then
			client.m_LastPropertyPickup:openForPlayer(client)
		end
	end)

	addEventHandler("GroupPropertyBuy", root, bind( GroupPropertyManager.BuyProperty, self))
	addEventHandler("GroupPropertySell", root, bind( GroupPropertyManager.SellProperty, self))
	addEventHandler("RequestImmoForSale", root, bind( GroupPropertyManager.OnRequestImmo, self))
	addEventHandler("requestImmoPanel", root, bind( GroupPropertyManager.OnRequestImmoPanel, self))
	addEventHandler("requestImmoPanelClose", root, bind( GroupPropertyManager.OnRequestImmoPanelClose, self))
	addEventHandler("switchGroupDoorState", root, bind( GroupPropertyManager.OnDrooStateSwitch, self))
	addEventHandler("KeyChangeAction", root, bind( GroupPropertyManager.OnKeyChange, self))
	addEventHandler("requestRefresh", root, bind( GroupPropertyManager.OnRefreshRequest, self))
	addEventHandler("updatePropertyText",root,bind(GroupPropertyManager.OnMessageTextChange,self))
	addEventHandler("requestPropertyItemDepot",root,bind(GroupPropertyManager.OnRequestPropertyItemDepot,self))

end

function GroupPropertyManager:OnMessageTextChange( text )
	if text then
		if client then
			if client.m_LastPropertyPickup then
				client.m_LastPropertyPickup.m_Message = text
				client:sendInfo("Die Eingangsnachricht wurde aktualisiert!")
			end
		end
	end
end

function GroupPropertyManager:OnRequestPropertyItemDepot(id)
	if client then
		if client.m_LastPropertyPickup then
			client.m_LastPropertyPickup:getDepot():showItemDepot(client)
		end
	end
end

function GroupPropertyManager:OnRequestImmoPanel( id )
	if client then
		if GroupPropertyManager:getSingleton().Map[id] then
			GroupPropertyManager:getSingleton().Map[id]:Event_requestImmoPanel( client )
			client.m_LastPropertyPickup = GroupPropertyManager:getSingleton().Map[id]
		end
	end
end

function GroupPropertyManager:OnRequestImmoPanelClose( id )
	if client then
		if GroupPropertyManager:getSingleton().Map[id] then
			client:triggerEvent("forceGroupPropertyClose")
		end
	end
end

function GroupPropertyManager:addNewProperty( )
	sql:queryExec("INSERT INTO ??_group_property (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sql:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end

function GroupPropertyManager:OnRequestImmo()
	client:triggerEvent("GetImmoForSale", GroupPropertyManager:getSingleton().Map )
end

function GroupPropertyManager:OnKeyChange( player,action)
	if client then
		if client.m_LastPropertyPickup then
			client.m_LastPropertyPickup:Event_keyChange( player, action, client )
		end
	end
end

function GroupPropertyManager:OnRefreshRequest()
	if client then
		if client.m_LastPropertyPickup then
			client.m_LastPropertyPickup:Event_RefreshPlayer( client )
		end
	end
end

function GroupPropertyManager:OnDrooStateSwitch( )
	if client then
		if client.m_LastPropertyPickup then
			client.m_LastPropertyPickup:Event_ChangeDoor( client )
		end
	end
end

function GroupPropertyManager:BuyProperty( Id )
	local property = GroupPropertyManager:getSingleton().Map[Id]
	local propCount = self:getPropsForPlayer( client )
	if #propCount > 0 then 
		return client:sendError("Sie haben bereits eine Immobilie")
	end
	if property then
		local price = property.m_Price
		if price <= client:getMoney() then
			local oldOwner = property.m_Owner
			local newOwner = client:getGroup()
			if not oldOwner then
				property.m_Owner = newOwner or false
				property.m_OwnerID = newOwner.m_Id or false
				sql:queryExec("UPDATE ??_group_property SET GroupId=? WHERE Id=?", sql:getPrefix(), newOwner.m_Id, property.m_Id)
				property.m_Open = 1
				client:takeMoney(price, "Immobilie "..property.m_Name.." gekauft!")
				client:sendInfo("Du hast die Immobilie gekauft!")
				client:triggerEvent("ForceClose")
				for key, player in ipairs( newOwner:getOnlinePlayers() ) do
					player:triggerEvent("addPickupToGroupStream",property.m_ExitMarker, property.m_Id)
					x,y,z = getElementPosition( property.m_Pickup )
					player:triggerEvent("createGroupBlip",x,y,z,property.m_Id)
				end
			end
		end
	end
end

function GroupPropertyManager:SellProperty(  )
	if client then
		local property = client.m_LastPropertyPickup
		if property then
			outputChatBox("check2")
			local price = property.m_Price
			local sellMoney = math.floor(price * 0.66)
			local pOwner = property.m_Owner
			local clientGroup = client:getGroup()
			if pOwner == clientGroup then
				property.m_Owner = false
				property.m_OwnerID = false
				sql:queryExec("UPDATE ??_group_property SET GroupId=? WHERE Id=?", sql:getPrefix(), 0, property.m_Id)
				property.m_Open = 1
				client:giveMoney(sellMoney, "Immobilie "..property.m_Name.." verkauft!")
				client:sendInfo("Sie haben die Immobilie verkauft!")
				for key, player in ipairs( pOwner:getOnlinePlayers() ) do
					player:triggerEvent("destroyGroupBlip",pOwner.m_Id)
					player:triggerEvent("forceGroupPropertyClose")
				end
			end
		end
	end
end

function GroupPropertyManager:destructor()
	for id, obj in pairs( self.Map ) do
		obj:delete()
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
