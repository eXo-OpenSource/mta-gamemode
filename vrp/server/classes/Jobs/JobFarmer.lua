JobFarmer = inherit(Job)

local VEHICLE_SPAWN = {-66.21, 69.00, 2.2, 68}
--local PLANT_DELIVERY = {-1108.28723,-1620.65833,75.36719}
local PLANT_DELIVERY = {-2150.31, -2445.04, 29.63}
local MONEYPERPLANT = 25
local PLANTSONWALTON = 50
local STOREMARKERPOS = {-37.85, 58.03, 2.2}

function JobFarmer:constructor()
	Job.constructor(self)
	self.m_Plants = {}

	local x,y,z,rotation = unpack ( VEHICLE_SPAWN )
	self.m_VehicleSpawner = VehicleSpawner:new(x,y,z, {"Tractor"; "Combine Harvester"; "Walton"}, rotation, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

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

function JobFarmer:onVehicleSpawn(player,vehicleModel,vehicle)
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
	end

	addEventHandler("onVehicleStartEnter",vehicle, function(vehPlayer, seat)
		vehPlayer:sendError("Du kannst nicht in dieses Job-Fahrzeug!")
		cancelEvent()
	end)

	player.farmerVehicle = vehicle
	addEventHandler("onVehicleExit", vehicle, function(vehPlayer, seat)
		if seat == 0 then
			if vehPlayer:getData("Farmer.Income") and vehPlayer:getData("Farmer.Income") > 0 then
				vehPlayer:giveMoney(player:getData("Farmer.Income"), "Farmer-Job")
				vehPlayer:setData("Farmer.Income", 0)
				vehPlayer:triggerEvent("Job.updateIncome", 0)
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
	if getElementType(hitElement) == "player" then
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
		self.m_DeliveryBlip = Blip:new("Waypoint.png", x, y, player,600)
		self.m_DeliveryBlip:setStreamDistance(2000)
	else
		delete(self.m_DeliveryBlip)
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
		player:giveMoney(player:getData("Farmer.Income"), "Farmer-Job")
		player:setData("Farmer.Income", 0)
		player:triggerEvent("Job.updateIncome", 0)
	end
	if player.farmerVehicle and isElement(player.farmerVehicle) then player.farmerVehicle:destroy() end
end

function JobFarmer:checkRequirements(player)
	if not (player:getJobLevel() >= 4) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel 4", player), 255, 0, 0)
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
		player:sendMessage("Sie haben die Lieferung abgegeben, Gehalt : $"..self.m_CurrentPlants[player]*MONEYPERPLANT,0,255,0)
		player:giveMoney(self.m_CurrentPlants[player]*MONEYPERPLANT, "Farmer-Job")
		player:givePoints(math.ceil(self.m_CurrentPlants[player]/10))
		self.m_CurrentPlants[player] = 0
		self:updatePrivateData(player)

		for i, v in pairs(getAttachedElements(hitElement)) do
			if v:getModel() == 2968 then -- only destroy crates
				destroyElement(v)
			end
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
		hitElement:setData("Farmer.Income", hitElement:getData("Farmer.Income") + math.random(2, 3))
		hitElement:triggerEvent("Job.updateIncome", hitElement:getData("Farmer.Income"))
		self.m_CurrentPlantsFarm = self.m_CurrentPlantsFarm + 1
		self:updateClientData()

		-- Give some points
		if chance(6) then
			hitElement:givePoints(1)
		end
	else
		if vehicleID == getVehicleModelFromName("Tractor") and not self.m_Plants[createColShape] then
			self.m_Plants[createColShape] = createObject(818,x,y,z-1.5)
			local object = self.m_Plants[createColShape]
			object.isFarmAble = false
			setTimer(function (o) o.isFarmAble = true end, 1000*7.5, 1, object)
			setElementVisibleTo(object, hitElement, true)
			if not hitElement:getData("Farmer.Income") then hitElement:setData("Farmer.Income", 0) end
			hitElement:setData("Farmer.Income", hitElement:getData("Farmer.Income") + math.random(1, 2))
			hitElement:triggerEvent("Job.updateIncome", hitElement:getData("Farmer.Income"))
			-- Give some points
			if chance(4) then
				hitElement:givePoints(1)
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

addCommandHandler("plant", function(player)
	local pos = player:getPosition()
	local function farmRound(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	local x, y, z = farmRound(pos.x, 2), farmRound(pos.y, 2), farmRound(pos.z, 2)
	outputChatBox("{"..x..", "..y..", "..z.."},")
end)

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
}
