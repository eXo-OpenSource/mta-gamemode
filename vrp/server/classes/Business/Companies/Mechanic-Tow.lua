MechanicTow = inherit(Company)
addRemoteEvents{"mechanicRepair", "mechanicRepairConfirm", "mechanicRepairCancel", "mechanicTakeVehicle", "mechanicOpenTakeGUI"}

function MechanicTow:constructor()
	self:createTowLot()
	self.m_PendingQuestions = {}

	local safe = createObject(2332, 923.60, -1166.50, 17.70, 0, 0, 270)
	self:setSafe(safe)

	local x, y, z, rot

	self.m_NonCollissionCols = {}
	for index, pos in pairs(MechanicTow.SpawnPositions) do
		x, y, z, rot = unpack(pos)
		self.m_NonCollissionCols[index] = createColSphere(x, y, z, 10)
		self.m_NonCollissionCols[index]:setData("NonCollidingSphere", true, true)
	end

	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
	addEventHandler("mechanicTakeVehicle", root, bind(self.Event_mechanicTakeVehicle, self))
	addEventHandler("mechanicOpenTakeGUI", root, bind(self.VehicleTakeGUI, self))
end

function MechanicTow:destuctor()

end

function MechanicTow:respawnVehicle(vehicle)
	outputDebug("Respawning vehicle in mechanic base")
	vehicle:setPositionType(VehiclePositionType.Mechanic)
	vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
	vehicle:fix()
end

function MechanicTow:VehicleTakeGUI(vehicleType)
	local vehicleTable = {}

	if vehicleType == "permanentVehicle" then
		vehicleTable = VehicleManager:getSingleton():getPlayerVehicles(client)
	elseif vehicleType == "groupVehicle" then
		local group = client:getGroup()
		if not group then client:sendError(_("Du bist in keiner Gruppe!", client)) return end
		vehicleTable = VehicleManager:getSingleton():getGroupVehicles(group:getId())
	end

	-- Get a list of vehicles that need manual repairing
	local vehicles = {}
	for _, vehicle in pairs(vehicleTable) do
		if vehicle:getPositionType() == VehiclePositionType.Mechanic then
			table.insert(vehicles, vehicle)
		end
	end

	if #vehicles > 0 then
		-- Open "vehicle take GUI"
		-- Todo: Probably better: Trigger a vehicle table with different vehicle types and add specific tabs to VehicleTakeGUI
		client:triggerEvent("vehicleTakeMarkerGUI", vehicles, "mechanicTakeVehicle")
	else
		client:sendInfo(_("Keine abholbaren Fahrzeuge vorhanden!", client))
	end
end

function MechanicTow:Event_mechanicRepair()
	if client:getCompany() ~= self then
		return
	end
	if not client:isCompanyDuty() then
		client:sendError(_("Du bist nicht im Dienst!", client))
		return
	end

	local driver = source:getOccupant(0)
	if not driver then
		client:sendError(_("Jemand muss sich auf dem Fahrersitz befinden!", client))
		return
	end
	if driver == client then
		client:sendError(_("Du kannst dein eigenes Fahrzeug nicht reparieren!", client))
		return
	end
	if source:getHealth() > 950 then
		client:sendError(_("Dieses Fahrzeug hat keine nennenswerten Beschädigungen!", client))
		return
	end

	if not source:isRepairAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht repariert werden!", client))
		return
	end

	source.PendingMechanic = client
	local price = math.floor((1000 - getElementHealth(source))*0.5)

	if self.m_PendingQuestions[client] and not timestampCoolDown(self.m_PendingQuestions[client], 60) then
		client:sendError(_("Du kannst nur jede Minute eine Reparatur-Anfrage stellen!", client))
		return
	end

	self.m_PendingQuestions[client] = getRealTime().timestamp
	driver:triggerEvent("questionBox", _("Darf %s dein Fahrzeug reparieren? Dies kostet dich zurzeit %d$!\nBeim nächsten Pay'n'Spray zahlst du einen Aufschlag von +33%%!", client, getPlayerName(client), price), "mechanicRepairConfirm", "mechanicRepairCancel", source)

