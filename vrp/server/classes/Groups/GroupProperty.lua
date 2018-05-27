-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupProperty.lua
-- *  PURPOSE:     Group Property class
-- *
-- ****************************************************************************
GroupProperty = inherit(Object)
local PICKUP_SOLD = 1272
local PICKUP_FOR_SALE = 1273
function GroupProperty:constructor(Id, Name, OwnerId, Type, Price, Pickup, InteriorId, InteriorSpawn, Cam, Open, Message, depotId, elevatorData)

	self.m_Id = Id
	self.m_Name = Name
	self.m_Price = Price
	self.m_OwnerID = OwnerId
	self.m_Message = Message
	self.m_Owner = GroupManager:getSingleton():getFromId(OwnerId) or false
	if not self.m_Owner then
		Open = 1
	end
	self.m_Open = Open
	self.m_Position = Pickup
	self.m_Interior = InteriorId
	self.m_InteriorPosition = InteriorSpawn
	self.m_Dimension = Id+1000
	self.m_CamMatrix = {tonumber(gettok(Cam,1,",")), tonumber(gettok(Cam,2,",")), tonumber(gettok(Cam,3,",")), Pickup.x, Pickup.y, Pickup.z}

	self.m_Pickup = createPickup(Pickup, 3, PICKUP_FOR_SALE, 0)
	if self.m_OwnerID ~= 0 then setPickupType(self.m_Pickup, 3, PICKUP_SOLD) end

	self.m_Pickup.m_PickupType = "GroupProperty" -- used for fire message geration
	self.m_Pickup.m_PickupName = Name
	
	self.m_DepotId = depotId
	self.m_Depot = Depot.load(depotId, self)

	if elevatorData then
		local elevatorData = fromJSON(elevatorData)
		if elevatorData and elevatorData.stations and #elevatorData.stations > 1 then
			local elevator = Elevator:new()
			for i, station in ipairs(elevatorData.stations) do
				elevator:addStation(station.name, normaliseVector(station.position), station.rotation, station.interior, station.dimension)
			end
		end
	end

	self:getKeysFromSQL()

	addEventHandler("onPickupHit", self.m_Pickup, bind(self.onEnter, self))

	self.m_ExitMarker = createMarker(InteriorSpawn, "corona", 2, 255, 255, 255, 200)
	self.m_ExitMarker:setInterior(InteriorId)
	self.m_ExitMarker:setDimension(self.m_Dimension)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if matchingDimension then
				self:closeForPlayer(hitElement)
			end
		end
	)

	--Liberty City Mapfix
	if self.m_Interior == 1 then
		local door1 = createObject ( 3089, -792.09998, 497.20001, 1367.9 )
		local door2 = createObject ( 3089, -790.59998, 497.20001, 1365.3, 0, 180, 0 )
		door1:setInterior(self.m_Interior)
		door1:setDimension(self.m_Dimension)
		door2:setInterior(self.m_Interior)
		door2:setDimension(self.m_Dimension)
	end

end

function GroupProperty:destructor()
	if isElement(self.m_Pickup) then
		self.m_Pickup:destroy()
	end
	local action,player, prop
	if #self.m_ChangeKeyMap > 0 then
		for k, obj in ipairs( self.m_ChangeKeyMap) do
			action,player, prop = obj[1],obj[2],obj[3]
			if action == "add" then
				sql:queryExec("INSERT IGNORE INTO ??_group_propKeys (Owner,PropId) VALUES (?,?)",sql:getPrefix(),player,self.m_Id)
			elseif action == "remove" then
				sql:queryExec("DELETE FROM ??_group_propKeys WHERE Owner=? AND PropId=?",sql:getPrefix(),player,self.m_Id)
			end
		end
	end
	sql:queryExec("UPDATE ??_group_property SET open=?, DepotId=? WHERE Id=?", sql:getPrefix(), self.m_Open, self.m_DepotId, self.m_Id)
	if self.m_Depot then
		self.m_Depot:save()
	else
		outputDebugString("Save Depot for Group Property "..self.m_Id.." failed! (Not found)")
	end
end

function GroupProperty:setDepotId(Id)
	self.m_DepotId = Id
end

function GroupProperty:getDepot()
	return self.m_Depot
end

function GroupProperty:Event_requestImmoPanel( client )
	local rank = 0
	if self.m_Owner then
		rank = self.m_Owner:getPlayerRank(client:getId())
	end
	if rank then
		if rank >= 1 then
			client:triggerEvent("setPropGUIActive", self)
			client:triggerEvent("sendGroupKeyList",self.m_Keys, self.m_ChangeKeyMap)
		end
	end
