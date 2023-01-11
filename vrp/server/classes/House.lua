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
local PICKUP_SOLD = 1272
local PICKUP_FOR_SALE = 1273
local PICKUP_SET_FOR_SALE = 1875
function House:constructor(id, position, interiorID, keys, owner, price, lockStatus, rentPrice, elements, money, skyscraperId, buyPrice, saleInfo, bIsRob)
	if owner == 0 then
		owner = false
	end
	if skyscraperId == 0 then
		skyscraperId = false
	end
	if saleInfo then
		saleInfo = fromJSON(saleInfo)
	else
	  	saleInfo = {["Price"] = 0, ["ShowInTownhall"] = false}
	end

	self.hasRobbedHouse = {}
	self.m_CurrentRobber = false
	self.m_LastRobbed = 0
	self.m_PlayersInterior = {}
	self.m_Price = price
	self.m_BuyPrice = buyPrice
	self.m_RentPrice = rentPrice
	self.m_LockStatus = true
	self.m_Pos = position
	self.m_Keys = fromJSON(keys)
	self.m_InteriorID = interiorID
	self.m_Owner = owner
	self.m_Id = id
	self.m_SkyscraperId = skyscraperId
	self.m_Elements = fromJSON(elements or "")
	self.m_Money = money or 0
	self.m_IsRob = bIsRob
	self.m_IsInSkyscraper = skyscraperId
	self.m_Garage = {}
	self.m_ForSale = false
	self.m_SalePrice = 0
	self.m_ShowSaleInTownhall = false
	self.m_IsLockable = true
	self.m_BankAccountServer = BankServer.get("action.house_rob")
	self.m_BankAccountServer2 = BankServer.get("server.house")

	self.m_BankAccount = BankAccount.loadByOwner(self.m_Id, BankAccountTypes.House)
	if not self.m_BankAccount then
		self.m_BankAccount = BankAccount.create(BankAccountTypes.House, self.m_Id)
		self.m_BankAccountServer2:transferMoney(self.m_BankAccount, self.m_Money, "Migration", "House", "Migration")
		self.m_Money = 0
		self.m_BankAccount:save()
	end

	self:refreshInteriorMarker()

	--self.m_ColShape = createColSphere(position, 1)

	if owner == false then
		self.m_Keys = {}
	else
		self.m_Keys = table.setIndexToInteger(self.m_Keys)
	end

	if saleInfo["Price"] > 0 and owner then
		self:setForSale(true, saleInfo["Price"], saleInfo["ShowInTownhall"])
	end

	--addEventHandler ("onPlayerJoin", root, bind(self.checkContractMonthly, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerFade, self))
	addEventHandler("onPlayerWasted", root, bind(self.onPlayerFade, self))
	--addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.onColShapeLeave, self))

	self:updatePickup()
end

function House:updatePickup()
	if not self.m_IsInSkyscraper then
		if self.m_Pickup then
			local pickupId = ((self.m_Owner == 0 or self.m_Owner == false) and PICKUP_FOR_SALE or ((self.m_Owner > 0 and self.m_ForSale) and PICKUP_SET_FOR_SALE) or PICKUP_SOLD)
			setPickupType(self.m_Pickup, 3, pickupId)
		else
			local pickupId = ((self.m_Owner == 0 or self.m_Owner == false) and PICKUP_FOR_SALE or ((self.m_Owner > 0 and self.m_ForSale) and PICKUP_SET_FOR_SALE) or PICKUP_SOLD)
			self.m_Pickup = createPickup(self.m_Pos, 3, pickupId, 10, math.huge)
			self.m_Pickup.m_PickupType = "House" --only used for fire message creation
			addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
		end
	end
end

function House:createGarage(id, garageId, posX, posY, posZ, rotX, rotY, rotZ)
	local count = #self.m_Garage + 1
	self.m_Garage[count] = HouseGarage:new(id, self.m_Id, garageId, posX, posY, posZ, rotX, rotY, rotZ)
	return self.m_Garage[count]
