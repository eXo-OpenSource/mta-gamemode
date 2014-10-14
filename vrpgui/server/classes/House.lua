House = inherit(Object)

local BREAKIN_INTERVAL = 1000*60*30 -- 30 Minutes

function House:constructor(id, x, y, z, interiorID, keys, owner, price, lockStatus, rentPrice)

	if owner == 0 then
		owner = false 
	end
	
	self.m_PlayersInterior = {}
	self.m_Price = price
	self.m_Rentprice = rentPrice
	self.m_LockStatus = toboolean(lockStatus)
	self.m_Pos = {x, y, z}
	self.m_Keys = fromJSON(keys)
	self.m_InteriorID = interiorID
	self.m_Owner = owner
	self.m_Id = id
	self.m_Pickup = createPickup(x, y, z, 3, 1239, 10, math.huge)
	self.m_LastBreakIn = false
	
	--addEventHandler ("onPlayerJoin",root, bind(self.checkContractMonthly, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerQuit, self))
	addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
	
	addCommandHandler("bought", bind(self.commandBuyHouse, self))
	addCommandHandler("rent", bind(self.commandRentHouse, self))
	addCommandHandler("unrent", bind(self.commandUnrentHouse, self))
	
end

function House:getKeys()
	return self.m_Keys
end

function House:isValidToEnter(playerName)
	return self.m_Keys[playerName] ~= false
end

function House:rentHouse(player)
	if not self.m_Keys[getPlayerName(player)] then
		self.m_Keys[getPlayerName(player)] = getRealTime().timestamp
	end
end

function House:save ()
	local houseID = self.m_Owner or 0
	
	return sql:queryExec("UPDATE ??_houses SET interiorID = ?, `keys` = ?, owner = ?, price = ?, lockStatus = ?, rentPrice = ? WHERE id = ?;", sql:getPrefix(),
		self.m_InteriorID, toJSON(self.m_Keys), houseID, self.m_Price, self.m_LockStatus and 1 or 0, self.m_Rentprice, self.m_Id)	
end

function House:sellHouse(player)
	self.m_Owner = false
end

function House:unrentHouse(playerName)
	if self.m_Keys[playerName] then
		self.m_Keys[playerName] = nil
		local player = getPlayerFromName(playerName)
		if player and isElement(player) then -- Jusonex: Andersherum, da sonst Bad argument @ isElement
			--[[
				...
			]]
		end
	end
end

function House:AbleToBreakin(player)
	if not self.m_LastBreakIn or getTickCount() >= self.m_LastBreakIn+BREAKIN_INTERVAL and player.m_Group then
		return true
	end
	return false
end

function House:enterHouse(player)
	if self.m_Keys[getPlayerName(player)] or not self.m_LockStatus or player:getId() == self.m_Owner then
		local houseData = House.interiorTable[self.m_InteriorID]
		local x, y, z, int, dim = unpack(houseData)
		setElementPosition(player, x, y, z)
		setElementInterior(player, int)
		setElementDimension(player, dim)
	end
end

function House:breakHouse(player)
	if self:AbleToBreakin(player) and not self.m_Keys[getPlayerName(player)] or player:getId() == self.m_Owner then
		player:sendMessage("Todo")
	end
end

function House:removePlayerFromList(player)
	if self.m_PlayersInterior[player] then
		self.m_PlayersInterior[player] = nil
	end
end

function House:leaveHouse(player)
	self:removePlayerFromList(player)
	setElementPosition(player, unpack(self.m_Pos))
	setElementInterior(player, 0)
	setElementDimension(player, 0)
end

function House:onPlayerQuit(player)
	self:removePlayerFromList(player)
	
	--[[
		...
	]]
end

function House:buyHouse(player)
	if not self.m_Owner and getPlayerMoney(player) >= self.m_Price then
		takePlayerMoney(player, self.m_Price)
		self.m_Owner = player:getId()
	end
end

-- // unimplemented features
--[[function House:getSecondsForNewContract () return 60*60*24*30 end

function House:checkContractMonthly (playerName)
	localplayer= getPlayerFromName(playerName) or false
	if self.m_Keys[playerName] then
		if getRealTime().timestamp >= self.m_Keys[playerName] + self:getSecondsForNewContract() then
			outputChatBox ("Vertrag abgelaufen !")
		end
	end
end]]

function House:onPickupHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		outputChatBox ("Besitzer : "..tostring(self.m_Owner), hitElement, 200, 200, 255 )
		outputChatBox ("Preis    : $ "..self.m_Price, hitElement, 200, 200, 255)
		outputChatBox ("Miete    : $ "..self.m_Rentprice, hitElement, 200, 200, 255)
	end
end

function House:commandBuyHouse(player)
	local x, y, z = getElementPosition(player)
	if getDistanceBetweenPoints3D(self.m_Pos[1], self.m_Pos[2], self.m_Pos[3], x, y, z) < 2 then
		self:buyHouse(player)
	end	
end

function House:commandRentHouse(player)
	local x, y, z = getElementPosition(player)
	if getDistanceBetweenPoints3D(self.m_Pos[1], self.m_Pos[2], self.m_Pos[3], x, y, z) < 2 then
		self:rentHouse(player)
	end	
end

function House:commandUnrentHouse(player)
	local x, y, z = getElementPosition(player)
	if getDistanceBetweenPoints3D(self.m_Pos[1], self.m_Pos[2], self.m_Pos[3], x, y, z) < 2 then
		self:unrentHouse(getPlayerName(player))
	end		
end
