-- ****************************************************************************
-- *
-- *  PROJECT:    vRoleplay
-- *  FILE:       server/classes/Vehicle/ShopVehicleRob.lua
-- *  PURPOSE:    Shop vehicle rob class
-- *
-- ****************************************************************************
ShopVehicleRob = inherit(Object)

function ShopVehicleRob:constructor(robber, vehicle)
	self.m_Robber = robber
	self.m_Gang = self.m_Robber:getGroup()
	self.m_Vehicle = vehicle
	self.m_VehicleEstimated = false
	self.m_VehiclePos = vehicle.position
	self.m_VehicleRot = vehicle.rotation
	self.m_Shop = ShopManager.VehicleShopsMap[self.m_Vehicle:getData("ShopId")]
	self.m_VehicleIndex = #self.m_Shop.m_VehicleList[self.m_Vehicle:getModel()]
	self.m_StartTime = getRealTime().timestamp
	self.m_Timer = setTimer(bind(self.onTimeUp, self), SHOP_VEHICLE_ROB_MAX_TIME*1000, 1)
	self.m_VehicleShopPrice = self.m_Shop.m_VehicleList[self.m_Vehicle:getModel()][self.m_VehicleIndex].price

	setVehicleDamageProof(self.m_Vehicle, false)
	self.m_Vehicle:setData("Vehicle:Stolen", true, true)
	self.m_Shop.m_Ped:setDimension(PRIVATE_DIMENSION_SERVER)

	self:addMarkerAndBlips()
	self:startPickingLock(self.m_Robber)

	StatisticsLogger:getSingleton():addActionLog("ShopVehicle-Rob", "start", self.m_Robber, self.m_Gang, "group")
	PlayerManager:getSingleton():breakingNews("Autohaus %s meldet einen Überfall durch eine Straßengang!", self.m_Shop:getName())
	Discord:getSingleton():outputBreakingNews(string.format("Autohaus %s meldet einen Überfall durch eine Straßengang!", self.m_Shop:getName()))
	FactionState:getSingleton():sendWarning("Die Alarmanlage vom Autohaus %s meldet einen Überfall! Die Täterbeschreibung passt zu Mitgliedern der Gang %s", "Neuer Einsatz", false, serialiseVector(self.m_Vehicle), self.m_Shop:getName(), self.m_Gang:getName())

	self.m_onVehicleEnter = bind(self.onVehicleEnter, self)
	self.m_onVehicleExit = bind(self.onVehicleExit, self)
	addEventHandler("onVehicleEnter", self.m_Vehicle, self.m_onVehicleEnter)
	addEventHandler("onVehicleExit", self.m_Vehicle, self.m_onVehicleExit)
end

function ShopVehicleRob:destructor()
	self.m_Vehicle:setPosition(self.m_VehiclePos)
	self.m_Vehicle:setRotation(self.m_VehicleRot)
	setVehicleDamageProof(self.m_Vehicle, true)
	self.m_Vehicle.m_DisableToggleHandbrake = true
	self.m_Vehicle.m_DisableToggleEngine = true
	self.m_Vehicle:setLocked(true)
	self.m_Vehicle:setFrozen(true)
	self.m_Vehicle:setEngineState(false)
	self.m_Vehicle:fix()
	self.m_Vehicle:setData("Vehicle:Stolen", false, true)
	self.m_Vehicle:setData("Vehicle:LockIsPicked", false, true)

	removeEventHandler("onVehicleEnter", self.m_Vehicle, self.m_onVehicleEnter)
	removeEventHandler("onVehicleExit",self.m_Vehicle, self.m_onVehicleExit)

	StatisticsLogger:getSingleton():addActionLog("ShopVehicle-Rob", "stop", nil, self.m_Gang, "group")

	if isElement(self.m_StateMarker) then self.m_StateMarker:destroy() end
	if isElement(self.m_EvilMarker) then self.m_EvilMarker:destroy() end
	if isElement(self.m_MechanicClose) then self.m_MechanicClose:destroy() end
	if isElement(self.m_MechanicMedium) then self.m_MechanicMedium:destroy() end
	if isElement(self.m_MechanicFar) then self.m_MechanicFar:destroy() end
	if self.m_StateBlip then delete(self.m_StateBlip) end
	if self.m_EvilBlip then delete(self.m_EvilBlip) end
	if self.m_MechanicCloseBlip then delete(self.m_MechanicCloseBlip) end
	if self.m_MechanicMediumBlip then delete(self.m_MechanicMediumBlip) end
	if self.m_MechanicFarBlip then delete(self.m_MechanicFarBlip) end
	if isTimer(self.m_Timer) then self.m_Timer:destroy() end
	self.m_Gang:removePlayerMarkers()
	
	self.m_Shop.m_Ped:setDimension(0)

	SHOP_VEHICLE_ROB_IS_STARTABLE = true
	SHOP_VEHICLE_ROB_LAST_ROB =  getRealTime().timestamp
	self.m_Shop.m_LastRob = getRealTime().timestamp
