JobFarmer = inherit(Job)

local VEHICLE_SPAWN = {-66.21, 69.00, 2.2, 68}
--local PLANT_DELIVERY = {-1108.28723,-1620.65833,75.36719}
local PLANT_DELIVERY = {-2150.31, -2445.04, 29.63}
local PLANTSONWALTON = 50
local STOREMARKERPOS = {-37.85, 58.03, 2.2}

local MONEY_PER_PLANT = 58 --// default 10
local MONEY_PLANT_HARVESTER = 10
local MONEY_PLANT_TRACTOR = 8

function JobFarmer:constructor()
	Job.constructor(self)
	self.m_Plants = {}

	local x,y,z,rotation = unpack ( VEHICLE_SPAWN )
	self.m_VehicleSpawner = VehicleSpawner:new(x,y,z, {"Tractor"; "Combine Harvester"; "Walton"}, rotation, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	self.m_DeliveryBlips = {}

	self.m_JobElements = {}
	self.m_CurrentPlants = {}
	self.m_CurrentPlantsFarm = 0

	local x,y,z = unpack(STOREMARKERPOS)

	self.m_Storemarker = self:createJobElement ( createMarker (x,y,z,"cylinder",3,0,125,0,125) )

	addEventHandler("onMarkerHit",self.m_Storemarker,bind(self.storeHit,self))


	-- // this the delivery BLIP
	x,y,z = unpack (PLANT_DELIVERY)

	self.m_DeliveryMarker = self:createJobElement(createMarker(x,y,z,"corona",4))

	addEventHandler ("onMarkerHit",self.m_DeliveryMarker,bind(self.deliveryHit,self))

	for key, value in ipairs (JobFarmer.PlantPlaces) do
		x,y,z = unpack(value)

		addEventHandler("onColShapeHit",createColSphere (x,y,z,3),
			function (hitElement)
				if getElementType(hitElement) ~= "vehicle" then
					return
				end

				local player = getVehicleOccupant(hitElement,0)

				if player then
					self:createPlant(player,source,hitElement)
				end
			end
		)
	end

end

function JobFarmer:onVehicleSpawn(player, vehicleModel, vehicle)
	player.m_LastJobAction = getRealTime().timestamp

	if vehicleModel == 531 then
		vehicle.trailer = createVehicle(610, vehicle:getPosition())
		vehicle:attachTrailer(vehicle.trailer)

		addEventHandler("onElementDestroy", vehicle,
			function()
				if source.trailer and isElement(source.trailer) then source.trailer:destroy() end
			end)

		addEventHandler("onTrailerDetach", vehicle.trailer, function(tractor)
			tractor:attachTrailer(source)
		end)
	elseif vehicleModel == 478 then --Walton
		self:registerJobVehicle(player, vehicle, true, false)
		addEventHandler("onElementDestroy", vehicle,
			function()
				self.m_CurrentPlants[player] = 0
				self:updatePrivateData(player)
			end)
	end



	player.farmerVehicle = vehicle
	addEventHandler("onVehicleExit", vehicle, function(vehPlayer, seat)
		if seat == 0 and source:getModel() ~= 478 then
			if vehPlayer:getData("Farmer.Income") and vehPlayer:getData("Farmer.Income") > 0 then
				local income = player:getData("Farmer.Income")
				local duration = getRealTime().timestamp - vehPlayer.m_LastJobAction
				vehPlayer.m_LastJobAction = getRealTime().timestamp
				if vehicle:getModel() == 531 then
					StatisticsLogger:getSingleton():addJobLog(vehPlayer, "jobFarmer.tractor", duration, income)
				else
					StatisticsLogger:getSingleton():addJobLog(vehPlayer, "jobFarmer.combine", duration, income)
				end
				vehPlayer:addBankMoney( income, "Farmer-Job")
				vehPlayer:setData("Farmer.Income", 0)
				vehPlayer:triggerEvent("Job.updateIncome", 0)

				addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
					vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
					cancelEvent()
				end)
			end
			vehicle:destroy()
			self.m_CurrentPlants[vehPlayer] = 0
		end
	end)
end

function JobFarmer:onVehicleDestroy(vehicle)
	if vehicle:getModel() == getVehicleModelFromName("Combine Harvester") and vehicle.ColShape then
		vehicle.ColShape:destroy()
	end
end

function JobFarmer:storeHit(hitElement,matchingDimension)
	if getElementType(hitElement) == "player" and hitElement:getJob() == self then
		hitElement:sendShortMessage(_("Hier kannst du den Walton beladen!",hitElement))
	end
	if getElementType(hitElement) ~= "vehicle" then
		return
	end
	local player = getVehicleOccupant(hitElement,0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") then
		if self.m_CurrentPlants[player] ~= 0 then
			outputChatBox("Du hast schon "..self.m_CurrentPlants[player].." Getreide auf deinem Walton !",player,255,0,0)
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

			setTimer (
				function(element)
					setElementFrozen(element,false)
				end,3500,1,hitElement
			)
		else
			player:sendMessage(_("Zum Aufladen werden mindestens %d Getreide benötigt. Momentanes Getreide: %d!", player, PLANTSONWALTON  ,self.m_CurrentPlantsFarm),255,0,0)
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
		self.m_DeliveryBlips[player:getId()] = Blip:new("Waypoint.png", x, y, player, 4000)
		self.m_DeliveryBlips[player:getId()]:setStreamDistance(4000)
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

	if player:getData("Farmer.Income") and player:getData("Farmer.Income") > 0 then
		local income = player:getData("Farmer.Income")
		local duration = getRealTime().timestamp - vehPlayer.m_LastJobAction
		vehPlayer.m_LastJobAction = getRealTime().timestamp
		StatisticsLogger:getSingleton():addJobLog(vehPlayer, "jobFarmer", duration, income)
		player:addBankMoney(income, "Farmer-Job")
		player:setData("Farmer.Income", 0)
		player:triggerEvent("Job.updateIncome", 0)
	end
	if player.farmerVehicle and isElement(player.farmerVehicle) then player.farmerVehicle:destroy() end
end

function JobFarmer:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_FARMER) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_FARMER))
		return false
	end
	return true
