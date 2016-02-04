-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeaponTruck = inherit(Object)
WeaponTruck.attachCords = {
	Vector3(0.7, -0.1, 0.1), Vector3(-0.7, -0.1, 0.1), Vector3(0.7, -1.4, 0.1), Vector3(-0.7, -1.4, 0.1),
	Vector3(-0.7, -2.7, 0.1), Vector3(0.7, -2.7, 0.1), Vector3(-0.7, -4, 0.1), Vector3(0.7, -4, 0.1)
}

function WeaponTruck:constructor(driver, weaponTable)
	self.m_Truck = TemporaryVehicle.create(455, -1869.58, 1430.02, 7.62, 224)
	--self.m_Truck:setFrozen(true)
	self.m_Truck:setData("WeaponTruck", true)
    self.m_Truck:setColor(0, 0, 0)
    --self.m_Truck:setLocked(true)
	self.m_Truck:setVariant(255, 255)

	self.m_Boxes = {}
	self.m_BoxesOnTruck = {}
	self.m_StartPlayer = driver
	self.m_WeaponLoad = weaponTable
	self.m_AttachBoxEvent =bind(self.attachBoxToPlayer,self)

	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.EventOnWeaponTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.EventOnWeaponTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.EventOnWeaponTruckExit,self))

	self:spawnBoxes()
	self:createLoadMarker()
end

function WeaponTruck:destructor()
	self.m_Truck:destroy()
	self.m_DestinationMarker:destroy()
	for index, value in pairs(self.m_Boxes) do
		value:destroy()
	end
end

function WeaponTruck:EventOnWeaponTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Waffentruck können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function WeaponTruck:EventOnWeaponTruckEnter(player,seat)
	if seat == 0 and player:getFaction() then
		local factionId = player:getFaction():getId()
		outputDebug(factionId)
		local destination = factionWTDestination[factionId]
		self.m_Blip = Blip:new("Waypoint.png", destination.x, destination.y, player)
		self.m_DestinationMarker = createMarker(destination,"cylinder",8)
		addEventHandler("onMarkerHit", self.m_DestinationMarker, bind(self.Event_onDestinationMarkerHit, self))
	end
end

function WeaponTruck:EventOnWeaponTruckExit(player,seat)
	if seat == 0 and player:getFaction() then
		self.m_Blip:delete()
		self.m_DestinationMarker:delete()
	end
end

function WeaponTruck:createLoadMarker()
	self.m_LoadMarker = createMarker(-1873.56, 1434.15, 7.18,"corona",2)
	addEventHandler("onMarkerHit", self.m_LoadMarker, bind(self.Event_onLoadMarkerHit, self))
end

function WeaponTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if faction:isEvilFaction() then
				outputChatBox(_("Der Waffentruck erfolgreich wurde erfolgreich abgegeben!",hitElement),rootElement,255,0,0)
				hitElement:sendInfo(_("Du hast den Matstruck erfolgreich abgegeben! Die Waffen sind nun im Fraktions-Depot!",hitElement))
				ActionsCheck:getSingleton():endAction()
				local depot = faction.m_Depot
				depot:addWeaponsToDepot(self.m_WeaponLoad)
				self:delete()
			end
		end
	end
end

function WeaponTruck:Event_onLoadMarkerHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if faction:isEvilFaction() then
				local box = self:getAttachedBox(hitElement)
				if box then
					box:detach()
					hitElement:setAnimation(false)
					self:loadBoxOnWeaponTruck(hitElement,box)
					self:toggleControlsWhileBoxAttached(hitElement, true)
				else
					hitElement:sendError(_("Du hast keine Kiste dabei!",hitElement))
				end
			end
		end
	end
end

function WeaponTruck:getAttachedBox(player)
	for key, value in pairs (getAttachedElements(player)) do
		if value:getModel() == 2912 then
			return value
		end
	end
	return false
end

function WeaponTruck:spawnBoxes()
	self:spawnBox(1,Vector3(-1875.75, 1416, 6.2))
	self:spawnBox(2,Vector3(-1875.75, 1416, 6.9))
	self:spawnBox(3,Vector3(-1873.74, 1415, 6.2))
	self:spawnBox(4,Vector3(-1873.74, 1415, 6.9))
	self:spawnBox(5,Vector3(-1875.27, 1414, 6.2))
	self:spawnBox(6,Vector3(-1875.27, 1414, 6.9))
	self:spawnBox(7,Vector3(-1873.11, 1413, 6.2))
	self:spawnBox(8,Vector3(-1873.11, 1413, 6.9))
end

function WeaponTruck:spawnBox(i, position)
	self.m_Boxes[i] = createObject(2912, position, 0, 0, math.random(0,360))
	addEventHandler("onElementClicked", self.m_Boxes[i], self.m_AttachBoxEvent)
end

function WeaponTruck:toggleControlsWhileBoxAttached(player, bool)
	toggleControl(player, "jump", bool )
	toggleControl(player, "fire", bool )
	toggleControl(player, "sprint", bool )
	toggleControl(player, "next_weapon", bool )
	toggleControl(player, "previous weapon", bool )
end

function WeaponTruck:attachBoxToPlayer(button, state, player)
	if button == "left" and state == "down" then
		if not self:getAttachedBox(player) then
			if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
				self:toggleControlsWhileBoxAttached(player, false)
				source:setCollisionsEnabled(false)
				source:attach(player, -0.09, 0.35, 0.45, 10, 0, 0)
				player:setAnimation("carry", "crry_prtial", 1, true, true, false, true)
			else
				player:sendError(_("Du bist zuweit von der Kiste entfernt!", player))
			end
		end
	end
end

function WeaponTruck:loadBoxOnWeaponTruck(player,box)
	table.insert(self.m_BoxesOnTruck,box)
	setObjectScale(box, 1.6)
	attachElements(box, self.m_Truck, WeaponTruck.attachCords[#self.m_BoxesOnTruck])

	if #self.m_BoxesOnTruck >= 8 then
		player:sendInfo(_("Alle Kisten aufgeladen! Der Truck ist bereit!",player))
		self.m_Truck:setFrozen(false)
		self.m_Truck:setLocked(false)
		self.m_LoadMarker:destroy()
	else
		player:sendInfo(_("%d/8 Kisten aufgeladen!", player, #self.m_BoxesOnTruck))
	end
end