end

function House:getOwner()
	return self.m_Owner
end

function House:setOwner(ownerId)
	if ownerId and tonumber(ownerId) then
		self.m_Owner = tonumber(ownerId)
	end
end

function House:getPosition()
	return self.m_Pos
end

function House:setPosition(position)
	if position and position.x then
		self.m_Pos = position
		self:updatePickup()
	end
end

function House:toggleLockState( player )
	if not self:isLockable() then
		return player:sendError(_("Das Haus steht zum Verkauf und kan deshalb nicht auf oder abgeschlossen werden!", player))
	end

	self.m_LockStatus = not self.m_LockStatus
	local info = "aufgeschlossen"
	if self.m_LockStatus then
		info = "abgeschlossen"
	end
	player:sendInfo("Das Haus wurde "..info.."!")
	self:showGUI(player)
end

function House:showGUI(player)
	local tenants = {}
	local pickup = self.m_Pickup
	for playerId, timestamp in pairs(self.m_Keys) do
		tenants[playerId] = Account.getNameFromId(playerId)
	end
	if self.m_IsInSkyscraper then
		pickup = SkyscraperManager.Map[self.m_SkyscraperId].m_Pickup
	end
	if player:getId() == self.m_Owner then
		player:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, false, self.m_LockStatus, tenants, self.m_BankAccount:getMoney(), true, self.m_Id, pickup, #self.m_Garage ~= 0 and "Ja" or "Nein", self.m_SalePrice)
	else
		player:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, self:isValidRob(player), self.m_LockStatus, tenants, false, self:isValidToEnter(player) and true or false, self.m_Id, pickup, #self.m_Garage ~= 0 and "Ja" or "Nein", self.m_SalePrice)
	end
end

function House:breakHouse(player)
	if getRealTime().timestamp >= self.m_LastRobbed + ROB_DELAY then
		if not HouseManager:getSingleton():isCharacterAllowedToRob(player) then
			player:sendWarning(_("Du hast vor kurzem schon ein Haus ausgeraubt!", player))
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
					self.m_BankAccountServer:transferMoney(unit, loot, "Haus-Überfall", "Action", "HouseRob")
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
		hitElement.lastHousePickup = source
		hitElement:triggerEvent("onTryEnterExit", source, "Haus")
	end
end

function House:isValidRob(player)
	if self.m_Keys[player:getId()] or self.m_Owner == player:getId() or not player:getGroup() --[[ or not self.m_Owner]] then
		return false
	end
	return true
end

function House:isPlayerNearby(player)
	if isElement(player) then
		if player:getInterior() == 0 and getDistanceBetweenPoints3D(self.m_Pos, player.position) < 10 then
			return true
		elseif player:getInterior() ~= 0 and getDistanceBetweenPoints3D(self.m_HouseMarker.position, player.position) < 10 then
			return true
		end
	end
end

function House:isCopNearby(player)
	for i, pplayer in pairs(getElementsByType("player")) do
		if pplayer ~= player then
			if pplayer:isFactionDuty() and pplayer:getFaction() and pplayer:getFaction():isStateFaction() == true then
				if getDistanceBetweenPoints3D(player.position, pplayer.position) < 5 then
					return true
				end
			end
		end
	end
	return false
end

function House:isValidToEnter(player)
	return self.m_Keys[player:getId()] or player:getId() == self.m_Owner
end