end

function MechanicTow:Event_mechanicRepairConfirm(vehicle)
	local price = math.floor((1000 - getElementHealth(vehicle))*0.5)
	if client:getMoney() >= price then
		fixVehicle(vehicle)
		client:takeMoney(price, "Mech&Tow")

		if vehicle.PendingMechanic then
			if client ~= vehicle.PendingMechanic then
				vehicle.PendingMechanic:giveMoney(math.floor(price*0.3), "Mech & Tow Reparatur")
				vehicle.PendingMechanic:givePoints(5)
				vehicle.PendingMechanic:sendInfo(_("Du hast das Fahrzeug von %s erfolgreich repariert! Du hast %s$ verdient!", vehicle.PendingMechanic, getPlayerName(client), price))
				client:sendInfo(_("%s hat dein Fahrzeug erfolgreich repariert!", client, getPlayerName(vehicle.PendingMechanic)))

				self:giveMoney(math.floor(price*0.7), "Reparatur")
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
		self:giveMoney(500, "Fahrzeug freikauf")
		source:fix()

		-- Spawn vehicle in non-collision zone
		source:setPositionType(VehiclePositionType.World)
		source:setDimension(0)
		local x, y, z, rotation = unpack(Randomizer:getRandomTableValue(self.SpawnPositions))


		if source:getVehicleType() == VehicleType.Plane then
			x, y, z, rotation = 871.285, -1264.624, 15.5, 0
		elseif source:getVehicleType() == VehicleType.Helicopter then
			x, y, z, rotation =  912.602, -1252.053, 16, 0
		end

		source:setPosition(x, y, z)
		source:setRotation(0, 0, rotation)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end

function MechanicTow:createTowLot()
	self.m_TowColShape = createColRectangle( 809.78967, -1278.67761, 49, 49)
	addEventHandler("onColShapeHit", self.m_TowColShape, bind( self.onEnterTowLot, self ))
	addEventHandler("onColShapeLeave", self.m_TowColShape, bind( self.onLeaveTowLot, self ))
	addEventHandler("onTrailerAttach", getRootElement(), bind(self.onAttachVehicleToTow, self))
	addEventHandler("onTrailerDetach", getRootElement(), bind( self.onDetachVehicleFromTow, self ))
end

function MechanicTow:onEnterTowLot( hElement )
	local bType = getElementType(hElement) == "player"
	if bType then
		local veh = getPedOccupiedVehicle( hElement )
		if veh then
			if hElement:getCompany() == self then
				if instanceof(veh, CompanyVehicle) and veh:getCompany() == self then
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

function MechanicTow:onAttachVehicleToTow(towTruck)
	local driver = getVehicleOccupant( towTruck )
	if driver then
		if towTruck.getCompany and towTruck:getCompany() == self then
			if instanceof(source, PermanentVehicle, true) or instanceof(source, GroupVehicle, true) then
				source:toggleRespawn(false)
			else
				driver:sendInfo(_("Dieses Fahrzeug kann nicht abgeschleppt werden!", driver))
			end
		end
	end
end

function MechanicTow:onDetachVehicleFromTow( towTruck )
	source:toggleRespawn(true)

	local driver = getVehicleOccupant( towTruck )
	if driver and driver.m_InTowLot then
		if towTruck.getCompany and towTruck:getCompany() == self then
			if instanceof(source, PermanentVehicle, true) or instanceof(source, GroupVehicle, true) then
				self:respawnVehicle(source)
				driver:sendInfo(_("Das Fahrzeug ist nun abgeschleppt!", driver))
				StatisticsLogger:getSingleton():vehicleTowLogs(driver, source)
				self:addLog(driver, "Abschlepp-Logs", ("hat ein Fahrzeug (%s) von %s abgeschleppt!"):format(source:getName(), getElementData(source, "OwnerName") or "Unbekannt"))
			else
				driver:sendError(_("Dieses Fahrzeug kann nicht abgeschleppt werden!", driver))
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
