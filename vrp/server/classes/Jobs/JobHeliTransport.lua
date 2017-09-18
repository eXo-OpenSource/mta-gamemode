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

	self.m_VehicleSpawner = VehicleSpawner:new(1765.5999755859, -2286.3000488281, 25.65, {"Cargobob"}, 270, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	self.m_VehData = {}

	addRemoteEvents{"jobHeliTransportOnPickupLoad", "jobHeliTransportOnDelivery"}
	addEventHandler("jobHeliTransportOnPickupLoad", root, bind(self.onPickupLoad, self))
	addEventHandler("jobHeliTransportOnDelivery", root, bind(self.onDelivery, self))

end

function JobHeliTransport:start(player)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobHeliTransport:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_HELITRANSPORT) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_HELITRANSPORT))
		return false
	end
	return true
end

function JobHeliTransport:stop(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	player:setData("JobHeliTransport:Money", 0)
	player:triggerEvent("endHeliTransport")
	if player.heliJobVehicle and isElement(player.heliJobVehicle) then
		player.heliJobVehicle:destroy()
	end
end

function JobHeliTransport:onVehicleSpawn(player,vehicleModel,vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	self.m_VehData[vehicle] = {}
	self.m_VehData[vehicle].package = createObject(1299, 0, 0, 0)
	self.m_VehData[vehicle].package:attach(vehicle, -0.5, -1.5, -1)
	self.m_VehData[vehicle].package:setAlpha(0)
	self.m_VehData[vehicle].load = false
	vehicle.player = player
	player.heliJobVehicle = vehicle
	player:triggerEvent("jobHeliTransportCreateMarker", "pickup")
	player:sendInfo(_("Bitte belade deinen Helikopter am Ladepunkt!", player))
	addEventHandler("onVehicleExplode", vehicle, bind(self.onCargoBobExplode, self))
	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		if vehPlayer ~= player then
			vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
			cancelEvent()
		end
	end)
	vehicle:addCountdownDestroy(10)
	addEventHandler("onElementDestroy", vehicle, bind(self.onCargoBobDestroy, self))
end

function JobHeliTransport:onCargoBobExplode()
	local player = source:getOccupant()
	player:setPosition(Vector3(1788.84, -2275.36, 26.78))
	player:sendError(_("Dein Helikopter ist explodiert! Der Job wurde beendet!", player))
	self:stop(player)
end

function JobHeliTransport:onCargoBobDestroy()
	if self.m_VehData[source] and self.m_VehData[source].package and isElement(self.m_VehData[source].package) then self.m_VehData[source].package:destroy() end
	self.m_VehData[source] = nil
	local player = source.player
	player:setData("JobHeliTransport:Money", 0)
	player:triggerEvent("endHeliTransport")
	self.m_VehicleSpawner:toggleForPlayer(player, false)
end

function JobHeliTransport:onPickupLoad()
	local vehicle = client:getOccupiedVehicle()
	if self.m_VehData[vehicle].package then
		self.m_VehData[vehicle].package:setAlpha(255)
		self.m_VehData[vehicle].load = true
		self.m_PickupPos = vehicle:getPosition()
		if client:getData("JobHeliTransport:Money") and client:getData("JobHeliTransport:Money") > 0 then
			client:sendInfo(_("Dein Helikopter wurde wieder neu beladen.", client)) --TODO
			local duration = getRealTime().timestamp - client.m_LastJobAction
			client.m_LastJobAction = getRealTime().timestamp
			StatisticsLogger:getSingleton():addJobLog(client, "jobHeliTransport", duration, client:getData("JobHeliTransport:Money"), nil, nil, math.floor(10*JOB_EXTRA_POINT_FACTOR))
			client:addBankMoney(client:getData("JobHeliTransport:Money"), "Helitransport-Job")
			client:setData("JobHeliTransport:Money", 0)
			client:givePoints(math.floor(10*JOB_EXTRA_POINT_FACTOR))
		else
			client:sendInfo(_("Ladung aufgenommen! Liefere Sie nun ab!", client))
		end
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
		client:setData("JobHeliTransport:Money", math.floor(distance/(3.489/2))) --// Default distance/8
		client:sendInfo(_("Du hast die Ladung abgegeben! Flieg zurück und hole dir dein Geld ab!", client))
		client:triggerEvent("jobHeliTransportCreateMarker", "pickup")
	else
		client:sendInfo(_("Falsches Fahrzeug!", client))
	end
end