function House:rentHouse(player)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if not self.m_Keys[player:getId()] then
		if not self.m_Owner or self.m_Owner == 0 then
			player:sendError(_("Einmieten fehlgeschlagen - dieses Haus hat keinen Eigentümer!", player))
			return
		end
		if self.m_RentPrice <= 0 then
			player:sendError(_("Einmieten fehlgeschlagen - Der Eigentümer erlaubt kein einmieten!", player))
			return
		end

		if player:getId() ~= self.m_Owner then
			self.m_Keys[player:getId()] = getRealTime().timestamp
			player:sendSuccess(_("Du wurdest erfolgreich eingemietet", player))
			if #self.m_Garage > 0 then
				for i, garage in pairs(self.m_Garage) do
					player:triggerEvent("addGarageBlip", garage.m_Id, garage.m_GaragePosition.x, garage.m_GaragePosition.y)
				end
			end
			player:triggerEvent("addHouseBlip", self.m_Id, self.m_Pos.x, self.m_Pos.y)
			self:showGUI(player)
		else
			player:sendError(_("Du kannst dich nicht in dein eigenes Haus einmieten!", player))
		end
	else
		player:sendError(_("Du bist bereits in diesem Haus eingemietet!", player))
	end
end

function House:unrentHouse(player, noDistanceCheck)
	if not self:isPlayerNearby(player) and not noDistanceCheck then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if self.m_Keys[player:getId()] then
		self.m_Keys[player:getId()] = nil
		if player and isElement(player) then
			player:sendSuccess(_("Du hast deinen Mietvertrag gekündigt!", player))
			player:triggerEvent("removeHouseBlip", self.m_Id)
			for i, garage in pairs(self.m_Garage) do
				player:triggerEvent("removeGarageBlip", garage.m_Id)
			end
	
			if not noDistanceCheck then
				self:showGUI(player)
			end

			if self.m_PlayersInterior[player] then
				self:leaveHouse(player)
			end
		end
	else
		player:sendError(_("Du bist in diesem Haus nicht eingemietet!", player))
	end
end

function House:setRent(player, rent)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if player:getId() == self.m_Owner then
		self.m_RentPrice = rent
		if rent > 0 then
			player:sendInfo(_("Du hast die Miete auf %d$ gesetzt!", player, rent))
			self:sendTenantsMessage(_("%s hat die Miete für sein Haus auf %d$ gesetzt!", player, player:getName(), rent))
		else
			player:sendInfo(_("Nun kann sich keiner mehr in deinem Haus einmieten!", player, rent))
			self:sendTenantsMessage(_("%s hat das einmieten für sein Haus deaktiviert!", player, player:getName()))
		end
		self:showGUI(player)
	end
end

function House:getRent()
	return self.m_RentPrice
end

function House:deposit(player, amount)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	amount = tonumber(amount)
	if player:getId() == self.m_Owner then
		if player:getMoney() >= amount then
			player:transferMoney(self.m_BankAccount, amount, "Hauskasse", "House", "Deposit")
			self:showGUI(player)
		else
			player:sendError(_("Du hast nicht genug Geld dabei!", player))
		end
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:withdraw(player, amount)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	amount = tonumber(amount)
	if player:getId() == self.m_Owner then
		if self.m_BankAccount:getMoney() >= amount then
			self.m_BankAccount:transferMoney(player, amount, "Hauskasse", "House", "Withdraw")
			self:showGUI(player)
		else
			player:sendError(_("In der Hauskasse ist nicht genug Geld!", player))
		end
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:removeTenant(player, id)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if player:getId() == self.m_Owner then
		if self.m_Keys[id] then
			self.m_Keys[id] = nil
			local name = Account.getNameFromId(id)
			player:sendSuccess(_("Du hast den Mietvertrag mit %s gekündigt!", player, name))
			if getPlayerFromName(name) then
				local target = getPlayerFromName(name)
				target:sendSuccess(_("%s hat den Mietvertrag mit dir gekündigt!", target, player:getName()))
				target:triggerEvent("removeHouseBlip", self.m_Id)
				for i, garage in pairs(self.m_Garage) do
					target:triggerEvent("removeGarageBlip", garage.m_Id)
				end
			end
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

