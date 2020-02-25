-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/StateEvidenceTruck.lua
-- *  PURPOSE:     State Evidence Truck Class
-- *
-- ****************************************************************************

StateEvidenceTruck = inherit(Singleton)
StateEvidenceTruck.Time = 20*60*1000 -- in ms
StateEvidenceTruck.spawnPos = Vector3(1591.18, -1685.65, 6.02)
StateEvidenceTruck.spawnRot = Vector3(0, 0, 0)
StateEvidenceTruck.Destination = Vector3(135.33, 1964.97, 19)
StateEvidenceTruck.MoneyBagSpawns = { -- 10
	Vector3(1581.15, -1690.91, 5.61),Vector3(1582.36, -1691.19, 5.61),Vector3(1581.64, -1691.72, 5.61),Vector3(1581.30, -1692.48, 5.61),Vector3(1582.35, -1692.36, 5.61),
	Vector3(1583.17, -1691.73, 5.61),Vector3(1583.39, -1692.46, 5.61),Vector3(1582.48, -1692.85, 5.61),Vector3(1581.88, -1693.05, 5.61),Vector3(1583.71, -1693.12, 5.61),
}

function StateEvidenceTruck:constructor(driver, money)
	self.m_Truck = TemporaryVehicle.create(428, StateEvidenceTruck.spawnPos, StateEvidenceTruck.spawnRot)
	self.m_Truck:setData("State Evidence Truck", true, true)
    self.m_Truck:setColor(0, 50, 0, 0, 50, 0)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(1500, true)
	self.m_Truck:setBulletArmorLevel(2)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setInterior(0)
	self.m_Truck:setDimension(5)
	self.m_Truck:initObjectLoading()
	self.m_Timer = setTimer(bind(self.timeUp, self), StateEvidenceTruck.Time, 1)

	self.m_StartTime = getTickCount()
	self.m_DestinationBlips = {}
	self.m_DestinationMarkers = {}
	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()
	self.m_Money = money
	self.ms_MoneyPerBag = math.floor(EVIDENCETRUCK_MAX_LOAD/10) -- 10 bags
	self.m_MoneyBag = {}
	self.m_BankAccountServer = BankServer.get("action.evidence_trunk")

	self.m_Event_onBagClickFunc = bind(self.Event_onBagClick, self)
	self.m_DestroyFunc = bind(self.Event_OnTruckDestroy,self)

	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnTruckExit,self))
	addEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc, false)
	addEventHandler("onVehicleExplode",self.m_Truck,self.m_DestroyFunc)

	local dest = StateEvidenceTruck.Destination

	self.m_DestinationBlips["State"] = Blip:new("Marker.png", dest.x, dest.y, {factionType = "State", duty = true}, 9999, BLIP_COLOR_CONSTANTS.Red)
	self.m_DestinationBlips["State"]:setDisplayText("Geldtruck-Abgabepunkt")

	for i, faction in pairs(FactionEvil:getSingleton():getFactions()) do
		self:addDestinationMarker(faction:getId(), "evil", false)
	end
	self:addDestinationMarker(1, "state") -- State
	self:spawnMoneyBags()
	TollStation.openAll()
	FactionState:getSingleton():forceOpenAreaGates()
end

function StateEvidenceTruck:destructor()
	removeEventHandler("onElementDestroy",self.m_Truck, self.m_DestroyFunc)
	ActionsCheck:getSingleton():endAction()
	StatisticsLogger:getSingleton():addActionLog("Geld-Transport", "stop", self.m_StartPlayer, self.m_StartFaction, "faction")
	self.m_Truck:destroy()

	if isTimer(self.m_Timer) then self.m_Timer:destroy() end

	for index, value in pairs(self.m_DestinationMarkers) do
		if isElement(value) then value:destroy() end
	end

	for index, value in pairs(self.m_DestinationBlips) do
		if value then delete(value) end
	end

	for index, value in pairs(self.m_MoneyBag) do
		if isElement(value) then
			if value:isAttached() and isElement(value:getAttachedTo()) and value:getAttachedTo():getType() == "player" then
				value:getAttachedTo():detachPlayerObject(value)
			end
		 	value:destroy()
		end
	end

	TollStation.closeAll()
end

function StateEvidenceTruck:timeUp()
	PlayerManager:getSingleton():breakingNews("Der Geldtransport ist fehlgeschlagen! (Zeit abgelaufen)")
	FactionEvil:getSingleton():giveKarmaToOnlineMembers(-10, "Geldtransport verhindert!")
	delete(self)
end

