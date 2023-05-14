-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeedTruck.lua
-- *  PURPOSE:     Weed Truck Class
-- *
-- ****************************************************************************

WeedTruck = inherit(Object)
WeedTruck.LoadTime = 30*1000 -- in ms
WeedTruck.Time = 15*60*1000 -- in ms
WeedTruck.spawnPos = Vector3(-1105.76, -1621.55, 76.54)
WeedTruck.spawnRot = Vector3(0, 0, 270)
WeedTruck.Destination = Vector3(2181.59, -2626.35, 11.5)
WeedTruck.StateDestination = Vector3(1182.66, -1797.50, 12)
WeedTruck.loadMarkerPos = Vector3(-1111.62, -1621.53, 76.37)
WeedTruck.PackageSpawnCords = {
	Vector3(-1119.9, -1622.7, 76.17), Vector3(-1119.9, -1622.35, 76.17),
	Vector3(-1119.9, -1622, 76.17), Vector3(-1119.9, -1621.65, 76.17),
	Vector3(-1119.9, -1621.3, 76.17), Vector3(-1119.9, -1620.95, 76.17),
	Vector3(-1119.9, -1620.6, 76.17), Vector3(-1119.9, -1620.25, 76.17),
	Vector3(-1119.9, -1619.9, 76.17), Vector3(-1119.9, -1619.55, 76.17),
}
WeedTruck.attachCords = {
	Vector3(0.5, -0.1, 0.03), Vector3(-0.6, -0.1, 0.03),
	Vector3(-0.6, -1.1, 0.03), Vector3(0.5, -1, 0.03),
	Vector3(0.5, -1.9, 0.03), Vector3(0.5, -2.8, 0.03), 
	Vector3(-0.6, -1.9, 0.03), Vector3(-0.6, -2.8, 0.03), 
	Vector3(0.5, -3.7, 0.03), Vector3(-0.6, -3.7, 0.03),	
}
WeedTruck.MaxPackages = 10
WeedTruck.WeedPerPackage = 300


function WeedTruck:constructor(driver)
	self.m_Truck = TemporaryVehicle.create(456, WeedTruck.spawnPos, WeedTruck.spawnRot)
	self.m_Truck:setDoorOpenRatio(1, 1)
	self.m_Truck:setData("WeedTruck", true, true)
    self.m_Truck:setColor(0, 50, 0)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(1500, true)
	self.m_Truck:setBulletArmorLevel(2)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck:initObjectLoading()
	--self.m_Truck.m_DisableToggleHandbrake = true
	self.m_Packages = {}
	self.m_DestinationPeds = {}
	self.m_DestinationBlips = {}

	self.m_StartTime = getTickCount()
	--warpPedIntoVehicle(driver, self.m_Truck)
	self.m_Driver = driver

	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()

	self.m_Destroyed = false
	self.m_DestroyFunc = bind(self.Event_OnWeedTruckDestroy,self)

	self.m_WaterCheckTimer = setTimer(bind(self.isWeedTruckInWater, self), 10000, 0)
	self.m_IsSubmerged = false
	
	PlayerManager:getSingleton():breakingNews("Ein Weed-Transport wurde soeben gestartet!")
	Discord:getSingleton():outputBreakingNews("Ein Weed-Transport wurde soeben gestartet!")
	FactionState:getSingleton():sendWarning("Ein Weed-Transport wurde gestartet!", "Neuer Einsatz", true, serialiseVector(WeedTruck.spawnPos))
	
	for i, faction in pairs(FactionEvil:getSingleton():getFactions()) do
		local pos = factionDTDestination[faction:getId()][1]
		self:addDestinationPed(faction, "evil")
		self.m_DestinationBlips[faction:getId()] = Blip:new("Marker.png", pos.x, pos.y, {factionType = {"State", "Evil"}, duty = true}, 9999, BLIP_COLOR_CONSTANTS.Red)
		self.m_DestinationBlips[faction:getId()]:setDisplayText(("Drogentruck-Abgabepunkt (%s)"):format(faction:getShortName()))
		self.m_DestinationBlips[faction:getId()]:setZ(pos.z)
	end

	local pos = factionDTDestination[2][1]
	self:addDestinationPed(FactionManager:getSingleton():getFromId(2), "state")
	self.m_DestinationBlips["state"] = Blip:new("Marker.png", pos.x, pos.y, {factionType = {"State", "Evil", duty = true}}, 9999, BLIP_COLOR_CONSTANTS.Blue)
	self.m_DestinationBlips["state"]:setDisplayText("Drogentruck-Abgabe (Staat)")
	self.m_DestinationBlips["state"]:setZ(pos.z)

	self.m_Event_onPackageClickFunc =bind(self.Event_onPackageClick,self)

	TollStation.openAll()
	self.m_Timer = setTimer(bind(self.timeUp, self), WeedTruck.Time, 1)

	addEventHandler("onVehicleStartEnter", self.m_Truck, bind(self.Event_OnWeedTruckStartEnter,self))
	addEventHandler("onVehicleEnter", self.m_Truck, bind(self.Event_OnWeedTruckEnter,self))
	addEventHandler("onVehicleExit" ,self.m_Truck, bind(self.Event_OnWeedTruckExit,self))
	addEventHandler("onElementDestroy", self.m_Truck, self.m_DestroyFunc)
	addEventHandler("onVehicleExplode", self.m_Truck, self.m_DestroyFunc)

	self:spawnPackages()
