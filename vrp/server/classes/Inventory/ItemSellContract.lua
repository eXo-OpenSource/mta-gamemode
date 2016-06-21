-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemSellContract.lua
-- *  PURPOSE:     SellContract Item Class
-- *
-- ****************************************************************************
ItemSellContract = inherit(Item)
addRemoteEvents{"VehicleSell_requestSell", "VehicleSell_tradeCar", "VehicleTransaction_OnBuyPapers"}

function ItemSellContract:constructor()
	addEventHandler("VehicleSell_requestSell", root, bind( self.Event_OnSellRequest, self))
	addEventHandler("VehicleSell_tradeCar", root, bind( self.Event_OnTradeSuceed, self))
	addEventHandler("VehicleTransaction_OnBuyPapers", root, bind( self.Event_OnBuyPapers, self ))
end

function ItemSellContract:destructor()

end

function ItemSellContract:Event_OnBuyPapers()
	local money = source:getMoney()
	if money >= 300 then 
		source:takeMoney( 300 )
		InventoryManager:getSingleton():getPlayerInventory(source):giveItem("Handelsvertrag", 1)
	end
end
function ItemSellContract:Event_OnSellRequest( player, price, veh )
	player = getPlayerFromName(player)
	if isElement( player ) then 
		local car = getPedOccupiedVehicle( source) 
		if car == veh then
			source:triggerEvent("closeVehicleContract")
			player:triggerEvent("vehicleConfirmSell", player, price, car)
			source:sendInfo(_("Ein Anfrage zum Kauf wurde abgeschickt!", source))
		else source:sendError(_("Du sitzt nicht im Fahrzeug!", source))
		end
	end
end

function ItemSellContract:Event_OnTradeSuceed( player, price, car )
	if isElement( player ) then 
		local money = source:getMoney()
		price = tonumber( price )
		if money >= price then
			player:triggerEvent("closeVehicleAccept")
			source:sendInfo(_("Der Handel wurde abgeschlossen!", source))
			player:sendInfo(_("Der Handel wurde abgeschlossen!", player))
			car:setOwner( player ) 
			setData(car, "OwnerName", player.name, true)
			player:takeMoney( price ) 
			source:giveMoney( price )
			InventoryManager:getSingleton():getPlayerInventory( source ):removeItem("Handelsvertrag", 1)
		else 
			source:sendError(_("Du hast nicht genügend Geld!", source))
			player:sendInfo(_("Der Käufer hat zu wenig Geld!", player))
		end
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