end

function ShopVehicleRob:onTimeUp()
	delete(self)
end

function ShopVehicleRob:addMarkerAndBlips()
	local statePos = self:getNearestMarker(self.m_Vehicle.position, ROBABLE_SHOP_STATE_TARGETS)
	local _, _, evilPos = self:getNearestMarker(self.m_Vehicle.position, ROBABLE_VEHICLE_SHOP_EVIL_TARGETS)
	local mechnaicPos1, mechnaicPos2, mechnaicPos3 = self:getNearestMarker(evilPos, ROBABLE_VEHICLE_SHOP_MECHANIC_POSITION)

	self.m_Gang:attachPlayerMarkers()
	self.m_EvilBlip = Blip:new("Marker.png", evilPos.x, evilPos.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_EvilBlip:setDisplayText("Fahrzeug-Abgabepunkt")
	self.m_EvilBlip:setZ(evilPos.z)
	self.m_StateBlip = Blip:new("PoliceRob.png", statePos.x, statePos.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Yellow)
	self.m_StateBlip:setDisplayText("Fahrzeug-Abgabe (Staat)")
	self.m_StateBlip:setZ(statePos.z)

	self.m_MechanicCloseBlip = Blip:new("PayNSpray.png", mechnaicPos1.x, mechnaicPos1.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_MechanicCloseBlip:setDisplayText("Gutachter (nah)")
	self.m_MechanicCloseBlip:setZ(mechnaicPos1.z)
	self.m_MechanicMediumBlip = Blip:new("PayNSpray.png", mechnaicPos2.x, mechnaicPos2.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_MechanicMediumBlip:setDisplayText("Gutachter (mittel)")
	self.m_MechanicMediumBlip:setZ(mechnaicPos2.z)
	self.m_MechanicFarBlip = Blip:new("PayNSpray.png", mechnaicPos3.x, mechnaicPos3.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_MechanicFarBlip:setDisplayText("Gutachter (weit)")
	self.m_MechanicFarBlip:setZ(mechnaicPos3.z)

	self.m_MechanicClose = createMarker(mechnaicPos1, "cylinder", 4, 255, 0, 0, 100)
	self.m_MechanicMedium = createMarker(mechnaicPos2, "cylinder", 4, 255, 0, 0, 100)
	self.m_MechanicFar = createMarker(mechnaicPos3, "cylinder", 4, 255, 0, 0, 100)
	self.m_EvilMarker = createMarker(evilPos, "cylinder", 4, 255, 0, 0, 100)
	self.m_StateMarker = createMarker(statePos, "cylinder", 4, 0, 255, 0, 100)
	self.m_onEstimateMarkerHit = bind(self.onEstimateMarkerHit, self)
	self.m_onDeliveryMarkerHit = bind(self.onDeliveryMarkerHit, self)
	addEventHandler("onMarkerHit", self.m_MechanicClose, self.m_onEstimateMarkerHit)
	addEventHandler("onMarkerHit", self.m_MechanicMedium, self.m_onEstimateMarkerHit)
	addEventHandler("onMarkerHit", self.m_MechanicFar, self.m_onEstimateMarkerHit)
	addEventHandler("onMarkerHit", self.m_EvilMarker, self.m_onDeliveryMarkerHit)
	addEventHandler("onMarkerHit", self.m_StateMarker, self.m_onDeliveryMarkerHit)
end

function ShopVehicleRob:onVehicleEnter(player)
	player:triggerEvent("Countdown", math.floor(self.m_StartTime + SHOP_VEHICLE_ROB_MAX_TIME - getRealTime().timestamp), "Fahrzeugdiebstahl")
end

function ShopVehicleRob:onVehicleExit(player)
	player:triggerEvent("CountdownStop", "Fahrzeugdiebstahl")
end

function ShopVehicleRob:getNearestMarker(position, markerPositions)
	table.sort(markerPositions, function(a, b)
		return getDistanceBetweenPoints3D(a, position) < getDistanceBetweenPoints3D(b, position)
	end)
	return markerPositions[1], markerPositions[2], markerPositions[3]
end

function ShopVehicleRob:startPickingLock(player)
	if isTimer(self.m_LockPickingTimer) then return player:sendError(_"Jemand ist bereits dabei das Schloss zu knacken.") end
	local time = (self.m_Shop.m_VehicleList[self.m_Vehicle:getModel()][self.m_VehicleIndex].price / 2)
	
	self.m_LockPickingTimer = setTimer(bind(self.finishPickingLock, self, player), time, 1)
	player:setAnimation("bomber", "bom_plant_loop", -1, true, false, false, false, 250, true)
	setPedAnimationSpeed(player, "bom_plant_loop", .5)
	toggleAllControls(player, false)
	player:triggerEvent("ShopVehicleRob:openGUI", time/1000)
	player.shopVehicleRob = self
end

function ShopVehicleRob:finishPickingLock(player)
	player:setAnimation(nil)
	self.m_Vehicle.m_DisableToggleHandbrake = false
	self.m_Vehicle.m_DisableToggleEngine = false
	self.m_Vehicle:setLocked(false)
	self.m_Vehicle:setData("Vehicle:LockIsPicked", true, true)
	toggleAllControls(player, true)
	player.shopVehicleRob = nil
end

function ShopVehicleRob:stopPickingLock(player)
	if self.m_LockPickingTimer then
		self.m_LockPickingTimer:destroy()
	end

	player:setAnimation(nil)
	toggleAllControls(player, true)
	player.shopVehicleRob = nil
end

function ShopVehicleRob:onEstimateMarkerHit(hitElement, matchingDim)
	if hitElement.type == "player" then
		if hitElement.vehicle and hitElement.vehicle == self.m_Vehicle and hitElement.vehicleSeat == 0  then
			local freezeTime = 0
			hitElement:sendInfo(_"Der Preis des Fahrzeugs wird nun geschätzt.")
			self.m_Vehicle:setFrozen(true)
			self.m_Vehicle.m_DisableToggleHandbrake = true
			if source == self.m_MechanicClose then
				freezeTime = 10000
				self.m_VehicleEstimated = math.random(self.m_VehicleShopPrice*0.07, self.m_VehicleShopPrice*0.10)
			elseif source == self.m_MechanicMedium then
				freezeTime = 18000
				self.m_VehicleEstimated = math.random(self.m_VehicleShopPrice*0.10, self.m_VehicleShopPrice*0.13)
			elseif source == self.m_MechanicFar then
				freezeTime = 28000
				self.m_VehicleEstimated = math.random(self.m_VehicleShopPrice*0.13, self.m_VehicleShopPrice*0.15)
			end
			setTimer(function()
				self.m_Vehicle:setFrozen(false)
				self.m_Vehicle.m_DisableToggleHandbrake = false
			end, freezeTime, 1)
		end
	end
end

function ShopVehicleRob:onDeliveryMarkerHit(hitElement, matchingDim)
	if hitElement.type == "player" then
		if source == self.m_StateMarker then
			if hitElement.vehicle == self.m_Vehicle and hitElement.vehicleSeat == 0 then
				if hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
					for i, v in pairs(getVehicleOccupants(self.m_Vehicle)) do
						removePedFromVehicle(v)
					end

					ShopVehicleRobManager:getSingleton().m_BankAccountServer:transferMoney({hitElement, true}, 2500, "Wiederbeschaffungsprämie", "Gameplay", "ShopVehicleRob")
				elseif hitElement:getGroup() == self.m_Gang then
					return hitElement:sendError(_"Du kannst hier nicht abgeben!")
				else return end
			else return end
		elseif source == self.m_EvilMarker then
			if hitElement.vehicle == self.m_Vehicle and hitElement.vehicleSeat == 0 then
				if hitElement:getGroup() == self.m_Gang and not hitElement:isFactionDuty() then
					for i, v in pairs(getVehicleOccupants(self.m_Vehicle)) do
						removePedFromVehicle(v)
					end

					ShopVehicleRobManager:getSingleton().m_BankAccountServer:transferMoney(hitElement, self:calcPrice(), "Fahrzeugdiebstahl", "Gameplay", "ShopVehicleRob")
					self.m_Shop:decreaseVehicleStock(self.m_Vehicle:getModel(), self.m_VehicleIndex)
				elseif hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
					return hitElement:sendError(_"Du kannst hier nicht abgeben!")
				else return end
			else return end
		end
		delete(self)
	end
end

function ShopVehicleRob:calcPrice()
	local price = 0
	if self.m_Vehicle:getModel() == ShopVehicleRobManager:getSingleton().m_DemandedVehicle then	
		if self.m_VehicleEstimated then
			price = math.random(self.m_VehicleEstimated*1.05, self.m_VehicleEstimated*1.15)
		else
			price = math.random(self.m_VehicleShopPrice*0.05, self.m_VehicleShopPrice*0.08)
		end
	else
		if self.m_VehicleEstimated then
			price = math.random(self.m_VehicleEstimated, self.m_VehicleEstimated*1.05)
		else
			price = math.random(self.m_VehicleShopPrice*0.03, self.m_VehicleShopPrice*0.05)
		end
	end
	return price
end