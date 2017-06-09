-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeaponTruck = inherit(Object)
WeaponTruck.Time = 20*60*1000 -- in ms
WeaponTruck.spawnPos = {
	["evil"] = {-1869.58, 1430.02, 7.62, 224},
	["state"] = {120.23, 1899.40, 18.97, 0}
}
WeaponTruck.loadMarkerPos = {
	["evil"] = Vector3(-1873.56, 1434.15, 7.18),
	["state"] = Vector3(120.26, 1894.21, 18.42)
}
WeaponTruck.attachCords = {
	Vector3(0.7, -0.1, 0.1), Vector3(-0.7, -0.1, 0.1), Vector3(0.7, -1.4, 0.1), Vector3(-0.7, -1.4, 0.1),
	Vector3(-0.7, -2.7, 0.1), Vector3(0.7, -2.7, 0.1), Vector3(-0.7, -4, 0.1), Vector3(0.7, -4, 0.1)
}
WeaponTruck.boxSpawnCords = {
	["evil"] = {
		Vector3(-1875.75, 1416, 6.2), Vector3(-1875.75, 1416, 6.9),
		Vector3(-1873.74, 1415, 6.2), Vector3(-1873.74, 1415, 6.9),
		Vector3(-1875.27, 1414, 6.2), Vector3(-1875.27, 1414, 6.9),
		Vector3(-1873.11, 1413, 6.2), Vector3(-1873.11, 1413, 6.9)
				},
	["state"] = {
		Vector3(124.81, 1894.03, 17.5), Vector3(124.81, 1894.03, 18.2),
		Vector3(123.61, 1897.85, 17.5), Vector3(123.61, 1897.85, 18.2),
		Vector3(125.19, 1896.54, 17.5), Vector3(125.19, 1896.54, 18.2),
		Vector3(125.37, 1892.65, 17.5), Vector3(125.37, 1892.65, 18.2)
				}
}

function WeaponTruck:constructor(driver, weaponTable, totalAmount, type)
	self.m_Type = type
	self.m_Truck = TemporaryVehicle.create(455, unpack(WeaponTruck.spawnPos[type]))
	self.m_Truck:setData("WeaponTruck", true, true)
    self.m_Truck:setColor(0, 0, 0)
	self.m_Truck:setFrozen(true)
    self.m_Truck:setLocked(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(4000, true)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck.m_DisableToggleHandbrake = true

	self.m_StartTime = getTickCount()
	self.m_DestinationBlips = {}
	self.m_DestinationMarkers = {}

	self.m_Boxes = {}
	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()

	TollStation.openAll()

	if self.m_Type == "evil" then
		self.m_AmountPerBox = WEAPONTRUCK_MAX_LOAD/6
		self.m_StartFaction:giveKarmaToOnlineMembers(-5, "Waffentruck gestartet!")
		self:addDestinationMarker(self.m_StartFaction:getId(), "evil", true, true)
	elseif self.m_Type == "state" then
		self.m_AmountPerBox = WEAPONTRUCK_MAX_LOAD_STATE/6
		FactionState:getSingleton():giveKarmaToOnlineMembers(5, "Staats-Waffentruck gestartet!")
		for i, faction in pairs(FactionEvil:getSingleton():getFactions()) do
			self:addDestinationMarker(faction:getId(), "evil", false, false)
		end
	end

	self.m_BoxesCount = 8


	self.m_WeaponLoad = weaponTable
	self.m_Event_onBoxClickFunc =bind(self.Event_onBoxClick,self)

	self.m_Timer = setTimer(bind(self.timeUp, self), WeaponTruck.Time, 1)
	self.m_Destroyed = false
	self.m_DestroyFunc = bind(self.Event_OnWeaponTruckDestroy,self)



	addRemoteEvents{"weaponTruckDeloadBox", "weaponTruckLoadBox"}

	addEventHandler("weaponTruckDeloadBox",root, bind(self.Event_DeloadBox,self))
	addEventHandler("weaponTruckLoadBox",root, bind(self.Event_LoadBox,self))


	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnWeaponTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnWeaponTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnWeaponTruckExit,self))
	addEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)
	addEventHandler("onVehicleExplode",self.m_Truck,self.m_DestroyFunc)

	self:spawnBoxes()
	self:createLoadMarker()
	self:addDestinationMarker(1, "state", true) -- State

