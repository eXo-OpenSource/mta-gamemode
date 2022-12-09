-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ChristmasTruck.lua
-- *  PURPOSE:     christmas truck class
-- *
-- ****************************************************************************
ChristmasTruck = inherit(Object)

ChristmasTruck.spawnPos = {-1563.24, 2693.13, 56.18, 178.93}
ChristmasTruck.loadMarkerPos = Vector3(-1563.25, 2698.75, 55.83)
ChristmasTruck.attachCords = {
	Vector3(0.7, -0.2, 0.3), Vector3(-0.7, -0.2, 0.3), Vector3(0.7, -1.5, 0.3), Vector3(-0.7, -1.5, 0.3),
	Vector3(-0.7, -2.8, 0.3), Vector3(0.7, -2.8, 0.3), Vector3(-0.7, -4.1, 0.3), Vector3(0.7, -4.1, 0.3)
}
ChristmasTruck.presentSpawnCords = {
		{Vector3(-1563.719, 2705.254, 54.888), 125}, {Vector3(-1563.419, 2709.254, 54.888), 152},
		{Vector3(-1561.631, 2706.815, 54.888), 32}, {Vector3(-1561.446, 2708.502, 54.888), 145},
		{Vector3(-1561.347, 2710.412, 54.892), 100}, {Vector3(-1559.767, 2708.066, 54.892), 109},
		{Vector3(-1559.297, 2709.915, 54.892), 187}, {Vector3(-1558.239, 2708.272, 54.892), 257}
}
ChristmasTruck.blipPos = { -- for now only the positions from active factions
	[1] = Vector3(2764.90, -2383.23, 12.6625),
	[2] = Vector3(2765.54, -2508.25, 12.6625),
	[3] = Vector3(2744.84, -2421.651, 12.6625),
	[5] = Vector3(683.15, -1255.801, 12.5837),
	[7] = Vector3(2492.44, -1668.54, 12.36312),
	[8] = Vector3(2225.167, -1431.90, 22.9),
	[10] = Vector3(2782.35, -2019.28, 12.55),
}
ChristmasTruck.Time = 20*60*1000
ChristmasTruck.MaxPresents = 8


function ChristmasTruck:constructor(driver)
	self.m_Type = type
	self.m_Truck = TemporaryVehicle.create(455, unpack(ChristmasTruck.spawnPos))
	self.m_Truck:setData("ChristmasTruck:Truck", true, true)
	self.m_Truck:setColor(0, 0, 0)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setLocked(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(2000, true)
	self.m_Truck:setBulletArmorLevel(2)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck.m_DisableToggleHandbrake = true
	-- edit handling to match Barracks' handling
	self.m_Truck:setHandling("engineInertia", 25)
	self.m_Truck:setHandling("dragCoeff", 4)
	self.m_Truck:setHandling("brakeBias", 0.4)
	self.m_Truck:setHandling("engineAcceleration", 8)
	self.m_Truck:setHandling("brakeDeceleration", 4)
	
	

	self.m_StartTime = getTickCount()
	self.m_DestinationBlips = {}

	self.m_Presents = {}
	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()

	TollStation.openAll()
	FactionEvil:getSingleton():forceOpenLCNGates()

	local dest
	for i, faction in pairs(FactionManager:getSingleton():getAllFactions()) do
		if not faction:isRescueFaction() then
			local pos = ChristmasTruck.blipPos[faction:getId()]
			local color
			if faction:isEvilFaction() then
				color = BLIP_COLOR_CONSTANTS.Red
			elseif faction:isStateFaction() then
				color = BLIP_COLOR_CONSTANTS.Blue
			end

			self.m_DestinationBlips[faction:getId()] = Blip:new("Marker.png", pos.x, pos.y, {factionType = {"State", "Evil", duty = true}}, 9999, color)
			self.m_DestinationBlips[faction:getId()]:setDisplayText(("Weihnachtsbaum (%s)"):format(faction:getShortName()))
			self.m_DestinationBlips[faction:getId()]:setZ(pos.z)
		end
	end

	self.m_OnPresentCickFunc = bind(self.Event_onPresentClick,self)
	self.m_PresentCount = 0
	if table.size(ChristmasTruckManager:getSingleton().m_FactionPresents[self.m_StartFaction:getId()]) > ChristmasTruckManager.MaxPresents - ChristmasTruck.MaxPresents then
		self.m_PresentCount = table.size(ChristmasTruckManager:getSingleton().m_FactionPresents[self.m_StartFaction:getId()]) - ChristmasTruckManager.MaxPresents
	else
		self.m_PresentCount = ChristmasTruck.MaxPresents
	end


	self.m_Timer = setTimer(bind(self.timeUp, self), ChristmasTruck.Time, 1)
	self.m_Destroyed = false
	self.m_DestroyFunc = bind(self.Event_OnChristmasTruckDestroy,self)

	self.m_WaterCheckTimer = setTimer(bind(self.isChristmasTruckInWater, self), 10000, 0)
	self.m_IsSubmerged = false

	self.m_Event_loadPresent = bind(self.Event_DeloadPresent,self)
	self.m_Event_deloadPresent = bind(self.Event_LoadPresent,self)

	addRemoteEvents{"ChristmasTruckDeloadBox", "ChristmasTruckLoadBox"}
	addEventHandler("ChristmasTruckDeloadBox",root, self.m_Event_loadPresent)
	addEventHandler("ChristmasTruckLoadBox",root, self.m_Event_deloadPresent)
	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnChristmasTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnChristmasTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnChristmasTruckExit,self))
	addEventHandler("onElementDestroy",self.m_Truck, self.m_DestroyFunc, false)
	addEventHandler("onVehicleExplode",self.m_Truck, self.m_DestroyFunc)

	self:spawnPresents()
	self:createLoadMarker()