function House:sendTenantsMessage(msg)
	for targetId, timestamp in pairs(self.m_Keys) do
		if targetId and targetId > 0 then
			local target, isOffline = DatabasePlayer.get(targetId)
			if target then
				if isOffline then
					target:addOfflineMessage(msg, 1)

					target.m_DoNotSave = true
					delete(target)
				else
					target:sendInfo(msg)
				end
			end
		end
	end
end

function House:save()
	self.m_BankAccount:save()
	local houseID = self.m_Owner or 0
	local pos = self.m_Pos
	local saleInfo = {["Price"] = self.m_SalePrice, ["ShowInTownhall"] = self.m_ShowSaleInTownhall or false}
	if not self.m_Keys then self.m_Keys = {} end
	if not self.m_Elements then self.m_Elements = {} end
	return sql:queryExec("UPDATE ??_houses SET x = ?, y = ?, z = ?, interiorID = ?, `keys` = ?, owner = ?, price = ?, buyPrice = ?, lockStatus = ?, rentPrice = ?, elements = ?, money = ?, skyscraperID = ?, salePrice = ?  WHERE id = ?;", sql:getPrefix(),
		pos.x, pos.y, pos.z, self.m_InteriorID, toJSON(self.m_Keys), houseID, self.m_Price, self.m_BuyPrice, self.m_LockStatus and 1 or 0, self.m_RentPrice, toJSON(self.m_Elements), self.m_Money, not self.m_SkyscraperId and 0 or self.m_SkyscraperId, 
		toJSON(saleInfo) , self.m_Id)
end

function House:sellHouse(player)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if player:getId() == self.m_Owner then
		-- destroy blip
		player:triggerEvent("removeHouseBlip", self.m_Id)
		for i, garage in pairs(self.m_Garage) do
			player:triggerEvent("removeGarageBlip", garage.m_Id)
		end

		local price = math.floor(self.m_BuyPrice*0.75)
		player:sendInfo(_("Du hast dein Haus für %d$ verkauft!", player, price))
		self.m_BankAccountServer2:transferMoney({player, true}, price, "Haus-Verkauf", "House", "Sell")
		self.m_BankAccount:transferMoney(player, self.m_BankAccount:getMoney(), "Hauskasse", "House", "Sell")

		self:clearHouse()
		self:showGUI(player)
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:sellToPlayer(seller, buyer)
	local seller = tonumber(seller)
	if seller and seller == self.m_Owner then
		local sellerPlayer, isSellerOffline = DatabasePlayer.get(seller)
		local housePrice = math.floor(self.m_BuyPrice*0.75)
		local salePrice = self.m_SalePrice

		self.m_BankAccountServer2:transferMoney({"player", seller, true}, housePrice, "Haus-Verkauf", "House", "Sell")
		self.m_BankAccount:transferMoney({"player", seller, true}, self.m_BankAccount:getMoney(), "Hauskasse", "House", "Sell")
		buyer:transferBankMoney({"player", seller, true}, salePrice, "Haus-Kauf (Kaufpreis)", "House", "SellToPlayer")
		self:clearHouse()
		self:buyHouse(buyer)

		StatisticsLogger:getSingleton():addHouse( seller, "sellToPlayer", self.m_Id)
		StatisticsLogger:getSingleton():addHouse( buyer, "buyFromPlayer", self.m_Id)

		if not isSellerOffline then
			sellerPlayer:triggerEvent("removeHouseBlip", self.m_Id)
			for i, garage in pairs(self.m_Garage) do
				sellerPlayer:triggerEvent("removeGarageBlip", garage.m_Id)
			end
			sellerPlayer:sendInfo(_("Du hast dein Haus für %s (%s Grundpreis & %s Verkaufspreis) an %s verkauft!", sellerPlayer, toMoneyString(salePrice + housePrice), toMoneyString(housePrice), toMoneyString(salePrice)))
		else
			sellerPlayer:addOfflineMessage(("Du hast dein Haus für %s (%s Grundpreis & %s Verkaufspreis) an %s verkauft!"):format(toMoneyString(salePrice + housePrice), toMoneyString(housePrice), toMoneyString(salePrice), buyer:getName()), 1)
		end
	else
		return false
	end
