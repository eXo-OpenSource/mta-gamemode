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
	self.m_UsedEstimateMarker = {}
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
	PlayerManager:getSingleton():breakingNews("%s meldet einen Überfall durch eine Straßengang!", self.m_Shop:getName())
	Discord:getSingleton():outputBreakingNews(string.format("%s meldet einen Überfall durch eine Straßengang!", self.m_Shop:getName()))
	FactionState:getSingleton():sendWarning("Die Alarmanlage von %s meldet einen Überfall! Die Täterbeschreibung passt zu Mitgliedern der Gang %s", "Neuer Einsatz", false, serialiseVector(self.m_Vehicle:getPosition()), self.m_Shop:getName(), self.m_Gang:getName())

	self.m_onVehicleEnter = bind(self.Event_onVehicleEnter, self)
	self.m_onVehicleExit = bind(self.Event_onVehicleExit, self)
	self.m_ExplodeFunc = bind(self.Event_onVehicleExplode, self)
	addEventHandler("onVehicleEnter", self.m_Vehicle, self.m_onVehicleEnter)
	addEventHandler("onVehicleExit", self.m_Vehicle, self.m_onVehicleExit)
	addEventHandler("onVehicleExplode", self.m_Vehicle, self.m_ExplodeFunc)
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

	for i, v in pairs(getVehicleOccupants(self.m_Vehicle)) do
		removePedFromVehicle(v)
	end

	removeEventHandler("onVehicleEnter", self.m_Vehicle, self.m_onVehicleEnter)
	removeEventHandler("onVehicleExit", self.m_Vehicle, self.m_onVehicleExit)
	removeEventHandler("onVehicleExplode", self.m_Vehicle, self.m_ExplodeFunc)

	StatisticsLogger:getSingleton():addActionLog("ShopVehicle-Rob", "stop", nil, self.m_Gang, "group")

	if isElement(self.m_StateMarker) then self.m_StateMarker:destroy() end
	if isElement(self.m_EvilMarker) then self.m_EvilMarker:destroy() end
	if self.m_StateBlip then delete(self.m_StateBlip) end
	if self.m_EvilBlip then delete(self.m_EvilBlip) end
	if isTimer(self.m_Timer) then self.m_Timer:destroy() end
	self.m_Gang:removePlayerMarkers()
	
	self.m_Shop.m_Ped:setDimension(0)

	for i, ped in pairs(self.m_MechanicPeds) do
		ped:destroy()
	end

	for i, blip in pairs(self.m_MechanicBlip) do
		if blip then delete(blip) end
	end

	for i, marker in pairs(self.m_MechanicMarker) do
		if isElement(marker) then marker:destroy() end
	end

	SHOP_VEHICLE_ROB_IS_STARTABLE = true
	SHOP_VEHICLE_ROB_LAST_ROB =  getRealTime().timestamp
	self.m_Shop.m_LastRob = getRealTime().timestamp
end

function ShopVehicleRob:onTimeUp()
	PlayerManager:getSingleton():breakingNews("%s Überfall: Die Täter haben sich zu viel Zeit gelassen!", self.m_Shop:getName())
	delete(self)
end

function ShopVehicleRob:Event_onVehicleExplode()
	PlayerManager:getSingleton():breakingNews("%s Überfall: Das Fahrzeug wurde zerstört!", self.m_Shop:getName())
	self.m_Shop:decreaseVehicleStock(self.m_Vehicle:getModel(), self.m_VehicleIndex)
	delete(self)
end