end

function GroupProperty:giveKey( player, client )
	local id = player:getId()
	local bCheck = self:checkChangeMap(player, "add")
	local bCheck2 = self:checkChangeMap(player, "remove")
	local bCheck3 = self:hasPlayerAlreadyKey( player )
	local bCompCheck = (not bCheck and not bCheck3) or bCheck2
	if bCompCheck then
		if player and type(id) == "number" then
			if bCheck2 then
				table.remove(self.m_ChangeKeyMap,bCheck2)
			end
			self.m_ChangeKeyMap[#self.m_ChangeKeyMap+1] = {"add",id,self.m_Id,Account.getNameFromId(id)}
			outputChatBox("Du hast einen Schlüssel für die Immobilie "..self.m_Name.." erhalten!",player,0,200,0)
		end
	else
		client:sendError("Spieler hat bereits einen Schlüssel!")
	end
end

function GroupProperty:removeKey( player, client )
	local id = player:getId()
	local bCheck = self:checkChangeMap(player, "add")
	local bCheck2 = self:hasPlayerAlreadyKey( player )
	local bCompCheck = (bCheck or bCheck2)
	if bCompCheck then
		if player and type(id) == "number" then
			if bCheck2 then
				for k,row in ipairs(self.m_Keys) do
					if tonumber(row.Owner) == id then
						table.remove(self.m_Keys,k)
					end
				end
			end
			if bCheck then
				table.remove(self.m_ChangeKeyMap, bCheck)
			end
			self.m_ChangeKeyMap[#self.m_ChangeKeyMap+1] = {"remove",id,self.m_Id,Account.getNameFromId(id)}
			outputChatBox("Dein Schlüssel für die Immobilie "..self.m_Name.." wurde abgenommen!",player,200,0,0)
			return
		end
	else
		player:sendError("Spieler hat keinen Schlüssel!")
	end
end

function GroupProperty:checkChangeMap(player, action)
	for k, obj in ipairs( self.m_ChangeKeyMap) do
		if obj[1] == action and tonumber(obj[2]) == player:getId() then
			return k
		end
	end
	return false
end


function GroupProperty:hasPlayerAlreadyKey( player )
	for k, row in ipairs( self.m_Keys) do
		if row.Owner == player:getId() then
			return true
		end
	end
	return false
end

function GroupProperty:sendKeyList()
	if client then
		client:triggerEvent("sendGroupKeyList",self.m_Keys,self.m_ChangeKeyMap)
	end
end

function GroupProperty:getKeysFromSQL()
	local result = sql:queryFetch("SELECT * FROM ??_group_propKeys WHERE PropId=?", sql:getPrefix(),self.m_Id)
	self.m_Keys = result or {}
	local name
	for k, obj in ipairs(self.m_Keys) do
		if obj.Owner then
			name = Account.getNameFromId(tonumber(obj.Owner))
			obj.NameOfOwner = name
		end
	end
	self.m_ChangeKeyMap = {}
end

function GroupProperty:hasKey( player )
	local check = self:hasPlayerAlreadyKey( player )
	local check2 = self:checkChangeMap( player, "add")
	return check or check2
end

function GroupProperty:openForPlayer(player)
	local rank = 0
	if self.m_Owner then
		rank = self.m_Owner:getPlayerRank(player:getId())
	end
	if not player.vehicle then
		if self.m_Open == 1 or self:hasKey(player) or rank == 6 then
			if getElementType(player) == "player" then
				fadeCamera(player,false,1,0,0,0)
				setElementFrozen( player, true)
				self:outputEntry( player )
				setTimer( bind( GroupProperty.setInside,self),2500,1, player)
			end
		else
			player:sendError("Tür kann nicht geöffnet werden!")
		end
	end
end

function GroupProperty:setInside( player )
	if isElement(player) and not player.vehicle then
		setElementInterior(player,self.m_Interior, self.m_InteriorPosition.x, self.m_InteriorPosition.y, self.m_InteriorPosition.z)
		setElementDimension(player,self.m_Dimension)
		player:setRotation(0, 0, 0)
		player:setCameraTarget(player)
		fadeCamera(player, true)
		setTimer(function() --map glitch fix
			setElementFrozen( player, false)
		end, 1000, 1)
		player.justEntered = true
		setTimer(function() player.justEntered = false end, 2000,1)
	end
end

function GroupProperty:setOutside( player )
	if isElement(player) then
		setElementInterior(player,0, self.m_Position.x, self.m_Position.y, self.m_Position.z)
		setElementDimension(player,0)
		player:setRotation(0, 0, 0)
		player:setCameraTarget(player)
		fadeCamera(player, true)
		setElementFrozen( player, false)
		player:triggerEvent("forceGroupPropertyClose")
	end
end

function GroupProperty:outputEntry( client )
	if self.m_Message then
		if not self.m_Message or self.m_Message == "" or #self.m_Message < 1 then
			self.m_Message = self.m_Name
		end
		client:triggerEvent("groupEntryMessage",self.m_Message)
	end
end

function GroupProperty:closeForPlayer(player)
	local rank = 0
	if self.m_Owner then
		rank = self.m_Owner:getPlayerRank(player:getId())
	end
	if getElementType(player) == "player" then
		if self.m_Open == 1 or self:hasKey(player) or rank == 6 then
			if not player.justEntered then
				fadeCamera(player,false,1,0,0,0)
				setElementFrozen( player, true)
				player:triggerEvent("forceGroupPropertyClose")
				setTimer( bind( GroupProperty.setOutside,self),2500,1, player)
			end
		else
			player:sendError("Tür kann nicht geöffnet werden!")
		end
	end
end

function GroupProperty:addLog(player, category, text)
	if self.m_Owner then
		assert(self.m_Owner.addLog, "group property owner has no log function")
		self.m_Owner:addLog(player, category, text)
	end
end

--// now the so-called EVENT-ZONE //
function GroupProperty:Event_ChangeDoor( client )
	if self.m_Open == 1 then
		self.m_Open = 0
		self.m_Owner:sendMessage("["..self.m_Owner:getName().."] #ffffff"..client:getName().." schloss die Tür ab! ("..self.m_Name..")", 0,200,200,true)
		client:sendInfo("Tür ist nun zu!")
	else
		self.m_Open = 1
		self.m_Owner:sendMessage("["..self.m_Owner:getName().."] #ffffff"..client:getName().." schloss die Tür auf! ("..self.m_Name..")", 0,200,200,true)
		client:sendInfo("Tür ist nun offen!")
	end
	client:triggerEvent("updateGroupDoorState",self.m_Open)
end

function GroupProperty:Event_RefreshPlayer( client )
	if client then
		client:triggerEvent("sendGroupKeyList",self.m_Keys,self.m_ChangeKeyMap)
	end
end

function GroupProperty:Event_RemoveAll( client )
	self.m_ChangeKeyMap = {}
	for k, obj in ipairs(self.m_Keys) do
		self.m_ChangeKeyMap[#self.m_ChangeKeyMap+1] = {"remove",obj.Owner,self.m_Id,Account.getNameFromId(obj.Owner)}
	end
	self:Event_RefreshPlayer( client )
	client:sendInfo("Alle Schlüssel wurden zerstört!")
end

function GroupProperty:Event_keyChange( player, action, client )
	if action == "all" then
		self:Event_RemoveAll(client)
	end
	if player then
		player = PlayerManager:getSingleton():getPlayerFromPartOfName(player,client,false)
		if player then
			if action == "add" then
				self:giveKey( player, client )
			elseif action == "remove" then
				self:removeKey( player, client )
			end
			self:Event_RefreshPlayer( client )
		else client:sendError("Spieler nicht gefunden!")
		end
	end
end

function GroupProperty:onEnter( player )
	local bDim = getElementDimension(player) == getElementDimension( source)
	if bDim and player:getType() == "player" and not player.vehicle then
		local name = "Kein Besitzer"
		if self.m_Owner then
			name = self.m_Owner.m_Name
		end
		player.m_LastPropertyPickup = self
		player:triggerEvent("showGroupEntrance", self, self.m_Pickup, name)
	end
end

--// SETTERS
function GroupProperty:setOwner( id )
	self.m_Owner = GroupManager.getFromId(id) or false
	if self.m_Owner == false then
		setPickupType(self.m_Pickup, 3, PICKUP_FOR_SALE)
		self.m_OwnerID = 0
	else
		setPickupType(self.m_Pickup, 3, PICKUP_SOLD)
		self.m_OwnerID = id
	end
	return self.m_Owner
end

-- Short getters
function GroupProperty:getId() return self.m_Id end
function GroupProperty:getName() return self.m_Name end
function GroupProperty:getPrice() return self.m_Price end
function GroupProperty:hasOwner() return self.m_Owner ~= false end
function GroupProperty:getOwner() return self:hasOwner() and self.m_Owner or false end