end

function JobFarmer:deliveryHit (hitElement,matchingDimension)
	if getElementType(hitElement) ~= "vehicle" then
		return
	end
	local player = getVehicleOccupant(hitElement,0)
	if player and player:getJob() ~= self then
		return
	end
	if player and matchingDimension and getElementModel(hitElement) == getVehicleModelFromName("Walton") then
		if self.m_CurrentPlants[player] and self.m_CurrentPlants[player] > 0 then
			player:sendMessage("Sie haben die Lieferung abgegeben, Gehalt : $"..self.m_CurrentPlants[player]*MONEY_PER_PLANT,0,255,0)
			local income = self.m_CurrentPlants[player]*MONEY_PER_PLANT
			local duration = getRealTime().timestamp - player.m_LastJobAction
			player.m_LastJobAction = getRealTime().timestamp
			StatisticsLogger:getSingleton():addJobLog(player, "jobFarmer.transport", duration, income)
			player:addBankMoney(income, "Farmer-Job")
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

function JobFarmer:createPlant (hitElement,createColShape,vehicle )

	if hitElement:getJob() ~= self then
		return
	end

	local x,y,z = getElementPosition(hitElement)

	local vehicleID = getElementModel(vehicle)

	if self.m_Plants[createColShape] and vehicleID == getVehicleModelFromName("Combine Harvester") and self.m_Plants[createColShape].isFarmAble then
		local pos = vehicle.position + vehicle.matrix.forward * 2
		local distance = getDistanceBetweenPoints3D(pos,createColShape.position)
		if distance > 4 then return end
		destroyElement (self.m_Plants[createColShape])
		self.m_Plants[createColShape] = nil
		if not hitElement:getData("Farmer.Income") then hitElement:setData("Farmer.Income", 0) end
		hitElement:setData("Farmer.Income", hitElement:getData("Farmer.Income") + MONEY_PLANT_HARVESTER)
		hitElement:triggerEvent("Job.updateIncome", hitElement:getData("Farmer.Income"))
		self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm + 1
		self:updateClientData()

		-- Give some points
		if chance(6) then
			hitElement:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
		end
	else
		if vehicleID == getVehicleModelFromName("Tractor") and not self.m_Plants[createColShape] then
			self.m_Plants[createColShape] = createObject(818,x,y,z-1.5)
			local object = self.m_Plants[createColShape]
			object.isFarmAble = false
			setTimer(function (o) o.isFarmAble = true end, 1000*7.5, 1, object)
			setElementVisibleTo(object, hitElement, true)
			if not hitElement:getData("Farmer.Income") then hitElement:setData("Farmer.Income", 0) end
			hitElement:setData("Farmer.Income", hitElement:getData("Farmer.Income") + MONEY_PLANT_TRACTOR)
			hitElement:triggerEvent("Job.updateIncome", hitElement:getData("Farmer.Income"))
			-- Give some points
			if chance(4) then
				hitElement:givePoints(math.floor(1*JOB_EXTRA_POINT_FACTOR))
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

