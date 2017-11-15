-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeedTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeedTruck = inherit(Object)
WeedTruck.LoadTime = 30*1000 -- in ms
WeedTruck.Time = 10*60*1000 -- in ms
WeedTruck.spawnPos = Vector3(-1105.76, -1621.55, 76.54)
WeedTruck.spawnRot = Vector3(0, 0, 270)
WeedTruck.Destination = Vector3(2181.59, -2626.35, 11.5)
WeedTruck.Weed = 1500

function WeedTruck:constructor(driver)
	self.m_Truck = TemporaryVehicle.create(456, WeedTruck.spawnPos, WeedTruck.spawnRot)
	self.m_Truck:setData("WeedTruck", true, true)
    self.m_Truck:setColor(0, 50, 0)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(1500, true)
	self.m_Truck:setBulletArmorLevel(2)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck.m_DisableToggleHandbrake = true


	self.m_StartTime = getTickCount()
	warpPedIntoVehicle(driver, self.m_Truck)
	self.m_Driver = driver

	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()
	self.m_StartFaction:giveKarmaToOnlineMembers(-5, "Weedtruck gestartet!")


	self.m_Destroyed = false
	self.m_DestroyFunc = bind(self.Event_OnWeedTruckDestroy,self)

	driver:triggerEvent("Countdown", math.floor(WeedTruck.LoadTime/1000), "Beladung")
	self.m_LoadTimer = setTimer(bind(self.truckLoaded, self), WeedTruck.LoadTime, 1)
	self.m_StartPlayer:sendInfo(_("Der Weed-Truck wird beladen! Bitte warten!", self.m_StartPlayer))

	PlayerManager:getSingleton():breakingNews("Ein Weed-Transport wurde soeben gestartet!")
	FactionState:getSingleton():sendWarning("Ein Weed-Transport wurde gestartet!", "Neuer Einsatz", true, serialiseVector(WeedTruck.spawnPos))

	self.m_Blip = Blip:new("Marker.png", WeedTruck.Destination.x, WeedTruck.Destination.y, {faction = self.m_StartFaction:getId(), factionType = "State"}, 9999, BLIP_COLOR_CONSTANTS.Red)
	self.m_DestinationMarker = createMarker(WeedTruck.Destination,"cylinder",8)
	addEventHandler("onMarkerHit", self.m_DestinationMarker, bind(self.Event_onDestinationMarkerHit, self))

	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnWeedTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnWeedTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnWeedTruckExit,self))
	addEventHandler("onVehicleExplode", self.m_Truck, self.m_DestroyFunc)
end

function WeedTruck:destructor()
	ActionsCheck:getSingleton():endAction()
	if isElement(self.m_Truck) then self.m_Truck:destroy() end
	if isElement(self.m_DestinationMarker) then self.m_DestinationMarker:destroy() end
	if self.m_Blip then delete(self.m_Blip) end
	if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	if isTimer(self.m_Timer) then killTimer(self.m_Timer) end

	StatisticsLogger:getSingleton():addActionLog("Weed-Truck", "stop", self.m_StartPlayer, self.m_StartFaction, "faction")

	TollStation.closeAll()
end


function WeedTruck:truckLoaded()
	self.m_StartPlayer:sendInfo(_("Der Weed-Truck ist vollständig beladen!", self.m_StartPlayer))
	self.m_Truck:setFrozen(false)
	TollStation.openAll()
	self.m_Timer = setTimer(bind(self.timeUp, self), WeedTruck.Time, 1)
	self:Event_OnWeedTruckEnter(self.m_StartPlayer, 0)

end

function WeedTruck:timeUp()
	PlayerManager:getSingleton():breakingNews("Der Weed-Transport wurde beendet! Den Verbrechern ist die Zeit ausgegangen!")
	delete(self)
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
		FactionState:getSingleton():giveKarmaToOnlineMembers(10, "Weedtruck verhindert!")
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

function WeedTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and hitElement.type == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction and faction:isEvilFaction() then
			if isPedInVehicle(hitElement) and hitElement:getOccupiedVehicle() == self.m_Truck then
				PlayerManager:getSingleton():breakingNews("Der Weed-Transport wurde erfolgreich abgeschlossen!")
				hitElement:sendInfo(_("Weed-Truck abgegeben! Du erhälst %d Gramm Weed!", hitElement, WeedTruck.Weed))
				faction:giveKarmaToOnlineMembers(-10, "Weed-Truck abgegeben!")
				hitElement:getInventory():giveItem("Weed", WeedTruck.Weed)
				self:Event_OnWeedTruckExit(hitElement,0)
				delete(self)
			end
		end
	end
end
