-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)

function JobPizza:constructor( ) 
	Job.constructor(self)

end

function JobPizza:start(player)
	VehicleSpawner:new(2102.41, -1785.12, 12.39, {509,448}, 90,  bind(JobPizza.additionalCheck, self),bind(JobPizza.onVehicleSpawn, self))
end

function JobPizza:onVehicleSpawn( vehicle, player )
	player.m_PizzaVeh = vehicle
	player.m_OldSkin = player:getModel()
	player:setModel( 155 )
	addEventHandler("onVehicleExit",vehicle,bind(JobPizza.onExitVehicle,self) )
	addEventHandler("onVehicleEnter",vehicle,bind(JobPizza.onEnterVehicle,self) )
	player:triggerEvent("nextPizzaDelivery")
end

function JobPizza:additionalCheck( player ) 
	if self:requireVehicle(player) then 	
		if not player.m_PizzaVeh then 
			return true
		else player:sendError(_("Sie besitzen bereits ein Lieferfahrzeug!" , player ))
		end
	end
	return false
end


function JobPizza:startPlayerShift( player ) 

end

function JobPizza:endPizzaShift ( player )
	destroyElement( player.m_PizzaVeh )
	player.m_PizzaVeh = nil
	player:setModel( player.m_OldSkin )
	player:triggerEvent("stopPizzaShift")
end

function JobPizza:onEnterVehicle( player ) 
	if isTimer(player.m_EndPizzaJobTimer) then 
		killTimer( player.m_EndPizzaJobTimer )
	end
end


function JobPizza:onExitVehicle( player ) 
	player:sendError(_("Du hast noch 20 Sekunden um wieder in den Pizza-Boy einzusteigen!" , player ))
	player.m_EndPizzaJobTimer = setTimer( bind(JobPizza.endPizzaShift,self),20000,1, player )
end


function JobPizza:onPizzaDeliver() 

end