function ShopVehicleRob:addMarkerAndBlips()
	local statePos = self:getNearestMarker(self.m_Vehicle.position, ROBABLE_SHOP_STATE_TARGETS)
	local evilPos = ROBABLE_VEHICLE_SHOP_EVIL_TARGETS[self.m_Shop.m_Id][math.random(1,3)]
	local mechanicPos = self:getRandomPos(ROBABLE_VEHICLE_SHOP_MECHANIC_POSITION, 3)

	self.m_Gang:attachPlayerMarkers()
	self.m_EvilBlip = Blip:new("Marker.png", evilPos.x, evilPos.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_EvilBlip:setDisplayText("Fahrzeug-Abgabepunkt")
	self.m_EvilBlip:setZ(evilPos.z)
	self.m_StateBlip = Blip:new("PoliceRob.png", statePos.x, statePos.y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Yellow)
	self.m_StateBlip:setDisplayText("Fahrzeug-Abgabe (Staat)")
	self.m_StateBlip:setZ(statePos.z)

	self.m_MechanicBlip = {}
	self.m_MechanicBlip[1] = Blip:new("PayNSpray.png", mechanicPos[1][1].x, mechanicPos[1][1].y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_MechanicBlip[1]:setDisplayText("Gutachter")
	self.m_MechanicBlip[1]:setZ(mechanicPos[1][1].z)
	self.m_MechanicBlip[2] = Blip:new("PayNSpray.png", mechanicPos[2][1].x, mechanicPos[2][1].y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_MechanicBlip[2]:setDisplayText("Gutachter")
	self.m_MechanicBlip[2]:setZ(mechanicPos[2][1].z)
	self.m_MechanicBlip[3] = Blip:new("PayNSpray.png", mechanicPos[3][1].x, mechanicPos[3][1].y, {factionType = "State", duty = true, group = self.m_Gang:getId()}, 2000, BLIP_COLOR_CONSTANTS.Red)
	self.m_MechanicBlip[3]:setDisplayText("Gutachter")
	self.m_MechanicBlip[3]:setZ(mechanicPos[3][1].z)

	self.m_MechanicMarker = {}
	self.m_MechanicMarker[1]= createMarker(mechanicPos[1][1], "cylinder", 4, 255, 0, 0, 100)
	self.m_MechanicMarker[2] = createMarker(mechanicPos[2][1], "cylinder", 4, 255, 0, 0, 100)
	self.m_MechanicMarker[3] = createMarker(mechanicPos[3][1], "cylinder", 4, 255, 0, 0, 100)
	self.m_EvilMarker = createMarker(evilPos, "cylinder", 4, 255, 0, 0, 100)
	self.m_StateMarker = createMarker(statePos, "cylinder", 4, 0, 255, 0, 100)
	self.m_onEstimateMarkerHit = bind(self.Event_onEstimateMarkerHit, self)
	self.m_onDeliveryMarkerHit = bind(self.Event_onDeliveryMarkerHit, self)
	addEventHandler("onMarkerHit", self.m_MechanicMarker[1], self.m_onEstimateMarkerHit)
	addEventHandler("onMarkerHit", self.m_MechanicMarker[2], self.m_onEstimateMarkerHit)
	addEventHandler("onMarkerHit", self.m_MechanicMarker[3], self.m_onEstimateMarkerHit)
	addEventHandler("onMarkerHit", self.m_EvilMarker, self.m_onDeliveryMarkerHit)
	addEventHandler("onMarkerHit", self.m_StateMarker, self.m_onDeliveryMarkerHit)

	self.m_MechanicPeds = {}
	self.m_MechanicPeds[1] = createPed(mechanicPos[1][2][1], mechanicPos[1][2][2], mechanicPos[1][2][3])
	self.m_MechanicPeds[2] = createPed(mechanicPos[2][2][1], mechanicPos[2][2][2], mechanicPos[2][2][3])
	self.m_MechanicPeds[3] = createPed(mechanicPos[3][2][1], mechanicPos[3][2][2], mechanicPos[3][2][3])
	for i, ped in ipairs(self.m_MechanicPeds) do
		ped:setFrozen(true)
		ped:setData("NPC:Immortal", true, true)
		addEventHandler("onElementClicked", ped, bind(self.onEstimatePedClick, self))
		ped.marker = self.m_MechanicMarker[i]
	end
end

function ShopVehicleRob:Event_onVehicleEnter(player, seat)
	if seat == 0 and player and isElement(player) then
		player:triggerEvent("Countdown", math.floor(self.m_StartTime + SHOP_VEHICLE_ROB_MAX_TIME - getRealTime().timestamp), "Fahrzeugdiebstahl")
	end
end

function ShopVehicleRob:Event_onVehicleExit(player, seat)
	if seat == 0 and player and isElement(player) then
		player:triggerEvent("CountdownStop", "Fahrzeugdiebstahl")

		if isElementWithinMarker(source, self.m_StateMarker) then
			if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
				ShopVehicleRobManager:getSingleton().m_BankAccountServer:transferMoney({player, true}, 2500, "Wiederbeschaffungsprämie", "Gameplay", "ShopVehicleRob")
				PlayerManager:getSingleton():breakingNews("%s Überfall: Das Fahrzeug wurde sichergestellt!", self.m_Shop:getName())
			elseif player:getGroup() == self.m_Gang then
				return player:sendError(_("Du kannst hier nicht abgeben!", player))
			else return end

		elseif isElementWithinMarker(source, self.m_EvilMarker) then
			if player:getGroup() == self.m_Gang and not player:isFactionDuty() then
				ShopVehicleRobManager:getSingleton().m_BankAccountServer:transferMoney(player, self:calcPrice(), "Fahrzeugdiebstahl", "Gameplay", "ShopVehicleRob")
				PlayerManager:getSingleton():breakingNews("%s Überfall: Die Täter sind mit dem Fahrzeug entkommen!", self.m_Shop:getName())
				self.m_Shop:decreaseVehicleStock(self.m_Vehicle:getModel(), self.m_VehicleIndex)
			elseif player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
				return player:sendError(_("Du kannst hier nicht abgeben!", player))
			else return end

		else return end
		delete(self)
	end
end

function ShopVehicleRob:getNearestMarker(position, markerPositions)
	table.sort(markerPositions, function(a, b)
		return getDistanceBetweenPoints3D(a, position) < getDistanceBetweenPoints3D(b, position)
	end)
	return markerPositions[1], markerPositions[2], markerPositions[3]
end

function ShopVehicleRob:getRandomPos(tbl, number)
	local temp = {}
	local i = 0
	repeat
		pos = Randomizer:getRandomTableValue(tbl)
		if not table.find(temp, pos) then
			i = i + 1
			table.insert(temp, pos)
		end
	until
		i == number
	return temp
end

function ShopVehicleRob:startPickingLock(player)
	if isTimer(self.m_LockPickingTimer) then return player:sendError(_("Jemand ist bereits dabei das Schloss zu knacken.", player)) end
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

function ShopVehicleRob:Event_onEstimateMarkerHit(hitElement, matchingDim)
	if hitElement.type == "player" then
		if hitElement.vehicle and hitElement.vehicle == self.m_Vehicle and hitElement.vehicleSeat == 0  then
			if not self.m_UsedEstimateMarker[source] then
				hitElement:sendInfo(_("Klicke auf den NPC, um das Fahrzeug schätzen zu lassen.", hitElement))
			else
				hitElement:sendWarning(_("Du hast das Fahrzeug hier bereits schätzen lassen.", hitElement))
			end
		end
	end
end

function ShopVehicleRob:Event_onDeliveryMarkerHit(hitElement, matchingDim)
	if hitElement.type == "player" then
		if hitElement.vehicle == self.m_Vehicle and hitElement.vehicleSeat == 0 then
			hitElement:sendInfo(_("Steige aus, um das Fahrzeug abzugeben.", hitElement))
		end
	end
end

function ShopVehicleRob:calcPrice()
	local price = 0
	if self.m_Vehicle:getModel() == ShopVehicleRobManager:getSingleton().m_DemandedVehicle then	
		if self.m_VehicleEstimated then
			price = math.random(self.m_VehicleEstimated*1.05, self.m_VehicleEstimated*1.17)
		else
			price = math.random(self.m_VehicleShopPrice*0.05, self.m_VehicleShopPrice*0.08)
		end
	else
		if self.m_VehicleEstimated then
			price = math.random(self.m_VehicleEstimated, self.m_VehicleEstimated*1.05)
		else
			price = math.random(self.m_VehicleShopPrice*0.01, self.m_VehicleShopPrice*0.03)
		end
	end
	return price
end

function ShopVehicleRob:onEstimatePedClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player.position, source.position) < 12 then
			if isElementWithinMarker(player, source.marker) then
				if player.vehicle and player.vehicle == self.m_Vehicle and player.vehicleSeat == 0  then
					if not self.m_UsedEstimateMarker[source.marker] then

						local freezeTime = 0
						player:sendInfo(_("Der Wert des Fahrzeugs wird nun geschätzt.", player))
						self.m_Vehicle:setFrozen(true)
						self.m_Vehicle.m_DisableToggleHandbrake = true
						self.m_UsedEstimateMarker[source.marker] = true
						if isElementWithinMarker(player, self.m_MechanicMarker[1]) then
							freezeTime = 12000
							self.m_VehicleEstimated = math.random(self.m_VehicleShopPrice*0.05, self.m_VehicleShopPrice*0.07)
						elseif isElementWithinMarker(player, self.m_MechanicMarker[2]) then
							freezeTime = 18000
							self.m_VehicleEstimated = math.random(self.m_VehicleShopPrice*0.06, self.m_VehicleShopPrice*0.09)
						elseif isElementWithinMarker(player, self.m_MechanicMarker[3]) then
							freezeTime = 28000
							self.m_VehicleEstimated = math.random(self.m_VehicleShopPrice*0.04, self.m_VehicleShopPrice*0.1)
						end
						setTimer(function()
							self.m_Vehicle:setFrozen(false)
							self.m_Vehicle.m_DisableToggleHandbrake = false
							player:sendInfo(_("Der Wert des Fahrzeugs wurde auf %s$ geschätzt.", player, self.m_VehicleEstimated))
						end, freezeTime, 1)
					else
						player:sendError(_("Du hast das Fahrzeug hier bereits schätzen lassen.", player))
					end
				end
			else
				player:sendError(_("Fahre zuerst in den Marker.", player))
			end
		end
	end
end