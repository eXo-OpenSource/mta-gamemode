-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)
addRemoteEvents{ "onPizzaDelivered"}

local BASE_LOAN = 10
function JobPizza:constructor( )
	Job.constructor(self)
	self.m_VehicleSpawner = VehicleSpawner:new(2102.41, -1785.12, 12.39, {509,448}, 90,  bind(JobPizza.additionalCheck, self),bind(JobPizza.onVehicleSpawn, self))
	self.m_VehicleSpawner:disable()

	addEventHandler("onPizzaDelivered", root, bind( JobPizza.onPizzaDeliver, self ) )
	addEventHandler("onPlayerDisconnect", root, bind(JobPizza.onPlayerDisconnect, self) )
end

function JobRoadSweeper:onPlayerDisconnect()
	if isElement(source.m_PizzaVeh) then
		destroyElement( source.m_PizzaVeh)
	end
end

function JobPizza:start(player)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobPizza:stop(player)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	if player.m_PizzaVeh and isElement(player.m_PizzaVeh) then player.m_PizzaVeh:destroy() end
end

function JobPizza:onVehicleSpawn( vehicle, player )
	if player.m_PizzaVeh then cancelEvent(); self:endPizzaShift( player ) end
	player.m_PizzaVeh = vehicle
	vehicle.m_PizzaOwner = player
	player.m_OldSkin = player:getModel()
	player:setModel( 155 )
	addEventHandler("onVehicleExit", vehicle, bind(JobPizza.onExitVehicle, self) )
	addEventHandler("onVehicleEnter", vehicle, bind(JobPizza.onEnterVehicle, self) )
	addEventHandler("onVehicleDamage", vehicle, bind(JobPizza.onDamageVehicle, self) )
	addEventHandler("onVehicleExplode", vehicle, bind(JobPizza.onExplodeVehicle, self) )
	addEventHandler("onPlayerDisconnect", player, bind(JobPizza.onPlayerDisconnect, self) )
	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		if vehPlayer ~= player then
			vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
			cancelEvent()
		end
	end)
	player:triggerEvent("nextPizzaDelivery")
	vehicle:addCountdownDestroy(10)
	addEventHandler("onElementDestroy", vehicle, bind(self.stop, self))
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
		self:endPizzaShift ( source.m_PizzaOwner )
	end
end

function JobPizza:onExplodeVehicle( )
	self:endPizzaShift ( source.m_PizzaOwner )
end

function JobPizza:startPlayerShift( player )

end

function JobPizza:endPizzaShift ( player )
	if isElement( player.m_PizzaVeh ) then
		destroyElement( player.m_PizzaVeh )
	end
	player.m_PizzaVeh = nil
	player:setModel( player.m_OldSkin )
	player:triggerEvent("stopPizzaShift")
	player:sendInfo(_("Schicht beendet!" , player ))
	if isTimer(player.m_EndPizzaJobTimer) then
		killTimer( player.m_EndPizzaJobTimer )
	end
end

function JobPizza:onPlayerDisconnect(  )
	if player.m_PizzaVeh then
		destroyElement( player.m_PizzaVeh )
	end
	if isTimer(player.m_EndPizzaJobTimer) then
		killTimer( player.m_EndPizzaJobTimer )
	end
end

function JobPizza:onEnterVehicle( player )
	if isTimer(player.m_EndPizzaJobTimer) then
		killTimer( player.m_EndPizzaJobTimer )
	end
end


function JobPizza:onExitVehicle( player )
	player:sendWarning(_("Du hast noch 20 Sekunden um wieder in den Pizza-Boy einzusteigen!" , player ))
	player.m_EndPizzaJobTimer = setTimer( bind(JobPizza.endPizzaShift,self),20000,1, player )
end

--// Loan-Formula = BASE_LOAN * ( distance / time )
function JobPizza:onPizzaDeliver( player, distance, time)
	local workFactor = distance / time
	local pay = math.floor( BASE_LOAN * workFactor )
	player:giveMoney(pay, "Pizza-Job")
end