end

function WeaponTruck:destructor()
	removeEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)
	ActionsCheck:getSingleton():endAction()
	StatisticsLogger:getSingleton():addActionLog(WEAPONTRUCK_NAME[self.m_Type], "stop", self.m_StartPlayer, self.m_StartFaction, "faction")
	self.m_Truck:destroy()
	TollStation.closeAll()

	if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	if isTimer(self.m_Timer) then self.m_Timer:destroy() end

	for index, value in pairs(self.m_DestinationMarkers) do
		if isElement(value) then value:destroy() end
	end

	for index, value in pairs(self.m_DestinationBlips) do
		if value then delete(value) end
	end

	for index, value in pairs(self.m_Boxes) do
		if isElement(value) then
			if value:isAttached() and isElement(value:getAttachedTo()) and value:getAttachedTo():getType() == "player" then
				value:getAttachedTo():detachPlayerObject(value)
			end
		 	value:destroy() 
		end
	end
end


function WeaponTruck:timeUp()
	PlayerManager:getSingleton():breakingNews("Der %s ist fehlgeschlagen! (Zeit abgelaufen)", WEAPONTRUCK_NAME[self.m_Type])
	if self.m_Type == "evil" then
		FactionState:getSingleton():giveKarmaToOnlineMembers(10, "Waffentruck verhindert!")
	elseif self.m_Type == "state" then
		FactionEvil:getSingleton():giveKarmaToOnlineMembers(-10, "Staats-Waffentruck verhindert!")
	end

	self:delete()
end

-- Marker methodes/events
function WeaponTruck:createLoadMarker()
	self.m_LoadMarker = createMarker(WeaponTruck.loadMarkerPos[self.m_Type],"corona",2)
	addEventHandler("onMarkerHit", self.m_LoadMarker, bind(self.Event_onLoadMarkerHit, self))
end



function WeaponTruck:Event_onLoadMarkerHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			local box = hitElement:getPlayerAttachedObject()
			if box then
				hitElement:detachPlayerObject(box)
				self:loadBoxOnWeaponTruck(hitElement,box)
			else
				hitElement:sendError(_("Du hast keine Kiste dabei!",hitElement))
			end
		end
	end
end

--Box methodes
function WeaponTruck:spawnBoxes()
	for i=1,self.m_BoxesCount do
		if WeaponTruck.boxSpawnCords[self.m_Type][i] then
			self:spawnBox(i, WeaponTruck.boxSpawnCords[self.m_Type][i])
		end
	end

	for i, box in pairs(self.m_Boxes) do
		if isElement(box) then
			if box.sum == 0 then
				box:destroy()
				self.m_BoxesCount = self.m_BoxesCount -1
			end
		end
	end
end

function WeaponTruck:getRemainingBoxAmount()
	local count = 0
	for i,k in pairs(self.m_Boxes) do
		if isElement(k) then
			count = count +1
		end
	end
	return count
end

function WeaponTruck:spawnBox(i, position)
	if position then
		self.m_Boxes[i] = createObject(2912, position, 0, 0, math.random(0,360))
		addEventHandler("onElementClicked", self.m_Boxes[i], self.m_Event_onBoxClickFunc)
		self.m_Boxes[i].content = {}
		self.m_Boxes[i].sum = 0
		self.m_Boxes[i].id = i
		self:setBoxContent(i)
		self.m_Boxes[i]:setData("weaponBox", true, true)
		self.m_Boxes[i]:setData("content", self.m_Boxes[i].content, true)
		setElementData(self.m_Boxes[i], "clickable", true)
		--self:outputBoxContent(self.m_StartPlayer,i)
		return self.m_Boxes[i]
	else
		outputDebugString("Weapontruck Error: Spawning Weaponbox "..i.."! Position missing!")
	end
end

function WeaponTruck:Event_onBoxClick(button, state, player)
	if button == "left" and state == "down" then
		if player.vehicle then return end
		if player:getFaction() and (player:getFaction():isStateFaction() or player:getFaction():isEvilFaction()) then
			if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
				player:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
				player:attachPlayerObject(source)
			else
				player:sendError(_("Du bist zuweit von der Kiste entfernt!", player))
			end
		else
			player:sendError(_("Nur Fraktionisten können Kisten aufheben!",player))
		end
	end