end

function ChristmasTruck:destructor()
	removeEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)
	removeEventHandler("ChristmasTruckDeloadBox",root, self.m_Event_loadPresent)
	removeEventHandler("ChristmasTruckLoadBox",root, self.m_Event_deloadPresent)
	ActionsCheck:getSingleton():endAction()
	StatisticsLogger:getSingleton():addActionLog("ChristmasTruck", "stop", self.m_StartPlayer, self.m_StartFaction, "faction")
	self.m_Truck:destroy()
	TollStation.closeAll()

	if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	if isTimer(self.m_Timer) then self.m_Timer:destroy() end

	for index, value in pairs(self.m_DestinationBlips) do
		if value then delete(value) end
	end

	for index, value in pairs(self.m_Presents) do
		if isElement(value) then
			if value:isAttached() and isElement(value:getAttachedTo()) and value:getAttachedTo():getType() == "player" then
				value:getAttachedTo():detachPlayerObject(value)
			end
			value.Present:destroy()
		 	value:destroy()
		end
	end
	killTimer(self.m_WaterCheckTimer)
	if isTimer(self.m_WaterNotificationTimer) then killTimer(self.m_WaterNotificationTimer) end
end

function ChristmasTruck:Event_OnChristmasTruckDestroy()
	if self and not self.m_Destroyed then
		self.m_Destroyed = true
		self:Event_OnChristmasTruckExit(self.m_Driver,0)
		PlayerManager:getSingleton():breakingNews("Der Weihnachtstruck wurde zerstört!")
		Discord:getSingleton():outputBreakingNews("Der Weihnachtstruck wurde zerstört!")
		delete(self)
	end
end

function ChristmasTruck:timeUp()
	delete(self)
	PlayerManager:getSingleton():breakingNews("Die Geschenke konnten nicht rechtzeitig unter den Baum gelegt werden! (Zeit abgelaufen)")
	Discord:getSingleton():outputBreakingNews("Die Geschenke konnten nicht rechtzeitig unter den Baum gelegt werden! (Zeit abgelaufen)")
end

function ChristmasTruck:Event_OnChristmasTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Weihnachtstruck können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function ChristmasTruck:Event_OnChristmasTruckEnter(player,seat)
	if seat == 0 and player:getFaction() then
		self.m_Driver = player
		player:triggerEvent("Countdown", math.floor((ChristmasTruck.Time-(getTickCount()-self.m_StartTime))/1000), "ChristmasTruck")
		player:triggerEvent("VehicleHealth")
	end
end

function ChristmasTruck:Event_OnChristmasTruckExit(player,seat)
	if seat == 0 and player and isElement(player) then
		player:triggerEvent("CountdownStop","ChristmasTruck")
		player:triggerEvent("VehicleHealthStop")
	end