end

function House:clearHouse()
	self.m_Owner = false
	self.m_Keys = {}
	self.m_Money = 0
	self.m_BuyPrice = 0
	self:setForSale(false, false)
	if self.m_BankAccount:getMoney() > 0 then
		self.m_BankAccount:transferMoney(self.m_BankAccountServer2, self.m_BankAccount:getMoney(), "Hausräumung", "House", "Cleared")
	end
	self:updatePickup()
	if self.m_IsInSkyscraper then
		SkyscraperManager.Map[self.m_SkyscraperId]:updatePickup()
	end
	self:save()
end

function House:onPickupHit(hitElement)
	if hitElement:getType() == "player" and (hitElement:getDimension() == source:getDimension()) then
		if hitElement.vehicle then return end
		hitElement.visitingHouse = self.m_Id
		hitElement.lastHousePickup = source
		hitElement:triggerEvent("onTryEnterExit", source, "Haus")
	end
end

function House:enterHouseTry(player)
	if not self.m_Owner or (self.m_Keys[player:getId()] or player:getId() == self.m_Owner or self.m_CurrentRobber == player) or not self.m_LockStatus then
		if not player:isInGangwar() then
			self:enterHouse(player)
		else 
			player:sendError(_("Du darfst dieses Haus nicht betreten (Gangwar) !", player))
		end
	else
		player:sendError(_("Du darfst dieses Haus nicht betreten!", player))
	end
end

function House:enterHouse(player)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	local isRobberEntering = false

	if self.m_RobGroup then
		if player:getGroup() == self.m_RobGroup and player:getGroup().m_CurrentRobbing == self and self:isValidRob(player) and not self.hasRobbedHouse[player:getId()] then
			isRobberEntering = true
		end
	end

	local int, x, y, z = unpack(HOUSE_INTERIOR_TABLE[self.m_InteriorID])
	if isRobberEntering  then
		player:meChat(true, "betritt das Haus an der kaputten Tür vorbei!")
		if player.m_LastRobHouse then
			if player.m_LastRobHouse ~= self then
				player:triggerEvent("onClientStartHouseRob", int, self, {x,y,z})
				player.m_LastRobHouse = self
				self.hasRobbedHouse[player:getId()] = true
			end
		else
			player:triggerEvent("onClientStartHouseRob", int, self, {x,y,z})
			player.m_LastRobHouse = self
			self.hasRobbedHouse[player:getId()] = true
		end
	else
		player:meChat(true, "öffnet die Tür und betritt das Haus!")
	end

	player:setPosition(x, y, z)
	setElementDimension(player, self.m_Id)
	setElementInterior(player,int)
	player.m_CurrentHouse = self
	self.m_PlayersInterior[player] = true

	return true
end

