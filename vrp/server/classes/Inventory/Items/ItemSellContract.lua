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
	local amount = source:getInventory():getFreePlacesForItem("Handelsvertrag") > 0	
	if amount then
		if money >= 300 then 
			source:takeMoney( 300 )
			InventoryManager:getSingleton():getPlayerInventory(source):giveItem("Handelsvertrag", 1)
		end
	else source:sendError(_("Du besitzt zu viele Verkauspapiere!", source))
	end
end

function ItemSellContract:Event_OnSellRequest( player, price, veh )
	player = getPlayerFromName(player)
	if isElement( player ) then 
		local car = getPedOccupiedVehicle( source) 
		if car == veh then
			source.lastContract = player
			source:triggerEvent("closeVehicleContract")
			player:triggerEvent("vehicleConfirmSell", player, price, car, source)
			source:sendInfo(_("Ein Anfrage zum Kauf wurde abgeschickt!", source))
		else source:sendError(_("Du sitzt nicht im Fahrzeug!", source))
		end
	end
end

function ItemSellContract:Event_OnTradeSuceed( player, price, car )
	if isElement( player ) then 
		local money = client:getMoney()
		price = tonumber( price )
		if price > 0 then
			if player ~= client then
				if player.lastContract == client then
					if money >= price then
						client:triggerEvent("closeVehicleAccept")
						client:sendInfo(_("Der Handel wurde abgeschlossen!", client))
						player:sendInfo(_("Der Handel wurde abgeschlossen!", player))
						VehicleManager:getSingleton():removeRef( car, false)
						car:setOwner( client ) 
						car:setData("OwnerName", source.name, true)
						VehicleManager:getSingleton():addRef( car, false)
						client:takeMoney( price ) 
						player:giveMoney( price )
						car.m_Keys = {}
						VehicleManager:getSingleton():syncVehicleInfo( player )
						VehicleManager:getSingleton():syncVehicleInfo( client )
						player:getInventory():removeItem("Handelsvertrag", 1)
					else 
						source:sendError(_("Du hast nicht genügend Geld!", client))
						player:sendInfo(_("Der Käufer hat zu wenig Geld!", player))
					end
				player:sendError(_("Vertrag abgelaufen!", player))
				end
			else client:sendError(_("Sie können nicht selbst ihr Fahrzeug kaufen!", client))
			end
		else client:sendError(_("Ungültiger Betrag!", client))
		end
	end
end

function ItemSellContract:use(player)
	local veh = getPedOccupiedVehicle( player )
	if veh then 
		if veh:getOwner() == player:getId() then
			if veh:isPermanent() then
				local time = getRealTime()
				local dataTable = { time.monthday, time.month, time.year}
				triggerClientEvent("vehicleStartSell", player,dataTable )
			else player:sendError(_("Ungültiges Fahrzeug!", player))
			end
		else player:sendError(_("Dies ist nicht dein Fahrzeug!", player))
		end
	else player:sendError(_("Du musst in einem Fahrzeug drinnen sitzen!", player))
	end
end

