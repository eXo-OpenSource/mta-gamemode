-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleScrapper.lua
-- *  PURPOSE:     VehicleScrapper class
-- *
-- ****************************************************************************
VehicleScrapper = inherit(Singleton)

function VehicleScrapper:constructor() 
	self.m_BankAccountServer = BankServer.get("server.scrapyard")
	addRemoteEvents{"VehicleScrapper:onVehicleScrapRequest"}
	addEventHandler("VehicleScrapper:onVehicleScrapRequest", root, bind(self.Event_onRequestScrap, self))

	self.m_ScrapMarker = createMarker(2198.36, -1977.69, 12.5, "cylinder", 4, 58, 186, 242, 100)
	ElementInfo:new(self.m_ScrapMarker, "Verschrottung", 1.2, "Car", true)
	addEventHandler("onMarkerHit", self.m_ScrapMarker, function(hE, dim)
		if (source:getDimension() == hE:getDimension()) and (hE:getInterior() == source:getInterior()) and hE.vehicle then
			hE:triggerEvent("onTryEnterExit", self.m_ScrapMarker, "Verschrottung", "files/images/Other/info.png", 5, true) 
		end
	end)
	
	self.m_ScrapYard = Blip:new("Scrap.png", 2198.86, -1977.5, root, 600)
	self.m_ScrapYard:setDisplayText("Schrottplatz", BLIP_CATEGORY.VehicleMaintenance)
	self.m_ScrapYard:setOptionalColor({150, 150, 150})
end


function VehicleScrapper:destructor() 

end

function VehicleScrapper:Event_onRequestScrap() 
	if Vector3(client.position - self.m_ScrapMarker.position):getLength() > 5 then return end
	if client.vehicle then
		if client.vehicle:getOwner() == client:getId() then 
			local price = client.vehicle:getBuyPrice()
			if price then
				ShortMessageQuestion:new(client, client, _("Möchtest du dieses Fahrzeug für $%s verschrotten?", client, convertNumber(price*.1)), function(player)
					self:Event_onConfirmScrap(player)
				end, function() end, client)
			else 
				client:sendError(_("Du kannst dieses Fahrzeug nicht Verschrotten!", client))
			end 
		else 
			client:sendError(_("Dieses Fahrzeug gehört dir nicht!", client))
		end
	end
end

function VehicleScrapper:Event_onConfirmScrap(player) 
	if player.vehicle then
		if player.vehicle:getOwner() == player:getId() then 
			local price = player.vehicle:getBuyPrice()
			if price then
				QuestionBox:new(player, player, _("Möchtest du dieses Fahrzeug wirklich für $%s verschrotten?", player, convertNumber(price*.1)), function(player) 
					self:Event_onScrap(player)
				end, function() end, player)
			end 
		end
	end
end


function VehicleScrapper:Event_onScrap(player) 
	if player then 
		if player.vehicle then
			if player.vehicle:getOwner() == player:getId() then 
				local price = player.vehicle:getBuyPrice()
				if price then 
					price = math.floor(price * .1)
					if not player.vehicle.m_Premium then 
						StatisticsLogger:getSingleton():addVehicleTradeLog(player.vehicle, player, 0, price, "server (Verschrottung)")
						player.vehicle:purge()
						self.m_BankAccountServer:transferMoney(player, price, "Fahrzeug-Verkauf", "Vehicle", "SellToServer (Scrap)")
						VehicleManager:getSingleton():Event_vehicleRequestInfo(player)
					else 
						player:sendError(_("Dieses Fahrzeug kann nicht verschrottet werden!", player))
					end
				else 
					player:sendError(_("Diese Fahrzeug hat keinen richtig ermittelbaren Preis!", player))
				end
			else 
				player:sendError(_("Diese Fahrzeug gehört nicht dir!", player))
			end
		else
			player:sendError(_("Du musst in einem Fahrzeug sitzen!", player))
		end
	end
end