function House:ringDoorBell(player)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if player.m_HouseDoorBellCooldown then return end
	local playersOnRing = {}
	for pInside in pairs(self.m_PlayersInterior) do 
		if isElement(pInside) then
			pInside:playSound("files/audio/door_bell.wav")
			pInside:sendInfo(_("Es klingelt an der Haustür!", player))
			playersOnRing[pInside] = pInside.position
		end
	end
	player:playSound("files/audio/door_bell.wav")
	player:meChat(true, "klingelt an der Haustür!")
	player.m_HouseDoorBellCooldown = true
	local timeForResponse = EVENT_HALLOWEEN and math.random(15000, 25000) or 5000
	local playerId = player:getId()
	if EVENT_HALLOWEEN then 
		Halloween:getSingleton():registerTrickOrTreat(playerId, self.m_Id, timeForResponse)
	end

	setTimer(function(player)
		if EVENT_HALLOWEEN then 
			Halloween:getSingleton():finishTrickOrTreat(playerId, self.m_Id)		
		elseif isElement(player) then
			if self:isPlayerNearby(player) then
				local pCount = table.size(self.m_PlayersInterior)
				if pCount > 0 then --check if there are players inside
					local playerMoved = false
					for player, pos in pairs(playersOnRing) do -- check positions between ring and now
						if isElement(player) and not self.m_PlayersInterior[player] then -- if the player is still  online, but not in the int
							playerMoved = nil
							break
						elseif isElement(player) and self.m_PlayersInterior[player] then -- if the player is still in the int
							if getDistanceBetweenPoints3D(pos, player.position) > 5 then --check for big movement
								playerMoved = true
								break
							end
						end
					end
					if playerMoved == true then --output sound activity
						player:sendShortMessage(_("Du hörst Geräusche im Haus!", player))
					elseif playerMoved == false then --just pretend there arent any players inside
						player:sendShortMessage(_("Es scheint niemand zu Hause zu sein.", player))
					end --do not output anything if playerMoved = nil (this means a player left the house and is probably standing outside)
				else
					player:sendShortMessage(_("Es scheint niemand zu Hause zu sein.", player))
				end
			end	
			player.m_HouseDoorBellCooldown = false		
		end
	end, timeForResponse, 1, player)
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
	local isRobberLeaving = false
	if self.m_RobGroup then
		if player:getGroup() == self.m_RobGroup then
			isRobberLeaving = true
		end
	end
	if isRobberLeaving then
		player:meChat(true, "verlässt das Haus!")
		player:triggerEvent("onClientEndHouseRob")
	else
		player:meChat(true, "öffnet die Tür und verlässt das Haus!")
	end
	self:removePlayerFromList(player)
	player:setPosition(self.m_Pos)
	setElementInterior(player, 0)
	setElementDimension(player, 0)
	player.m_CurrentHouse = false
	if self.m_CurrentRobber == player then
		player:triggerEvent("CountdownStop", "Haus-Raub")
	end
end

function House:tryRob( player )
	local gRob = GroupHouseRob:getSingleton()
	local bContinue = gRob:startNewRob( self, player)
	if bContinue then
		if self.m_LockStatus then
			self.m_LockStatus = false
			player:meChat(true, "holt zu einem Kick aus und tritt gegen die Tür!")
			player:districtChat("Der Klang von aufbrechenden Holz ertönt durch die Gegend!")
			self.m_RobGroup = player:getGroup()
			self.m_RobGroup.m_CurrentRobbing = self
			self.m_RobGroup.m_RobReported = false
		end
	end
end

function House:giveRobItem( player )
	if player then
		local group = player:getGroup()
		if group and self.m_RobGroup then
			if group == self.m_RobGroup then
				local item = GroupHouseRob:getSingleton():getRandomItem()
				player:meChat(true, "entdeckt etwas und versucht es einzustecken. (("..item.."))")
				player:getInventory():giveItem("Diebesgut",1)
			end
		end
	end
end

function House:tryToCatchRobbers( player )
	if player then
		local group = player:getGroup()
		if group and self.m_RobGroup then
			if group == self.m_RobGroup then
				local item = GroupHouseRob:getSingleton():getRandomItem()
				local isFaceConcealed = player:getData("isFaceConcealed")
				local wantedChance = math.random(1,10)
				if isFaceConcealed then
					wantedChance = math.random(1,20)
				end
				if wantedChance <= 5 and not group.m_RobReported then
					local pickup
					if self.m_IsInSkyscraper then
						pickup = SkyscraperManager.Map[self.m_SkyscraperId].m_Pickup
					else
						pickup = self.m_Pickup
					end

					group.m_RobReported = true
					FactionState:getSingleton():sendWarning("Hauseinbruch gemeldet - die Täterbeschreibung bisher passt auf Mitglieder der Gruppe %s!", "Neuer Einsatz", false, serialiseVector(pickup:getPosition()), group:getName())
				end
			end
		end
	end