end

function ChristmasTruck:spawnPresents()
	for i = 1, self.m_PresentCount, 1 do
		local pos = ChristmasTruck.presentSpawnCords[i]
		self.m_Presents[i] = self:createPresent(pos[1], pos[2])
		addEventHandler("onElementClicked", self.m_Presents[i], self.m_OnPresentCickFunc)
	end
end

function ChristmasTruck:createPresent(position, rot)
	local present = createObject(2070, position, 0, 0, rot)
	present:setCollisionsEnabled(false)
	present:setScale(0.6)

	local dummy = createObject(2912, position, 0, 0, rot)
	dummy:setAlpha(100)
	dummy.Present = present
	present:attach(dummy, 0, 0, 0.4)
	dummy:setData("ChristmasTruck:Present", true, true)

	return dummy
end

function ChristmasTruck:Event_onPresentClick(button, state, player)
	if button == "left" and state == "down" then
		if player.vehicle then return end
		if player:isDead() then return end
		if player:getFaction() and (player:getFaction():isStateFaction() or player:getFaction():isEvilFaction()) then
			if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
				player:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
				player:attachPlayerObject(source)
			else
				player:sendError(_("Du bist zu weit von Geschenk entfernt!", player))
			end
		else
			player:sendError(_("Nur Fraktionisten können Geschenke aufheben!",player))
		end
	end
end

function ChristmasTruck:createLoadMarker()
	self.m_LoadMarker = createMarker(ChristmasTruck.loadMarkerPos,"corona",2)
	addEventHandler("onMarkerHit", self.m_LoadMarker, bind(self.Event_onLoadMarkerHit, self))
end

function ChristmasTruck:Event_onLoadMarkerHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			local box = hitElement:getPlayerAttachedObject()
			if box then
				self:loadBoxOnChristmasTruck(hitElement,box)
			else
				hitElement:sendError(_("Du hast kein Geschenk dabei!",hitElement))
			end
		end
	end
end

function ChristmasTruck:loadBoxOnChristmasTruck(player,box)
	local presentsOnTruck = self:getAttachedPresents(self.m_Truck) + 1
	player:detachPlayerObject(box)
	box.Present:setScale(1)
	box:attach(self.m_Truck, ChristmasTruck.attachCords[presentsOnTruck])
	box:setCollisionsEnabled(false)
	removeEventHandler("onElementClicked", box, self.m_OnPresentCickFunc)

	if presentsOnTruck >= 8 then
		player:sendInfo(_("Alle Geschenke aufgeladen! Der Truck ist bereit!",player))
		self.m_Truck:setFrozen(false)
		self.m_Truck:setLocked(false)
		if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	else
		player:sendInfo(_("%d/%d Geschenke aufgeladen!", player, presentsOnTruck, 8))
	end
end


function ChristmasTruck:getAttachedPresents(element)
	local count = 0
	if getAttachedElements(element) then
		for index, ele in pairs(getAttachedElements(element)) do
			if ele:getModel() == 2912 and getElementData(ele, "ChristmasTruck:Present") then
				count = count + 1
			end
		end
	end
	return count
end

function ChristmasTruck:getRemainingPresentAmount()
	local count = 0
	for i,k in pairs(self.m_Presents) do
		if isElement(k) then
			count = count +1
		end
	end
	return count
end

function ChristmasTruck:isChristmasTruckInWater()
	if not self.m_IsSubmerged then
		if isElementInWater(self.m_Truck) then
			self:forcePresentsToDrop()
			self.m_WaterNotificationTimer = setTimer(
				function()
					PlayerManager:getSingleton():breakingNews("Neueste Quellen berichten, dass die Geschenke durch ein Unfall mit dem Transportfahrzeug im Wasser gelandet sind!")
				end
			, 180000, 1)
			self.m_IsSubmerged = true
		end
	end
end


function ChristmasTruck:forcePresentsToDrop()
	for key, box in pairs (getAttachedElements(self.m_Truck)) do
		if box.model == 2912 and box:getData("ChristmasTruck:Present")then
			box.Present:setScale(0.6)
			box:detach(self.m_Truck)
			nextframe(function() --to "prevent" it from spawning in another player / vehicle (added for RTS)
				box:setCollisionsEnabled(true)
			end)
			addEventHandler("onElementClicked", box, self.m_OnPresentCickFunc)
		end
	end
