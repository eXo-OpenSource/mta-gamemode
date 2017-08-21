-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Houses/House.lua
-- *  PURPOSE:     Serverside house class
-- *
-- ****************************************************************************
House = inherit(Object)

local ROB_DELAY = 3600
local ROB_NEEDED_TIME = 1000*60*4
local ARROW_PICKUP = 1318
local ARROW_FOR_SALE = 1273
function House:constructor(id, position, interiorID, keys, owner, price, lockStatus, rentPrice, elements, money, bIsRob)
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
	self.m_IsRob = bIsRob

	self:refreshInteriorMarker()

	self.m_HasGTAInterior = false
	if not self.m_HasGTAInterior then
		self.m_IndoorFurniture = IndoorFurnitureCollection:new(self, {

		})
		--self.m_OutdoorFurniture = FurnitureCollection:new()
	end

	--self.m_ColShape = createColSphere(position, 1)

	if owner == false then
		self.m_Keys = {}
	else
		self.m_Keys = table.setIndexToInteger(self.m_Keys)
	end

	--addEventHandler ("onPlayerJoin", root, bind(self.checkContractMonthly, self))
	addEventHandler("onPlayerQuit", root, bind(self.onPlayerFade, self))
	addEventHandler("onPlayerWasted", root, bind(self.onPlayerFade, self))
	--addEventHandler("onColShapeLeave", self.m_ColShape, bind(self.onColShapeLeave, self))

	self:updatePickup()
end

function House:updatePickup()
	if 	self.m_Pickup then self.m_Pickup:destroy() end
	self.m_Pickup = createPickup(self.m_Pos, 3, ((self.m_Owner == 0 or self.m_Owner == false) and ARROW_FOR_SALE or ARROW_PICKUP), 10, math.huge)
	addEventHandler("onPickupHit", self.m_Pickup, bind(self.onPickupHit, self))
end

function House:getOwner()
	return self.m_Owner
end

function House:toggleLockState( player )
	self.m_LockStatus = not self.m_LockStatus
	local info = "aufgeschlossen"
	if self.m_LockStatus then
		info = "abgeschlossen"
	end
	player:sendInfo("Das Haus wurde "..info.."!")
	self:showGUI(player)
end

function House:showGUI(player)

	local bIsGang = false
	if player:getGroup() then
		if player:getGroup():getType() == "Gang" then
			bIsGang = true
		end
	end
	if player:getId() == self.m_Owner then
		local tenants = {}
		for playerId, timestamp in pairs(self.m_Keys) do
			tenants[playerId] = Account.getNameFromId(playerId)
		end
		player:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, self:isValidRob(player), self.m_LockStatus, tenants, self.m_Money, false)
	else
		player:triggerEvent("showHouseMenu", Account.getNameFromId(self.m_Owner), self.m_Price, self.m_RentPrice, self:isValidRob(player), self.m_LockStatus, false, false, bIsGang)
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

