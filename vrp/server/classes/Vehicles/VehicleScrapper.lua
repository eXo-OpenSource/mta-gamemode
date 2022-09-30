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

	self.m_VehicleScrapMarker = createMarker(2198.36, -1977.69, 12.5, "cylinder", 4, 58, 186, 242, 100)
	self.m_BoatScrapMarker = createMarker(2295.95, -2429.16, -1, "cylinder", 4, 58, 186, 242, 100)
	self.m_BoatScrapCol = createColSphere(2295.71, -2429.60, 2.5, 5)
	self.m_PlaneScrapMarker = createMarker(2075.95, -2637.55, 12.5, "cylinder", 4, 58, 186, 242, 100)
	self.m_PlaneScrapCol = createColSphere(2075.95, -2637.55, 14.5, 5)

	ElementInfo:new(self.m_VehicleScrapMarker, "Verschrottung", 1.2, "Car", true)
	ElementInfo:new(self.m_BoatScrapMarker, "Verschrottung", 1.2, "Ship", true)
	ElementInfo:new(self.m_PlaneScrapMarker, "Verschrottung", 1.2, "Plane", true)
	addEventHandler("onMarkerHit", self.m_VehicleScrapMarker, function(hE, dim)
		if (source:getDimension() == hE:getDimension()) and (hE:getInterior() == source:getInterior()) and hE.vehicle then
			hE:triggerEvent("onTryEnterExit", self.m_VehicleScrapMarker, "Verschrottung", "files/images/Other/info.png", 5, true) 
		end
	end)
	addEventHandler("onColShapeHit", self.m_BoatScrapCol, function(hE, dim)
		if (source:getDimension() == hE:getDimension()) and (hE:getInterior() == source:getInterior()) and hE.vehicle then
			hE:triggerEvent("onTryEnterExit", self.m_BoatScrapCol, "Verschrottung", "files/images/Other/info.png", 10, true) 
		end
	end)
	addEventHandler("onColShapeHit", self.m_PlaneScrapCol, function(hE, dim)
		if (source:getDimension() == hE:getDimension()) and (hE:getInterior() == source:getInterior()) and hE.vehicle then
			if hE.vehicle:getVehicleType() == VehicleType.Plane or hE.vehicle:getVehicleType() == VehicleType.Helicopter then
				hE:triggerEvent("onTryEnterExit", self.m_PlaneScrapCol, "Verschrottung", "files/images/Other/info.png", 10, true) 
			else
				hE:sendError(_("Du kannst hier nur Flugzeuge und Helikopter verschrotten.", hE))
			end
		end
	end)

	self.m_VehicleScrapYard = Blip:new("Scrap.png", 2198.86, -1977.5, root, 600)
	self.m_BoatScrapYard = Blip:new("Scrap.png",2295.95, -2429.16, root, 600)
	self.m_PlaneScrapYard = Blip:new("Scrap.png", 2075.95, -2637.55, root, 600)
	self.m_VehicleScrapYard:setDisplayText("Schrottplatz", BLIP_CATEGORY.VehicleMaintenance)
	self.m_BoatScrapYard:setDisplayText("Schrottplatz", BLIP_CATEGORY.VehicleMaintenance)
	self.m_PlaneScrapYard:setDisplayText("Schrottplatz", BLIP_CATEGORY.VehicleMaintenance)
	self.m_VehicleScrapYard:setOptionalColor({150, 150, 150})
	self.m_BoatScrapYard:setOptionalColor({150, 150, 150})
	self.m_PlaneScrapYard:setOptionalColor({150, 150, 150})
end


function VehicleScrapper:destructor() 

end

function VehicleScrapper:Event_onRequestScrap() 
	if Vector3(client.position - self.m_VehicleScrapMarker.position):getLength() < 5 or 
	Vector3(client.position - self.m_BoatScrapMarker.position):getLength() < 5 or
	Vector3(client.position - self.m_PlaneScrapMarker.position):getLength() < 5 then
		if client.vehicle then
			if client.vehicle:getOwner() == client:getId() then 
				local price = client.vehicle:getBuyPrice()
				if price then
					ShortMessageQuestion:new(client, client, _("Möchtest du dieses Fahrzeug für $%s verschrotten?", client, convertNumber(price*.1)), function(player)
						self:Event_onConfirmScrap(player)
					end, function() end, tocolor(0, 94, 255), client)
				else 
					client:sendError(_("Du kannst dieses Fahrzeug nicht Verschrotten!", client))
				end 
			else 
				client:sendError(_("Dieses Fahrzeug gehört dir nicht!", client))
			end
		end
	else return end
end

function VehicleScrapper:Event_onConfirmScrap(player) 
	if player.vehicle then
		if player.vehicle:getOwner() == player:getId() then 
			local price = player.vehicle:getBuyPrice()
			if price then
				QuestionBox:new(player, _("Möchtest du dieses Fahrzeug wirklich für $%s verschrotten?", player, convertNumber(price*.1)), function(player) 
					self:Event_onScrap(player)
				end, function() end, false, false, player)
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