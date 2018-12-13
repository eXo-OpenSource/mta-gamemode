JobFarmer = inherit(Job)

local VEHICLE_SPAWN = {-66.21, 69.00, 2.2, 68}
local PLANT_DELIVERY = {-2150.31, -2445.04, 29.63}
local PLANTSONWALTON = 50
local STOREMARKERPOS = {-37.85, 58.03, 2.2}

local MONEY_PER_PLANT = 104
local MONEY_PLANT_HARVESTER = 20
local MONEY_PLANT_TRACTOR = 13

function JobFarmer:constructor()
	Job.constructor(self)

	local x, y, z, rotation = unpack (VEHICLE_SPAWN)
	self.m_VehicleSpawner = VehicleSpawner:new(x,y,z, {"Tractor"; "Combine Harvester"; "Walton"}, rotation, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	self.m_Plants = {}
	self.m_DeliveryBlips = {}
	self.m_JobElements = {}
	self.m_CurrentPlants = {}
	self.m_CurrentPlantsFarm = 0
	self.m_BankAccountServer = BankServer.get("job.farmer")

	local x, y, z = unpack(STOREMARKERPOS)
	self.m_Storemarker = self:createJobElement (createMarker (x,y,z,"cylinder",3,0,125,0,125))
	addEventHandler("onMarkerHit",self.m_Storemarker,bind(self.storeHit,self))

	-- // this the delivery BLIP
	local x,y,z = unpack(PLANT_DELIVERY)
	self.m_DeliveryMarker = self:createJobElement(createMarker(x,y,z,"corona",4))
	addEventHandler ("onMarkerHit",self.m_DeliveryMarker,bind(self.deliveryHit,self))

	addRemoteEvents{"jobFarmerCreatePlant"}
	addEventHandler("jobFarmerCreatePlant", root, bind(self.createPlant, self))
end

function JobFarmer:giveJobMoney(player, vehicle)
	if player:getData("Farmer.Income") and player:getData("Farmer.Income") > 0 then
		local income = player:getData("Farmer.Income")
		local duration = getRealTime().timestamp - player.m_LastJobAction
		player.m_LastJobAction = getRealTime().timestamp
		if vehicle:getModel() == 531 then
			StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.tractor", duration, income)
		else
			StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.combine", duration, income)
		end
		self.m_BankAccountServer:transferMoney({player, true}, income, "Farmer-Job", "Job", "Farmer")
		player:setData("Farmer.Income", 0)
		player:triggerEvent("Job.updateIncome", 0)
	end
end

function JobFarmer:onVehicleSpawn(player, vehicleModel, vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	self:registerJobVehicle(player, vehicle, true, false)

	if vehicleModel == 531 then -- Tractor
		vehicle.trailer = createVehicle(610, vehicle:getPosition())
		vehicle:attachTrailer(vehicle.trailer)

		addEventHandler("onTrailerDetach", vehicle.trailer, function(tractor) tractor:attachTrailer(source)	end)
		addEventHandler("onElementDestroy", vehicle, function() if source.trailer and isElement(source.trailer) then source.trailer:destroy() end end, false)
	elseif vehicleModel == 478 then -- Walton
		addEventHandler("onElementDestroy", vehicle,
			function()
				self.m_CurrentPlants[player] = 0
				self:updatePrivateData(player)
			end, false
		)
	end

	addEventHandler("onVehicleExit", vehicle,
		function(vehPlayer, seat)
			if seat == 0 and source:getModel() ~= 478 then
				self:giveJobMoney(vehPlayer, source)
			end
		end
	)
end

function JobFarmer:storeHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and hitElement:getJob() == self then
		hitElement:sendShortMessage(_("Hier kannst du den Walton beladen!",hitElement))
	end
	if getElementType(hitElement) ~= "vehicle" then
		return
	end
	local player = getVehicleOccupant(hitElement, 0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") and hitElement == player.jobVehicle then
		if self.m_CurrentPlants[player] ~= 0 then
			player:sendError(_("Du hast schon %d Getreide auf deinem Walton!", player, self.m_CurrentPlants[player]))
			return
		end
		if self.m_CurrentPlantsFarm >= PLANTSONWALTON then
			self.m_CurrentPlants[player] = PLANTSONWALTON
			self:updatePrivateData(player)
			local x,y,z = unpack (PLANT_DELIVERY)
			player:startNavigationTo(Vector3(x, y, z))

			self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm - PLANTSONWALTON
			self:updateClientData()
			hitElement:setFrozen(true)
			for i = 1, 3 do
				for j = 1, 3 do
					local obj = createObject(2968, 0, 0, 0)
					obj:setFrozen(true)
					attachElements(obj, hitElement, -1.2 + j * 0.6, -2.8 + i * 0.5, 0.3, 0, 0, 0)
					setElementParent(obj, hitElement)
				end
			end

			setTimer(
				function(element)
					if isElement(element) then
						setElementFrozen(element,false)
					end
				end, 3500, 1, hitElement
			)
		else
			player:sendError(_("Zum Aufladen werden mindestens %d Getreide benötigt. Momentanes Getreide: %d!", player, PLANTSONWALTON, self.m_CurrentPlantsFarm))
		end
	end
end

function JobFarmer:createJobElement (element)
	setElementVisibleTo(element, root, false)
	table.insert (self.m_JobElements,element)
	return element
end

function JobFarmer:start(player)
	self:setJobElementVisibility(player,true)
	self.m_CurrentPlants[player] = 0
	self.m_VehicleSpawner:toggleForPlayer(player, true)

	-- give Achievement
	player:giveAchievement(20)
end

function JobFarmer:setJobElementVisibility(player, state)
	if state then
		local x, y = unpack(PLANT_DELIVERY)
		self.m_DeliveryBlips[player:getId()] = Blip:new("Marker.png", x, y, player, 4000, BLIP_COLOR_CONSTANTS.Red)
		self.m_DeliveryBlips[player:getId()]:setDisplayText("Kisten-Abgabe")
	else
		delete(self.m_DeliveryBlips[player:getId()])
	end

	for key, element in pairs (self.m_JobElements) do
		setElementVisibleTo(element, player, state)
	end
end

function JobFarmer:stop(player)
	if self.m_CurrentPlants[player] then self.m_CurrentPlants[player] = nil end
	if self.m_Plants[player] then self.m_Plants[player] = nil end

	self:setJobElementVisibility(player, false)
	self.m_VehicleSpawner:toggleForPlayer(player, false)

	self:giveJobMoney(player, player.jobVehicle)
	self:destroyJobVehicle(player)
end

function JobFarmer:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_FARMER) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_FARMER))
		return false
	end
	return true