end

function WeedTruck:destructor()
	removeEventHandler("onElementDestroy",self.m_Truck, self.m_DestroyFunc)
	if isElement(self.m_Truck) then self.m_Truck:destroy() end
	if isTimer(self.m_Timer) then killTimer(self.m_Timer) end
	if isTimer(self.m_WaterCheckTimer) then killTimer(self.m_WaterCheckTimer) end
	ActionsCheck:getSingleton():endAction()
	
	for index, value in pairs(self.m_DestinationPeds) do
		if isElement(value) then value:destroy() end
	end

	for index, value in pairs(self.m_DestinationBlips) do
		if value then delete(value) end
	end

	for index, value in pairs(self.m_Packages) do
		if isElement(value) then
			if value:isAttached() and isElement(value:getAttachedTo()) and value:getAttachedTo():getType() == "player" then
				value:getAttachedTo():detachPlayerObject(value)
			end
		 	value:destroy()
		end
	end

	StatisticsLogger:getSingleton():addActionLog("Weed-Truck", "stop", self.m_StartPlayer, self.m_StartFaction, "faction")
	TollStation.closeAll()
end


--[[function WeedTruck:truckLoaded()
	self.m_StartPlayer:sendInfo(_("Der Weed-Truck ist vollständig beladen!", self.m_StartPlayer))
	self.m_Truck:setFrozen(false)

end]]

function WeedTruck:timeUp()
	PlayerManager:getSingleton():breakingNews("Der Weed-Transport wurde beendet! Den Verbrechern ist die Zeit ausgegangen!")
	delete(self)
end

-- Marker methodes/events
--[[function WeedTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and hitElement.type == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction and faction:isEvilFaction() then
			if isPedInVehicle(hitElement) and hitElement:getOccupiedVehicle() == self.m_Truck then
				PlayerManager:getSingleton():breakingNews("Der Weed-Transport wurde erfolgreich abgeschlossen!")
				Discord:getSingleton():outputBreakingNews("Der Weed-Transport wurde erfolgreich abgeschlossen!")
				hitElement:sendInfo(_("Weed-Truck abgegeben! Du erhälst %d Gramm Weed!", hitElement, WeedTruck.Weed))
				hitElement:getInventory():giveItem("Weed", WeedTruck.Weed)
				self:Event_OnWeedTruckExit(hitElement,0)
				delete(self)
			end
		end
	end
end]]


-- Package methodes
function WeedTruck:spawnPackages()
	for i=1, WeedTruck.MaxPackages do
		if WeedTruck.PackageSpawnCords[i] then
			self:spawnPackage(i, WeedTruck.PackageSpawnCords[i])
		end
	end
end

function WeedTruck:spawnPackage(i, position)
	if position then
		self.m_Packages[i] = createObject(1575, position, 0, 0, 0)
		addEventHandler("onElementClicked", self.m_Packages[i], self.m_Event_onPackageClickFunc)
		self.m_Packages[i].id = i
		self.m_Packages[i]:setData("drugPackage", true, true)
		setElementData(self.m_Packages[i], "clickable", true)
		return self.m_Packages[i]
	else
		outputDebugString("Weedtruck Error: Spawning Drugpackage "..i.."! Position missing!")
	end
end

function WeedTruck:getRemainingPackageAmount()
	local count = 0
	for i, package in pairs(self.m_Packages) do
		if isElement(package) then
			count = count +1
		end
	end
	return count
end

function WeedTruck:Event_onPackageClick(button, state, player)
	if button == "left" and state == "down" then
		if player.vehicle then return end
		if player:isDead() then return end
		if player:getFaction() and player:isFactionDuty() and (player:getFaction():isStateFaction() or player:getFaction():isEvilFaction()) then
			if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
				player:attachPlayerObject(source)
			else
				player:sendError(_("Du bist zu weit vom Paket entfernt!", player))
			end
		else
			player:sendError(_("Nur Fraktionisten können Drogenpakete aufheben!",player))
		end
	end
end

--Vehicle Events
function WeedTruck:Event_OnWeedTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Weed-Truck können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function WeedTruck:Event_OnWeedTruckDestroy()
	if self and not self.m_Destroyed then
		self.m_Destroyed = true
		self:Event_OnWeedTruckExit(self.m_Driver,0)
		PlayerManager:getSingleton():breakingNews("Der Weed-LKW wurde soeben zerstört!")
		Discord:getSingleton():outputBreakingNews("Der Weed-LKW wurde soeben zerstört!")
		delete(self)
	end
end

function WeedTruck:Event_OnWeedTruckEnter(player, seat)
	if seat == 0 and player:getFaction() then
		local factionId = player:getFaction():getId()
		local destination = WeedTruck.Destination
		self.m_Driver = player
		player:triggerEvent("Countdown", math.floor((WeedTruck.Time-(getTickCount()-self.m_StartTime))/1000), "Weed-Truck")
		player:triggerEvent("VehicleHealth", 980)

	end
