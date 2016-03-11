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

	self.m_Spawner = VehicleSpawner:new(1765.5999755859, -2286.3000488281, 26, {"Cargobob"}, 0, bind(Job.requireVehicle, self))
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
end

function JobHeliTransport:onPickupLoad()
	local vehicle = client:getOccupiedVehicle()
	if self.m_VehData[vehicle].package then
		self.m_VehData[vehicle].package:setAlpha(255)
		self.m_VehData[vehicle].load = true
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
		client:sendInfo(_("Du hast die Ladung abgegeben! Hole eine neue am Ladepunkt!", client))
		client:triggerEvent("jobHeliTransportCreateMarker", "pickup")
	else
		client:sendInfo(_("Falsches Fahrzeug!", client))
	end
end
