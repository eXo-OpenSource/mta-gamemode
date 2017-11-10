GroupPropertyManager = inherit(Singleton)
local PICKUP_ARROW = 1318
local PICKUP_FOR_SALE = 1272
addRemoteEvents{"GroupPropertyClientInput", "GroupPropertyBuy", "GroupPropertySell", "RequestImmoForSale","KeyChangeAction","requestRefresh","switchGroupDoorState","requestImmoPanel","updatePropertyText","requestImmoPanelClose","requestPropertyItemDepot"}
function GroupPropertyManager:constructor( )
	local st, count = getTickCount(), 0
	self.Map = {}
	self.ChangeMap = {}
	self.m_BankAccountServer = BankServer.get("group.properties")
	local result = sql:queryFetch("SELECT * FROM ??_group_property", sql:getPrefix())
	for k, row in ipairs(result) do
		self.Map[row.Id] = GroupProperty:new(row.Id, row.Name, row.GroupId, row.Type, row.Price, Vector3(unpack(split(row.Pickup, ","))), row.InteriorId,  Vector3(unpack(split(row.InteriorSpawn, ","))), row.Cam, row.open, row.Message, row.DepotId, row.ElevatorData)
		count = count + 1
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
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s group-properties in %sms"):format(count, getTickCount()-st)) end
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
	if not client:getGroup() then
		client:sendError("Du bist in keiner Firma oder Gang!")
		return
	end
	if client:getGroup():getPlayerRank(client) < GroupRank.Manager then
		client:sendError("Du bist nicht berechtigt eine Immobilie für deine Firma/Gang zu kaufen!")
		return
	end

	local newOwner = client:getGroup()
	local property = GroupPropertyManager:getSingleton().Map[Id]
	local propCount = self:getPropsForPlayer( client )
	if #propCount > 0 then
		return 	client:sendError("Deine Firma/Gang besitzt bereits eine Immobilie")
	end
	if property then
		local price = property.m_Price
		if price <= newOwner:getMoney() then
			local oldOwner = property.m_Owner
			if not oldOwner then
				property.m_Owner = newOwner or false
				property.m_OwnerID = newOwner.m_Id or false
				sql:queryExec("UPDATE ??_group_property SET GroupId=? WHERE Id=?", sql:getPrefix(), newOwner.m_Id, property.m_Id)
				property.m_Open = 1
				newOwner:transferMoney(self.m_BankAccountServer, price, "Immobilie "..property.m_Name.." gekauft!", "Group", "PropertyBuy")
				client:sendInfo("Du hast die Immobilie gekauft!")
				if property.m_Pickup and isElement(property.m_Pickup) then 
					setPickupType(property.m_Pickup, 3, PICKUP_ARROW)
				end
				client:triggerEvent("ForceClose")
				for key, player in ipairs( newOwner:getOnlinePlayers() ) do
					player:triggerEvent("addPickupToGroupStream",property.m_ExitMarker, property.m_Id)
					x,y,z = getElementPosition( property.m_Pickup )
					player:triggerEvent("createGroupBlip",x,y,z,property.m_Id,newOwner.m_Type)
				end
				StatisticsLogger:GroupBuyImmoLog( property.m_OwnerID or 0, "BUY", property.m_Id)
			else
				client:sendError(_("Diese Immobilie ist bereits vergeben!", client))
			end
		else
			client:sendError(_("In deiner Firmen/Gang-Kasse befindet sich nicht genug Geld!", client))
		end
	else
		client:sendError(_("Immobilie nicht gefunden!", client))
		outputDebugString("GroupPropertyManager:BuyProperty: Immobile ID "..Id.." not found!")
	end
end

function GroupPropertyManager:SellProperty(  )
	if client then
		if not client:getGroup() then
			client:sendError("Du bist in keiner Firma oder Gang!")
			return
		end
		if client:getGroup():getPlayerRank(client) < GroupRank.Manager then
			client:sendError("Du bist nicht berechtigt diese Immobilie zu verkaufen!")
			return
		end

		local property = client.m_LastPropertyPickup
		if property then
			local price = property.m_Price
			local sellMoney = math.floor(price * 0.66)
			local pOwner = property.m_Owner
			local group = client:getGroup()
			if pOwner == group then
				property.m_Owner = false
				property.m_OwnerID = 0
				sql:queryExec("UPDATE ??_group_property SET GroupId=? WHERE Id=?", sql:getPrefix(), 0, property.m_Id)
				property.m_Open = 1
				if property.m_Pickup and isElement(property.m_Pickup) then 
					setPickupType(property.m_Pickup, 3, PICKUP_FOR_SALE)
				end
				self.m_BankAccountServer:transferMoney(group, price, "Immobilie "..property.m_Name.." verkauft!", "Group", "PropertySell")
				client:sendInfo("Sie haben die Immobilie verkauft! Das Geld befindet sich in der Firmen/Gangkasse!")
				for key, player in ipairs( pOwner:getOnlinePlayers() ) do
					player:triggerEvent("destroyGroupBlip",property.m_Id)
					player:triggerEvent("forceGroupPropertyClose")
				end
				StatisticsLogger:GroupBuyImmoLog( pOwner.m_Id or 0, "SELL", property.m_Id or 0)
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
	if player then
		if player:getGroup() then
			for k,v in pairs(GroupPropertyManager:getSingleton().Map) do
				if v.m_OwnerID == player:getGroup():getId() then
					playerProps[#playerProps+1] = v
				end
			end
		end
	end
	return playerProps
end
