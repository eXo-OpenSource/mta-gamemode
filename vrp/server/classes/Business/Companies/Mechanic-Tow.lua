MechanicTow = inherit(Company)
addRemoteEvents{"mechanicRepair", "mechanicRepairConfirm", "mechanicRepairCancel", "mechanicTakeVehicle"}

function MechanicTow:constructor()
	self.m_VehicleTakeMarker = Marker.create(920.614, -1176.063, 16.2, "cylinder", 1, 255, 255, 0)
	self:createTowLot()
	addEventHandler("onMarkerHit", self.m_VehicleTakeMarker, bind(self.VehicleTakeMarker_Hit, self))

	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
	addEventHandler("mechanicTakeVehicle", root, bind(self.Event_mechanicTakeVehicle, self))
end

function MechanicTow:destuctor()

end

function MechanicTow:respawnVehicle(vehicle)
	outputDebug("Respawning vehicle in mechanic base")
	vehicle:setCurrentPositionAsSpawn(VehiclePositionType.Mechanic)
	vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
	vehicle:fix()
end

function MechanicTow:VehicleTakeMarker_Hit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		-- Get a list of vehicles that need manual repairing
		local vehicles = {}
		for k, vehicle in pairs(VehicleManager:getSingleton():getPlayerVehicles(hitElement)) do
			if vehicle:getPositionType() == VehiclePositionType.Mechanic then
				vehicles[#vehicles + 1] = vehicle
			end
		end

		if #vehicles > 0 then
			-- Open "vehicle take GUI"
			hitElement:triggerEvent("vehicleTakeMarkerGUI", vehicles, "mechanicTakeVehicle")
		else
			hitElement:sendWarning(_("Keine abholbaren Fahrzeuge vorhanden!", hitElement))
		end
	end
end

function MechanicTow:Event_mechanicRepair()
	if client:getCompany() ~= self then
		return
	end

	local driver = source:getOccupant(0)
	if not driver then
		client:sendError(_("Jemand muss sich auf dem Fahrersitz befinden!", client))
		return
	end
	--[[if driver == client then
		client:sendError(_("Du kannst dein eigenes Fahrzeug nicht reparieren!", client))
		return
	end]]
	if source:getHealth() > 950 then
		client:sendError(_("Dieses Fahrzeug hat keine nennenswerten Beschädigungen!", client))
		return
	end

	source.PendingMechanic = client
	local price = math.floor((1000 - getElementHealth(source))*0.5)
	driver:triggerEvent("questionBox", _("Darf %s dein Fahrzeug reparieren? Dies kostet dich zurzeit %d$!\nBeim nächsten Pay'n'Spray zahlst du einen Aufschlag von +33%%!", client, getPlayerName(client), price), "mechanicRepairConfirm", "mechanicRepairCancel", source)
end

function MechanicTow:Event_mechanicRepairConfirm(vehicle)
	local price = math.floor((1000 - getElementHealth(vehicle))*0.5)
	if client:getMoney() >= price then
		fixVehicle(vehicle)
		client:takeMoney(price, "Mech&Tow")

		if vehicle.PendingMechanic then
			if client ~= vehicle.PendingMechanic then
				vehicle.PendingMechanic:giveMoney(price, "Mech & Tow Reparatur")
				vehicle.PendingMechanic:givePoints(5)
				vehicle.PendingMechanic:sendInfo(_("Du hast das Fahrzeug von %s erfolgreich repariert! Du hast %s$ verdient!", vehicle.PendingMechanic, getPlayerName(client), price))
				client:sendInfo(_("%s hat dein Fahrzeug erfolgreich repariert!", client, getPlayerName(vehicle.PendingMechanic)))

				self.m_BankAccount:addMoney(price*0.01)
			else
				client:sendInfo(_("Du hat dein Fahrzeug erfolgreich repariert!", client))
			end
			vehicle.PendingMechanic = nil
		end
	else
		client:sendError(_("Du hast nicht genügend Geld! Benötigt werden %d$!", client, price))
	end
end

function MechanicTow:Event_mechanicRepairCancel(vehicle)
	if vehicle.PendingMechanic then
		vehicle.PendingMechanic:sendWarning(_("Der Reperaturvorgang wurde von der Gegenseite abgebrochen!", vehicle.PendingMechanic))
		vehicle.PendingMechanic = nil
	end
end

function MechanicTow:Event_mechanicTakeVehicle()
	if client:getMoney() >= 500 then
		client:takeMoney(500, "Mech&Tow")
		source:fix()

		-- Spawn vehicle in non-collision zone
		source:setPositionType(VehiclePositionType.World)
		source:setDimension(0)
		local x, y, z, rotation = unpack(Randomizer:getRandomTableValue(self.SpawnPositions))
		source:setPosition(x, y, z)
		source:setRotation(0, 0, rotation)
		client:warpIntoVehicle(source)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end

function MechanicTow:createTowLot()
	self.m_TowColShape = createColRectangle( 809.78967, -1278.67761, 49, 49)
	addEventHandler("onColShapeHit", self.m_TowColShape, bind( self.onEnterTowLot, self ))
	addEventHandler("onColShapeLeave", self.m_TowColShape, bind( self.onLeaveTowLot, self ))
	addEventHandler("onTrailerDetach", getRootElement(), bind( self.onDetachVehicleFromTow, self ))
end

function MechanicTow:onEnterTowLot( hElement )
	local bType = getElementType(hElement) == "player"
	if bType then
		local veh = getPedOccupiedVehicle( hElement )
		if veh then
			if hElement:getCompany() == self then
				if veh:getCompany() == self then
					if getElementModel( veh ) == 525 then
						hElement.m_InTowLot = true
						hElement:sendInfo(_("Du kannst hier abgeschleppte Fahrzeuge abladen!", hElement))
					end
				end
			end
		end
	end
end

function MechanicTow:onLeaveTowLot( hElement )
	hElement.m_InTowLot = false
end

function MechanicTow:onDetachVehicleFromTow( towTruck )
	local driver = getVehicleOccupant( towTruck )
	if driver then
		if driver.m_InTowLot then
			if towTruck.getCompany then
				local comp = towTruck:getCompany()
				if comp == self then
					if source.getOwner then
						local owner = source:getOwner()
						if type(owner) == "number" then
							if not source.getCompany and not source.getFaction then
								self:respawnVehicle( source )
								driver:sendInfo(_("Das Fahrzeug ist nun abgeschleppt!", driver))
							end
						else driver:sendError(_("Dieses Fahrzeug kann nicht abgeschleppt werden!", driver))
						end
					else driver:sendError(_("Dieses Fahrzeug kann nicht abgeschleppt werden!", driver))
					end
				end
			end
		end
	end
end

MechanicTow.SpawnPositions = {
	{894.370, -1187.525, 16.704, 180},
	{924.837, -1192.842, 16.704, 90},
	--{1097.2, -1198.1, 17.70, 180},
	--{1091.7, -1198.3, 17.70, 180},
	--
}
