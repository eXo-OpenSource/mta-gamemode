-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleManager.lua
-- *  PURPOSE:     Vehicle manager class
-- *
-- ****************************************************************************
VehicleManager = inherit(Singleton)
VehicleManager.sPulse = TimedPulse:new(5*1000)

function VehicleManager:constructor()
	self.m_Vehicles = {}
	self.m_TemporaryVehicles = {}
	self.m_CompanyVehicles = {}
	self.m_GroupVehicles = {}
	self.m_FactionVehicles = {}
	self:setSpeedLimits()

	-- Add events
	addRemoteEvents{"vehicleLock", "vehicleRequestKeys", "vehicleAddKey", "vehicleRemoveKey",
		"vehicleRepair", "vehicleRespawn", "vehicleRespawnWorld", "vehicleDelete", "vehicleSell", "vehicleSellAccept", "vehicleRequestInfo",
		"vehicleUpgradeGarage", "vehicleHotwire", "vehicleEmpty", "vehicleSyncMileage", "vehicleBreak", "vehicleUpgradeHangar", "vehiclePark",
		"soundvanChangeURL", "soundvanStopSound", "vehicleToggleHandbrake", "onVehicleCrash","checkPaintJobPreviewCar", "vehicleGetTuningList"}

	addEventHandler("vehicleLock", root, bind(self.Event_vehicleLock, self))
	addEventHandler("vehicleRequestKeys", root, bind(self.Event_vehicleRequestKeys, self))
	addEventHandler("vehicleAddKey", root, bind(self.Event_vehicleAddKey, self))
	addEventHandler("vehicleRemoveKey", root, bind(self.Event_vehicleRemoveKey, self))
	addEventHandler("vehicleRepair", root, bind(self.Event_vehicleRepair, self))
	addEventHandler("vehicleRespawn", root, bind(self.Event_vehicleRespawn, self))
	addEventHandler("vehicleRespawnWorld", root, bind(self.Event_vehicleRespawnWorld, self))
	addEventHandler("vehicleDelete", root, bind(self.Event_vehicleDelete, self))
	addEventHandler("vehicleSell", root, bind(self.Event_vehicleSell, self))
	addEventHandler("vehicleSellAccept", root, bind(self.Event_acceptVehicleSell, self))
	addEventHandler("vehicleRequestInfo", root, bind(self.Event_vehicleRequestInfo, self))
	addEventHandler("vehicleUpgradeGarage", root, bind(self.Event_vehicleUpgradeGarage, self))
	addEventHandler("vehicleHotwire", root, bind(self.Event_vehicleHotwire, self))
	addEventHandler("vehicleEmpty", root, bind(self.Event_vehicleEmpty, self))
	addEventHandler("vehicleSyncMileage", root, bind(self.Event_vehicleSyncMileage, self))
	addEventHandler("vehicleBreak", root, bind(self.Event_vehicleBreak, self))
	addEventHandler("vehicleUpgradeHangar", root, bind(self.Event_vehicleUpgradeHangar, self))
	addEventHandler("vehiclePark", root, bind(self.Event_vehiclePark, self))
	addEventHandler("vehicleToggleHandbrake", root, bind(self.Event_toggleHandBrake, self))
	addEventHandler("soundvanChangeURL", root, bind(self.Event_soundvanChangeURL, self))
	addEventHandler("soundvanStopSound", root, bind(self.Event_soundvanStopSound, self))
	addEventHandler("onTrailerAttach", root, bind(self.Event_TrailerAttach, self))
	addEventHandler("onVehicleCrash", root, bind(self.Event_OnVehicleCrash, self))
	addEventHandler("onElementDestroy", root, bind(self.Event_OnElementDestroy,self))
	addEventHandler("vehicleGetTuningList",root,bind(self.Event_GetTuningList, self))



	addEventHandler("checkPaintJobPreviewCar", root, function()
		if client then
			local occVeh = getPedOccupiedVehicle(client)
			if occVeh then
				if occVeh.m_Owner == client:getId() then
					triggerClientEvent("onClientPreviewVehicleChecked", client, occVeh)
				end
			end
		end
	end)
	-- Check Licenses
	addEventHandler("onVehicleStartEnter", root,
		function (player, seat)
			if player:getType() ~= "player" then return end
			if seat == 0 then
				self:checkVehicle(source)

				if not source:isLocked() then
					local vehicleType = source:getVehicleType()
					if (vehicleType == VehicleType.Plane or vehicleType == VehicleType.Helicopter) and not player:hasPilotsLicense() and not player:getPublicSync("inDrivingLession") == true then
						player:removeFromVehicle(source)
						player:setPosition(source.matrix:transformPosition(-1.5, 5, 0))
						player:sendShortMessage(_("Du hast keinen Flugschein!", player))
					elseif vehicleType == Vehicle.Automobile and not player:hasDrivingLicense() then
						player:sendShortMessage(_("Du hast keinen Führerschein! Lass dich nicht erwischen!", player))
					end
				end
			end
		end
	)

	-- Prevent the engine from being turned on
	addEventHandler("onVehicleEnter", root,
		function(player, seat, jackingPlayer)
			if player:getType() ~= "player" then return end
			if seat == 0 then
				self:checkVehicle(source)

				setVehicleEngineState(source, source:getEngineState())
				player:triggerEvent("vehicleFuelSync", source:getFuel())
			end
		end
	)
	VehicleManager.sPulse:registerHandler(bind(VehicleManager.removeUnusedVehicles, self))

	setTimer(bind(self.updateFuelOfPermanentVehicles, self), 60*1000, 0)

	self.NonOptionalTextures = --// Textures that cant be toggled off
	{
		FactionVehicle,
		CompanyVehicle,
	}