end

function WeaponTruck:loadBoxOnWeaponTruck(player,box)
	local boxesOnTruck = self:getAttachedBoxes(self.m_Truck) + 1
	player:detachPlayerObject(box)
	box:setScale(1.6)
	box:attach(self.m_Truck, WeaponTruck.attachCords[boxesOnTruck])
	box:setCollisionsEnabled(false)
	removeEventHandler("onElementClicked", box, self.m_Event_onBoxClickFunc)

	if boxesOnTruck >= self.m_BoxesCount then
		player:sendInfo(_("Alle Kisten aufgeladen! Der Truck ist bereit!",player))
		self.m_Truck:setFrozen(false)
		self.m_Truck:setLocked(false)
		if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	else
		player:sendInfo(_("%d/%d Kisten aufgeladen!", player, boxesOnTruck, self.m_BoxesCount))
	end
end

function WeaponTruck:setBoxContent(boxId)
	local box = self.m_Boxes[boxId]
	local depotInfo =  self.m_StartFaction.m_WeaponDepotInfo
	local preis

	for weaponID,v in pairs(self.m_WeaponLoad) do
		for typ,amount in pairs(self.m_WeaponLoad[weaponID]) do
			if amount > 0 then
				for i=0,amount do
					if typ == "Waffe" then preisString = "WaffenPreis" elseif typ == "Munition" then preisString = "MagazinPreis" end
					if box.sum + depotInfo[weaponID][preisString] < self.m_AmountPerBox or depotInfo[weaponID][preisString] > self.m_AmountPerBox then
						if not box.content[weaponID] then box.content[weaponID] = { ["Waffe"] = 0, ["Munition"] = 0 } end

						box.sum = box.sum + depotInfo[weaponID][preisString]
						self.m_WeaponLoad[weaponID][typ] = self.m_WeaponLoad[weaponID][typ] - 1
						box.content[weaponID][typ] = box.content[weaponID][typ] + 1
						--outputChatBox("1 "..typ.." "..WEAPON_NAMES[weaponID].." in die Kiste "..boxId.." geladen! SUM: "..box.sum.."$") -- Debug
						self:setBoxContent(boxId)
						return
					else
						return
					end
				end
			end
		end
	end

end

function WeaponTruck:outputBoxContent(player, box)
	if box and isElement(box) and box.content then
		local weaponTable = box.content
		for weaponID,v in pairs(weaponTable) do
			for typ,amount in pairs(weaponTable[weaponID]) do
				if amount > 0 then
					if typ == "Waffe" then
						outputChatBox("Kiste: "..box.id..": "..amount.." "..WEAPON_NAMES[weaponID].." Waffe/n",player,255,255,0)
					elseif typ == "Munition" then
						outputChatBox("Kiste: "..box.id..": "..amount.." "..WEAPON_NAMES[weaponID].." Magazin/e",player,255,255,0)
					end
				end
			end
		end
	else
		outputDebug("Error WT:outputBoxContent BoxId: "..box.id)
	end
end

--Vehicle Events
function WeaponTruck:Event_OnWeaponTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Waffentruck können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function WeaponTruck:Event_OnWeaponTruckDestroy()
	if self and not self.m_Destroyed then
		self.m_Destroyed = true
		self:Event_OnWeaponTruckExit(self.m_Driver,0)
		PlayerManager:getSingleton():breakingNews("Der %s wurde zerstört!", WEAPONTRUCK_NAME[self.m_Type])
		self:delete()
	end
end

function WeaponTruck:Event_OnWeaponTruckEnter(player,seat)
	if seat == 0 and player:getFaction() then
		self.m_Driver = player
		player:triggerEvent("Countdown", math.floor((WeaponTruck.Time-(getTickCount()-self.m_StartTime))/1000), WEAPONTRUCK_NAME_SHORT[self.m_Type])
		player:triggerEvent("VehicleHealth")
	end
end

