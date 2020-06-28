JobFarmer = inherit(Job)

local VEHICLE_SPAWN = {-66.21, 69.00, 2.2, 68}
local VEHICLE_SPAWN2 = {-28.54, 1178.83, 18.5, 0}
local PLANT_DELIVERY = {-19.44, 1185.90, 18.4} -- marker to deliver plants and load seeds
local PLANTSONWALTON = 50
local SEEDSONWALTON = 100
local STOREMARKERPOS = {-37.85, 58.03, 2.2} -- marker to deliver seeds and load plants

local MONEY_PER_PLANT = 16
local MONEY_PER_SEED = 8
local MONEY_PLANT_HARVESTER = 20
local MONEY_PLANT_TRACTOR = 20

function JobFarmer:constructor()
	Job.constructor(self)

	local x, y, z, rotation = unpack (VEHICLE_SPAWN)
	self.m_VehicleSpawner = VehicleSpawner:new(x,y,z, {"Tractor"; "Combine Harvester"; "Walton"}, rotation, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	local x, y, z, rotation = unpack (VEHICLE_SPAWN2)
	self.m_VehicleSpawner2 = VehicleSpawner:new(x,y,z, {"Walton"}, rotation, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner2.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner2:disable()

	self.m_PlayerIncomeCache = {} -- cache money when players are working on a field, only pay them if they leave the field
	self.m_Plants = {}
	self.m_DeliveryBlips = {}
	self.m_JobElements = {}
	self.m_CurrentPlants = {}
	self.m_CurrentPlantsFarm = 0
	self.m_CurrentSeeds = {}
	self.m_CurrentSeedsFarm = 100

	self.m_BankAccountServer = BankServer.get("job.farmer")
	self.m_CollectPlantEvent = bind(self.collectPlant, self)
	self.m_AddSeedsAutomatic = bind(self.addSeedsAutomatic, self)
	self.m_AddSeedsAutomaticTimer = setTimer(self.m_AddSeedsAutomatic, 30 * 60 * 1000, 0)

	local x, y, z = unpack(STOREMARKERPOS)
	self.m_Storemarker = self:createJobElement (createMarker (x,y,z,"cylinder",3,0,125,0,125))
	addEventHandler("onMarkerHit",self.m_Storemarker,bind(self.storeHit,self))

	-- // this the delivery BLIP
	local x,y,z = unpack(PLANT_DELIVERY)
	self.m_DeliveryMarker = self:createJobElement(createMarker(x,y,z,"cylinder",3,0,125,0,125))
	addEventHandler ("onMarkerHit",self.m_DeliveryMarker,bind(self.deliveryHit,self))

	addRemoteEvents{"jobFarmerCreatePlant", "jobFarmerLeaveField"}
	addEventHandler("jobFarmerCreatePlant", root, bind(self.createPlant, self))
	addEventHandler("jobFarmerLeaveField", root, bind(self.onClientLeaveField, self))
end

function JobFarmer:giveJobMoney(player)

	if not self.m_PlayerIncomeCache[player] then return end 
	local income = 0
	if self.m_PlayerIncomeCache[player].combine > 0 then
		income = self.m_PlayerIncomeCache[player].combine
		StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.combine", duration, income)
		self.m_PlayerIncomeCache[player].combine = 0 
	elseif self.m_PlayerIncomeCache[player].tractor > 0 then
		income = self.m_PlayerIncomeCache[player].tractor
		StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.tractor", duration, income)
		self.m_PlayerIncomeCache[player].tractor = 0
	end
	if income > 0 then
		local duration = getRealTime().timestamp - player.m_LastJobAction
		player.m_LastJobAction = getRealTime().timestamp
		player:giveCombinedReward("Farmer-Job", {
			money = {
				mode = "give",
				bank = true,
				amount = income,
				toOrFrom = self.m_BankAccountServer,
				category = "Job",
				subcategory = "Farmer"
			},
			points = math.round(((income / MONEY_PLANT_HARVESTER) / 6)*JOB_EXTRA_POINT_FACTOR), -- one point every six plants
		})

	end
end

function JobFarmer:onClientLeaveField()
	self:giveJobMoney(client)
end

function JobFarmer:addSeedsAutomatic()
	if self.m_CurrentSeedsFarm < 1000 then
		self.m_CurrentSeedsFarm = self.m_CurrentSeedsFarm + 100
	end
end

function JobFarmer:onVehicleSpawn(player, vehicleModel, vehicle)
	player.m_LastJobAction = getRealTime().timestamp
	self:registerJobVehicle(player, vehicle, true, false)

	self:setDeliveryBlipMode(player, false)

	if vehicleModel == 531 then -- Tractor
		vehicle.trailer = createVehicle(610, vehicle:getPosition())
		vehicle:attachTrailer(vehicle.trailer)

		addEventHandler("onTrailerDetach", vehicle.trailer, function(tractor) if isElement(tractor) then tractor:attachTrailer(source) end	end)
		addEventHandler("onElementDestroy", vehicle, function() if source.trailer and isElement(source.trailer) then source.trailer:destroy() end end, false)
	elseif vehicleModel == 478 then -- Walton
		if getDistanceBetweenPoints3D(player.position.x, player.position.y, player.position.z, unpack(PLANT_DELIVERY)) < getDistanceBetweenPoints3D(player.position.x, player.position.y, player.position.z, unpack(STOREMARKERPOS)) then
			self:setDeliveryBlipMode(player, "delivery")
		else
			self:setDeliveryBlipMode(player, "farm")
		end
		addEventHandler("onElementDestroy", vehicle,
			function()
				self.m_CurrentPlants[player] = 0
				self.m_CurrentSeeds[player] = 0
				self:updatePrivateData(player)
			end, false
		)
	end
end

function JobFarmer:storeHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and not hitElement.vehicle and hitElement:getJob() == self then
		hitElement:sendShortMessage(_("Hier kannst du den Walton mit Getreide beladen!",hitElement))
	end
	if getElementType(hitElement) ~= "vehicle" then
		return
	end
	local player = getVehicleOccupant(hitElement, 0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") and hitElement == player.jobVehicle then
		if self.m_CurrentSeeds[player] and self.m_CurrentSeeds[player] > 0 then
			if not hitElement.m_HasSeeds then
				self.m_CurrentSeeds[player] = 0
				player:sendError(_("Noughty boy", player))
				return
			end
			hitElement.m_HasSeeds = false

			local income = self.m_CurrentSeeds[player]*MONEY_PER_SEED * JOB_PAY_MULTIPLICATOR
			local duration = getRealTime().timestamp - player.m_LastJobAction
			player.m_LastJobAction = getRealTime().timestamp
			StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.transport", duration, income, nil, nil, math.floor(math.ceil(self.m_CurrentSeeds[player]/10)*JOB_EXTRA_POINT_FACTOR))
			player:giveCombinedReward("Farmer-Job", {
				money = {
					mode = "give",
					bank = true,
					amount = income,
					toOrFrom = self.m_BankAccountServer,
					category = "Job",
					subcategory = "Farmer"
				},
				points = math.floor(math.ceil(self.m_CurrentSeeds[player]/30)*JOB_EXTRA_POINT_FACTOR), -- one point every six plants
			})

			self.m_CurrentSeedsFarm = self.m_CurrentSeedsFarm + self.m_CurrentSeeds[player]
			self:updateClientData()
			self.m_CurrentSeeds[player] = 0
			self:updatePrivateData(player)
			for i, v in pairs(getAttachedElements(hitElement)) do
				if v:getModel() == 1221 then -- only destroy crates
					destroyElement(v)
				end
			end
		end
		if self.m_CurrentPlants[player] ~= 0 then
			player:sendError(_("Du hast schon %d Getreide auf deinem Walton!", player, self.m_CurrentPlants[player]))
			return
		end
		if self.m_CurrentPlantsFarm >= PLANTSONWALTON then
			self.m_CurrentPlants[player] = PLANTSONWALTON
			self:updatePrivateData(player)
			local x,y,z = unpack (PLANT_DELIVERY)
			player:startNavigationTo(Vector3(x, y, z))

			player:sendInfo(_("Dein Transporter wurde mit Getreide beladen. Liefere es nach Fort Carson!", player))
			self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm - PLANTSONWALTON
			self:updateClientData()
			hitElement:setFrozen(true)
			hitElement.m_HasPlants = true
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
		self:setDeliveryBlipMode(player, "delivery")
	end
end

function JobFarmer:createJobElement(element)
	setElementVisibleTo(element, root, false)
	table.insert (self.m_JobElements,element)
	return element
end

function JobFarmer:start(player)
	self:setJobElementVisibility(player,true)
	self.m_CurrentPlants[player] = 0
	self.m_PlayerIncomeCache[player] = {combine = 0, tractor = 0}
	self.m_VehicleSpawner:toggleForPlayer(player, true)
	self.m_VehicleSpawner2:toggleForPlayer(player, true)

	setTimer(self.updateClientData, 100, 1, self, player)
	-- give Achievement
	player:giveAchievement(20)
end

function JobFarmer:setJobElementVisibility(player, state)
	for key, element in pairs (self.m_JobElements) do
		setElementVisibleTo(element, player, state)
	end
end

function JobFarmer:stop(player)
	if self.m_CurrentPlants[player] then self.m_CurrentPlants[player] = nil end
	self:giveJobMoney(player)
	self.m_PlayerIncomeCache[player] = nil

	self:setJobElementVisibility(player, false)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	self.m_VehicleSpawner2:toggleForPlayer(player, false)

	self:setDeliveryBlipMode(player, false)

	self:destroyJobVehicle(player)
end

function JobFarmer:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_FARMER) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_FARMER))
		return false
	end
	return true