end

function ChristmasTruck:Event_LoadPresent(veh)
	if client:getFaction() then
		if veh == self.m_Truck or VEHICLE_BOX_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position,client.position) < 7 then
				if not client.vehicle then
					local box = client:getPlayerAttachedObject()
					if veh == self.m_Truck then
						self:loadBoxOnChristmasTruck(client,box)
						return
					end
					if self:getAttachedBoxes(veh) < VEHICLE_BOX_LOAD[veh.model]["count"] then
						if box then
							local count = self:getAttachedBoxes(veh)
							client:detachPlayerObject(box)
							box:attach(veh, VEHICLE_BOX_LOAD[veh.model][count+1])
							removeEventHandler("onElementClicked", box, self.m_OnPresentCickFunc)
						else
							client:sendError(_("Du hast keine Kiste dabei!",client))
						end
					else
						client:sendError(_("Das Fahrzeug ist bereits voll beladen!",client))
					end
				else
					client:sendError(_("Du darfst in keinem Fahrzeug sitzen!",client))
				end
			else
				client:sendError(_("Du bist zu weit vom Truck entfernt!",client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht beladen werden!",client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Kisten abladen!",client))
	end
end

function ChristmasTruck:Event_DeloadPresent(veh)
	if not veh then return end
	if client:getFaction() then
		if veh == self.m_Truck or VEHICLE_BOX_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client:getPlayerAttachedObject() then
					if not client.vehicle and not client:isDead() then
						for key, box in pairs (table.reverse(getAttachedElements(veh))) do
							if box.model == 2912 then
								box:detach(self.m_Truck)
								box.Present:setScale(0.6)
								client:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
								client:attachPlayerObject(box)
								addEventHandler("onElementClicked", box, self.m_OnPresentCickFunc)
								return
							end
						end
						client:sendError(_("Es befinden sich keine Geschenke auf dem Truck!",client))
						return
					else
						client:sendError(_("Du darfst in keinem Fahrzeug sitzen!",client))
					end
				else
					client:sendError(_("Du hast bereits ein Geschenk dabei!",client))
				end
			else
				client:sendError(_("Du bist zu weit vom Truck entfernt!",client))
			end
		else
			client:sendError(_("Von diesem Fahrzeug können keine Geschenke entladen werden!",client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Geschenke abladen!",client))
	end
end

function ChristmasTruck:onPresentDeliver(player, tree)
	local faction = FactionManager:getSingleton():getFromId(tree.FactionId)
	if isPedInVehicle(player) then
		player:sendInfo(_("Bitte steig aus um die Geschenke abzugeben!", player))
		return
	end
	if not faction then
		player:sendInfo(_("Nur Fraktionisten können Geschenke unter den Baum legen!", player))
		return
	end
	if player:getPlayerAttachedObject() and player:getPlayerAttachedObject():getData("ChristmasTruck:Present") then
		if self:getAttachedPresents(player) > 0 then
			local box = player:getPlayerAttachedObject()
			PlayerManager:getSingleton():breakingNews("Geschenk %d von %d wurde bei der/den %s unter den Weihnachtsbaum gelegt!", self.m_PresentCount-self:getRemainingPresentAmount()+1, self.m_PresentCount, faction:getShortName())
			player:sendInfo(_("Du hast ein Geschenk unter den Weihnachtsbaum gelegt!",player))
			player:detachPlayerObject(box)
			box.Present:destroy()
			box:destroy()
			
			if table.size(ChristmasTruckManager:getSingleton().m_FactionPresents[player:getFaction():getId()]) < ChristmasTruckManager.MaxPresents then
				local presentCount = table.size(ChristmasTruckManager:getSingleton().m_FactionPresents[player:getFaction():getId()])
				ChristmasTruckManager:getSingleton().m_FactionPresents[player:getFaction():getId()][presentCount + 1] = getRealTime().timestamp
			else
				player:sendError(_("Unter eurem Weihnachtsbaum ist kein Platz mehr für Geschenke", player))
			end
		end
	end

	if self:getRemainingPresentAmount() == 0 then
		delete(self)
	end
end