--[[function House:onColShapeLeave(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension and self.m_Id == hitElement.visitingHouse then
		hitElement:triggerEvent("hideHouseMenu")
	end
end]]

function House:isValidToEnter(player)
	return self.m_Keys[player:getId()] or player:getId() == self.m_Owner
end

function House:rentHouse(player)
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
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
			player:triggerEvent("addHouseBlip", self.m_Id, self.m_Pos.x, self.m_Pos.y)
		else
			player:sendError(_("Du kannst dich nicht in dein eigenes Haus einmieten!", player))
		end
	else
		player:sendError(_("Du bist bereits in diesem Haus eingemietet!", player))
	end
end

function House:unrentHouse(player, noDistanceCheck)
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 and not noDistanceCheck then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if self.m_Keys[player:getId()] then
		self.m_Keys[player:getId()] = nil
		if player and isElement(player) then
			player:sendSuccess(_("Du hast deinen Mietvertrag gekündigt!", player))
			player:triggerEvent("removeHouseBlip", self.m_Id)

			if self.m_PlayersInterior[player] then
				self:leaveHouse(player)
			end
		end
	else
		player:sendError(_("Du bist in diesem Haus nicht eingemietet!", player))
	end
end

function House:setRent(player, rent)
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if player:getId() == self.m_Owner then
		self.m_RentPrice = rent
		if rent > 0 then
			player:sendInfo(_("Du hast die Miete auf %d$ gesetzt!", player, rent))
			self:sendTenantsMessage(_("%s hat die Miete für sein Haus auf %d$ gesetzt!", player, player:getName(), rent))
		else
			player:sendInfo(_("Nun kann sich keiner mehr in deinem Haus einmieten!", player, rent))
			self:sendTenantsMessage(_("%s hat das einmieten für sein Haus deaktiviert!", player, player:getName()))
		end
	end
end

function House:getRent()
	return self.m_RentPrice
end

function House:deposit(player, amount)
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
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
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
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
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if player:getId() == self.m_Owner then
		if self.m_Keys[id] then
			self.m_Keys[id] = nil
			local name = Account.getNameFromId(id)
			player:sendSuccess(_("Du hast den Mietvertrag mit %s gekündigt!", player, name))
			if getPlayerFromName(name) then
				local target = getPlayerFromName(name)
				target:sendSuccess(_("%s hat den Mietvertrag mit dir gekündigt!", target, player:getName()))
				target:triggerEvent("removeHouseBlip", self.m_Id)
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

		self:clearHouse()
	else
		player:sendError(_("Das ist nicht dein Haus!", player))
	end
end

function House:clearHouse(player)
	self.m_Owner = 0
	self.m_Keys = {}
	self:updatePickup()
	self:save()
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
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	local isRobberEntering = false

	if self.m_RobGroup then
		if player:getGroup() == self.m_RobGroup and player:getGroup().m_CurrentRobbing == self then
			isRobberEntering = true
		end
	end

	local int, x, y, z = unpack(HOUSE_INTERIOR_TABLE[self.m_InteriorID])
	if isRobberEntering  then
		player:meChat(true, "betritt das Haus an der kaputten Tür vorbei!")
		if player.m_LastRobHouse then
			if player.m_LastRobHouse ~= self then
				player:triggerEvent("onClientStartHouseRob", int, self, {x,y,z})
				player.m_HasAlreadyHouseWanteds  = false
				player.m_LastRobHouse = self
			end
		else
			player:triggerEvent("onClientStartHouseRob", int, self, {x,y,z})
			player.m_HasAlreadyHouseWanteds  = false
			player.m_LastRobHouse = self
		end
	else
		player:meChat(true, "öffnet die Tür und betritt das Haus!")
	end

	if not self.m_HasGTAInterior then
		self.m_IndoorFurniture:increment()
		player:triggerEvent("setFurnitureEnabled", false)
		nextframe(function()
			player:setPosition(x, y, z)
			setElementDimension(player, self.m_Id)
			setElementInterior(player,int)
			player.m_CurrentHouse = self
			self.m_PlayersInterior[player] = true
		end)
	else
		player:setPosition(x, y, z)
		setElementDimension(player, self.m_Id)
		setElementInterior(player,int)
		player.m_CurrentHouse = self
		self.m_PlayersInterior[player] = true
	end
	return true
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
	if not self.m_HasGTAInterior then
		self.m_IndoorFurniture:decrement()
		player:triggerEvent("setFurnitureEnabled", true)
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
				if wantedChance <= 5 and not player.m_HasAlreadyHouseWanteds and not group.m_RobReported then
					player.m_HasAlreadyHouseWanteds = true
					player:setWanteds(player:getWanteds() + 3)
					group.m_RobReported = true
					player:sendWarning(_("Ein Nachbar rief die Polizei an, beeil dich!", player))
					FactionState:getSingleton():sendWarning("Hauseinbruch gemeldet - die Täterbeschreibung bisher passt auf %s!", "neuer Einsatz", false, serialiseVector(self.m_Pickup:getPosition()), player.name)
				end
			end
		end
	end
end

function House:onPlayerFade()
	self:removePlayerFromList(source)
end

function House:buyHouse(player)
	if getDistanceBetweenPoints3D(self.m_Pos, player.position) >= 10 then player:sendError(_("Du bist zu weit entfernt!", player)) return end
	if HouseManager:getSingleton():getPlayerHouse(player) then
		player:sendWarning(_("Du hast bereits ein Haus!", player))
		return
	end

	if (self.m_Owner or 0) > 0 then
		player:sendError(_("Dieses Haus hat schon einen Besitzer!", player))
		return
	end

	if player:getMoney() >= self.m_Price then
		player:giveAchievement(74)
		if self.m_Price >= 900000 then
			player:giveAchievement(69)
		end
		player:giveAchievement(34)

		player:takeMoney(self.m_Price, "Haus-Kauf")
		self.m_Owner = player:getId()
		self:updatePickup()
		player:sendSuccess(_("Du hast das Haus erfolgreich gekauft!", player))
		self:save()
		-- create blip
		player:triggerEvent("addHouseBlip", self.m_Id, self.m_Pos.x, self.m_Pos.y)
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
	self.m_HouseMarker:setDimension(self.m_Id)
	self.m_HouseMarker:setInterior(int)
	addEventHandler("onMarkerHit", self.m_HouseMarker, bind(self.onMarkerHit, self))
end

function House:createInsideFurniture(item, model, position, rotation)
	if not self.m_HasGTAInterior then
		self.m_IndoorFurniture:addByData(item, model, position, rotation, self.m_Id, HOUSE_INTERIOR_TABLE[self.m_InteriorID][1], true)
	end
end

function House:removeInsideFurniture(object)
	if not self.m_HasGTAInterior then
		self.m_IndoorFurniture:removeByObject(object)
	end
end
