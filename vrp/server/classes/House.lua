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

function House:constructor(id, position, interiorID, keys, owner, price, lockStatus, rentPrice, elements, money)
	if owner == 0 then
		owner = false
	end

	self.m_CurrentRobber = false
	self.m_LastRobbed = 0
	self.m_PlayersInterior = {}
	self.m_Price = price
	self.m_RentPrice = rentPrice
	self.m_LockStatus = true
	self.m_Pos = position
	self.m_Keys = fromJSON(keys)
	self.m_InteriorID = interiorID
	self.m_Owner = owner
	self.m_Id = id
	self.m_Elements = fromJSON(elements or "")
	self.m_Money = money or 0

	local int, ix, iy, iz  = unpack(House.interiorTable[self.m_InteriorID])
	self.m_HouseMarker = createMarker(ix, iy, iz-0.8, "cylinder", 1.2, 255, 255, 255, 125)
	self.m_HouseMarker:setDimension(self.m_Id)
	self.m_HouseMarker:setInterior(int)

	self.m_ColShape = createColSphere(position, 1)

	for playerId, timestamp in pairs(self.m_Keys) do -- Work-Arround: JSON saves Index as String
		self.m_Keys[tonumber(playerId)] = timestamp
		self.m_Keys[tostring(playerId)] = nil
	end

	if owner == false then
		self.m_Keys = {}
	end

	--addEventHandler ("onPlayerJoin", root, bind(self.checkContractMonthly, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerFade, self))
	addEventHandler("onPlayerWasted", root, bind(self.onPlayerFade, self))
	addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.onColShapeLeave, self))
	addEventHandler("onMarkerHit", self.m_HouseMarker, bind(self.onMarkerHit, self))

	self:updatePickup()
end

function House:updatePickup()
	if 	self.m_Pickup then self.m_Pickup:destroy() end
	self.m_Pickup = createPickup(self.m_Pos, 3, ((self.m_Owner == 0 or self.m_Owner == false) and 1273 or 1272), 10, math.huge)
	addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
end

function House:getOwner()
	return self.m_Owner
end

function House:toggleLockState( player )
	self.m_LockStatus = not self.m_LockStatus
	local info = "abgeschlossen"
	if self.m_LockStatus then
		info = "aufgeschlossen"
	end
	player:sendInfo("Das Haus wurde "..info.."!")
	self:showGUI(player)
end

function House:showGUI(player)
	if player:getId() == self.m_Owner then
		local tenants = {}
		for playerId, timestamp in pairs(self.m_Keys) do
			tenants[playerId] = Account.getNameFromId(playerId)
		end
		player:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, self:isValidRob(player), self.m_LockStatus, tenants, self.m_Money)
	else
		player:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, self:isValidRob(player), self.m_LockStatus)
	end
end

function House:breakHouse(player)
	if getRealTime().timestamp >= self.m_LastRobbed + ROB_DELAY then
		if not HouseManager:getSingleton():isCharacterAllowedToRob(player) then
			player:sendWarning(_("Du hast vor kurzem schon ein Haus ausgeraubt!", player), 125, 0, 0)
			return
		end
		self.m_CurrentRobber = player
		self.m_LastRobbed = getRealTime().timestamp
		HouseManager:getSingleton():addCharacterToRoblist(player)
		self:enterHouse(player)
		player:reportCrime(Crime.HouseRob)
		player:sendMessage("Halte die Stellung für %d Minuten!", 125, 0, 0, ROB_NEEDED_TIME/1000/60)
		player:triggerEvent("Countdown", ROB_NEEDED_TIME/1000, "Haus-Raub")

		setTimer(
			function(unit)
				local isRobSuccessfully = false

				if unit and isElement(unit) and self.m_PlayersInterior[unit] then
					isRobSuccessfully = true
				end
				if isRobSuccessfully then
					local loot = math.floor(self.m_Price/20*(math.random(75, 100)/100))
					unit:giveMoney(loot, "Haus-Überfall")
					unit:sendMessage("Du hast den Raub erfolgreich abgeschlossen! Dafür erhälst du $%s.", 0, 125, 0, loot)
					unit:triggerEvent("CountdownStop", "Haus-Raub")
					self:leaveHouse(unit)
				end

				self.m_CurrentRobber = false
			end,
			ROB_NEEDED_TIME, 1, player)
		return
	end
	player:sendMessage("Dieses Haus wurde erst vor kurzem ausgeraubt!", 125, 0, 0)
end

function House:onMarkerHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		if hitElement.vehicle then return end
		hitElement.visitingHouse = self.m_Id
		self:showGUI(hitElement)
	end
