House = inherit(Object)

function House:constructor(id, x, y, z, interiorID, keys, owner, price, lockStatus, rentPrice, elements)

	if owner == 0 then
		owner = false 
	end
	
	self.m_PlayersInterior = {}
	self.m_Price = price
	self.m_RentPrice = rentPrice
	self.m_LockStatus = toboolean(lockStatus)
	self.m_Pos = {x, y, z}
	self.m_Keys = fromJSON(keys)
	self.m_InteriorID = interiorID
	self.m_Owner = owner or false
	self.m_Id = id
	self.m_Elements = fromJSON(elements or "")
	self.m_Pickup = createPickup(x, y, z, 3, 1273, 10, math.huge)
	local ix, iy, iz, iint = unpack(House.interiorTable[self.m_InteriorID])
	self.m_HouseMarker = createMarker(ix,iy,iz-1,"cylinder",1.2,255,255,255,125)
	setElementDimension(self.m_HouseMarker,self.m_Id)
	setElementInterior(self.m_HouseMarker,iint)
	self.m_ColShape = createColSphere(x,y,z,1)
	
	--addEventHandler ("onPlayerJoin",root, bind(self.checkContractMonthly, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerQuit, self))
	addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.onColShapeLeave,self))
	addEventHandler("onMarkerHit", self.m_HouseMarker, bind(self.onMarkerHit,self))

end

function House:getKeys()
	return self.m_Keys
end

function House:onMarkerHit(hitElement,matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:triggerEvent("showHouseMenu",self.m_Owner,self.m_Price,self.m_RentPrice)
	end
end

function House:onColShapeLeave(hitElement,matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and self.m_Id == hitElement.visitingHouse then
		hitElement:triggerEvent("hideHouseMenu")
	end
end

function House:isValidToEnter(playerName)
	return self.m_Keys[playerName] ~= false
end

function House:rentHouse(player)
	if not self.m_Keys[getPlayerName(player)] then
		if self.m_Owner then
			self.m_Keys[getPlayerName(player)] = getRealTime().timestamp
			player:sendMessage("Sie wurden erfolgreich eingemietet.",0,255,0)
		else
			player:sendMessage("Einmieten fehlgeschlagen - dieses Haus hat keinen Eigentuemer!",255,0,0)
		end
	end
end

function House:save ()
	local houseID = self.m_Owner or 0
	
	return sql:queryExec("UPDATE ??_houses SET interiorID = ?, `keys` = ?, owner = ?, price = ?, lockStatus = ?, rentPrice = ?, elements = ? WHERE id = ?;", sql:getPrefix(),
		self.m_InteriorID, toJSON(self.m_Keys), houseID, self.m_Price, self.m_LockStatus and 1 or 0, self.m_RentPrice, toJSON(self.m_Elements), self.m_Id)	
end

function House:sellHouse(player)
	self.m_Owner = false
end

function House:unrentHouse(playerName)
	if self.m_Keys[playerName] then
		self.m_Keys[playerName] = nil
		local player = getPlayerFromName(playerName)
		if player and isElement(player) then -- Jusonex: Andersherum, da sonst Bad argument @ isElement
			player:sendMessage("Sie wurden ausgemietet!",255,0,0)
		end
	end
end

function House:enterHouse(player)
	if self.m_Keys[getPlayerName(player)] or not self.m_LockStatus or player:getId() == self.m_Owner then
		local x, y, z, int = unpack(House.interiorTable[self.m_InteriorID])
		setElementPosition(player, x, y, z)
		setElementInterior(player, int)
		setElementDimension(player, self.m_Id)
		self.m_PlayersInterior[player] = true
		player:triggerEvent("houseEnter")
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
	player:triggerEvent("houseLeave")
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

function House:onPickupHit(hitElement)
	if getElementType(hitElement) == "player" and (getElementDimension(hitElement) == getElementDimension(source)) then
		hitElement.visitingHouse = self.m_Id
		--self:enterHouse(hitElement)
		hitElement:triggerEvent("showHouseMenu",self.m_Owner,self.m_Price,self.m_RentPrice)
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

House.interiorTable = {
	[1] = {140.27800,1368.32727,1083.86279,5};
	[2] = {-284.91348,1470.60632,1084.37500,15};
}
