-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemSellContract.lua
-- *  PURPOSE:     SellContract Item Class
-- *
-- ****************************************************************************
ItemSellContract = inherit(Item)
addRemoteEvents{"VehicleSell_requestSell", "VehicleSell_tradeCar"}

function ItemSellContract:constructor()
	addEventHandler("VehicleSell_requestSell", root, bind( self.Event_OnSellRequest, self))
	addEventHandler("VehicleSell_tradeCar", root, bind( self.Event_OnTradeSuceed, self))
end

function ItemSellContract:destructor()

end

function ItemSellContract:Event_OnSellRequest( player, price, veh )
	player = getPlayerFromName(player)
	if isElement( player ) then 
		local car = getPedOccupiedVehicle( source) 
		if car == veh then
			player:triggerEvent("vehicleConfirmSell", player, price, car)
		else source:sendError(_("Du sitzt nicht im Fahrzeug!", source))
		end
	end
end

function ItemSellContract:Event_OnTradeSuceed( player, price, car )
	if isElement( player ) then 
		--player:triggerEvent("vehicleConfirmSell", player, price, car)
	end
end

function ItemSellContract:use(player)
	local veh = getPedOccupiedVehicle( player )
	if veh then 
		if veh:getOwner() == player:getId() then
			local time = getRealTime()
			local dataTable = { time.monthday, time.month, time.year}
			triggerClientEvent("vehicleStartSell", player,dataTable )
		else player:sendError(_("Dies ist nicht dein Fahrzeug!", player))
		end
	else player:sendError(_("Du musst in einem Fahrzeug drinnen sitzen!", player))
	end
end

