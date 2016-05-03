-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobHeliTransport.lua
-- *  PURPOSE:     Heli Transport job class
-- *
-- ****************************************************************************
JobHeliTransport = inherit(Job)

function JobHeliTransport:constructor()
	Job.constructor(self)

	self.m_Spawner = VehicleSpawner:new(1765.5999755859, -2286.3000488281, 26, {"Cargobob"}, 270, bind(Job.requireVehicle, self))
	self.m_Spawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehData = {}

	addRemoteEvents{"jobHeliTransportOnPickupLoad", "jobHeliTransportOnDelivery"}
	addEventHandler("jobHeliTransportOnPickupLoad", root, bind(self.onPickupLoad, self))
	addEventHandler("jobHeliTransportOnDelivery", root, bind(self.onDelivery, self))

end

function JobHeliTransport:start(player)

end

function JobHeliTransport:onVehicleSpawn(player,vehicleModel,vehicle)
	self.m_VehData[vehicle] = {}
	self.m_VehData[vehicle].package = createObject(1299, 0, 0, 0)
	self.m_VehData[vehicle].package:attach(vehicle, -0.5, -1.5, -1)
	self.m_VehData[vehicle].package:setAlpha(0)
	self.m_VehData[vehicle].load = false
	player:triggerEvent("jobHeliTransportCreateMarker", "pickup")
	client:sendInfo(_("Bitte belade deinen Helikopter am Ladepunkt!", client))
	addEventHandler("onVehicleExplode", vehicle, bind(self.onCargoBobExplode, self))
	addEventHandler("onVehicleExit", vehicle, bind(self.onCargoBobExit, self))
	addEventHandler("onVehicleDestroy", vehicle, bind(self.onCargoBobDestroy, self))

end

function JobHeliTransport:onCargoBobExplode()
	local player = source:getOccupant()
	player:setPosition(Vector3(1788.84, -2275.36, 26.78))
	player:sendError(_("Dein Helikopter ist explodiert! Der Job wurde beendet!", player))
	self.m_VehData[source] = nil
	player:triggerEvent("endHeliTransport")
end

function JobHeliTransport:onCargoBobExit(player)
	player:setPosition(Vector3(1788.84, -2275.36, 26.78))
	player:sendError(_("Du bist ausgestiegen! Der Job wurde beendet!", player))
	source:destroy()
	self.m_VehData[source] = nil

	player:triggerEvent("endHeliTransport")
end

function JobHeliTransport:onCargoBobDestroy()
	if isElement(self.m_VehData[source].package) then self.m_VehData[source].package:destroy() end
end

function JobHeliTransport:onPickupLoad()
	local vehicle = client:getOccupiedVehicle()
	if self.m_VehData[vehicle].package then
		self.m_VehData[vehicle].package:setAlpha(255)
		self.m_VehData[vehicle].load = true
		self.m_PickupPos = vehicle:getPosition()
		client:sendInfo(_("Ladung aufgenommen! Liefere Sie nun ab!", client))
		client:triggerEvent("jobHeliTransportCreateMarker", "delivery")
	else
		client:sendInfo(_("Falsches Fahrzeug!", client))
	end
end

function JobHeliTransport:onDelivery()
	local vehicle = client:getOccupiedVehicle()
	if self.m_VehData[vehicle].package then
		self.m_VehData[vehicle].package:setAlpha(0)
		self.m_VehData[vehicle].load = false
		local distance = getDistanceBetweenPoints3D(self.m_PickupPos, vehicle:getPosition())
		client:giveMoney(math.floor(distance/2), "Helitransport-Job")
		client:sendInfo(_("Du hast die Ladung abgegeben und erhälst %d$! Hole eine neue am Ladepunkt!", client, math.floor(distance/2)))
		client:triggerEvent("jobHeliTransportCreateMarker", "pickup")
	else
		client:sendInfo(_("Falsches Fahrzeug!", client))
	end
end