end

function House:breakDoor(player)
	if not self:isCopNearby(player) then return player:sendError(_("Du brauchst einen Partner um die Tür aufzubrechen!", player)) end
	
	if self.m_LockStatus then
		self.m_LockStatus = false
		player:meChat(true, _("nimmt anlauf und bricht die Tür auf.", player))
	else
		player:sendError(_("Die Tür ist bereits auf.", player))
	end
end

function House:onPlayerFade()
	self:removePlayerFromList(source)
end

function House:buyHouse(player)
	if not self:isPlayerNearby(player) then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if HouseManager:getSingleton():getPlayerHouse(player) then
		player:sendWarning(_("Du hast bereits ein Haus!", player))
		return
	end

	if (self.m_Owner or 0) > 0 then
		player:sendError(_("Dieses Haus hat schon einen Besitzer!", player))
		return
	end

	if player:getBankMoney() >= self.m_Price then
		player:giveAchievement(74)
		if self.m_Price >= 900000 then
			player:giveAchievement(69)
		end
		player:giveAchievement(34)

		player:transferBankMoney(self.m_BankAccountServer2, self.m_Price, "Haus-Kauf (Grundpreis)", "House", "Buy")
		self.m_BuyPrice = self.m_Price
		self.m_Owner = player:getId()
		self:updatePickup()
		if self.m_IsInSkyscraper then
			SkyscraperManager.Map[self.m_SkyscraperId]:updatePickup()
		end
		player:sendSuccess(_("Du hast das Haus erfolgreich gekauft!", player))
		self:save()
		-- create blip
		if #self.m_Garage > 0 then
			for i, garage in pairs(self.m_Garage) do
				player:triggerEvent("addGarageBlip", garage.m_Id, garage.m_GaragePosition.x, garage.m_GaragePosition.y)
			end
		end
		player:triggerEvent("addHouseBlip", self.m_Id, self.m_Pos.x, self.m_Pos.y)
		self:showGUI(player)
	else
		player:sendError(_("Du hast nicht genügend Geld!", player))
	end
end

function House:refreshInteriorMarker()
	if not HOUSE_INTERIOR_TABLE[self.m_InteriorID] then
		outputDebugString(("Error: Invalid InteriorId (%d) for House Id: %d"):format(self.m_InteriorID, self.m_Id))
		delete(self)
		return
	end
	if self.m_HouseMarker and isElement(self.m_HouseMarker) then self.m_HouseMarker:destroy() end
	local int, ix, iy, iz  = unpack(HOUSE_INTERIOR_TABLE[self.m_InteriorID])
	self.m_HouseMarker = createMarker(ix, iy, iz-0.8, "cylinder", 1.2, 255, 255, 255, 125)
	ElementInfo:new(self.m_HouseMarker, "Ausgang", 1.2, "Walking", true)
	self.m_HouseMarker:setDimension(self.m_Id)
	self.m_HouseMarker:setInterior(int)
	addEventHandler("onMarkerHit", self.m_HouseMarker, bind(self.onMarkerHit, self))
end

function House:setForSale(state, price, showInTownhall)
	if state == true then
		self.m_ForSale = true
		self.m_SalePrice = tonumber(price)
		self.m_ShowSaleInTownhall = showInTownhall or false
		self.m_IsLockable = false

		if self.m_LockStatus == true then self.m_LockStatus = false end
	else
		self.m_ForSale = false
		self.m_SalePrice = 0
		self.m_ShowSaleInTownhall = false
		self.m_IsLockable = true
	end
	self:updatePickup()
end

function House:isForSale()
	return self.m_ForSale
end

function House:getSalePrice()
	return self.m_SalePrice
end

function House:isLockable()
	return self.m_IsLockable
end

function House:getGarageCount()
	return table.size(self.m_Garage)
end