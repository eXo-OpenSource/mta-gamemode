-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)
addRemoteEvents{ "onPizzaDelivered"}

local BASE_LOAN = 14 --// 15

function JobPizza:constructor( )
	Job.constructor(self)

	self.m_VehicleSpawner = VehicleSpawner:new(2102.41, -1785.12, 12.39, {509,448}, 90, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	addEventHandler("onPizzaDelivered", root, bind( JobPizza.onPizzaDeliver, self ) )
end

function JobPizza:start(player)
	player:sendInfo(_("Job angenommen! Gehe zum roten Marker um ein Fahrzeug zu erhalten und die Schicht zu starten.", player))
	player.m_LastJobAction = getRealTime().timestamp
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobPizza:stop(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	if isTimer(player.m_EndPizzaJobTimer) then
		killTimer( player.m_EndPizzaJobTimer )
	end
end

function JobPizza:onVehicleSpawn(player,vehicleModel,vehicle)
	self:registerJobVehicle(player, vehicle, true, true)
	player:sendInfo(_("Liefere die Pizza nun zur Markierung auf der Karte.", player))
end

--// Loan-Formula = BASE_LOAN * ( distance / time )
function JobPizza:onPizzaDeliver(distance, time)
	if client.vehicle and client.jobVehicle == client.vehicle then
		if getTickCount() - (client.pizzaJobDelivered or 0) < 10000 then return end
		client.pizzaJobDelivered = getTickCount()

		local workFactor = math.min(distance, 1899) / math.max(time, 10) -- Note: 1899 is the longest distance from start point
		local pay = math.floor( BASE_LOAN * workFactor*2 )
		local duration = getRealTime().timestamp - client.m_LastJobAction
		local points = 0
		client.m_LastJobAction = getRealTime().timestamp
		
		if chance(30) then
			points = math.floor(1*JOB_EXTRA_POINT_FACTOR)
			client:givePoints(points)
		end	

		StatisticsLogger:getSingleton():addJobLog(client, "jobPizzaDelivery", duration, pay, client.vehicle:getModel(), distance, points, time)
		client:addBankMoney(pay, "Pizza-Job")
	end
end