end

function JobFarmer:deliveryHit (hitElement,matchingDimension)
	if not isValidElement(hitElement, "vehicle") then
		return
	end
	local player = getVehicleOccupant(hitElement,0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") and hitElement == player.jobVehicle then
		if self.m_CurrentPlants[player] and self.m_CurrentPlants[player] > 0 then
			player:sendSuccess(_("Du hast die Lieferung abgegeben, fahre nun zurück zur Farm.", player))
			local income = self.m_CurrentPlants[player]*MONEY_PER_PLANT
			local duration = getRealTime().timestamp - player.m_LastJobAction
			player.m_LastJobAction = getRealTime().timestamp
			StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.transport", duration, income, nil, nil, math.floor(math.ceil(self.m_CurrentPlants[player]/10)*JOB_EXTRA_POINT_FACTOR))
			self.m_BankAccountServer:transferMoney({player, true}, income, "Farmer-Job", "Job", "Farmer")
			player:givePoints(math.floor(math.ceil(self.m_CurrentPlants[player]/10)*JOB_EXTRA_POINT_FACTOR))
			self.m_CurrentPlants[player] = 0
			self:updatePrivateData(player)
			for i, v in pairs(getAttachedElements(hitElement)) do
				if v:getModel() == 2968 then -- only destroy crates
					destroyElement(v)
				end
			end
		else
			player:sendError(_("Du hast keine Ladung dabei!", player))
		end
	end
end

function JobFarmer:createPlant (colId, colPos, vehicle)
	if client:getJob() ~= self then
		return
	end

	local x,y,z = getElementPosition(client)
	local vehicleID = getElementModel(vehicle)
	local colX, colY, colZ = unpack(colPos)
	if self.m_Plants[colId] and vehicleID == getVehicleModelFromName("Combine Harvester") and self.m_Plants[colId].isFarmAble and vehicle == client.jobVehicle then
		local pos = vehicle.position + vehicle.matrix.forward * 2
		local distance = getDistanceBetweenPoints3D(pos, colX, colY, colZ)
		if distance > 4 then return end
		destroyElement (self.m_Plants[colId])
		self.m_Plants[colId] = nil
		if not client:getData("Farmer.Income") then client:setData("Farmer.Income", 0) end
		client:setData("Farmer.Income", client:getData("Farmer.Income") + MONEY_PLANT_HARVESTER)
		client:triggerEvent("Job.updateIncome", client:getData("Farmer.Income"))
		self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm + 1
		self:updateClientData()

		-- Give some points
		if chance(6) then
			client:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
		end
	else
		if vehicleID == getVehicleModelFromName("Tractor") and not self.m_Plants[colId] and vehicle == client.jobVehicle then
			self.m_Plants[colId] = createObject(818,x,y,z-1.5)
			local object = self.m_Plants[colId]
			object.isFarmAble = false
			setTimer(function (o) o.isFarmAble = true end, 1000*7.5, 1, object)
			setElementVisibleTo(object, client, true)
			if not client:getData("Farmer.Income") then client:setData("Farmer.Income", 0) end
			client:setData("Farmer.Income", client:getData("Farmer.Income") + MONEY_PLANT_TRACTOR)
			client:triggerEvent("Job.updateIncome", client:getData("Farmer.Income"))
			-- Give some points
			if chance(4) then
				client:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
			end
		end
	end
end

function JobFarmer:updateClientData ()
	-- TODO: Send info only to players doing this job
	for i, v in pairs(getElementsByType("player")) do
		v:triggerEvent("Job.updateFarmPlants", self.m_CurrentPlantsFarm)
	end
end

function JobFarmer:updatePrivateData (player)
	player:triggerEvent("Job.updatePlayerPlants", self.m_CurrentPlants[player])
end
