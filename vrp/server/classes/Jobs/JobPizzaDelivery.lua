-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)
addRemoteEvents{ "onPizzaDelivered"}

local BASE_LOAN = 30 --// 15
function JobPizza:constructor( )
	Job.constructor(self)

	self.m_VehicleSpawner = VehicleSpawner:new(2102.41, -1785.12, 12.39, {509,448}, 90, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	addEventHandler("onPizzaDelivered", root, bind( JobPizza.onPizzaDeliver, self ) )
end

function JobPizza:start(player)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobPizza:stop(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	player:sendInfo(_("Schicht beendet!" , player ))
	if isTimer(player.m_EndPizzaJobTimer) then
		killTimer( player.m_EndPizzaJobTimer )
	end
end

function JobPizza:onVehicleSpawn(player,vehicleModel,vehicle)
	self:registerJobVehicle(player, vehicle, true, true)
end

--// Loan-Formula = BASE_LOAN * ( distance / time )
function JobPizza:onPizzaDeliver( player, distance, time)
	if player.vehicle and player.jobVehicle == player.vehicle then
		local workFactor = distance / time
		local pay = math.floor( BASE_LOAN * workFactor )
		player:giveMoney(pay, "Pizza-Job")
		player:givePoints(2)
	end
end
