-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/House.lua
-- *  PURPOSE:     Serverside house class
-- *
-- ****************************************************************************
House = inherit(Object)

local ROB_DELAY = 3600
local ROB_NEEDED_TIME = 1000*60*4

function House:constructor(id, x, y, z, interiorID, keys, owner, price, lockStatus, rentPrice, elements)
	if owner == 0 then
		owner = false
	end

	self.m_CurrentRobber = false
	self.m_LastRobbed = 0
	self.m_PlayersInterior = {}
	self.m_Price = price
	self.m_RentPrice = rentPrice
	self.m_LockStatus = toboolean(lockStatus)
	self.m_Pos = {x, y, z}
	self.m_Keys = fromJSON(keys)
	self.m_InteriorID = interiorID
	self.m_Owner = owner
	self.m_Id = id
	self.m_Elements = fromJSON(elements or "")
	self.m_Pickup = createPickup(x, y, z, 3, 1273, 10, math.huge)
	local ix, iy, iz, int = unpack(House.interiorTable[self.m_InteriorID])
	self.m_HouseMarker = createMarker(ix,iy,iz-1,"cylinder",1.2,255,255,255,125)
	setElementDimension(self.m_HouseMarker,self.m_Id)
	setElementInterior(self.m_HouseMarker,int)
	self.m_ColShape = createColSphere(x,y,z,1)

	--addEventHandler ("onPlayerJoin",root, bind(self.checkContractMonthly, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerFade, self))
	addEventHandler("onPlayerWasted", root, bind(self.onPlayerFade, self))
	addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.onColShapeLeave,self))
	addEventHandler("onMarkerHit", self.m_HouseMarker, bind(self.onMarkerHit,self))

end

function House:breakHouse(player)
	if getRealTime().timestamp >= self.m_LastRobbed + ROB_DELAY then
		if not HouseManager:getSingleton():isCharacterAllowedToRob(player) then
			player:sendWarning(_("Du hast vor kurzem schon ein Haus ausgeraubt!", player),125,0,0)
			return
		end
		self.m_CurrentRobber = player
		self.m_LastRobbed = getRealTime().timestamp
		HouseManager:getSingleton():addCharacterToRoblist(player)
		self:enterHouse(player)
		player:reportCrime(Crime.HouseRob)
		player:sendMessage("Halte die Stellung für %d Minuten!", 125, 0, 0, ROB_NEEDED_TIME/1000/60)

		setTimer(
			function(unit)
				local isRobSuccessfully = false

				if unit and isElement(unit) and self.m_PlayersInterior[unit] then
					isRobSuccessfully = true
				end
				if isRobSuccessfully then
					local loot = math.floor(self.m_Price/20*(math.random(75,100)/100))
					unit:giveMoney(loot)
					unit:sendMessage("Du hast den Raub erfolgreich abgeschlossen! Dafür erhälst du $%s.",0,125,0,loot)
					self:leaveHouse(unit)
				end

				self.m_CurrentRobber = false
			end,
			ROB_NEEDED_TIME,1,player)
		return
	end
	player:sendMessage("Dieses Haus wurde erst vor kurzem ausgeraubt!",125,0,0)
end

function House:onMarkerHit(hitElement,matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice)
	end
end

function House:isValidRob(player)
	if self.m_Keys[player:getId()] or self.m_Owner == player:getId() or not player:getGroup() --[[ or not self.m_Owner]] then
		return false
	end
	return true
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
	if not self.m_Keys[player:getId()] then
		if not self.m_Owner then
			player:sendError(_("Einmieten fehlgeschlagen - dieses Haus hat keinen Eigentümer!", player), 255, 0, 0)
			return
		end

		if player:getId() ~= self.m_Owner then
			self.m_Keys[player:getId()] = getRealTime().timestamp
			player:sendSuccess(_("Sie wurden erfolgreich eingemietet", player),0,255,0)
		else
			player:sendError(_("Du kannst dich nicht in dein eigenes Haus einmieten!", player))
		end
	end
end

function House:save()
	local houseID = self.m_Owner or 0

	return sql:queryExec("UPDATE ??_houses SET interiorID = ?, `keys` = ?, owner = ?, price = ?, lockStatus = ?, rentPrice = ?, elements = ? WHERE id = ?;", sql:getPrefix(),
		self.m_InteriorID, toJSON(self.m_Keys), houseID, self.m_Price, self.m_LockStatus and 1 or 0, self.m_RentPrice, toJSON(self.m_Elements), self.m_Id)
end

function House:sellHouse(player)
	self.m_Owner = false
end

function House:onPickupHit(hitElement)
	if getElementType(hitElement) == "player" and (getElementDimension(hitElement) == getElementDimension(source)) then
		hitElement.visitingHouse = self.m_Id
		hitElement:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, self:isValidRob(hitElement))
	end
end

function House:unrentHouse(player)
	if self.m_Keys[player:getId()] then
		self.m_Keys[player:getId()] = nil
		if player and isElement(player) then
			player:sendSuccess(_("Du hast gekündigt!", player),255,0,0)
		end
	end
end

function House:enterHouseTry(player)
	if self.m_Keys[player:getId()] or not self.m_LockStatus or player:getId() == self.m_Owner or ( self.m_CurrentRobber and player:getJob() == 4 ) then
		self:enterHouse(player)
	end
end

function House:enterHouse(player)
	local x, y, z, int = unpack(House.interiorTable[self.m_InteriorID])
	setElementPosition(player, x, y, z)
	setElementInterior(player, int)
	setElementDimension(player, self.m_Id)
	self.m_PlayersInterior[player] = true
	player:triggerEvent("houseEnter")
end

function House:removePlayerFromList(player)
	if self.m_PlayersInterior[player] then
		self.m_PlayersInterior[player] = nil
		if player == self.m_CurrentRobber then
			self.m_CurrentRobber = false
		end
	end
end

function House:leaveHouse(player)
	if not self.m_PlayersInterior[player] then
		return
	end
	self:removePlayerFromList(player)
	setElementPosition(player, unpack(self.m_Pos))
	setElementInterior(player, 0)
	setElementDimension(player, 0)
	player:triggerEvent("houseLeave")
end

function House:onPlayerFade()
	self:removePlayerFromList(source)
end

function House:buyHouse(player)
	if self.m_Owner then
		player:sendError(_("Dieses Haus hat schon einen Besitzer!", player))
		return
	end

	if player:getMoney() >= self.m_Price then
		player:takeMoney(self.m_Price)
		self.m_Owner = player:getId()
		player:sendSuccess(_("Du hast das Haus erfolgreich gekauft!", player))
	else
		player:sendError(_("Du hast nicht genügend Geld!", player))
	end
end

House.interiorTable = {
	[1] = {140.27800,1368.32727,1083.86279,5};
	[2] = {-284.91348,1470.60632,1084.37500,15};
}