function StateEvidenceTruck:spawnMoneyBags()
	local moneyLeft = self.m_Money
	local bagid = 1
	while (moneyLeft > 0 and bagid <= 10) do
		local position = StateEvidenceTruck.MoneyBagSpawns[bagid]
		self.m_MoneyBag[bagid] = createObject(1550, position, 0, 0, math.random(0,360))
		addEventHandler("onElementClicked", self.m_MoneyBag[bagid], self.m_Event_onBagClickFunc)
		local money = math.min(moneyLeft, self.ms_MoneyPerBag)
		self.m_MoneyBag[bagid].money = money
		self.m_MoneyBag[bagid]:setData("Money", money, true)
		self.m_MoneyBag[bagid]:setData("MoneyBag", true, true)
		self.m_MoneyBag[bagid]:setInterior(0)
		self.m_MoneyBag[bagid]:setDimension(5)

		bagid = bagid + 1
		moneyLeft = moneyLeft - money
	end
	self.m_BagAmount = bagid - 1
end

function StateEvidenceTruck:addDestinationMarker(factionId, type, isEvil)
	local markerId = #self.m_DestinationMarkers+1
	local color = factionColors[factionId]
	local destination = factionId == 1 and StateEvidenceTruck.Destination or factionWTDestination[factionId]
	self.m_DestinationMarkers[markerId] = createMarker(destination,"cylinder",8, color.r, color.g, color.b, 100)
	self.m_DestinationMarkers[markerId].type = type
	self.m_DestinationMarkers[markerId].factionId = factionId

	addEventHandler("onMarkerHit", self.m_DestinationMarkers[markerId], bind(self.Event_onDestinationMarkerHit, self))
end

function StateEvidenceTruck:getRemainingBagAmount()
	local count = 0
	for i,k in pairs(self.m_MoneyBag) do
		if isElement(k) then
			count = count +1
		end
	end
	return count
end

function StateEvidenceTruck:Event_onBagClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			if player:getFaction() and ((player:getFaction():isStateFaction() and player:isFactionDuty()) or player:getFaction():isEvilFaction()) then
				player:attachPlayerObject(source)
			else
				player:sendError(_("Nur Fraktionisten können den Geldsack aufheben!", player))
			end
		else
			player:sendError(_("Du bist zu weit von dem Geldsack entfernt!", player))
		end
	end
end

function StateEvidenceTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and matchingDimension then
		if hitElement.type == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if (hitElement.vehicle and #getAttachedElements(hitElement.vehicle) > 0 ) or hitElement:getPlayerAttachedObject() then
					if faction:isEvilFaction() and source.type == "evil" and (source.factionId == faction:getId()) then
						self:onDestinationMarkerHit(hitElement)
					elseif faction:isStateFaction() and source.type == "state" then
						self:onDestinationMarkerHit(hitElement)
					else
						hitElement:sendError(_("Du kannst hier nicht abgeben!",hitElement))
					end
				end
			end
		end
	end
end

function StateEvidenceTruck:onDestinationMarkerHit(hitElement)
	local faction = hitElement:getFaction()
	local bag = false

	if hitElement:getPlayerAttachedObject() and hitElement:getPlayerAttachedObject():getModel() == 1550 then
			--bags = getAttachedElements(hitElement)
			PlayerManager:getSingleton():breakingNews("%d von %d Geldsäcken wurden abgegeben!", self.m_BagAmount-self:getRemainingBagAmount()+1, self.m_BagAmount)
			hitElement:sendInfo(_("Du hast erfolgreich einen Geldsack abgegeben!",hitElement))
			bag = hitElement:getPlayerAttachedObject()
			hitElement:detachPlayerObject(bag)
	elseif hitElement:getOccupiedVehicle() then
		hitElement:sendInfo(_("Du musst die Geldsäcke per Hand abladen!", hitElement))
		return
	end

	self.m_BankAccountServer:transferMoney(faction, bag.money, "Geldsack (Geldtransport)", "Action", "EvidenceTruck")
	bag:destroy()
	if self:getRemainingBagAmount() == 0 then
		delete(self)
	end
end

function StateEvidenceTruck:Event_OnTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Geldtransporter können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function StateEvidenceTruck:Event_OnTruckDestroy()
	if self and not self.m_Destroyed then
		self.m_Destroyed = true
		self:Event_OnTruckExit(self.m_Driver,0)
		PlayerManager:getSingleton():breakingNews("Der Geldtransporter wurde zerstört!")
		Discord:getSingleton():outputBreakingNews("Der Geldtransporter wurde zerstört!")
		delete(self)
	end
end

function StateEvidenceTruck:Event_OnTruckEnter(player, seat)
	if seat == 0 and player:getFaction() then
		self.m_Driver = player
		player:triggerEvent("Countdown", math.floor((StateEvidenceTruck.Time-(getTickCount()-self.m_StartTime))/1000), "Geld-Transport")
		player:triggerEvent("VehicleHealth")
	end
end

function StateEvidenceTruck:Event_OnTruckExit(player, seat)
	if seat == 0 and player and isElement(player) then
		player:triggerEvent("CountdownStop", "Geld-Transport")
		player:triggerEvent("VehicleHealthStop")
	end
end