end

function JobFarmer:setDeliveryBlipMode(player, mode)
	if self.m_DeliveryBlips[player:getId()] then
		delete(self.m_DeliveryBlips[player:getId()])
	end
	if mode == "delivery" then
		local x, y, z = unpack(PLANT_DELIVERY)
		self.m_DeliveryBlips[player:getId()] = Blip:new("Marker.png", x, y, player, 4000, BLIP_COLOR_CONSTANTS.Red)
		self.m_DeliveryBlips[player:getId()]:setDisplayText("Kisten-Abgabe & Saatgut-Beladung")
		self.m_DeliveryBlips[player:getId()]:setZ(z)
	elseif mode == "farm" then
		local x, y, z = unpack(STOREMARKERPOS)
		self.m_DeliveryBlips[player:getId()] = Blip:new("Marker.png", x, y, player, 4000, BLIP_COLOR_CONSTANTS.Red)
		self.m_DeliveryBlips[player:getId()]:setDisplayText("Saatgut-Abgabe & Kisten-Beladung")
		self.m_DeliveryBlips[player:getId()]:setZ(z)
	end
	
end

function JobFarmer:deliveryHit (hitElement,matchingDimension)
	if getElementType(hitElement) == "player" and not hitElement.vehicle and hitElement:getJob() == self then
		hitElement:sendShortMessage(_("Hier kannst du den Walton mit Saatgut beladen!",hitElement))
	end
	if not isValidElement(hitElement, "vehicle") then
		return
	end
	local player = getVehicleOccupant(hitElement,0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") and hitElement == player.jobVehicle then
		if self.m_CurrentPlants[player] and self.m_CurrentPlants[player] > 0 then
			if hitElement.m_HasPlants then
				local income = self.m_CurrentPlants[player]*MONEY_PER_PLANT * JOB_PAY_MULTIPLICATOR
				local duration = getRealTime().timestamp - player.m_LastJobAction
				player.m_LastJobAction = getRealTime().timestamp
				StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.transport", duration, income, nil, nil, math.floor(math.ceil(self.m_CurrentPlants[player]/10)*JOB_EXTRA_POINT_FACTOR))

				player:giveCombinedReward("Farmer-Job", {
					money = {
						mode = "give",
						bank = true,
						amount = income,
						toOrFrom = self.m_BankAccountServer,
						category = "Job",
						subcategory = "Farmer"
					},
					points = math.floor(math.ceil(self.m_CurrentPlants[player]/30)*JOB_EXTRA_POINT_FACTOR), -- one point every six plants
				})
				self.m_CurrentPlants[player] = 0
				self:updatePrivateData(player)
				for i, v in pairs(getAttachedElements(hitElement)) do
					if v:getModel() == 2968 then -- only destroy crates
						destroyElement(v)
					end
				end
			else
				self.m_CurrentPlants[player] = 0
				self:updatePrivateData(player)
			end
		end

		if not self.m_CurrentSeeds[player] or self.m_CurrentSeeds[player] == 0 then
			player:sendInfo(_("Dein Transporter wurde mit Saatgut beladen. Fahre zurück zur Farm!", player))
			self.m_CurrentSeeds[player] = SEEDSONWALTON
			self:updatePrivateData(player)
			local x,y,z = unpack(STOREMARKERPOS)
			player:startNavigationTo(Vector3(x, y, z))

			self:updateClientData()
			hitElement:setFrozen(true)
			hitElement.m_HasSeeds = true
			for i = 1, 3 do
				for j = 1, 3 do
					local obj = createObject(1221, 0, 0, 0)
					obj:setFrozen(true)
					obj:setScale(0.5, 0.5, 0.5)
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
			self:setDeliveryBlipMode(player, "farm")
		end
	end
end

function JobFarmer:createPlant(position, vehicle)
	if client:getJob() ~= self then
		return
	end
	local position = Vector3(unpack(position))
	local vehicleID = getElementModel(vehicle)

	if vehicleID == getVehicleModelFromName("Tractor") and vehicle == client.jobVehicle then
		if self.m_CurrentSeedsFarm <= 0 then
			client:sendError(_("Es gibt kein Saatgut mehr!", player))
			return false
		end
		local found = false

		-- Checks against event faking
		for k, v in pairs(self.m_Plants) do -- check if there is a plant to near to the new one
			if v and isElement(v) then
				if getDistanceBetweenPoints3D(position, v.position) < 5.5 then
					found = true
					break
				end
			end
		end

		if found then
			AntiCheat:getSingleton():report(client, "JobFarmer:InvalidDistance", CheatSeverity.Middle)
			return false
		end

		if position.z < 0 or position.z > 10 then -- Check if height is valid
			AntiCheat:getSingleton():report(client, "JobFarmer:InvalidHeight", CheatSeverity.Middle)
			return false
		end

		if getDistanceBetweenPoints3D(position, client.position) > 3.4 then -- Check if distance of player to vehicle is valid
			AntiCheat:getSingleton():report(client, "JobFarmer:InvalidVehicleDistance", CheatSeverity.Middle)
			return false
		end

		self.m_CurrentSeedsFarm = self.m_CurrentSeedsFarm - 1
		self:updateClientData()
		local object = createObject(818, position - Vector3(0, 0, 4), -1.5)
		table.insert(self.m_Plants, object)
		object.isFarmAble = false
		object:move(1000 * 7.5, position)
		object.m_ColShape = createColSphere(position, 3)
		object.m_ColShape.m_Plant = object
		addEventHandler("onColShapeHit", object.m_ColShape, self.m_CollectPlantEvent)
		setTimer(function (o) o.isFarmAble = true end, 1000*7.5, 1, object)
		setElementVisibleTo(object, client, true)

		local income = MONEY_PLANT_TRACTOR * JOB_PAY_MULTIPLICATOR	
		self.m_PlayerIncomeCache[client].tractor = self.m_PlayerIncomeCache[client].tractor + income
	end
end

function JobFarmer:collectPlant(hitElement, matchingDimension)
	if matchingDimension then
		if hitElement.type == "vehicle" and hitElement.model == getVehicleModelFromName("Combine Harvester") and
		   hitElement.controller and hitElement.controller.jobVehicle == hitElement and source.m_Plant.isFarmAble then
			local player = hitElement.controller
			local vehicle = hitElement

			local pos = vehicle.position + vehicle.matrix.forward * 2
			local distance = getDistanceBetweenPoints3D(pos, source.position)
			if distance > 4 then return end
			table.removevalue(self.m_Plants, source.m_Plant) -- unsure if this even works?
			destroyElement(source.m_Plant)
			destroyElement(source)

			local income = MONEY_PLANT_HARVESTER * JOB_PAY_MULTIPLICATOR
			self.m_PlayerIncomeCache[player].combine = self.m_PlayerIncomeCache[player].combine + income
			self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm + 1
			self:updateClientData()
		end
	end
end

function JobFarmer:updateClientData(player)
	-- TODO: Send info only to players doing this job
	if player and isElement(player) then
		player:triggerEvent("Job.updateFarmPlants", self.m_CurrentPlantsFarm, self.m_CurrentSeedsFarm)
	else
		triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "Job.updateFarmPlants", resourceRoot, self.m_CurrentPlantsFarm, self.m_CurrentSeedsFarm)
	end
end

function JobFarmer:updatePrivateData (player)
	player:triggerEvent("Job.updatePlayerPlants", self.m_CurrentPlants[player], self.m_CurrentSeeds[player])
end