end

function WeedTruck:Event_OnWeedTruckExit(player,seat)
	if seat == 0 then
		player:triggerEvent("CountdownStop", "Weed-Truck")
		player:triggerEvent("VehicleHealthStop")
	end
end

-- Marker methodes / events
function WeedTruck:addDestinationPed(faction, type)
	local data = factionDTDestination[faction:getId()]
	self.m_DestinationPeds[faction:getId()] = Ped.create(data[3], data[1], data[2])
	self.m_DestinationPeds[faction:getId()]:setData("NPC:Immortal", true, true)
	self.m_DestinationPeds[faction:getId()]:setFrozen(true)
	self.m_DestinationPeds[faction:getId()]:setData("clickable", true, true)
	self.m_DestinationPeds[faction:getId()]:setData("Ped:Name", data[4], true)
	self.m_DestinationPeds[faction:getId()]:setData("Ped:fakeNameTag", data[4], true)
	self.m_DestinationPeds[faction:getId()].type = type
	self.m_DestinationPeds[faction:getId()].faction = faction
	addEventHandler("onElementClicked", self.m_DestinationPeds[faction:getId()], bind(self.Event_onDestinationPedClick, self))
end

function WeedTruck:Event_onDestinationPedClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 7 then
			if player.type == "player" then
				if player.m_PlayerAttachedObject then
					local faction = player:getFaction()
					if player:getFaction() and player:isFactionDuty() and (player:getFaction():isStateFaction() or player:getFaction():isEvilFaction()) then
						if (player.vehicle and #getAttachedElements(player.vehicle) > 0 ) or player:getPlayerAttachedObject() then
							if source.type == "evil"  then
								self:onDestinationPedClick(player, source, false)
							elseif source.type == "state" then
								self:onDestinationPedClick(player, source, true)
							else
								player:sendError(_("Du kannst hier nicht abgeben!",player))
							end
						end
					else
						player:sendError(_("Nur Fraktionisten können Drogenpakete abgeben!",player))
					end
				end
			end
		end
	end
end

function WeedTruck:onDestinationPedClick(player, ped, stateDestination)
	local faction = player:getFaction()
	local package
	local breakingNewsText

	if player.vehicle then return player:sendInfo(_("Bitte steig aus um die Pakete abzugeben!", player)) end

	if player:getPlayerAttachedObject() then
		if player:getPlayerAttachedObject():getModel() == 1575 and player:getPlayerAttachedObject():getData("drugPackage") then
			if ped.faction == faction then
				if stateDestination then
					breakingNewsText = "Paket %d von %d wurde vom %s beschlagnahmt!"
					PlayerManager:getSingleton():breakingNews(breakingNewsText, 10-self:getRemainingPackageAmount()+1, WeedTruck.MaxPackages, faction:getShortName())
					StateEvidence:getSingleton():addItemToEvidence(player, "Weed", WeedTruck.WeedPerPackage, false)
				else
					if ped.faction == player:getFaction() then
						player:getInventory():giveItem("Weed", WeedTruck.WeedPerPackage)
						breakingNewsText = "Paket %d von %d wurde von der/dem %s abgegeben!"
					else
						breakingNewsText = "Paket %d von %d wurde an das/die %s übergeben!"
					end
					PlayerManager:getSingleton():breakingNews(breakingNewsText, 10-self:getRemainingPackageAmount()+1, WeedTruck.MaxPackages, ped.faction:getShortName())
				end
			else 
				if stateDestination then
					player:sendPedChatMessage(ped:getData("Ped:Name"), _("Vielen Dank für deine Kooperation mit dem Staat.", player))
					StateEvidence:getSingleton():addItemToEvidence(player, "Weed", WeedTruck.WeedPerPackage, false)
				else 
					player:sendPedChatMessage(ped:getData("Ped:Name"), _("Haste noch mehr? Wenn nicht kannste wieder gehen.", player))
				end
				breakingNewsText = "Paket %d von %d wurde an das/die %s übergeben!"
				PlayerManager:getSingleton():breakingNews(breakingNewsText, 10-self:getRemainingPackageAmount()+1, WeedTruck.MaxPackages, ped.faction:getShortName())
				player:giveAchievement(111) -- Snitch
				outputDebug("giveAchievement 111")
			end
			package = player:getPlayerAttachedObject()
			player:detachPlayerObject(package)
			package:destroy()
		end
	end

	if self:getRemainingPackageAmount() == 0  then
		delete(self)
	end
end

function WeedTruck:isWeedTruckInWater()
	if not self.m_IsSubmerged then
		if isElementInWater(self.m_Truck) then
			self.m_WaterNotificationTimer = setTimer(
				function()
					PlayerManager:getSingleton():breakingNews("Neueste Quellen berichten, dass der Weed-Transporter einen Unfall hatte und ins Wasser gefahren ist!")
				end
			, 180000, 1)
			self.m_IsSubmerged = true
		end
	end
end