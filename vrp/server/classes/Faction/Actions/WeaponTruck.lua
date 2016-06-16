-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeaponTruck = inherit(Object)
WeaponTruck.Time = 10*60*1000 -- in ms
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
	self.m_Truck:setEngineState(true)
	self.m_StartTime = getTickCount()


	self.m_AmountPerBox = 1250
	self.m_BoxesCount = math.ceil(totalAmount/self.m_AmountPerBox)

	self.m_Boxes = {}
	self.m_BoxesOnTruck = {}
	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()
	self.m_WeaponLoad = weaponTable
	self.m_Event_onBoxClickFunc =bind(self.Event_onBoxClick,self)

	self.m_Timer = setTimer(bind(self.timeUp, self), WeaponTruck.Time, 1)
	self.m_Destroyed = false
	self.m_DestroyFunc = bind(self.Event_OnWeaponTruckDestroy,self)

	self.m_StateMarker = createMarker(FACTION_STATE_WT_DESTINATION,"cylinder",6)
	addEventHandler("onMarkerHit", self.m_StateMarker, bind(self.Event_onStateMarkerHit, self))

	addRemoteEvents{"weaponTruckDeloadBox", "weaponTruckLoadBox"}

	addEventHandler("weaponTruckDeloadBox",root, bind(self.Event_DeloadBox,self))
	addEventHandler("weaponTruckLoadBox",root, bind(self.Event_LoadBox,self))


	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnWeaponTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnWeaponTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnWeaponTruckExit,self))
	addEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)

	self:spawnBoxes()
	self:createLoadMarker()
end

function WeaponTruck:destructor()
	removeEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)
	ActionsCheck:getSingleton():endAction()
	self.m_Truck:destroy()

	if isElement(self.m_DestinationMarker) then self.m_DestinationMarker:destroy() end
	if isElement(self.m_Blip) then self.m_Blip:delete() end
	if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	if isTimer(self.m_Timer) then self.m_Timer:destroy() end

	for index, value in pairs(self.m_Boxes) do
		if isElement(value) then value:destroy() end
	end
end


function WeaponTruck:timeUp()
	outputChatBox(_("Der %s ist fehlgeschlagen! (Zeit abgelaufen)",self.m_StartPlayer, WEAPONTRUCK_NAME[self.m_Type]),rootElement,255,0,0)
	self:delete()
end

-- Marker methodes/events
function WeaponTruck:createLoadMarker()
	self.m_LoadMarker = createMarker(WeaponTruck.loadMarkerPos[self.m_Type],"corona",2)
	addEventHandler("onMarkerHit", self.m_LoadMarker, bind(self.Event_onLoadMarkerHit, self))
end

function WeaponTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and matchingDimension then
		if hitElement.type == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if (isPedInVehicle(hitElement) and #getAttachedElements(getPedOccupiedVehicle(hitElement)) > 0 ) or hitElement:getPlayerAttachedObject() then
					local depot = faction.m_Depot
					local boxes
					if isPedInVehicle(hitElement) and getPedOccupiedVehicle(hitElement) == self.m_Truck then
						boxes = getAttachedElements(self.m_Truck)
						outputChatBox(_("Der %s wurde erfolgreich abgegeben!",hitElement, WEAPONTRUCK_NAME[self.m_Type]),rootElement,255,0,0)
						hitElement:sendInfo(_("Truck erfolgreich abgegeben! Die Waffen sind nun im Fraktions-Depot!",hitElement))
						self:Event_OnWeaponTruckExit(hitElement,0)
					elseif hitElement:getPlayerAttachedObject() then
						boxes = getAttachedElements(hitElement)
						outputChatBox(_("Eine Waffenkiste wurde abgegeben! (%d/%d)",hitElement,self:getRemainingBoxAmount(),self.m_BoxesCount),rootElement,255,0,0)
						hitElement:sendInfo(_("Du hast erfolgreich eine Kiste abgegeben! Die Waffen sind nun im Fraktions-Depot!",hitElement))
					end
					outputChatBox("Es wurden folgende Waffen und Magazine in das Lager gelegt:",hitElement,255,255,255)
					for key, value in pairs (boxes) do
						if value:getModel() == 2912 then
							depot:addWeaponsToDepot(value.content)
							self:outputBoxContent(hitElement,key)
							value:destroy()
						end
					end
					if self:getRemainingBoxAmount() == 0 then
						self:delete()
					end
				end
			end
		end
	end
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
		self:spawnBox(i, WeaponTruck.boxSpawnCords[self.m_Type][i])
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
	self.m_Boxes[i] = createObject(2912, position, 0, 0, math.random(0,360))
	addEventHandler("onElementClicked", self.m_Boxes[i], self.m_Event_onBoxClickFunc)
	self.m_Boxes[i].content = {}
	self.m_Boxes[i].sum = 0
	self:setBoxContent(i)
	self.m_Boxes[i]:setData("weaponBox", true, true)
	self.m_Boxes[i]:setData("content", self.m_Boxes[i].content, true)
	--self:outputBoxContent(self.m_StartPlayer,i)
	return self.m_Boxes[i]
end

function WeaponTruck:Event_onBoxClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			player:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
			player:attachPlayerObject(source)
		else
			player:sendError(_("Du bist zuweit von der Kiste entfernt!", player))
		end
	end
end

function WeaponTruck:loadBoxOnWeaponTruck(player,box)
	table.insert(self.m_BoxesOnTruck,box)
	box:setScale(1.6)
	box:attach(self.m_Truck, WeaponTruck.attachCords[#self.m_BoxesOnTruck])
	if #self.m_BoxesOnTruck >= self.m_BoxesCount then
		player:sendInfo(_("Alle Kisten aufgeladen! Der Truck ist bereit!",player))
		self.m_Truck:setFrozen(false)
		self.m_Truck:setLocked(false)
		self.m_LoadMarker:destroy()
	else
		player:sendInfo(_("%d/%d Kisten aufgeladen!", player, #self.m_BoxesOnTruck, self.m_BoxesCount))
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

function WeaponTruck:outputBoxContent(player,boxId)
	local weaponTable = self.m_Boxes[boxId].content
	for weaponID,v in pairs(weaponTable) do
		for typ,amount in pairs(weaponTable[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					outputChatBox("Kiste: "..boxId..": "..amount.." "..WEAPON_NAMES[weaponID].." Waffe/n",player,255,255,0)
				elseif typ == "Munition" then
					outputChatBox("Kiste: "..boxId..": "..amount.." "..WEAPON_NAMES[weaponID].." Magazin/e",player,255,255,0)
				end
			end
		end
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
		outputChatBox(_("Der %s ist fehlgeschlagen! (Zerstört)",self.m_StartPlayer, WEAPONTRUCK_NAME[self.m_Type]),rootElement,255,0,0)
		self:delete()
	end
end

function WeaponTruck:Event_OnWeaponTruckEnter(player,seat)
	if seat == 0 and player:getFaction() then
		local factionId = player:getFaction():getId()
		local destination = factionWTDestination[factionId]
		self.m_Driver = player
		player:triggerEvent("Countdown", math.floor((WeaponTruck.Time-(getTickCount()-self.m_StartTime))/1000))
		player:triggerEvent("VehicleHealth")
		self.m_Blip = Blip:new("Waypoint.png", destination.x, destination.y, player)
		self.m_DestinationMarker = createMarker(destination,"cylinder",8)
		addEventHandler("onMarkerHit", self.m_DestinationMarker, bind(self.Event_onDestinationMarkerHit, self))
	end
end

function WeaponTruck:Event_OnWeaponTruckExit(player,seat)
	if seat == 0 then
		player:triggerEvent("CountdownStop")
		player:triggerEvent("VehicleHealthStop")
		self.m_Blip:delete()
		if isElement(self.m_DestinationMarker) then self.m_DestinationMarker:destroy() end
	end
end

function WeaponTruck:Event_DeloadBox(veh)
	if client:getFaction() then
		if getElementData(veh,"WeaponTruck") or VEHICLE_BOX_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client.vehicle then
					for key, box in pairs (getAttachedElements(veh)) do
						if box.model == 2912 then
							box:setScale(1)
							box:detach(self.m_Truck)
							client:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
							client:attachPlayerObject(box)
							return
						end
					end
					client:sendError(_("Es befindet sich keine Kiste auf dem Truck!",client))
					return
				else
					client:sendError(_("Du darfst in keinem Fahrzeug sitzen!",client))
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

function WeaponTruck:Event_LoadBox(veh)
	if client:getFaction() then
		if getElementData(veh,"WeaponTruck") or VEHICLE_BOX_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position,client.position) < 7 then
				if not client.vehicle then
					local box = client:getPlayerAttachedObject()
					if #getAttachedElements(veh) < VEHICLE_BOX_LOAD[veh.model]["count"] then
						if box then
							local count = #getAttachedElements(veh)
							client:detachPlayerObject(box)
							box:attach(veh, VEHICLE_BOX_LOAD[veh.model][count+1])

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

function WeaponTruck:Event_onStateMarkerHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if faction:isStateFaction() then

			end
		end
	end
end