end

function VehicleManager:destructor()
	local st, count = getTickCount(), 0
	for ownerId, vehicles in pairs(self.m_Vehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
			count = count + 1
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s private_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	for companyId, vehicles in pairs(self.m_CompanyVehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
			count = count + 1
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s company_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	for groupId, vehicles in pairs(self.m_GroupVehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
			count = count + 1
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s group_vehicles in %sms"):format(count, getTickCount()-st)) end

	local st, count = getTickCount(), 0
	for factionId, vehicles in pairs(self.m_FactionVehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
			count = count + 1
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Saved %s faction_vehicles in %sms"):format(count, getTickCount()-st)) end
end

function VehicleManager:Event_OnElementDestroy()
	if getElementType(source) == "vehicle" then
		local occs = getVehicleOccupants( source )
		if occs then
			for seat, player in pairs(occs) do
				if player then
					player.m_SeatBelt = false
					setElementData(player,"isBuckeled", false)
				end
			end
		end
	end
end

function VehicleManager:Event_OnRadioChange( vehicle, radio)
	if vehicle and radio then

	end
end

function VehicleManager:Event_GetTuningList()
	source:getTuningList(client)
end

function VehicleManager:getFactionVehicles(factionId)
	return self.m_FactionVehicles[factionId]
end

function VehicleManager:getCompanyVehicles(companyId)
	return self.m_CompanyVehicles[companyId]
end

function VehicleManager:getGroupVehicles(groupId)
	return self.m_GroupVehicles[groupId]
end

function VehicleManager:getPlayerVehicleById(playerId, vehicleId)
	for _, vehicle in pairs(self:getPlayerVehicles(playerId)) do
		if vehicle:getId() == vehicleId then
			return vehicle
		end
	end
end

function VehicleManager:createVehiclesForPlayer(player)
	if player then
		local id = player:getId()
		if id then
			if not self.m_Vehicles[id] then
				self.m_Vehicles[id] = {}
			end
			local result = sql:queryFetch("SELECT * FROM ??_vehicles WHERE Owner = ?", sql:getPrefix(), id)
			local vehicleObj
			local skip = false
			for i, row in pairs( result ) do
				for i = 1, #self.m_Vehicles[id] do
					vehicleObj = self.m_Vehicles[id][i]
					if vehicleObj then
						if vehicleObj.m_Id == row.Id then
							skip = true
						end
					end
				end
				if not skip then
					local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, row.RotX or 0, row.RotY or 0, row.Rotation or 0)
					enew(vehicle, PermanentVehicle, tonumber(row.Id), row.Owner, fromJSON(row.Keys or "[ [ ] ]"), row.Health, row.PositionType, row.Mileage, row.Fuel, row.TrunkId, row.Premium, row.TuningsNew)
					VehicleManager:getSingleton():addRef(vehicle, false)
				end
				skip = false
			end
		end
	end
end

function VehicleManager:destroyUnusedVehicles( player )
	if player then
		local vehTable = self:getPlayerVehicles(player)
		if vehTable then
			local counter = 0
			for k , vehicle in pairs(vehTable) do
				if vehicle then
					if vehicle.m_HasBeenUsed then
						if vehicle.m_HasBeenUsed == 0 then
							destroyElement(vehicle)
							counter = counter + 1
						end
					end
				end
			end
			--outputDebugString("[Vehicle-Manager] Cleaned "..counter.." vehicles for player "..getPlayerName(player).."!",3,0,200,0)
			outputServerLog("[Vehicle-Manager] Cleaned "..counter.." vehicles for player "..getPlayerName(player).."!",3,0,200,0)
		end
	end
end

function VehicleManager.loadVehicles()
	local st, count = getTickCount(), 0
	--[[
	outputServerLog("Loading vehicles...")
	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation or 0)
		enew(vehicle, PermanentVehicle, tonumber(row.Id), row.Owner, fromJSON(row.Keys or "[ [ ] ]"), row.Color, row.Color2, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage, row.Fuel, row.LightColor, row.TrunkId, row.TexturePath, row.Horn, row.Neon, row.Special)
		VehicleManager:getSingleton():addRef(vehicle, false)
	end
	]]--
	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT * FROM ??_company_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
		enew(vehicle, CompanyVehicle, tonumber(row.Id), CompanyManager:getSingleton():getFromId(row.Company), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage)
		VehicleManager:getSingleton():addRef(vehicle, false)
		count = count + 1
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s company_vehicles in %sms"):format(count, getTickCount()-st)) end
	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT * FROM ??_faction_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		if FactionManager:getFromId(row.Faction) then
			local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
			enew(vehicle, FactionVehicle, tonumber(row.Id), FactionManager:getFromId(row.Faction), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage, row.handling, row.decal)
			VehicleManager:getSingleton():addRef(vehicle, false)
			count = count + 1
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s faction_vehicles in %sms"):format(count, getTickCount()-st)) end
	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT * FROM ??_group_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		if GroupManager:getFromId(row.Group) then
			local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, row.RotX or 0, row.RotY or 0, row.Rotation)
			enew(vehicle, GroupVehicle, tonumber(row.Id), GroupManager:getFromId(row.Group), row.Health, row.PositionType, row.Mileage, row.Fuel, row.TrunkId, row.TuningsNew, row.Premium, nil, nil, row.ForSale, row.SalePrice)
			if not row.ForSale == 1 then
				setElementDimension(vehicle,PRIVATE_DIMENSION_SERVER)
				vehicle.m_IsNotSpawnedYet = true
			end
			VehicleManager:getSingleton():addRef(vehicle, false)
			count = count + 1
		else
			sql:queryExec("DELETE FROM ??_group_vehicles WHERE ID = ?", sql:getPrefix(), row.Id)
		end
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s group_vehicles in %sms"):format(count, getTickCount()-st)) end
end

function VehicleManager:addRef(vehicle, isTemp)
	if isTemp then
		self.m_TemporaryVehicles[#self.m_TemporaryVehicles+1] = vehicle
		return
	end
	if instanceof(vehicle, CompanyVehicle) then
		local companyId = vehicle:getCompany() and vehicle:getCompany():getId()
		assert(companyId, "Bad company specified")

		if not self.m_CompanyVehicles[companyId] then
			self.m_CompanyVehicles[companyId] = {}
		end

		table.insert(self.m_CompanyVehicles[companyId], vehicle)
		return
	end
	if instanceof(vehicle, GroupVehicle) then
		local groupId = vehicle:getGroup() and vehicle:getGroup():getId()
		assert(groupId, "Bad group specified")

		if not self.m_GroupVehicles[groupId] then
			self.m_GroupVehicles[groupId] = {}
		end

		table.insert(self.m_GroupVehicles[groupId], vehicle)
		return
	end
	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction() then
		local factionId = vehicle:getFaction() and vehicle:getFaction():getId()
		assert(factionId, "Bad owner specified")

		if not self.m_FactionVehicles[factionId] then
			self.m_FactionVehicles[factionId] = {}
		end

		table.insert(self.m_FactionVehicles[factionId], vehicle)
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")

	if not self.m_Vehicles[ownerId] then
		self.m_Vehicles[ownerId] = {}
	end

	table.insert(self.m_Vehicles[ownerId], vehicle)
end

function VehicleManager:removeRef(vehicle, isTemp)
	if isTemp then
		local idx = table.find(self.m_TemporaryVehicles, vehicle)
		if idx then
			table.remove(self.m_TemporaryVehicles, idx)
		end
		return
	end
	if instanceof(vehicle, CompanyVehicle) and vehicle:getCompany() then
		local companyId = vehicle:getCompany() and vehicle:getCompany():getId()
		assert(companyId, "Bad company specified")

		if self.m_CompanyVehicles[companyId] then
			local idx = table.find(self.m_CompanyVehicles[companyId], vehicle)
			if idx then
				table.remove(self.m_CompanyVehicles[companyId], idx)
			end
		end
		return
	end

	if instanceof(vehicle, GroupVehicle) and vehicle:getGroup() then
		local groupId = vehicle:getGroup() and vehicle:getGroup():getId()
		assert(groupId, "Bad company specified")

		if self.m_GroupVehicles[groupId] then
			local idx = table.find(self.m_GroupVehicles[groupId], vehicle)
			if idx then
				table.remove(self.m_GroupVehicles[groupId], idx)
			end
		end
		return
	end

	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction() then
		local factionId = vehicle:getFaction() and vehicle:getFaction():getId()
		assert(factionId, "Bad faction specified")

		if self.m_FactionVehicles[factionId] then
			local idx = table.find(self.m_FactionVehicles[factionId], vehicle)
			if idx then
				table.remove(self.m_FactionVehicles[factionId], idx)
			end
		end
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")

	if self.m_Vehicles[ownerId] then
		local idx = table.find(self.m_Vehicles[ownerId], vehicle)
		if idx then
			table.remove(self.m_Vehicles[ownerId], idx)
		end
	end
end

function VehicleManager:removeUnusedVehicles()
	-- ToDo: Lateron, do not loop through all vehicles
	for ownerid, data in pairs(self.m_Vehicles) do
		for k, vehicle in pairs(data) do
			if vehicle:isBlown() then
				if vehicle:getVehicleType() == VehicleType.Automobile or vehicle:getVehicleType() == VehicleType.Bike then
					outputDebug("Respawning blown vehicle in mechanic base")
					vehicle:setPositionType(VehiclePositionType.Mechanic)
					vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
					respawnVehicle(vehicle)

					CompanyManager:getSingleton():getFromId(2):addLog(nil, "Respawn-Log", ("%s von %s wurde zerstört und respawnt!"):format(vehicle:getName(), Account.getNameFromId(vehicle:getOwner()) or "-"))
				else
					vehicle:respawn()
				end
			end
		end
	end

	for k, vehicle in pairs(self.m_TemporaryVehicles) do
		if vehicle and isElement(vehicle) then
			if vehicle:isRespawnAllowed() then
				if vehicle:getHealth() < 0.1 and vehicle:getLastUseTime() < getTickCount() - 1*60*1000 then
					vehicle:respawn()
				else
					if vehicle:getLastUseTime() < getTickCount() - 2*60*1000 then
						if vehicle:getModel() == 435 then
							if vehicle:getTowingVehicle() then
								return
							end
						end

						vehicle:respawn()
					end
				end
			end
		else
			self.m_TemporaryVehicles[k] = nil
		end
	end
end

function VehicleManager:getPlayerVehicles(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	return self.m_Vehicles[player] or {}
end

function VehicleManager:savePlayerVehicles(player)
	for k, vehicle in pairs(self:getPlayerVehicles(player)) do
		vehicle:save()
	end
end

function VehicleManager:refreshGroupVehicles(group)
	local groupId = group:getId()
	if not groupId then
		outputDebug("VehicleManager:refreshGroupVehicles: Group-Id Not Found!")
		return
	end
	-- Delete old Group Vehicles
	if self.m_GroupVehicles[groupId] then
		for index, veh in pairs(self.m_GroupVehicles[groupId]) do
			veh:destroy()
		end
	end
	-- Reload Group Vehicles from DB
	local result = sql:queryFetch("SELECT * FROM ??_group_vehicles WHERE `Group` = ?", sql:getPrefix(), groupId)
	for i, row in pairs(result) do
		if GroupManager:getFromId(row.Group) then
			local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
			enew(vehicle, GroupVehicle, tonumber(row.Id), GroupManager:getFromId(row.Group), row.Health, row.PositionType, row.Mileage, row.Fuel, row.TrunkId, row.TuningsNew, row.Premium, nil, nil, row.ForSale, row.SalePrice)
			if not row.ForSale == 1 then
				setElementDimension(vehicle,PRIVATE_DIMENSION_SERVER)
				vehicle.m_IsNotSpawnedYet = true
			end
			VehicleManager:getSingleton():addRef(vehicle, false)
		else
			sql:queryExec("DELETE FROM ??_group_vehicles WHERE ID = ?", sql:getPrefix(), row.Id)
		end
	end
end

function VehicleManager:updateFuelOfPermanentVehicles()
	for k, player in pairs(getElementsByType("player")) do
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle and vehicle.getFuel and vehicle:getEngineState() then
			local fuelConsumption = 0.5
			if vehicle.getSpeed and vehicle:getSpeed()/100 > fuelConsumption then
				fuelConsumption = math.abs(vehicle:getSpeed()/100)
			end
			vehicle:setFuel(vehicle:getFuel() - fuelConsumption)
		end
	end
end

function VehicleManager:checkVehicle(vehicle)
	-- Lightweight instanceof(vehicle, Vehicle)
	if not vehicle.toggleLight then
		-- Make a temporary vehicle if vehicle is not yet instance of any class
		enew(vehicle, TemporaryVehicle)
	end
end

function VehicleManager:Event_vehiclePark()
 	if not source or not isElement(source) then return end
 	self:checkVehicle(source)
	if source:isPermanent() or instanceof(source, GroupVehicle) then
		if source:hasKey(client) or client:getRank() >= RANK.Moderator or (instanceof(source, GroupVehicle) and  client:getGroup() and source:getGroup() and source:getGroup() == client:getGroup() and client:getGroup():getPlayerRank(client) >= GroupRank.Manager) then
			if source:isBroken() then
				client:sendError(_("Dein Fahrzeug ist kaputt und kann nicht geparkt werden!", client))
				return
			end

			if source:isInGarage() then
				source:setCurrentPositionAsSpawn(VehiclePositionType.Garage)
				client:sendInfo(_("Du hast das Fahrzeug erfolgreich in der Garage geparkt!", client))
				return
			end
			if source:getInterior() == 0 then
				source:setCurrentPositionAsSpawn(VehiclePositionType.World)
				client:sendInfo(_("Du hast das Fahrzeug erfolgreich geparkt!", client))
			else
				client:sendError(_("Du kannst dein Fahrzeug hier nicht parken!", client))
			end
		else
			client:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug", client))
		end
	else
		client:sendError(_("Dieses Fahrzeug kann nicht geparkt werden!", client))
	end
 end

function VehicleManager:Event_toggleHandBrake()
	if client:getCompany() and client:getCompany():getId() == CompanyStaticId.MECHANIC or client:getRank() >= RANK.Moderator then
		if source.m_HandBrake then
			source:toggleHandBrake(client)
			client:sendSuccess(_("Die Handbremse wurde gelöst!", client))

			if client:getCompany() and client:getCompany():getId() == CompanyStaticId.MECHANIC then
				client:getCompany():addLog(client, "Handbremsen-Logs", ("hat eine Handbremse gelöst. %s von %s"):format(source:getName(), getElementData(source, "OwnerName") or "Unbekannt"))
			end
		else
			client:sendError(_("Die Handbremse ist nicht angezogen!", client))
		end
	else
		client:sendError(_("Du bist nicht berechtigt!", client))
	end
end

function VehicleManager:setSpeedLimits()
	setModelHandling(462, "maxVelocity", 50) -- Faggio
	setModelHandling(509, "maxVelocity", 50) -- Bike
	setModelHandling(481, "maxVelocity", 50) -- BMX
	setModelHandling(510, "maxVelocity", 50) -- Mountain Bike
end

function VehicleManager:syncVehicleInfo(player)
	player:triggerEvent("vehicleRetrieveInfo", self:getVehiclesFromPlayer(player), player:getGarageType(), player:getHangarType())
end

function VehicleManager:Event_OnVehicleCrash( veh, loss )
	if veh:getVehicleType() == VehicleType.Plane or veh:getVehicleType() == VehicleType.Helicopter then
		return false
	end
	local occupants = getVehicleOccupants(veh)
	local speedx, speedy, speedz = getElementVelocity ( veh )
	local sForce = (speedx^2 + speedy^2 + speedz^2)^(0.5)
	local tickCount = getTickCount()
	if getPedOccupiedVehicle(source) == veh then
		if sForce >0.4 and loss*0.1 >= 2  then
			for seat, player in pairs(occupants) do
				if getElementType(player) == "player" then
					local playerHealth = getElementHealth(player)
					local bIsKill = (playerHealth - loss*0.02)  <= 0
					if not player.m_SeatBelt then
						if not bIsKill then
							setElementHealth(player, playerHealth - loss*0.02)
						else
							setElementHealth(player, 1)
						end
					end
					if sForce < 0.85 then
						if not player.m_lastInjuryMe then
							player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
							player.m_lastInjuryMe = tickCount
						elseif player.m_lastInjuryMe + 5000 <= tickCount then
							player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
							player.m_lastInjuryMe = tickCount
						end
						setPedAnimation(player, "ped", "hit_walk",700,true,false,false)
						setTimer(setPedAnimation, 700,2, player, nil)
					elseif sForce >= 0.85 then
						if not player.m_SeatBelt then
							player:meChat(true, "erleidet innere Blutungen durch den Aufprall!")
							removePedFromVehicle(player)
							setPedAnimation(player, "crack", "crckdeth2",5000,false,false,false)
							setTimer(setPedAnimation, 5000,1, player, nil)
						elseif player.m_SeatBelt == veh then
							if not player.m_lastInjuryMe then
								player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
								player.m_lastInjuryMe = tickCount
							elseif player.m_lastInjuryMe + 5000 <= tickCount then
								player:meChat(true, "wird im Fahrzeug umhergeschleudert!")
								player.m_lastInjuryMe = tickCount
							end
						else
							player:meChat(true, "erleidet innere Blutungen durch den Aufprall!")
							removePedFromVehicle(player)
							setPedAnimation(player, "crack", "crckdeth2",5000,false,false,false)
							setTimer(setPedAnimation, 5000,1, player, nil)
						end
					end
					player:triggerEvent("clientBloodScreen")
				end
			end
		end
	end
end

function VehicleManager:getVehiclesFromPlayer()
	local vehicles = {}
	for k, vehicle in pairs(self:getPlayerVehicles(client)) do
		vehicles[vehicle:getId()] = {vehicle, vehicle:getPositionType()}
	end
	return vehicles
end

function VehicleManager:Event_vehicleLock()
	if not source or not isElement(source) then return end
	self:checkVehicle(source)

	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		source:playLockEffect()
		source:setLocked(not source:isLocked())
		return
	end

	client:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug", client))
end

function VehicleManager:Event_vehicleRequestKeys()
	if not instanceof(source, PermanentVehicle, true) then
		triggerClientEvent(client, "vehicleKeysRetrieve", source, false)
		return
	end

	local names = source:getKeyNameList()
	triggerClientEvent(client, "vehicleKeysRetrieve", source, names)
end

function VehicleManager:Event_vehicleAddKey(player)
	if not player or not isElement(player) then return end
	if not player:isLoggedIn() then return end
	if not instanceof(source, PermanentVehicle, true) then return end

	if not source:isPermanent() then
		client:sendError(_("Nur permanente Fahrzeuge können Schlüssel haben!", client))
		return
	end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	if source:hasKey(player:getId()) then
		client:sendWarning(_("Dieser Spieler besitzt bereits einen Schlüssel!", client))
		return
	end

	-- Finally, add the key
	source:addKey(player)

	-- Give achievement
	client:giveAchievement(70)

	-- Tell the client that we added a new key
	triggerClientEvent(client, "vehicleKeysRetrieve", source, source:getKeyNameList())

	player:sendShortMessage(_("Du hast einen Fahrzeugschlüssel von %s erhalten! (%s)", player, client:getName(), source:getName()))
	client:sendShortMessage(_("Du hast %s einen Fahrzeugschlüssel gegeben! (%s)", client, player:getName(), source:getName()))
end

function VehicleManager:Event_vehicleRemoveKey(characterId)
	if not source:hasKey(characterId) then
		client:sendWarning(_("The specified player is not in possession of a key", client))
		return
	end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	-- Finally, remove the key
	source:removeKey(characterId)

	-- Tell the client that we removed the key
	triggerClientEvent(client, "vehicleKeysRetrieve", source, source:getKeyNameList())

	client:sendShortMessage(_("Du hast dem Spieler einen Fahrzeugschlüssel abgenommen! (%s)", client, source:getName()))
end

function VehicleManager:Event_vehicleRepair()
	if client:getRank() < RANK.Moderator then
		AntiCheat:getSingleton():report(client, "DisallowedEvent", CheatSeverity.High)
		return
	end

	source:fix()
end

function VehicleManager:Event_vehicleRespawn(garageOnly)
	self:checkVehicle(source)

	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht respawnt werden!", client))
		return
	end

	if source:getOccupantsCount() > 0 then
		client:sendError(_("Das Fahrzeug ist nicht leer!", client))
		return
	end

	if not instanceof(source, PermanentVehicle) then
		client:sendError(_("Das ist kein permanentes Server Fahrzeug!", client))
		return
	end

	if instanceof(source, FactionVehicle) then
		if client:getRank() >= RANK.Moderator then
			source:respawn(true)
			return
		else
			if (not client:getFaction()) or source:getFaction():getId() ~= client:getFaction():getId() then
				client:sendError(_("Dieses Fahrzeug ist nicht von deiner Fraktion!", client))
				return
			end
			source:respawn()
			return
		end
	end
	if instanceof(source, CompanyVehicle) then
		if client:getRank() >= RANK.Moderator then
			source:respawn( true )
			return
		else
			if (not client:getCompany()) or source:getCompany():getId() ~= client:getCompany():getId() then
				client:sendError(_("Diese Fahrzeug ist nicht von deiner Firma!", client))
				return
			end
			source:respawn( )
		end
	end

	if instanceof(source, GroupVehicle) then
		if (client:getRank() >= RANK.Moderator) then
			source:respawn( true )
			return
		else
			if (not client:getGroup()) or source:getGroup():getId() ~= client:getGroup():getId() then
				client:sendError(_("Diese Fahrzeug ist nicht von deiner Gruppe!", client))
				return
			end
			local group = client:getGroup()
			if not source.m_IsNotSpawnedYet then
				if group:getMoney() >= 100 then
					group:takeMoney(100, "Fahrzeug-Respawn")
					group:sendShortMessage(_("%s hat ein Fahrzeug deiner %s respawnt! (%s)", client, client:getName(), group:getType(), source:getName()))
				else
					client:sendError(_("In euerer %s-Kasse befindet sich nicht genug Geld! (100$)", client, group:getType()))
					return
				end
			else
				client:sendShortMessage(_("Du hast das Fahrzeug kostenlos gespawnt!", client))
				group:sendShortMessage(_("%s hat ein Fahrzeug deiner %s kostenlos gespawnt! (%s)", client, client:getName(), group:getType(), source:getName()))
			end
			source:respawn()
			return
		end
	end

	if source:getPositionType() == VehiclePositionType.Mechanic then
		client:sendError(_("Das Fahrzeug wurde abgeschleppt! Hole es an der Mech&Tow Base ab!", client))
		return
	end

	if source:getOwner() ~= client:getId() and client:getRank() < RANK.Supporter then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	if source:isBroken() and client:getRank() < RANK.Supporter then
		client:sendError(_("Dein Fahrzeug ist kaputt und kann nicht respawnt werden!", client))
		return
	end

	if client:getBankMoney() < 100 and source:getOwner() == client:getId() then
		client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto (100$)!", client))
		return
	end
	if source:isInGarage() then
		source:fix()
		setVehicleOverrideLights(source, 1)
		setVehicleEngineState(source, false)
		source.m_EngineState = false
		source:setSirensOn(false)
		if source:getOwner() == client:getId() then
			client:takeBankMoney(100, "Fahrzeug Respawn")
		end
		client:sendShortMessage(_("Fahrzeug repariert!", client))
		return
	end
	local occupants = getVehicleOccupants(source)
	for seat, player in pairs(occupants) do
		removePedFromVehicle(player)
	end

	if source:respawn(garageOnly) then
		if source:getOwner() == client:getId() then
			client:takeBankMoney(100, "Fahrzeug-Respawn")
		end
		source:fix()
		setVehicleOverrideLights(source, 1)
		source:setEngineState(false)
		source:setSirensOn(false)
	end

	-- Refresh location in the self menu
	client:triggerEvent("vehicleRetrieveInfo", self:getVehiclesFromPlayer(client))
end

function VehicleManager:Event_vehicleRespawnWorld()
	self:checkVehicle(source)
	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht respawnt werden!", client))
		return
	end

	if source:getOccupantsCount() > 0 then
		client:sendError(_("Das Fahrzeug ist nicht leer!", client))
		return
	end

 	if not instanceof(source, PermanentVehicle, true) and not instanceof(source, GroupVehicle) then
 		client:sendError(_("Das ist kein permanentes Server Fahrzeug!", client))
 		return
 	end

 	if source:getPositionType() == VehiclePositionType.Mechanic then
 		client:sendError(_("Das Fahrzeug wurde abgeschleppt! Hole es an der Mech&Tow Base ab!", client))
 		return
 	end

 	if source:getOwner() ~= client:getId() and client:getRank() < RANK.Supporter then
 		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
 		return
	end

	if source:isBroken() and client:getRank() < RANK.Supporter then
		client:sendError(_("Dein Fahrzeug ist kaputt und kann nicht respawnt werden!", client))
		return
	end

 	if source:getOwner() == client:getId() and client:getBankMoney() < 100 then
 		client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto (100$)!", client))
 		return
	end

 	if source:getPositionType() == VehiclePositionType.World then
 		if source:getOwner() == client:getId() then
			client:takeBankMoney(100, "Fahrzeug Respawn")
		end
		source:respawnOnSpawnPosition()
 	else
 		client:sendError(_("Das Fahrzeug hat keine Park-Position!", client))
 	end
 end

function VehicleManager:Event_vehicleDelete(reason)
	self:checkVehicle(source)

	if not source:isRespawnAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht gelöscht werden!", client))
		return
	end

	if client:getRank() < RANK.Moderator then
		-- Todo: Report cheat attempt
		return
	end

	if source:isPermanent() then
		client:sendInfo(_("%s von Besitzer %s wurde von Admin %s gelöscht! Grund: %s", client, source:getName(), getElementData(source, "OwnerName") or "Unknown", client:getName(), reason))

		if getElementData(source, "OwnerName") then
			local targetId = Account.getIdFromName(getElementData(source, "OwnerName"))
			if targetId and targetId > 0 then
				local delTarget, isOffline = DatabasePlayer.get(targetId)
				if delTarget then
					if isOffline then
						delTarget:addOfflineMessage("Dein Fahrzeug ("..source:getName().." wurde von "..client:getName().." gelöscht. ("..reason..")!",1)

						delTarget.m_DoNotSave = true
						delete(delTarget)
					else
						delTarget:sendInfo(_("%s von Besitzer %s wurde von Admin %s gelöscht! Grund: %s", client, source:getName(), getElementData(source, "OwnerName") or "Unknown", client:getName(), reason))
					end
				end
			else
				client:sendInfo(_("Fahrzeug %s wurde gelöscht! Besitzer: %s Grund: %s", client, source:getName(), getElementData(source, "OwnerName") or "Unknown", client:getName(), reason))
			end
		end

		-- Todo Add Log
		StatisticsLogger:getSingleton():addVehicleDeleteLog(source:getOwner(), client, source:getModel(), reason)
		source:purge()
	else
		destroyElement(source)
	end
end

function VehicleManager:Event_vehicleSell()
	if not instanceof(source, PermanentVehicle, true) then return end
	if source:getOwner() ~= client:getId() then	return end
	if source.m_Premium then
		client:sendError("Dieses Fahrzeug ist ein Premium Fahrzeug und darf nicht verkauft werden!")
		return
	end
	-- Search for price in vehicle shops table
	local getPrice = function(model)
		for shopId, shop in pairs(ShopManager.VehicleShopsMap) do
			if shop:getVehiclePrice(model) then
				return shop:getVehiclePrice(model)
			end
		end
		return false
	end

	local price = getPrice(source:getModel()) or 0
	if price > 0 then
		QuestionBox:new(client, client, _("Möchtest du das Fahrzeug wirklich für %d$ verkaufen?", client, math.floor(price * 0.75)), "vehicleSellAccept", nil, source)
	else
		client:sendError("Das Fahrzeug ist in keinem Shop erhätlich und kann nicht an den Server verkauft werden!")
		QuestionBox:new(client, client, _("Möchtest du dieses Fahrzeug entfernen?", client, math.floor(price * 0.75)), "vehicleSellAccept", nil, source)
	end
end

function VehicleManager:Event_acceptVehicleSell(veh)
	if not instanceof(veh, PermanentVehicle, true) then return end
	if veh:getOwner() ~= source:getId() then return end
	if veh.m_Premium then
		source:sendError("Dieses Fahrzeug ist ein Premium Fahrzeug und darf nicht verkauft werden!")
		return
	end
	-- Search for price in vehicle shops table
	local getPrice = function(model)
		for shopId, shop in pairs(ShopManager.VehicleShopsMap) do
			if shop:getVehiclePrice(model) then
				return shop:getVehiclePrice(model)
			end
		end
		return false
	end

	local price = getPrice(veh:getModel()) or 0
	if price then
		veh:purge()
		source:giveMoney(math.floor(price * 0.75), "Fahrzeug-Verkauf")

		self:Event_vehicleRequestInfo(source)

	else
		source:sendError("Beim verkauf dieses Fahrzeuges ist ein Fehler aufgetreten!")
	end
end

function VehicleManager:Event_vehicleRequestInfo(player)
	local client = client or player
	client:triggerEvent("vehicleRetrieveInfo", self:getVehiclesFromPlayer(client), client:getGarageType(), client:getHangarType())
end

function VehicleManager:Event_vehicleUpgradeGarage()
	local currentGarage = client:getGarageType()
	if currentGarage >= 0 then
		local price = GARAGE_UPGRADES_COSTS[currentGarage + 1]
		if price then
			if client:getBankMoney() >= price then
				client:takeBankMoney(price, "Garagen-Upgrade")
				client:setGarageType(currentGarage + 1)

				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType(), client:getHangarType())
			else
				client:sendError(_("Du hast nicht genügend Geld auf deinem Bankkonto, um die Garage zu kaufen oder upzugraden", client))
			end
		else
			client:sendError(_("Deine Garage ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keine gültige Garage!", client))
	end
end

function VehicleManager:Event_vehicleUpgradeHangar()
	local currentHangar = client:getHangarType()
	if currentHangar >= 0 then
		local price = HANGAR_UPGRADES_COSTS[currentHangar + 1]
		if price then
			if client:getMoney() >= price then
				client:takeBankMoney(price, "Hangar-Upgrade")
				client:setHangarType(currentHangar + 1)

				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType(), client:getHangarType())
			else
				client:sendError(_("Du hast nicht genügend Geld, um dein Hangar zu upgraden", client))
			end
		else
			client:sendError(_("Deine Hangar ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keinen gültigen Hangar!", client))
	end
end

function VehicleManager:Event_vehicleHotwire()
	if client:getInventory():hasItem(ITEM_HOTWIREKIT) then
		if source:isBroken() then
			client:sendError(_("Dieses Fahrzeug ist kaputt und kann nicht kurzgeschlossen werden!", client))
			return
		end
		client:sendInfo(_("Schließe kurz...", client), 20000)
		client:reportCrime(Crime.Hotwire)
		client:giveKarma(-0.1)

		setTimer(
			function(source)
				if isElement(source) then
					source:setEngineState(true)
				end
			end, 20000, 1, source
		)
	else
		client:sendWarning(_("Hierfür brauchst du ein Kurzschließkit!", client))
	end
end

function VehicleManager:Event_vehicleEmpty()
	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		for seat, occupant in pairs(getVehicleOccupants(source) or {}) do
			if seat ~= 0 then
				removePedFromVehicle(occupant)
				if occupant:getData("BeggarId") then
					occupant:onTransportExit(client)
				end
				if occupant:getData("isDrivingCoach") then
					if DrivingSchool.m_LessonVehicles[client] == source then
						DrivingSchool.m_LessonVehicles[client] = nil
						if source.m_NPC then
							destroyElement(source.m_NPC)
						end
						destroyElement(source)
					end
					client:triggerEvent("DrivingLesson:endLesson")
					fadeCamera(client,false,0.5)
					setTimer(setElementPosition,1000,1,client,1348.97, -1620.68, 13.60)
					setTimer(fadeCamera,1500,1, client,true,0.5)
					outputChatBox("Du hast den Fahrlehrer rausgeworfen und die Prüfung beendet!", client, 200,0,0)
				end
			end
		end
		client:sendShortMessage(_("Mitfahrer wurden herausgeworfen!", client))
	else
		client:sendError(_("Hierzu hast du keine Berechtigungen!", client))
	end
end

function VehicleManager:Event_vehicleSyncMileage(diff)
	if diff < -0.001 then
		AntiCheat:getSingleton():report(client, "Sent invalid mileage", CheatSeverity.Middle)
		return
	end

	local vehicle = client:getOccupiedVehicle()
	if vehicle then
		if vehicle.setMileage and vehicle.setMileage then
			vehicle:setMileage((vehicle:getMileage() or 0) + diff)
			client:increaseStatistics("Driven", diff)
		end
	end
end

function VehicleManager:Event_vehicleBreak()
	self:checkVehicle(source)
	outputDebug("Vehicle has been broken by "..client:getName())
	-- TODO: The following behavior is pretty bad in terms of security, so fix it asap (without breaking its behavior)
	source:setBroken(true)
end

function VehicleManager:Event_soundvanChangeURL(url)
	if source.m_Special and source.m_Special == VehicleSpecial.Soundvan then
		source.m_SoundURL = url
		triggerClientEvent("soundvanChangeURLClient", source, url)
	end
end

function VehicleManager:Event_soundvanStopSound()
	if source.m_Special and source.m_Special == VehicleSpecial.Soundvan then
		source.m_SoundURL = nil
		triggerClientEvent("soundvanStopSoundClient", source, url)
	end
end

function VehicleManager:Event_TrailerAttach(truck)
	if not getVehicleOccupant(truck) then return end
	if not instanceof(truck, PermanentVehicle) then return end
	if not instanceof(source, PermanentVehicle) then return end

	if source:getOwner() == truck:getOwner() then
		source:setFrozen(false)
	end
end