end

function House:isValidRob(player)
	if self.m_Keys[player:getId()] or self.m_Owner == player:getId() or not player:getGroup() --[[ or not self.m_Owner]] then
		return false
	end
	return true
end

function House:onColShapeLeave(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension and self.m_Id == hitElement.visitingHouse then
		hitElement:triggerEvent("hideHouseMenu")
	end
end

function House:isValidToEnter(playerName)
	return self.m_Keys[playerName] ~= false
end

function House:rentHouse(player)
	if not self.m_Keys[player:getId()] then
		if not self.m_Owner or self.m_Owner == 0 then
			player:sendError(_("Einmieten fehlgeschlagen - dieses Haus hat keinen Eigentümer!", player), 255, 0, 0)
			return
		end

		if player:getId() ~= self.m_Owner then
			self.m_Keys[player:getId()] = getRealTime().timestamp
			player:sendSuccess(_("Sie wurden erfolgreich eingemietet", player), 0, 255, 0)
			player:triggerEvent("addHouseBlip", self.m_Id, self.m_Pos.x, self.m_Pos.y)
		else
			player:sendError(_("Du kannst dich nicht in dein eigenes Haus einmieten!", player))
		end
	else
		player:sendError(_("Du bist bereits in diesem Haus eingemietet!", player))
	end
end

function House:unrentHouse(player)
	if self.m_Keys[player:getId()] then
		self.m_Keys[player:getId()] = nil
		if player and isElement(player) then
			player:sendSuccess(_("Du hast deinen Mietvertrag gekündigt!", player), 255, 0, 0)
			player:triggerEvent("removeHouseBlip", self.m_Id)
		end
	else
		player:sendError(_("Du bist in diesem Haus nicht eingemietet!", player))
	end
end

function House:setRent(player, rent)
	if player:getId() == self.m_Owner then
		player:sendInfo(_("Du hast die Miete auf %d$ gesetzt!", player, rent))
		self.m_RentPrice = rent
	end
end

function House:getRent()
	return self.m_RentPrice
end

function House:deposit(player, amount)
	amount = tonumber(amount)
	if player:getId() == self.m_Owner then
		if player:getMoney() >= amount then
			player:takeMoney(amount, "Hauskasse")
			self.m_Money = self.m_Money + amount
			self:showGUI(player)
		else
			player:sendError(_("Du hast nicht genug Geld dabei!", player))
		end
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:withdraw(player, amount)
	amount = tonumber(amount)
	if player:getId() == self.m_Owner then
		if self.m_Money >= amount then
			self.m_Money = self.m_Money - amount
			player:giveMoney(amount, "Hauskasse")
			self:showGUI(player)
		else
			player:sendError(_("In der Hauskasse ist nicht genug Geld!", player))
		end
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:removeTenant(player, id)
	if player:getId() == self.m_Owner then
		if self.m_Keys[id] then
			self.m_Keys[id] = nil
			player:sendSuccess(_("Du hast den Mietvertrag mit %s gekündigt!", player, Account.getNameFromId(id)), 255, 0, 0)
			self:showGUI(player)
		end
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:isTenant(id)
	if self.m_Keys[id] then
		return true
	end
	return false
end

function House:save()
	local houseID = self.m_Owner or 0
	if not self.m_Keys then self.m_Keys = {} end
	if not self.m_Elements then self.m_Elements = {} end
	return sql:queryExec("UPDATE ??_houses SET interiorID = ?, `keys` = ?, owner = ?, price = ?, lockStatus = ?, rentPrice = ?, elements = ?, money = ? WHERE id = ?;", sql:getPrefix(),
		self.m_InteriorID, toJSON(self.m_Keys), houseID, self.m_Price, self.m_LockStatus and 1 or 0, self.m_RentPrice, toJSON(self.m_Elements), self.m_Money, self.m_Id)
end

function House:sellHouse(player)
	if player:getId() == self.m_Owner then
		-- destroy blip
		player:triggerEvent("removeHouseBlip", self.m_Id)

		local price = math.floor(self.m_Price*0.75)
		player:sendInfo(_("Du hast dein Haus für %d$ verkauft!", player, price))
		player:giveMoney(price, "Haus-Verkauf")
		self.m_Owner = 0
		self.m_Keys = 0
		self:updatePickup()
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:onPickupHit(hitElement)
	if hitElement:getType() == "player" and (hitElement:getDimension() == source:getDimension()) then
		if hitElement.vehicle then return end
		hitElement.visitingHouse = self.m_Id
		self:showGUI(hitElement)
	end
end

function House:enterHouseTry(player)
	if (self.m_Keys[player:getId()] or player:getId() == self.m_Owner or self.m_CurrentRobber == player) or not self.m_LockStatus then
		self:enterHouse(player)
	else
		player:sendError(_("Du darfst dieses Haus nicht betreten!", player))

	end
end

function House:enterHouse(player)
	local int, x, y, z = unpack(House.interiorTable[self.m_InteriorID])
	player:setPosition(x, y, z)
	player:setDimension(self.m_Id)
	player:setInterior(int)
	self.m_PlayersInterior[player] = true
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
	if self.m_Keys[player:getId()] or not self.m_LockStatus  then
		self:removePlayerFromList(player)
		player:setPosition(self.m_Pos)
		player:setInterior(0)
		player:setDimension(0)
		if self.m_CurrentRobber == player then
			player:triggerEvent("CountdownStop", "Haus-Raub")
		end
	else
		player:sendError(_("Das Tür ist verschlossen!", player))
	end
end

function House:onPlayerFade()
	self:removePlayerFromList(source)
end

function House:buyHouse(player)
	if HouseManager:getSingleton():getPlayerHouse(player) then
		player:sendWarning(_("Du hast bereits ein Haus!", player), 125, 0, 0)
		return
	end

	if (self.m_Owner or 0) > 0 then
		player:sendError(_("Dieses Haus hat schon einen Besitzer!", player))
		return
	end

	if player:getMoney() >= self.m_Price then
		player:takeMoney(self.m_Price, "Haus-Kauf")
		self.m_Owner = player:getId()
		self:updatePickup()
		player:sendSuccess(_("Du hast das Haus erfolgreich gekauft!", player))

		-- create blip
		player:triggerEvent("addHouseBlip", self.m_Id, self.m_Pos.x, self.m_Pos.y)
	else
		player:sendError(_("Du hast nicht genügend Geld!", player))
	end
end

House.interiorTable = {
	[1] = {1, 223.27027893066, 1287.4304199219, 1081.9130859375};
	[2] = {5, 2233.8625488281, -1113.7662353516, 1050.8828125};
	[3] = {8, 2365.224609375, -1135.1401367188, 1050.875};
	[4] = {11, 2282.9448242188, -1139.9676513672, 1050.8984375};
	[5] = {6, 2196.373046875, -1204.3984375, 1049.0234375};
	[6] = {10, 2270.2353515625, -1210.4715576172, 1047.5625};
	[7] = {6, 2309.1716308594, -1212.6801757813, 1049.0234375};
	[8] = {1, 2217.1474609375, -1076.2725830078, 1050.484375};
	[9] = {2, 2237.5483398438, -1081.1091308594, 1049.0234375};
	[10] = {9, 2318.0712890625, -1026.2338867188, 1050.2109375};
	[11] = {4, 260.99948120117, 1284.8186035156, 1080.2578125};
	[12] = {5, 140.2495880127, 1366.5075683594, 1083.859375};
	[13] = {9, 82.978126525879, 1322.5451660156, 1083.8662109375};
	[14] = {15, -284.0530090332, 1471.0965576172, 1084.375};
	[15] = {4, -260.75534057617, 1456.6932373047, 1084.3671875};
	[16] = {8, -42.373157501221, 1405.9846191406, 1084.4296875};
	[17] = {0, -68.801879882813, 1351.6536865234, 1080.2109375};
	[18] = {0, 2333.0395507813, -1076.3621826172, 1049.0234375};
	[19] = {0, 271.884979, 306.631988, 999.148437};
	[20] = {3, 291.282989, 310.031982, 999.148437};
	[21] = {4, 302.180999, 300.72299, 999.148437};
	[22] = {5, 322.197998, 302.497985, 999.148437};
	[23] = {6, 346.870025, 309.259033, 999.148437};
	[24] = {3, 513.882507, -11.269994, 1001.565307};
	[25] = {2, 2454.717041, -1700.871582, 1013.515197};
	[26] = {1, 2527.654052, -1679.388305, 1015.515197};
	[27] = {5, 2350.339843, -1181.649902, 1027.0234375};
	[28] = {8, 2807.619873, -1171.899902, 1025.5234375};
	[29] = {5, 318.564971, 1118.209960, 1083.5234375};
	[30] = {12, 2324.419921, -1145.568359, 1050.5234375};
	[31] = {5, 1298.8719482422, -796.77032470703, 1083.6569824219};
	[32] = {0, -2170.5698242188, 358.4921875, 57.766414642334};
}