JobFarmer.PlantPlaces = {
{-122.78, 61.12, 3.12}, -- Field1-Line1
{-127.95, 47.94, 3.12}, -- Field1-Line1
{-133.12, 34.77, 3.12}, -- Field1-Line1
{-138.29, 21.59, 3.12}, -- Field1-Line1
{-143.46, 8.42, 3.12}, -- Field1-Line1
{-148.63, -4.76, 3.12}, -- Field1-Line1
{-153.8, -17.94, 3.12}, -- Field1-Line1
{-158.97, -31.11, 3.12}, -- Field1-Line1
{-164.14, -44.29, 3.12}, -- Field1-Line1
{-169.31, -57.46, 3.12}, -- Field1-Line1
{-174.48, -70.64, 3.12}, -- Field1-Line1
{-130.39, 64.36, 3.12}, -- Field1-Line2
{-136.05, 49.45, 3.12}, -- Field1-Line2
{-141.7, 34.53, 3.12}, -- Field1-Line2
{-147.35, 19.62, 3.12}, -- Field1-Line2
{-153.01, 4.71, 3.12}, -- Field1-Line2
{-158.66, -10.2, 3.12}, -- Field1-Line2
{-164.31, -25.12, 3.12}, -- Field1-Line2
{-169.96, -40.03, 3.12}, -- Field1-Line2
{-175.62, -54.94, 3.12}, -- Field1-Line2
{-181.27, -69.85, 3.12}, -- Field1-Line2
{-186.92, -84.77, 3.12}, -- Field1-Line2
{-194.29, -85.55, 3.12}, -- Field1-Line3
{-188.71, -70.19, 3.12}, -- Field1-Line3
{-183.14, -54.84, 3.12}, -- Field1-Line3
{-177.57, -39.48, 3.12}, -- Field1-Line3
{-172, -24.13, 3.12}, -- Field1-Line3
{-166.43, -8.78, 3.12}, -- Field1-Line3
{-160.85, 6.58, 3.12}, -- Field1-Line3
{-155.28, 21.93, 3.12}, -- Field1-Line3
{-149.71, 37.29, 3.12}, -- Field1-Line3
{-144.14, 52.64, 3.12}, -- Field1-Line3
{-138.57, 67.99, 3.12}, -- Field1-Line3
{-145.09, 71.23, 3.12}, -- Field1-Line4
{-150.65, 55.6, 3.12}, -- Field1-Line4
{-156.2, 39.96, 3.12}, -- Field1-Line4
{-161.76, 24.33, 3.12}, -- Field1-Line4
{-167.31, 8.7, 3.12}, -- Field1-Line4
{-172.87, -6.94, 3.12}, -- Field1-Line4
{-178.42, -22.57, 3.12}, -- Field1-Line4
{-183.98, -38.2, 3.12}, -- Field1-Line4
{-189.54, -53.84, 3.12}, -- Field1-Line4
{-195.09, -69.47, 3.12}, -- Field1-Line4
{-200.65, -85.1, 3.12}, -- Field1-Line4
{-207.1, -86.09, 3.12}, -- Field1-Line5
{-201.72, -70.09, 3.12}, -- Field1-Line5
{-196.35, -54.09, 3.12}, -- Field1-Line5
{-190.97, -38.09, 3.12}, -- Field1-Line5
{-185.59, -22.09, 3.12}, -- Field1-Line5
{-180.22, -6.09, 3.12}, -- Field1-Line5
{-174.84, 9.91, 3.12}, -- Field1-Line5
{-169.47, 25.91, 3.12}, -- Field1-Line5
{-164.09, 41.91, 3.12}, -- Field1-Line5
{-158.71, 57.91, 3.12}, -- Field1-Line5
{-153.34, 73.91, 3.12}, -- Field1-Line5
{-160.44, 77.03, 3.12}, -- Field1-Line6
{-165.97, 60.8, 3.12}, -- Field1-Line6
{-171.49, 44.57, 3.12}, -- Field1-Line6
{-177.02, 28.34, 3.12}, -- Field1-Line6
{-182.54, 12.11, 3.12}, -- Field1-Line6
{-188.07, -4.12, 3.12}, -- Field1-Line6
{-193.59, -20.35, 3.12}, -- Field1-Line6
{-199.12, -36.58, 3.12}, -- Field1-Line6
{-204.64, -52.81, 3.12}, -- Field1-Line6
{-210.17, -69.04, 3.12}, -- Field1-Line6
{-215.69, -85.27, 3.12}, -- Field1-Line6
{-227.11, -83.26, 3.12}, -- Field1-Line7
{-221.58, -66.74, 3.12}, -- Field1-Line7
{-216.06, -50.23, 3.12}, -- Field1-Line7
{-210.54, -33.72, 3.12}, -- Field1-Line7
{-205.01, -17.21, 3.12}, -- Field1-Line7
{-199.49, -0.69, 3.12}, -- Field1-Line7
{-193.97, 15.82, 3.12}, -- Field1-Line7
{-188.44, 32.33, 3.12}, -- Field1-Line7
{-182.92, 48.84, 3.12}, -- Field1-Line7
{-177.4, 65.36, 3.12}, -- Field1-Line7
{-171.87, 81.87, 3.12}, -- Field1-Line7
{-179.81, 85.15, 3.12}, -- Field1-Line8
{-185.37, 68.68, 3.12}, -- Field1-Line8
{-190.93, 52.2, 3.12}, -- Field1-Line8
{-196.49, 35.72, 3.12}, -- Field1-Line8
{-202.05, 19.25, 3.12}, -- Field1-Line8
{-207.61, 2.77, 3.12}, -- Field1-Line8
{-213.17, -13.7, 3.12}, -- Field1-Line8
{-218.73, -30.18, 3.12}, -- Field1-Line8
{-224.29, -46.66, 3.12}, -- Field1-Line8
{-229.85, -63.13, 3.12}, -- Field1-Line8
{-235.41, -79.61, 3.12}, -- Field1-Line8
{-243.19, -77.88, 3.12}, -- Field1-Line9
{-237.66, -61.45, 3.12}, -- Field1-Line9
{-232.14, -45.02, 3.12}, -- Field1-Line9
{-226.62, -28.58, 3.12}, -- Field1-Line9
{-221.09, -12.15, 3.12}, -- Field1-Line9
{-215.57, 4.28, 3.12}, -- Field1-Line9
{-210.05, 20.72, 3.12}, -- Field1-Line9
{-204.52, 37.15, 3.12}, -- Field1-Line9
{-199, 53.58, 3.12}, -- Field1-Line9
{-193.48, 70.02, 3.12}, -- Field1-Line9
{-187.95, 86.45, 3.12}, -- Field1-Line9
{-194.69, 91.14, 3.12}, -- Field1-Line10
{-200.23, 74.71, 3.12}, -- Field1-Line10
{-205.78, 58.28, 3.12}, -- Field1-Line10
{-211.33, 41.86, 3.12}, -- Field1-Line10
{-216.87, 25.43, 3.12}, -- Field1-Line10
{-222.42, 9, 3.12}, -- Field1-Line10
{-227.96, -7.42, 3.12}, -- Field1-Line10
{-233.51, -23.85, 3.12}, -- Field1-Line10
{-239.05, -40.28, 3.12}, -- Field1-Line10
{-244.6, -56.71, 3.12}, -- Field1-Line10
{-250.14, -73.13, 3.12}, -- Field1-Line10
{-258.73, -72.54, 3.12}, -- Field1-Line11
{-253.07, -55.98, 3.11}, -- Field1-Line11
{-247.41, -39.43, 3.1}, -- Field1-Line11
{-241.76, -22.88, 3.1}, -- Field1-Line11
{-236.1, -6.33, 3.09}, -- Field1-Line11
{-230.44, 10.22, 3.08}, -- Field1-Line11
{-224.79, 26.78, 3.08}, -- Field1-Line11
{-219.13, 43.33, 3.07}, -- Field1-Line11
{-213.47, 59.88, 3.06}, -- Field1-Line11
{-207.82, 76.43, 3.06}, -- Field1-Line11
{-202.16, 92.98, 3.05}, -- Field1-Line11
{-209.29, 96.23, 2.76}, -- Field1-Line12
{-214.86, 79.76, 2.79}, -- Field1-Line12
{-220.43, 63.3, 2.83}, -- Field1-Line12
{-226.01, 46.83, 2.87}, -- Field1-Line12
{-231.58, 30.36, 2.9}, -- Field1-Line12
{-237.15, 13.9, 2.94}, -- Field1-Line12
{-242.73, -2.57, 2.97}, -- Field1-Line12
{-248.3, -19.04, 3.01}, -- Field1-Line12
{-253.87, -35.51, 3.05}, -- Field1-Line12
{-259.44, -51.97, 3.08}, -- Field1-Line12
{-265.02, -68.44, 3.12}, -- Field1-Line12
{-271.25, -62.02, 3.12}, -- Field1-Line13
{-265.77, -46, 3.05}, -- Field1-Line13
{-260.3, -29.98, 2.99}, -- Field1-Line13
{-254.82, -13.97, 2.92}, -- Field1-Line13
{-249.34, 2.05, 2.85}, -- Field1-Line13
{-243.87, 18.07, 2.79}, -- Field1-Line13
{-238.39, 34.08, 2.72}, -- Field1-Line13
{-232.91, 50.1, 2.66}, -- Field1-Line13
{-227.44, 66.12, 2.59}, -- Field1-Line13
{-221.96, 82.13, 2.53}, -- Field1-Line13
{-216.49, 98.15, 2.46}, -- Field1-Line13
{-223.85, 100.93, 2.16}, -- Field1-Line14
{-229, 85.51, 2.25}, -- Field1-Line14
{-234.15, 70.08, 2.35}, -- Field1-Line14
{-239.31, 54.66, 2.44}, -- Field1-Line14
{-244.46, 39.24, 2.54}, -- Field1-Line14
{-249.61, 23.82, 2.64}, -- Field1-Line14
{-254.77, 8.4, 2.73}, -- Field1-Line14
{-259.92, -7.03, 2.83}, -- Field1-Line14
{-265.08, -22.45, 2.92}, -- Field1-Line14
{-270.23, -37.87, 3.02}, -- Field1-Line14
{-275.38, -53.29, 3.12}, -- Field1-Line14
--NewField:
 {-119.42, 95.81, 3.12}, -- Field2-Line1
{-117.64, 101.29, 3.12}, -- Field2-Line1
{-115.87, 106.78, 3.13}, -- Field2-Line1
{-114.1, 112.26, 3.13}, -- Field2-Line1
{-112.33, 117.75, 3.14}, -- Field2-Line1
{-110.56, 123.23, 3.15}, -- Field2-Line1
{-108.79, 128.72, 3.15}, -- Field2-Line1
{-107.02, 134.2, 3.16}, -- Field2-Line1
{-105.24, 139.69, 3.16}, -- Field2-Line1
{-103.47, 145.17, 3.17}, -- Field2-Line1
{-101.7, 150.66, 3.18}, -- Field2-Line1
{-109.54, 152.98, 3.41}, -- Field2-Line2
{-111.38, 147.48, 3.38}, -- Field2-Line2
{-113.22, 141.98, 3.35}, -- Field2-Line2
{-115.06, 136.48, 3.32}, -- Field2-Line2
{-116.9, 130.99, 3.29}, -- Field2-Line2
{-118.74, 125.49, 3.26}, -- Field2-Line2
{-120.58, 119.99, 3.23}, -- Field2-Line2
{-122.42, 114.49, 3.21}, -- Field2-Line2
{-124.26, 108.99, 3.18}, -- Field2-Line2
{-126.1, 103.49, 3.15}, -- Field2-Line2
{-127.94, 97.99, 3.12}, -- Field2-Line2
{-136.54, 100.3, 3.12}, -- Field2-Line3
{-134.66, 105.86, 3.17}, -- Field2-Line3
{-132.79, 111.41, 3.23}, -- Field2-Line3
{-130.91, 116.97, 3.28}, -- Field2-Line3
{-129.04, 122.52, 3.34}, -- Field2-Line3
{-127.16, 128.08, 3.39}, -- Field2-Line3
{-125.29, 133.63, 3.45}, -- Field2-Line3
{-123.41, 139.19, 3.51}, -- Field2-Line3
{-121.54, 144.74, 3.56}, -- Field2-Line3
{-119.66, 150.3, 3.62}, -- Field2-Line3
{-117.79, 155.86, 3.67}, -- Field2-Line3
{-125.71, 157.88, 4.09}, -- Field2-Line4
{-127.64, 152.38, 4}, -- Field2-Line4
{-129.57, 146.88, 3.91}, -- Field2-Line4
{-131.5, 141.39, 3.81}, -- Field2-Line4
{-133.43, 135.89, 3.72}, -- Field2-Line4
{-135.35, 130.39, 3.62}, -- Field2-Line4
{-137.28, 124.89, 3.53}, -- Field2-Line4
{-139.21, 119.39, 3.43}, -- Field2-Line4
{-141.14, 113.89, 3.34}, -- Field2-Line4
{-143.06, 108.4, 3.24}, -- Field2-Line4
{-144.99, 102.9, 3.15}, -- Field2-Line4
{-152.86, 106.26, 3.21}, -- Field2-Line5
{-150.96, 111.68, 3.36}, -- Field2-Line5
{-149.06, 117.1, 3.51}, -- Field2-Line5
{-147.17, 122.53, 3.66}, -- Field2-Line5
{-145.27, 127.95, 3.81}, -- Field2-Line5
{-143.37, 133.37, 3.96}, -- Field2-Line5
{-141.47, 138.8, 4.11}, -- Field2-Line5
{-139.57, 144.22, 4.26}, -- Field2-Line5
{-137.67, 149.64, 4.41}, -- Field2-Line5
{-135.77, 155.07, 4.56}, -- Field2-Line5
{-133.87, 160.49, 4.71}, -- Field2-Line5
{-142.71, 163.4, 5.39}, -- Field2-Line6
{-144.57, 157.98, 5.18}, -- Field2-Line6
{-146.42, 152.57, 4.97}, -- Field2-Line6
{-148.27, 147.15, 4.75}, -- Field2-Line6
{-150.13, 141.74, 4.54}, -- Field2-Line6
{-151.98, 136.32, 4.33}, -- Field2-Line6
{-153.84, 130.91, 4.11}, -- Field2-Line6
{-155.69, 125.49, 3.9}, -- Field2-Line6
{-157.55, 120.07, 3.69}, -- Field2-Line6
{-159.4, 114.66, 3.47}, -- Field2-Line6
{-161.25, 109.24, 3.26}, -- Field2-Line6
{-168.6, 112.78, 3.33}, -- Field2-Line7
{-166.81, 118.05, 3.61}, -- Field2-Line7
{-165.02, 123.31, 3.88}, -- Field2-Line7
{-163.24, 128.58, 4.16}, -- Field2-Line7
{-161.45, 133.85, 4.44}, -- Field2-Line7
{-159.66, 139.12, 4.72}, -- Field2-Line7
{-157.87, 144.39, 5}, -- Field2-Line7
{-156.08, 149.66, 5.28}, -- Field2-Line7
{-154.29, 154.93, 5.56}, -- Field2-Line7
{-152.5, 160.19, 5.84}, -- Field2-Line7
{-150.71, 165.46, 6.12}, -- Field2-Line7
{-159.43, 168.61, 7.14}, -- Field2-Line8
{-161.25, 163.39, 6.76}, -- Field2-Line8
{-163.07, 158.17, 6.39}, -- Field2-Line8
{-164.88, 152.95, 6.02}, -- Field2-Line8
{-166.7, 147.73, 5.64}, -- Field2-Line8
{-168.52, 142.51, 5.27}, -- Field2-Line8
{-170.34, 137.29, 4.89}, -- Field2-Line8
{-172.15, 132.07, 4.52}, -- Field2-Line8
{-173.97, 126.85, 4.14}, -- Field2-Line8
{-175.79, 121.63, 3.77}, -- Field2-Line8
{-177.6, 116.41, 3.39}, -- Field2-Line8
{-185.25, 119.34, 3.45}, -- Field2-Line9
{-183.49, 124.52, 3.9}, -- Field2-Line9
{-181.72, 129.69, 4.36}, -- Field2-Line9
{-179.96, 134.86, 4.82}, -- Field2-Line9
{-178.2, 140.04, 5.27}, -- Field2-Line9
{-176.43, 145.21, 5.73}, -- Field2-Line9
{-174.67, 150.38, 6.19}, -- Field2-Line9
{-172.91, 155.56, 6.64}, -- Field2-Line9
{-171.14, 160.73, 7.1}, -- Field2-Line9
{-169.38, 165.9, 7.55}, -- Field2-Line9
{-167.62, 171.08, 8.01}, -- Field2-Line9
{-175.95, 173.64, 8.58}, -- Field2-Line10
{-177.6, 168.84, 8.08}, -- Field2-Line10
{-179.26, 164.04, 7.58}, -- Field2-Line10
{-180.91, 159.23, 7.08}, -- Field2-Line10
{-182.57, 154.43, 6.58}, -- Field2-Line10
{-184.22, 149.62, 6.08}, -- Field2-Line10
{-185.88, 144.82, 5.58}, -- Field2-Line10
{-187.54, 140.01, 5.08}, -- Field2-Line10
{-189.19, 135.21, 4.58}, -- Field2-Line10
{-190.85, 130.4, 4.08}, -- Field2-Line10
{-192.5, 125.6, 3.58}, -- Field2-Line10
{-200.01, 130.51, 3.48}, -- Field2-Line11
{-198.44, 135.1, 4.03}, -- Field2-Line11
{-196.88, 139.69, 4.58}, -- Field2-Line11
{-195.31, 144.28, 5.13}, -- Field2-Line11
{-193.74, 148.88, 5.68}, -- Field2-Line11
{-192.17, 153.47, 6.24}, -- Field2-Line11
{-190.6, 158.06, 6.79}, -- Field2-Line11
{-189.04, 162.65, 7.34}, -- Field2-Line11
{-187.47, 167.24, 7.89}, -- Field2-Line11
{-185.9, 171.83, 8.44}, -- Field2-Line11
{-184.33, 176.42, 8.99}, -- Field2-Line11
{-192.16, 176.59, 8.8}, -- Field2-Line12
{-193.66, 172.53, 8.27}, -- Field2-Line12
{-195.16, 168.47, 7.73}, -- Field2-Line12
{-196.65, 164.41, 7.2}, -- Field2-Line12
{-198.15, 160.35, 6.67}, -- Field2-Line12
{-199.64, 156.29, 6.13}, -- Field2-Line12
{-201.14, 152.23, 5.6}, -- Field2-Line12
{-202.63, 148.17, 5.06}, -- Field2-Line12
{-204.13, 144.11, 4.53}, -- Field2-Line12
{-205.63, 140.05, 4}, -- Field2-Line12
{-207.12, 136, 3.46}, -- Field2-Line12
{-215.15, 141.33, 3.37}, -- Field2-Line13
{-213.72, 144.88, 3.89}, -- Field2-Line13
{-212.3, 148.43, 4.42}, -- Field2-Line13
{-210.88, 151.99, 4.94}, -- Field2-Line13
{-209.45, 155.54, 5.46}, -- Field2-Line13
{-208.03, 159.09, 5.99}, -- Field2-Line13
{-206.61, 162.64, 6.51}, -- Field2-Line13
{-205.18, 166.19, 7.03}, -- Field2-Line13
{-203.76, 169.74, 7.56}, -- Field2-Line13
{-202.33, 173.29, 8.08}, -- Field2-Line13
{-200.91, 176.85, 8.6}, -- Field2-Line13
--NewField:
{20.03, 65.69, 3.12}, -- Field3-Line1
{19.02, 62.68, 3.12}, -- Field3-Line1
{18, 59.67, 3.12}, -- Field3-Line1
{16.99, 56.66, 3.12}, -- Field3-Line1
{15.97, 53.65, 3.12}, -- Field3-Line1
{14.96, 50.63, 3.12}, -- Field3-Line1
{13.94, 47.62, 3.12}, -- Field3-Line1
{12.93, 44.61, 3.12}, -- Field3-Line1
{11.91, 41.6, 3.12}, -- Field3-Line1
{10.9, 38.59, 3.12}, -- Field3-Line1
{9.88, 35.58, 3.12}, -- Field3-Line1
{14.45, 27.38, 3.12}, -- Field3-Line2
{15.7, 30.9, 3.12}, -- Field3-Line2
{16.95, 34.41, 3.12}, -- Field3-Line2
{18.2, 37.92, 3.12}, -- Field3-Line2
{19.45, 41.43, 3.12}, -- Field3-Line2
{20.7, 44.94, 3.12}, -- Field3-Line2
{21.95, 48.45, 3.12}, -- Field3-Line2
{23.2, 51.96, 3.12}, -- Field3-Line2
{24.45, 55.48, 3.12}, -- Field3-Line2
{25.7, 58.99, 3.12}, -- Field3-Line2
{26.95, 62.5, 3.12}, -- Field3-Line2
{33.3, 60.33, 3.12}, -- Field3-Line3
{31.86, 56.35, 3.12}, -- Field3-Line3
{30.43, 52.36, 3.12}, -- Field3-Line3
{29, 48.37, 3.12}, -- Field3-Line3
{27.57, 44.38, 3.12}, -- Field3-Line3
{26.13, 40.39, 3.12}, -- Field3-Line3
{24.7, 36.4, 3.12}, -- Field3-Line3
{23.27, 32.41, 3.12}, -- Field3-Line3
{21.84, 28.42, 3.12}, -- Field3-Line3
{20.4, 24.43, 3.12}, -- Field3-Line3
{18.97, 20.44, 3.12}, -- Field3-Line3
{23.39, 12.01, 3.12}, -- Field3-Line4
{24.99, 16.4, 3.08}, -- Field3-Line4
{26.58, 20.79, 3.03}, -- Field3-Line4
{28.18, 25.17, 2.99}, -- Field3-Line4
{29.78, 29.56, 2.95}, -- Field3-Line4
{31.37, 33.95, 2.91}, -- Field3-Line4
{32.97, 38.34, 2.87}, -- Field3-Line4
{34.57, 42.73, 2.83}, -- Field3-Line4
{36.16, 47.12, 2.78}, -- Field3-Line4
{37.76, 51.51, 2.74}, -- Field3-Line4
{39.36, 55.89, 2.7}, -- Field3-Line4
{45.39, 52.1, 2.05}, -- Field3-Line5
{43.72, 47.49, 2.16}, -- Field3-Line5
{42.05, 42.88, 2.26}, -- Field3-Line5
{40.37, 38.27, 2.37}, -- Field3-Line5
{38.7, 33.67, 2.48}, -- Field3-Line5
{37.03, 29.06, 2.58}, -- Field3-Line5
{35.36, 24.45, 2.69}, -- Field3-Line5
{33.69, 19.84, 2.8}, -- Field3-Line5
{32.02, 15.23, 2.9}, -- Field3-Line5
{30.35, 10.63, 3.01}, -- Field3-Line5
{28.68, 6.02, 3.12}, -- Field3-Line5
{34.28, 0.38, 3.12}, -- Field3-Line6
{35.95, 5.1, 2.95}, -- Field3-Line6
{37.62, 9.83, 2.79}, -- Field3-Line6
{39.28, 14.55, 2.62}, -- Field3-Line6
{40.95, 19.27, 2.45}, -- Field3-Line6
{42.62, 24, 2.29}, -- Field3-Line6
{44.28, 28.72, 2.12}, -- Field3-Line6
{45.95, 33.45, 1.96}, -- Field3-Line6
{47.62, 38.17, 1.79}, -- Field3-Line6
{49.29, 42.9, 1.62}, -- Field3-Line6
{50.95, 47.62, 1.46}, -- Field3-Line6
{57.24, 42.3, 0.79}, -- Field3-Line7
{55.49, 37.49, 1.02}, -- Field3-Line7
{53.74, 32.68, 1.26}, -- Field3-Line7
{51.99, 27.87, 1.49}, -- Field3-Line7
{50.23, 23.06, 1.72}, -- Field3-Line7
{48.48, 18.25, 1.95}, -- Field3-Line7
{46.73, 13.44, 2.19}, -- Field3-Line7
{44.98, 8.63, 2.42}, -- Field3-Line7
{43.23, 3.82, 2.65}, -- Field3-Line7
{41.48, -0.99, 2.88}, -- Field3-Line7
{39.73, -5.8, 3.12}, -- Field3-Line7
{44.38, -12.07, 2.72}, -- Field3-Line8
{46.24, -7.02, 2.51}, -- Field3-Line8
{48.1, -1.97, 2.3}, -- Field3-Line8
{49.96, 3.08, 2.08}, -- Field3-Line8
{51.82, 8.14, 1.87}, -- Field3-Line8
{53.68, 13.19, 1.66}, -- Field3-Line8
{55.54, 18.24, 1.45}, -- Field3-Line8
{57.4, 23.29, 1.24}, -- Field3-Line8
{59.26, 28.35, 1.03}, -- Field3-Line8
{61.11, 33.4, 0.82}, -- Field3-Line8
{62.97, 38.45, 0.61}, -- Field3-Line8
{69.25, 33.98, 0.61}, -- Field3-Line9
{67.32, 28.65, 0.76}, -- Field3-Line9
{65.4, 23.33, 0.91}, -- Field3-Line9
{63.47, 18, 1.06}, -- Field3-Line9
{61.55, 12.68, 1.22}, -- Field3-Line9
{59.63, 7.35, 1.37}, -- Field3-Line9
{57.7, 2.03, 1.52}, -- Field3-Line9
{55.78, -3.3, 1.67}, -- Field3-Line9
{53.86, -8.62, 1.82}, -- Field3-Line9
{51.93, -13.95, 1.97}, -- Field3-Line9
{50.01, -19.27, 2.12}, -- Field3-Line9
{55.2, -25.2, 1.6}, -- Field3-Line10
{57.14, -19.82, 1.5}, -- Field3-Line10
{59.09, -14.44, 1.4}, -- Field3-Line10
{61.03, -9.06, 1.3}, -- Field3-Line10
{62.97, -3.68, 1.21}, -- Field3-Line10
{64.92, 1.7, 1.11}, -- Field3-Line10
{66.86, 7.08, 1.01}, -- Field3-Line10
{68.8, 12.46, 0.91}, -- Field3-Line10
{70.74, 17.84, 0.81}, -- Field3-Line10
{72.69, 23.22, 0.71}, -- Field3-Line10
{74.63, 28.6, 0.61}, -- Field3-Line10
{79.79, 22.09, 0.61}, -- Field3-Line11
{77.78, 16.61, 0.66}, -- Field3-Line11
{75.77, 11.13, 0.7}, -- Field3-Line11
{73.75, 5.65, 0.75}, -- Field3-Line11
{71.74, 0.17, 0.79}, -- Field3-Line11
{69.73, -5.31, 0.84}, -- Field3-Line11
{67.71, -10.79, 0.89}, -- Field3-Line11
{65.7, -16.27, 0.93}, -- Field3-Line11
{63.69, -21.75, 0.98}, -- Field3-Line11
{61.67, -27.23, 1.02}, -- Field3-Line11
{59.66, -32.71, 1.07}, -- Field3-Line11
{65.19, -39.32, 0.61}, -- Field3-Line12
{66.43, -35.85, 0.61}, -- Field3-Line12
{67.67, -32.38, 0.61}, -- Field3-Line12
{68.92, -28.91, 0.61}, -- Field3-Line12
{70.16, -25.44, 0.61}, -- Field3-Line12
{71.4, -21.97, 0.61}, -- Field3-Line12
{72.65, -18.51, 0.61}, -- Field3-Line12
{73.89, -15.04, 0.61}, -- Field3-Line12
{75.13, -11.57, 0.61}, -- Field3-Line12
{76.38, -8.1, 0.61}, -- Field3-Line12
{77.62, -4.63, 0.61}, -- Field3-Line12
-- New Field
{-10.02, 0.76, 3.12}, -- Field4-Line1
{-13.89, -10.09, 3.12}, -- Field4-Line1
{-17.76, -20.95, 3.12}, -- Field4-Line1
{-21.63, -31.8, 3.12}, -- Field4-Line1
{-25.51, -42.65, 3.12}, -- Field4-Line1
{-29.38, -53.5, 3.12}, -- Field4-Line1
{-33.25, -64.35, 3.12}, -- Field4-Line1
{-37.12, -75.2, 3.12}, -- Field4-Line1
{-40.99, -86.05, 3.12}, -- Field4-Line1
{-44.86, -96.91, 3.12}, -- Field4-Line1
{-48.73, -107.76, 3.12}, -- Field4-Line1
{-40.53, -109.98, 3.12}, -- Field4-Line2
{-37.07, -99.5, 3.12}, -- Field4-Line2
{-33.61, -89.03, 3.12}, -- Field4-Line2
{-30.15, -78.55, 3.12}, -- Field4-Line2
{-26.69, -68.08, 3.12}, -- Field4-Line2
{-23.23, -57.61, 3.12}, -- Field4-Line2
{-19.77, -47.13, 3.12}, -- Field4-Line2
{-16.31, -36.66, 3.12}, -- Field4-Line2
{-12.85, -26.18, 3.12}, -- Field4-Line2
{-9.39, -15.71, 3.12}, -- Field4-Line2
{-5.93, -5.23, 3.12}, -- Field4-Line2
{-1.12, -9.96, 3.12}, -- Field4-Line3
{-4.31, -20.08, 3.12}, -- Field4-Line3
{-7.5, -30.2, 3.12}, -- Field4-Line3
{-10.69, -40.32, 3.12}, -- Field4-Line3
{-13.88, -50.44, 3.12}, -- Field4-Line3
{-17.07, -60.56, 3.12}, -- Field4-Line3
{-20.26, -70.67, 3.12}, -- Field4-Line3
{-23.45, -80.79, 3.12}, -- Field4-Line3
{-26.63, -90.91, 3.12}, -- Field4-Line3
{-29.82, -101.03, 3.12}, -- Field4-Line3
{-33.01, -111.15, 3.12}, -- Field4-Line3
{-25.19, -112.82, 3.12}, -- Field4-Line4
{-22.21, -103.26, 3.12}, -- Field4-Line4
{-19.22, -93.69, 3.12}, -- Field4-Line4
{-16.24, -84.12, 3.12}, -- Field4-Line4
{-13.25, -74.55, 3.12}, -- Field4-Line4
{-10.26, -64.98, 3.12}, -- Field4-Line4
{-7.28, -55.41, 3.12}, -- Field4-Line4
{-4.29, -45.85, 3.12}, -- Field4-Line4
{-1.31, -36.28, 3.12}, -- Field4-Line4
{1.68, -26.71, 3.12}, -- Field4-Line4
{4.67, -17.14, 3.12}, -- Field4-Line4
{10.67, -23.64, 3.12}, -- Field4-Line5
{7.9, -32.61, 3.09}, -- Field4-Line5
{5.12, -41.58, 3.06}, -- Field4-Line5
{2.34, -50.55, 3.03}, -- Field4-Line5
{-0.44, -59.53, 3.01}, -- Field4-Line5
{-3.22, -68.5, 2.98}, -- Field4-Line5
{-5.99, -77.47, 2.95}, -- Field4-Line5
{-8.77, -86.44, 2.93}, -- Field4-Line5
{-11.55, -95.42, 2.9}, -- Field4-Line5
{-14.33, -104.39, 2.87}, -- Field4-Line5
{-17.11, -113.36, 2.84}, -- Field4-Line5
{-9.53, -115.29, 2.14}, -- Field4-Line6
{-6.92, -106.72, 2.24}, -- Field4-Line6
{-4.31, -98.14, 2.34}, -- Field4-Line6
{-1.7, -89.57, 2.43}, -- Field4-Line6
{0.91, -80.99, 2.53}, -- Field4-Line6
{3.51, -72.41, 2.63}, -- Field4-Line6
{6.12, -63.84, 2.73}, -- Field4-Line6
{8.73, -55.26, 2.82}, -- Field4-Line6
{11.34, -46.68, 2.92}, -- Field4-Line6
{13.95, -38.11, 3.02}, -- Field4-Line6
{16.56, -29.53, 3.12}, -- Field4-Line6
{22.51, -36.73, 3.12}, -- Field4-Line7
{20.15, -44.65, 2.95}, -- Field4-Line7
{17.78, -52.57, 2.79}, -- Field4-Line7
{15.42, -60.48, 2.62}, -- Field4-Line7
{13.06, -68.4, 2.46}, -- Field4-Line7
{10.7, -76.32, 2.29}, -- Field4-Line7
{8.34, -84.24, 2.12}, -- Field4-Line7
{5.98, -92.16, 1.96}, -- Field4-Line7
{3.62, -100.08, 1.79}, -- Field4-Line7
{1.25, -108, 1.63}, -- Field4-Line7
{-1.11, -115.92, 1.46}, -- Field4-Line7
{6.56, -117.72, 0.76}, -- Field4-Line8
{8.64, -110.41, 1}, -- Field4-Line8
{10.72, -103.1, 1.23}, -- Field4-Line8
{12.8, -95.79, 1.47}, -- Field4-Line8
{14.89, -88.48, 1.7}, -- Field4-Line8
{16.97, -81.17, 1.94}, -- Field4-Line8
{19.05, -73.86, 2.18}, -- Field4-Line8
{21.13, -66.55, 2.41}, -- Field4-Line8
{23.21, -59.24, 2.65}, -- Field4-Line8
{25.29, -51.93, 2.88}, -- Field4-Line8
{27.38, -44.62, 3.12}, -- Field4-Line8
{33.27, -52.77, 2.3}, -- Field4-Line9
{31.42, -59.37, 2.13}, -- Field4-Line9
{29.58, -65.96, 1.96}, -- Field4-Line9
{27.73, -72.56, 1.79}, -- Field4-Line9
{25.88, -79.16, 1.62}, -- Field4-Line9
{24.04, -85.75, 1.45}, -- Field4-Line9
{22.19, -92.35, 1.28}, -- Field4-Line9
{20.34, -98.94, 1.12}, -- Field4-Line9
{18.49, -105.54, 0.95}, -- Field4-Line9
{16.65, -112.13, 0.78}, -- Field4-Line9
{14.8, -118.73, 0.61}, -- Field4-Line9
{22.84, -119.95, 0.61}, -- Field4-Line10
{24.42, -114.15, 0.68}, -- Field4-Line10
{26.01, -108.34, 0.76}, -- Field4-Line10
{27.59, -102.54, 0.84}, -- Field4-Line10
{29.17, -96.73, 0.91}, -- Field4-Line10
{30.76, -90.93, 0.99}, -- Field4-Line10
{32.34, -85.12, 1.06}, -- Field4-Line10
{33.92, -79.31, 1.14}, -- Field4-Line10
{35.51, -73.51, 1.21}, -- Field4-Line10
{37.09, -67.7, 1.29}, -- Field4-Line10
{38.67, -61.9, 1.36}, -- Field4-Line10
{44.37, -71.69, 0.61}, -- Field4-Line11
{43.06, -76.43, 0.61}, -- Field4-Line11
{41.74, -81.17, 0.61}, -- Field4-Line11
{40.43, -85.9, 0.61}, -- Field4-Line11
{39.11, -90.64, 0.61}, -- Field4-Line11
{37.8, -95.37, 0.61}, -- Field4-Line11
{36.48, -100.11, 0.61}, -- Field4-Line11
{35.16, -104.84, 0.61}, -- Field4-Line11
{33.85, -109.58, 0.62}, -- Field4-Line11
{32.53, -114.31, 0.62}, -- Field4-Line11
{31.22, -119.05, 0.62}, -- Field4-Line11
{40.76, -115.96, 0.62}, -- Field4-Line12
{41.63, -112.8, 0.62}, -- Field4-Line12
{42.51, -109.63, 0.62}, -- Field4-Line12
{43.38, -106.46, 0.61}, -- Field4-Line12
{44.25, -103.3, 0.61}, -- Field4-Line12
{45.13, -100.13, 0.61}, -- Field4-Line12
{46, -96.96, 0.61}, -- Field4-Line12
{46.88, -93.8, 0.61}, -- Field4-Line12
{47.75, -90.63, 0.61}, -- Field4-Line12
{48.63, -87.46, 0.61}, -- Field4-Line12
{49.5, -84.3, 0.61}, -- Field4-Line12

}
