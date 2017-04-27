-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicle/TollStation.lua
-- *  PURPOSE:     Toll Station Class
-- *
-- ****************************************************************************
TollStation = inherit(Object)

function TollStation:constructor(Name, BarrierPos, BarrierRot, PedPos, PedRot, type)
	self.m_Name = Name or "Unkown"
	self.m_Barrier = VehicleBarrier:new(BarrierPos, BarrierRot, 2.5, type, 1500)
	self.m_Barrier.onBarrierHit = bind(self.onBarrierHit, self)

	self.m_Ped = NPC:new(71, PedPos.x, PedPos.y, PedPos.z)
	self.m_Ped:setImmortal(true)
	self.m_Ped:giveWeapon(31, 999999999, true)
	self.m_Ped:setRotation(PedRot)
	self.m_Ped:setFrozen(true)
	self.m_RespawnPos = PedPos
	self.m_RespawnRot = PedRot
	addEventHandler("onPedWasted", self.m_Ped, bind(self.onPedWasted, self))
end

function TollStation:destructor()
end

function TollStation:checkRequirements(player)
	-- Step 1: Check for State Duty
		if player:getFaction() then
			local faction = player:getFaction()
			if faction:isStateFaction() or faction:isRescueFaction() then
				if player:isFactionDuty() then
					player:sendShortMessage(("Willkommen bei der Maut-Station %s! Da du Staats-Dienstlich unterwegs bist, darfst du kostenlos passieren! Gute Fahrt."):format(self.m_Name), ("Maut-Station: %s"):format(self.m_Name), {125, 0, 0})
					return true
				end
			end
		end

		if player:getInventory():getItemAmount("Mautpass") > 0 then
			player:sendShortMessage(("Willkommen bei der Maut-Station %s! Da du einen Mautpass besitzt, darfst du kostenlos passieren! Gute Fahrt."):format(self.m_Name), ("Maut-Station: %s"):format(self.m_Name), {125, 0, 0})
			return true
		end

	return false
end

function TollStation:getBarrier()
	return self.m_Barrier
end

function TollStation:onBarrierHit(player)
	if not self.m_Ped:isDead() then
		if player.vehicle and player:getOccupiedVehicleSeat() == 0 then

			local veh = player.vehicle
			for seat, occupant in pairs(veh:getOccupants()) do
				if occupant:getWantedLevel() > 0 then
					for i, faction in pairs(FactionState:getSingleton():getFactions()) do
						faction:sendShortMessage(("Ein Beamter der Maut-Station %s meldet die Sichtung des Flüchtigen %s!"):format(self.m_Name, occupant:getName()), 10000)
					end
				end
			end

			if player:getOccupiedVehicleSeat() == 0 then
				if self:checkRequirements(player) then -- Check for Toll Pass
					return true
				else
					if player.m_BuyTollFunc then
						unbindKey(player, TOLL_PAY_KEY, "down", player.m_BuyTollFunc)
						player.m_BuyTollFunc = nil
					end

					player:sendShortMessage(("Willkommen bei der Maut-Station %s! Drücke auf '%s' um ein Ticket zu kaufen!\nDu kannst dir aber auch an einem 24/7 einen Mautpass kaufen, dann fährst du unkompliziert und schnell durch die Maut-Stationen!"):format(self.m_Name, TOLL_PAY_KEY:upper()), ("Maut-Station: %s"):format(self.m_Name), {125, 0, 0})

					player.m_BuyTollFunc = bind(self.buyToll, self, player)
					bindKey(player, TOLL_PAY_KEY, "down", player.m_BuyTollFunc)
				end
			end
		end
	else
		player:sendError(_("Diese Maut-Stationen ist derzeit geschlossen!", player))
	end

	return false
end

function TollStation:buyToll(player)
	if isElement(player) then
		if (player:getPosition() - self.m_Barrier.m_Barrier:getPosition()).length <= 10 then
			if player:getMoney() >= TOLL_KEY_COSTS then
				player:takeMoney(TOLL_KEY_COSTS, "Mautkosten")
				self.m_Barrier:toggleBarrier(player, true)
				FactionManager:getSingleton():getFromId(1):giveMoney(TOLL_KEY_COSTS, "Mautstation")
				player:sendShortMessage(_("Vielen Dank. Wir wünschen dir eine gute Fahrt!", player), ("Maut-Station: %s"):format(self.m_Name), {125, 0, 0})
			else
				player:sendError(_("Du hast zuwenig Geld! (%s$)", player, TOLL_KEY_COSTS))
			end
		else
			player:sendError(_("Du bist zuweit entfernt!", player))
		end

		unbindKey(player, TOLL_PAY_KEY, "down", player.m_BuyTollFunc)
		player.m_BuyTollFunc = nil
	end
end

function TollStation:onPedWasted(_, killer)
	local killer = killer
	if killer then
		if killer:getType() == "vehicle" then
			killer = killer:getOccupant()
		end

		if killer:getType() == "player" then
			-- Send the News to the San News Company
			CompanyManager:getSingleton():getFromId(CompanyStaticId.SANNEWS):sendShortMessage(("Ein Beamter an der Maut-Station %s wurde erschossen! Die Station bleibt bis auf weiteres geschlossen."):format(self.m_Name), 10000)

			killer:reportCrime(Crime.Kill)
			outputDebug(("%s killed a Ped at %s"):format(killer:getName(), self.m_Name))

			setTimer(
				function()
					self.m_Ped:destroy()
					self.m_Ped = NPC:new(71, self.m_RespawnPos.x, self.m_RespawnPos.y, self.m_RespawnPos.z)
					self.m_Ped:setImmortal(true)
					self.m_Ped:setRotation(self.m_RespawnRot)
					self.m_Ped:giveWeapon(31, 999999999, true)
					self.m_Ped:setFrozen(true)
					addEventHandler("onPedWasted", self.m_Ped, bind(self.onPedWasted, self))
				end, TOLL_PED_RESPAWN_TIME, 1
			)
		end
	end
end

TollStation.Map = {}

function TollStation.initializeAll()
	for i, data in pairs(TOLL_STATIONS) do
		TollStation.Map[#TollStation.Map+1] = TollStation:new(data.Name, data.BarrierData.pos, data.BarrierData.rot, data.PedData.pos, data.PedData.rot, data.Type)
	end
end

function TollStation.openAll()
	for i, tollstation in pairs(TollStation.Map) do
		tollstation:getBarrier():open()
	end
end

function TollStation.closeAll()
	for i, tollstation in pairs(TollStation.Map) do
		tollstation:getBarrier():close()
	end
end
