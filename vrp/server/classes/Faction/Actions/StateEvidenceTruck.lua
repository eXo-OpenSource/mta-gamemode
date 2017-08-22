-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/StateEvidenceTruck.lua
-- *  PURPOSE:     State Evidence Truck Class
-- *
-- ****************************************************************************

StateEvidenceTruck = inherit(Singleton)
StateEvidenceTruck.LoadTime = 30*1000 -- in ms
StateEvidenceTruck.Time = 10*60*1000 -- in ms
StateEvidenceTruck.spawnPos = Vector3(1591.18, -1685.65, 6.02)
StateEvidenceTruck.spawnRot = Vector3(0, 0, 0)
StateEvidenceTruck.Destination = Vector3(119.08, 1902.07, 18.3)
StateEvidenceTruck.MoneyBagSpawns = {
	Vector3(1585.43, -1681.84, 14.39), Vector3(1585.46, -1682.38, 14.39),
	Vector3(1584.85, -1681.83, 14.39), Vector3(1584.91, -1682.33, 14.39),
}

function StateEvidenceTruck:constructor(driver, money)
	self.m_Truck = TemporaryVehicle.create(428, StateEvidenceTruck.spawnPos, StateEvidenceTruck.spawnRot)
	self.m_Truck:setData("State Evidence Truck", true, true)
    self.m_Truck:setColor(0, 50, 0, 0, 50, 0)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(1500, true)
	self.m_Truck:setBulletArmorLevel(2)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck.m_DisableToggleHandbrake = true

	self.m_StartTime = getTickCount()
	self.m_DestinationBlips = {}
	self.m_DestinationMarkers = {}
	self.m_StartPlayer = driver
	self.m_Money = money
	self.m_MoneyBag = {}

	self.m_Event_onBagClickFunc = bind(self.Event_onBagClick, self)

	local dest = StateEvidenceTruck.Destination

	self.m_DestinationBlips["State"] = Blip:new("Marker.png", dest.x, dest.y, {factionType = "State"}, 9999, BLIP_COLOR_CONSTANTS.Red)
	self.m_DestinationBlips["State"]:setDisplayText("Geldtruck-Abgabepunkt")

	for i, faction in pairs(FactionEvil:getSingleton():getFactions()) do
		self:addDestinationMarker(faction:getId(), "evil", false)
	end
	self:addDestinationMarker(1, "state") -- State

	self:spawnMoneyBags()
end

function StateEvidenceTruck:spawnMoneyBags()
	for i, position in pairs(StateEvidenceTruck.MoneyBagSpawns) do
		self.m_MoneyBag[i] = createObject(1550, position, 0, 0, math.random(0,360))
		addEventHandler("onElementClicked", self.m_MoneyBag[i], self.m_Event_onBagClickFunc)
		local money = math.floor(self.m_Money/#StateEvidenceTruck.MoneyBagSpawns)
		self.m_MoneyBag[i].money = money
		self.m_MoneyBag[i]:setData("Money", money, true)
		self.m_MoneyBag[i]:setData("MoneyBag", true, true)
	end
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
	local bags = {}
	local finish = false
	if isPedInVehicle(hitElement) and getPedOccupiedVehicle(hitElement) == self.m_Truck then
		bags = getAttachedElements(self.m_Truck)
		hitElement:sendInfo(_("Geld-Transporter erfolgreich abgegeben!",hitElement))
		self:Event_OnTruckExit(hitElement,0)
		if faction:isEvilFaction() then
			faction:getSingleton():giveKarmaToOnlineMembers(-10, "Geld-Transport gestohlen!")
			PlayerManager:getSingleton():breakingNews("Der Geldtransport wurde von der Fraktion %s gestohlen!", faction:getName())
		else
			FactionState:getSingleton():giveKarmaToOnlineMembers(10, "Geld-Transport abgegeben!")
			PlayerManager:getSingleton():breakingNews("Der Geld-Transporter wurde erfolgreich abgegeben!")
		end
		finish = true
	elseif hitElement:getPlayerAttachedObject() then
			bags = getAttachedElements(hitElement)
			PlayerManager:getSingleton():breakingNews("%d von %d Geldsäcke wurden abgegeben!", #StateEvidenceTruck.MoneyBagSpawns-self:getRemainingBagAmount()+1, #StateEvidenceTruck.MoneyBagSpawns)
			hitElement:sendInfo(_("Du hast erfolgreich eine Geldsack abgegeben!",hitElement))
			hitElement:detachPlayerObject(hitElement:getPlayerAttachedObject())
	elseif hitElement:getOccupiedVehicle() then
		hitElement:sendInfo(_("Du musst die Geldsäacke per Hand oder mit dem Geld-Transporter abladen!", hitElement))
		return
	end
	for key, value in pairs (bags) do
		if value:getModel() == 1550 then
			faction:giveMoney(value.money, "Geldsack")
			value:destroy()
		end
	end
	if self:getRemainingBagAmount() == 0 or finish == true then
		delete(self)
	end
end
