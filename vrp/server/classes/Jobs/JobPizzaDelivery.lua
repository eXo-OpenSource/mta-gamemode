-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)
addRemoteEvents{ "onPizzaDelivered"}

local BASE_LOAN = 15
function JobPizza:constructor( )
	Job.constructor(self)
	self.m_VehicleSpawner = VehicleSpawner:new(2102.41, -1785.12, 12.39, {509,448}, 90,  bind(JobPizza.additionalCheck, self),bind(JobPizza.onVehicleSpawn, self))
	self.m_VehicleSpawner:disable()

	addEventHandler("onPizzaDelivered", root, bind( JobPizza.onPizzaDeliver, self ) )
end

function JobPizza:start(player)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobPizza:stop(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)

	if player.m_PizzaVeh and isElement(player.m_PizzaVeh) then
		removeEventHandler("onElementDestroy", player.m_PizzaVeh, self.m_OnVehicleAction)
		player.m_PizzaVeh:destroy()
	end
	player.m_PizzaVeh = nil
	player:setModel(player.m_OldSkin)
	player:triggerEvent("stopPizzaShift")
	player:sendInfo(_("Schicht beendet!" , player ))
	if isTimer(player.m_EndPizzaJobTimer) then
		killTimer( player.m_EndPizzaJobTimer )
	end
end

function JobPizza:onVehicleSpawn( vehicle, player )
	if player.m_PizzaVeh then cancelEvent() self:stop(player) end
	player.m_PizzaVeh = vehicle
	vehicle.m_PizzaOwner = player
	player.m_OldSkin = player:getModel()
	player:setModel( 155 )
	addEventHandler("onVehicleDamage", vehicle, bind(JobPizza.onDamageVehicle, self) )
	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		if vehPlayer ~= player then
			vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
			cancelEvent()
		end
	end)
	player:triggerEvent("nextPizzaDelivery")
	vehicle:addCountdownDestroy(10)
	self.m_OnVehicleAction = bind(self.onVehicleAction, self)
	addEventHandler("onVehicleExplode", vehicle, self.m_OnVehicleAction)
	addEventHandler("onElementDestroy", vehicle, self.m_OnVehicleAction)

end

function JobPizza:additionalCheck( player )
	if self:requireVehicle( player ) then
		if not player.m_PizzaVeh then
			return true
		else player:sendError(_("Sie besitzen bereits ein Lieferfahrzeug!" , player ))
		end
	end
	return false
end

function JobPizza:onDamageVehicle( )
	local vehHealth = getElementHealth( source )
	if vehHealth <= 310 then
		self:stop(source.m_PizzaOwner)
	end
end

function JobPizza:onVehicleAction()
	self:stop(source.m_PizzaOwner)
end

--// Loan-Formula = BASE_LOAN * ( distance / time )
function JobPizza:onPizzaDeliver( player, distance, time)
	if player.vehicle and player.vehicle.m_PizzaOwner and player.vehicle.m_PizzaOwner == player then
		local workFactor = distance / time
		local pay = math.floor( BASE_LOAN * workFactor )
		player:giveMoney(pay, "Pizza-Job")
		player:givePoints(2)
	end
end
