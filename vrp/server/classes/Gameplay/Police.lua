Police = inherit(Singleton)

function Police:constructor()
	-- Garage Spawns
	local policeVehicleCreation = bind(Police.onVehicleSpawn, self)
	local jobPolice = JobPolice:getSingleton()

	for i = 0, 4 do
		AutomaticVehicleSpawner:new(596, 1554.9 + i * 5, -1606.4, 13.2, 0, 0, 180, policeVehicleCreation, jobPolice)
	end
	for i = 5, 7 do
		AutomaticVehicleSpawner:new(599, 1554.9 + i * 5, -1606.4, 13.5, 0, 0, 180, policeVehicleCreation, jobPolice)
	end
	for i = 8, 10 do
		AutomaticVehicleSpawner:new(523, 1554.9 + i * 5, -1606.4, 13, 0, 0, 180, policeVehicleCreation, jobPolice)
	end

	-- Cellar
	AutomaticVehicleSpawner:new(427, 1534.77, -1645.97, 6.02, 0.00, 0.00, 180.61, policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(427, 1526.55, -1645.73, 6.02, 0.00, 0.00, 181.03, policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1545.93, -1659.14, 5.61, 0.00, 0.00, 89.46,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1545.48, -1663.07, 5.61, 0.00, 0.00, 89.82,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1545.31, -1672.17, 5.61, 0.00, 0.00, 91.07,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1545.32, -1680.21, 5.61, 0.00, 0.00, 89.03,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1545.78, -1684.36, 5.61, 0.00, 0.00, 91.38,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(599, 1574.36, -1711.16, 6.08, 0.00, 0.00, 1.48,   policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(599, 1578.49, -1711.36, 6.08, 0.00, 0.00, 0.03,   policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(599, 1583.66, -1710.94, 6.08, 0.00, 0.00, 359.88, policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(601, 1564.39, -1710.41, 5.65, 0.00, 0.00, 0.57,   policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(528, 1595.60, -1710.79, 5.94, 0.00, 0.00, 359.42, policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(528, 1591.40, -1710.46, 5.94, 0.00, 0.00, 358.93, policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1601.44, -1704.34, 5.61, 0.00, 0.00, 89.49,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1601.49, -1700.08, 5.61, 0.00, 0.00, 87.91,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(596, 1601.24, -1692.24, 5.61, 0.00, 0.00, 90.24,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(523, 1603.58, -1682.96, 5.46, 0.00, 0.00, 89.01,  policeVehicleCreation, jobPolice)
	AutomaticVehicleSpawner:new(523, 1603.20, -1686.84, 5.46, 0.00, 0.00, 89.22,  policeVehicleCreation, jobPolice)

	self.m_VehicleAccessHandler = bind(Police.validateVehicleAccess, self)
end

function Police:onVehicleSpawn(vehicle)
	addEventHandler("onVehicleStartEnter", vehicle, self.m_VehicleAccessHandler)
end

function Police:validateVehicleAccess(player, seat)
	local vehicle = source

	-- If not driver, ignore
	if seat ~= 0 then
		return
	end

	local karma = player:getKarma()
	local neededKarma = 0
	local model = getElementModel(vehicle)
	if 		model == 523 or
			model == 596 then neededKarma = Karma.POLICE_VEHICLE_NORMAL
	elseif 	model == 427 then neededKarma = Karma.POLICE_ENFORCER
	elseif 	model == 599 then neededKarma = Karma.POLICE_RANGER
	elseif 	model == 601 then neededKarma = Karma.POLICE_SWAT_TANK
	elseif 	model == 528 then neededKarma = Karma.POLICE_SWAT
	elseif 	model == 497 then neededKarma = Karma.POLICE_HELI
	else
		outputDebug("Police - Invalid Model "..tostring(model))
		neededKarma = 9999 -- this should not happen
	end

	if karma < neededKarma then
		cancelEvent()
		player:sendShortMessage(_("Du kannst dieses Fahrzeug erst ab %d positivem Karma nutzen!", player, neededKarma))
		return
	end

	vehicle.m_TempoaryOwner = player
end