function WeaponTruck:addDestinationMarker(factionId, type, blip, isEvil)
	local markerId = #self.m_DestinationMarkers+1
	local color = factionColors[factionId]
	local destination = factionWTDestination[factionId]
	self.m_DestinationMarkers[markerId] = createMarker(destination,"cylinder",8, color.r, color.g, color.b, 100)
	self.m_DestinationMarkers[markerId].type = type
	self.m_DestinationMarkers[markerId].factionId = factionId

	addEventHandler("onMarkerHit", self.m_DestinationMarkers[markerId], bind(self.Event_onDestinationMarkerHit, self))

	if blip then
		local facObj = FactionManager:getSingleton():getFromId(factionId)
		if facObj then
			local blipId = #self.m_DestinationBlips+1
			if isEvil then
				self.m_DestinationBlips[blipId] = Blip:new("Waypoint.png", destination.x, destination.y, {"faction",facObj}, 9999)
			else 
				self.m_DestinationBlips[blipId] = Blip:new("Waypoint.png", destination.x, destination.y, root, 9999)
			end
		end
	end

end

function WeaponTruck:Event_OnWeaponTruckExit(player,seat)
	if seat == 0 and player and isElement(player) then
		player:triggerEvent("CountdownStop", WEAPONTRUCK_NAME_SHORT[self.m_Type])
		player:triggerEvent("VehicleHealthStop")
	end
end

function WeaponTruck:Event_DeloadBox(veh)
	if not veh then return end
	if client:getFaction() then
		if veh == self.m_Truck or VEHICLE_BOX_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client:getPlayerAttachedObject() then
					if not client.vehicle then
						for key, box in pairs (getAttachedElements(veh)) do
							if box.model == 2912 then
								box:setScale(1)
								box:detach(self.m_Truck)
								client:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
								client:attachPlayerObject(box)
								addEventHandler("onElementClicked", box, self.m_Event_onBoxClickFunc)
								return
							end
						end
						client:sendError(_("Es befindet sich keine Kiste auf dem Truck!",client))
						return
					else
						client:sendError(_("Du darfst in keinem Fahrzeug sitzen!",client))
					end
				else
					client:sendError(_("Du hast bereits ein Objekt dabei!",client))
				end
			else
				client:sendError(_("Du bist zuweit vom Truck entfernt!",client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht entladen werden!",client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Kisten abladen!",client))
	end
end

function WeaponTruck:getAttachedBoxes(element)
	local count = 0
	if getAttachedElements(element) then
		for index, ele in pairs(getAttachedElements(element)) do
			if ele:getModel() == 2912 then
				count = count + 1
			end
		end
	end
	return count
end

function WeaponTruck:Event_LoadBox(veh)
	if client:getFaction() then
		if veh == self.m_Truck or VEHICLE_BOX_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position,client.position) < 7 then
				if not client.vehicle then
					local box = client:getPlayerAttachedObject()
					if veh == self.m_Truck then
						self:loadBoxOnWeaponTruck(client,box)
						return
					end
					if self:getAttachedBoxes(veh) < VEHICLE_BOX_LOAD[veh.model]["count"] then
						if box then
							local count = self:getAttachedBoxes(veh)
							client:detachPlayerObject(box)
							box:attach(veh, VEHICLE_BOX_LOAD[veh.model][count+1])
							removeEventHandler("onElementClicked", box, self.m_Event_onBoxClickFunc)
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
				client:sendError(_("Du bist zuweit vom Truck entfernt!",client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht beladen werden!",client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Kisten abladen!",client))
	end
end

function WeaponTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and matchingDimension then
		if hitElement.type == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if (hitElement.vehicle and #getAttachedElements(hitElement.vehicle) > 0 ) or hitElement:getPlayerAttachedObject() then
					if faction:isEvilFaction() and source.type == "evil" and (source.factionId == faction:getId()) then
						self:onDestinationMarkerHit(hitElement)
					elseif faction:isStateFaction() and source.type == "state" then
						if self.m_Type == "state" then
							self:onDestinationMarkerHit(hitElement)
						else
							self:onStateMarkerHit(hitElement)
						end
					else
						hitElement:sendError(_("Du kannst hier nicht abgeben!",hitElement))

					end
				end
			end
		end
	end
end

function WeaponTruck:onDestinationMarkerHit(hitElement)
	local faction = hitElement:getFaction()
	local depot = faction.m_Depot
	local boxes = {}
	local finish = false
	if isPedInVehicle(hitElement) and getPedOccupiedVehicle(hitElement) == self.m_Truck then
		boxes = getAttachedElements(self.m_Truck)
		hitElement:sendInfo(_("Truck erfolgreich abgegeben! Die Waffen sind nun im Fraktions-Depot!",hitElement))
		self:Event_OnWeaponTruckExit(hitElement,0)
		if self.m_Type == "evil" then
			faction:giveKarmaToOnlineMembers(-10, "Waffentruck abgegeben!")
			PlayerManager:getSingleton():breakingNews("Der %s wurde erfolgreich abgegeben!", WEAPONTRUCK_NAME[self.m_Type])
		elseif self.m_Type == "state" then
			if faction:isEvilFaction() then
				PlayerManager:getSingleton():breakingNews("Der %s wurde von der Fraktion %s gestohlen!", WEAPONTRUCK_NAME[self.m_Type], faction:getName())
			else
				FactionState:getSingleton():giveKarmaToOnlineMembers(10, "Staats-Waffentruck abgegeben!")
				PlayerManager:getSingleton():breakingNews("Der %s wurde erfolgreich abgegeben!", WEAPONTRUCK_NAME[self.m_Type])
			end
		end
		finish = true
	elseif hitElement:getPlayerAttachedObject() then
		if self:getAttachedBoxes(hitElement) > 0 then
			boxes = getAttachedElements(hitElement)
			PlayerManager:getSingleton():breakingNews("%d von %d Waffenkisten wurden abgegeben!", self.m_BoxesCount-self:getRemainingBoxAmount()+1, self.m_BoxesCount)
			hitElement:sendInfo(_("Du hast erfolgreich eine Kiste abgegeben! Die Waffen sind nun im Fraktions-Depot!",hitElement))
			hitElement:detachPlayerObject(hitElement:getPlayerAttachedObject())
		end
	elseif hitElement:getOccupiedVehicle() then
		hitElement:sendInfo(_("Du musst die Kisten per Hand oder mit dem Waffentruck abladen!", hitElement))
		return
	end
	outputChatBox("Es wurden folgende Waffen und Magazine in das Lager gelegt:",hitElement,255,255,255)
	for key, value in pairs (boxes) do
		if value:getModel() == 2912 then
			depot:addWeaponsToDepot(value.content)
			self:outputBoxContent(hitElement, value)
			value:destroy()
		end
	end
	if self:getRemainingBoxAmount() == 0 or finish == true then
		delete(self)
	end
end

function WeaponTruck:onStateMarkerHit(hitElement)
	local faction = hitElement:getFaction()
	local boxes
	if isPedInVehicle(hitElement) and getPedOccupiedVehicle(hitElement) == self.m_Truck then
		boxes = getAttachedElements(self.m_Truck)
		PlayerManager:getSingleton():breakingNews("Der %s wurde sichergestellt!", WEAPONTRUCK_NAME[self.m_Type])
		hitElement:sendInfo(_("Truck erfolgreich sichergestellt",hitElement))
		self:Event_OnWeaponTruckExit(hitElement,0)
	elseif hitElement:getPlayerAttachedObject() then
		boxes = getAttachedElements(hitElement)
		PlayerManager:getSingleton():breakingNews("%d von %d Waffenkisten wurden sichergestellt!", self.m_BoxesCount-self:getRemainingBoxAmount()+1, self.m_BoxesCount)
		hitElement:sendInfo(_("Du hast erfolgreich eine Kiste abgegeben! Das Geld wurde in die Fraktionskasse überwiesen!",hitElement))
		hitElement:detachPlayerObject(hitElement:getPlayerAttachedObject())
	elseif hitElement:getOccupiedVehicle() then
		hitElement:sendInfo(_("Du musst die Kisten per Hand oder mit dem Waffentruck abladen!", hitElement))
		return
	end
	local sum = 0
	for key, box in pairs (boxes) do
		if box:getModel() == 2912 then
			sum = sum + box.sum
			box:destroy()
		end
	end
	if sum > 0 then
		hitElement:getFaction():giveMoney(sum, "Waffentruck Kisten")
	end

	if self:getRemainingBoxAmount() == 0 then
		delete(self)
	end
end
