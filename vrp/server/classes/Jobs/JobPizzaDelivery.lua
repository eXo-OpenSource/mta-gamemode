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
	
	addEventHandler("onPlayerVehicleExit", root, bind(self.onPlayerVehicleExit, self))
	
end

function JobPizza:startPlayerShift( player ) 

end

function JobPizza:endPizzaShift ( player )

end

function JobPizza:onPlayerVehicleExit() 

end

function JobPizza:onPizzaDeliver() 

end

function JobPizza:onPizzaPickup()

end

function JobPizza:setNextDestination( player )

end
