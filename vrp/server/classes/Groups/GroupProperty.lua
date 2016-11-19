-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupProperty.lua
-- *  PURPOSE:     Group Property class
-- *
-- ****************************************************************************
GroupProperty = inherit(Object)

function GroupProperty:constructor(Id, Name, OwnerId, Type, Price, Pickup, InteriorId, InteriorSpawn, Cam, Open)

	self.m_Id = Id
	self.m_Name = Name
	self.m_Price = Price
	self.m_OwnerID = OwnerId
	self.m_Owner = GroupManager:getSingleton():getFromId(OwnerId) or false
	self.m_Open = Open
	self.m_Position = Pickup
	self.m_Interior = InteriorId
	self.m_InteriorPosition = InteriorSpawn
	self.m_Dimension = Id+1000
	self.m_CamMatrix = {tonumber(gettok(Cam,1,",")), tonumber(gettok(Cam,2,",")), tonumber(gettok(Cam,3,",")), Pickup.x, Pickup.y, Pickup.z}

	self.m_Pickup = createPickup(Pickup, 3, 1272, 0)
	self.m_EnterFunc = bind( GroupProperty.onEnter, self)
	
	self:getKeysFromSQL()
	
	addEventHandler("onPickupHit", self.m_Pickup, self.m_EnterFunc)
	
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
end

function GroupProperty:getKeysFromSQL() 
	local result = sql:queryFetch("SELECT * FROM ??_group_propKeys WHERE PropId=?", sql:getPrefix(),self.m_Id)
	self.m_Keys = result or {}
	self.m_ChangeKeyMap = {}
end

function GroupProperty:giveKey( player )
	local id = player:getId()
	if player and type(id) == "number" then
		self.m_ChangeKeyMap[#self.m_ChangeKeyMap+1] = {"add",id,self.m_Id}
		outputChatBox("Du hast einen Schlüssel für die Immobilie "..self.m_Name.." erhalten!",player,0,200,0)
	end
end

function GroupProperty:removeKey( player )
	local id = player:getId()
	if player and type(id) == "number" then
		for k,row in ipairs(self.m_Keys) do 
			if tonumber(row.Owner) == id then 
				table.remove(self.m_Keys,k)
				self.m_ChangeKeyMap[#self.m_ChangeKeyMap+1] = {"remove",id,self.m_Id}
				outputChatBox("Dein Schlüssel für die Immobilie "..self.m_Name.." wurde abgenommen!",player,200,0,0)
				return
			end
		end
	end
end

function GroupProperty:checkChangeMap(player, action)
	for k, obj in ipairs( self.m_ChangeKeyMap) do 
		if obj[1] == action and tonumber(obj[2]) == player:getId() then 
			return false
		end	
	end
	return true
end

function GroupProperty:hasPlayerAlreadyKey( player ) 
	for k, row in ipairs( self.m_Keys) do 
		if row.Owner == player:getId() then 
			return true 
		end
	end
	return false
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
				sql:queryExec("INSERT INTO ??_group_propKeys (Owner,PropId) VALUES (?,?)",sql:getPrefix(),player,self.m_Id)
			elseif action == "remove" then 
				sql:queryExec("DELETE FROM ??_group_propKeys WHERE Owner=? AND PropId=?",sql:getPrefix(),player,self.m_Id)
			end
		end
	end
end

function GroupProperty:checkForChangeEntry(player, action, bRemove)
	local ac_, pl_
	for k, obj in ipairs( self.m_ChangeKeyMap) do 
		ac_,pl_ = obj[1],obj[2]
		if action == ac_ and pl_ == player:getId() then
			if bRemove then 
				table.remove( self.m_ChangeKeyMap, k)
				if action == "add" then 
					outputChatBox("Dein Schlüssel für die Immobilie "..self.m_Name.." wurde abgenommen!",player,200,0,0)
				end
			end
			return true
		end
	end
	return false
end

function GroupProperty:Event_keyChange( player, action, client )
	if player then 
		player = PlayerManager:getSingleton():getPlayerFromPartOfName(player,client,false)
		if player then 
			if self:checkChangeMap(player,action) then
				if action == "add" then 
					if not self:hasPlayerAlreadyKey( player ) or self:checkForChangeEntry(player,"remove", true) then
						self:giveKey( player )
					else client:sendError("Spieler besitzt bereits einen Schlüssel!")
					end
				elseif action == "remove" then 
					if self:hasPlayerAlreadyKey( player ) or self:checkForChangeEntry(player,"add", true) then
						self:removeKey( player )
					else client:sendError("Spieler besitzt keinen Schlüssel!")
					end
				end
			end
		else client:sendError("Spieler nicht gefunden!")
		end
	end
end

function GroupProperty:onEnter( player ) 
	local bDim = getElementDimension(player) == getElementDimension( source)
	if bDim then
		local name = "Kein Besitzer"
		if self.m_Owner then 
			name = self.m_Owner.m_Name
		end
		player.m_LastPropertyPickup = self
		player:triggerEvent("showGroupEntrance", self, self.m_Pickup, name)
	end
end

function GroupProperty:openForPlayer(player)
	if getElementType(player) == "player" then
		if self.m_Owner then
			if self.m_Owner:getPlayerRank(player:getId()) then 
				player:triggerEvent("setPropGUIActive", self)
			end
		end
		player:setInterior(self.m_Interior, self.m_InteriorPosition.x, self.m_InteriorPosition.y, self.m_InteriorPosition.z)
		player:setDimension(self.m_Dimension)
		player:setRotation(0, 0, 0)
		player:setCameraTarget(player)
		player.justEntered = true
		setTimer(function() player.justEntered = false end, 2000,1)
	end
end

function GroupProperty:closeForPlayer(player)
	if getElementType(player) == "player" then
		if not player.justEntered then
			player:setInterior(0, self.m_Position.x, self.m_Position.y, self.m_Position.z)
			player:setDimension(0)
			player:setRotation(0, 0, 0)
			player:setCameraTarget(player)
		end
	end
end


function GroupProperty:setOwner( id ) 
	self.m_Owner = GroupManager.getFromId(OwnerId) or false 
	return self.m_Owner
end

-- Short getters
function GroupProperty:getId() return self.m_Id end
function GroupProperty:getName() return self.m_Name end
function GroupProperty:getPrice() return self.m_Price end
function GroupProperty:hasOwner() return self.m_Owner ~= false end
function GroupProperty:getOwner() return self:hasOwner() and self.m_Owner or false end


