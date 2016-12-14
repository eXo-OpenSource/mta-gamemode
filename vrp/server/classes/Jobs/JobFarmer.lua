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
{-123.23, 59.59, 3.12},
{-123.71, 58.34, 3.12},
{-124.84, 55.41, 3.12},
{-126.01, 52.38, 3.12},
{-126.91, 50.05, 3.12},
{-128.31, 46.41, 3.12},
{-129.43, 43.59, 3.12},
{-131.02, 39.7, 3.12},
{-132.44, 36.36, 3.12},
{-133.94, 32.41, 3.12},
{-135.43, 28.47, 3.12},
{-136.73, 25.03, 3.12},
{-138.02, 21.63, 3.12},
{-139.3, 18.25, 3.12},
{-140.61, 14.81, 3.12},
{-141.92, 11.36, 3.12},
{-143.19, 8, 3.12},
{-144.62, 4.45, 3.12},
{-146.44, 0.26, 3.12},
{-147.92, -3.12, 3.12},
{-149.83, -7.49, 3.12},
{-151.31, -10.88, 3.12},
{-152.82, -14.33, 3.12},
{-154.3, -17.85, 3.12},
{-155.73, -21.82, 3.12},
{-156.83, -25.13, 3.12},
{-158.27, -29.06, 3.12},
{-160.04, -33.49, 3.12},
{-161.6, -37.5, 3.12},
{-163.13, -41.39, 3.12},
{-164.92, -45.96, 3.12},
{-166.54, -50.11, 3.12},
{-168.25, -54.45, 3.12},
{-170.35, -59.47, 3.12},
{-172.15, -64.26, 3.12},
{-173.89, -68.77, 3.12},
{-181.86, -83.27, 3.12},
{-180.38, -79.46, 3.12},
{-178.67, -74.61, 3.12},
{-177.17, -70.08, 3.12},
{-175.65, -65.51, 3.12},
{-174.5, -62.07, 3.12},
{-173.21, -58.43, 3.12},
{-171.76, -54.3, 3.12},
{-170.18, -50.15, 3.12},
{-168.61, -46.44, 3.12},
{-167.3, -43.08, 3.12},
{-165.74, -39.05, 3.12},
{-164.23, -35.17, 3.12},
{-162.91, -31.6, 3.12},
{-161.61, -28.21, 3.12},
{-160.25, -24.64, 3.12},
{-158.77, -20.78, 3.12},
{-156.89, -15.81, 3.12},
{-155.42, -11.9, 3.12},
{-154.05, -8.48, 3.12},
{-152.36, -4.2, 3.12},
{-150.55, 0.44, 3.12},
{-148.91, 4.67, 3.12},
{-147.15, 9.2, 3.12},
{-145.8, 12.67, 3.12},
{-144.17, 16.79, 3.12},
{-142.34, 21.27, 3.12},
{-140.77, 25.14, 3.12},
{-139.15, 28.96, 3.12},
{-137.2, 33.91, 3.12},
{-135.46, 38.31, 3.12},
{-133.94, 42.14, 3.12},
{-132.18, 46.51, 3.12},
{-130.41, 50.93, 3.12},
{-128.87, 54.86, 3.12},
{-127.25, 59.08, 3.12},
{-130.3, 64.08, 3.12},
{-131.73, 60.71, 3.12},
{-133.17, 57.28, 3.12},
{-134.74, 53.14, 3.12},
{-136.19, 49.08, 3.12},
{-137.49, 45.15, 3.12},
{-139.32, 40.08, 3.12},
{-140.55, 36.69, 3.12},
{-142.3, 31.56, 3.12},
{-143.68, 27.57, 3.12},
{-144.92, 24.13, 3.12},
{-146.18, 20.74, 3.12},
{-147.98, 16.08, 3.12},
{-149.3, 12.57, 3.12},
{-150.88, 8.41, 3.12},
{-152.31, 4.88, 3.12},
{-154.08, 0.26, 3.12},
{-155.39, -3.36, 3.12},
{-156.94, -7.38, 3.12},
{-158.36, -11.08, 3.12},
{-160.02, -15.22, 3.12},
{-161.39, -18.65, 3.12},
{-163.04, -22.73, 3.12},
{-164.36, -26.04, 3.12},
{-165.73, -29.46, 3.12},
{-167.19, -33.2, 3.12},
{-168.72, -37.35, 3.12},
{-170.11, -40.86, 3.12},
{-171.74, -44.93, 3.12},
{-173.35, -48.99, 3.12},
{-174.71, -52.58, 3.12},
{-176.35, -56.91, 3.12},
{-177.76, -60.53, 3.12},
{-179.06, -64.51, 3.12},
{-180.66, -68.99, 3.12},
{-181.97, -72.96, 3.12},
{-183.22, -76.99, 3.12},
{-184.61, -80.93, 3.12},
{-189.07, -84.33, 3.12},
{-188.16, -80.38, 3.12},
{-186.68, -76.54, 3.12},
{-185.28, -73.13, 3.12},
{-183.51, -69.14, 3.12},
{-181.99, -65.42, 3.12},
{-180.39, -61.3, 3.12},
{-179.37, -57.73, 3.12},
{-178.21, -53.27, 3.12},
{-176.75, -48.89, 3.12},
{-175.67, -45.84, 3.12},
{-173.87, -41.29, 3.12},
{-172.45, -37.62, 3.12},
{-171.05, -33.85, 3.12},
{-169.73, -30.26, 3.12},
{-168.42, -26.75, 3.12},
{-166.91, -22.66, 3.12},
{-165.64, -19.21, 3.12},
{-164.18, -15.27, 3.12},
{-162.71, -11.42, 3.12},
{-161.11, -7.52, 3.12},
{-159.49, -3.65, 3.12},
{-157.87, 0.19, 3.12},
{-156.24, 4.07, 3.12},
{-154.68, 7.89, 3.12},
{-153.11, 11.73, 3.12},
{-151.6, 15.56, 3.12},
{-150.36, 18.92, 3.12},
{-149, 22.91, 3.12},
{-147.78, 26.52, 3.12},
{-146.62, 29.95, 3.12},
{-145.53, 33.35, 3.12},
{-144.2, 37.35, 3.12},
{-142.76, 41.27, 3.12},
{-141.53, 44.62, 3.12},
{-140.24, 48.54, 3.12},
{-138.9, 52.57, 3.12},
{-137.48, 56.54, 3.12},
{-136.3, 60.01, 3.12},
{-135, 64.04, 3.12},
{-137.62, 65.85, 3.12},
{-139.02, 63.13, 3.12},
{-140.68, 59.35, 3.12},
{-142.02, 55.64, 3.12},
{-143.24, 52.02, 3.12},
{-144.8, 47.56, 3.12},
{-123.23, 59.59, 3.12},
{-123.71, 58.34, 3.12},
{-124.84, 55.41, 3.12},
{-126.01, 52.38, 3.12},
{-126.91, 50.05, 3.12},
{-128.31, 46.41, 3.12},
{-129.43, 43.59, 3.12},
{-131.02, 39.7, 3.12},
{-132.44, 36.36, 3.12},
{-133.94, 32.41, 3.12},
{-135.43, 28.47, 3.12},
{-136.73, 25.03, 3.12},
{-138.02, 21.63, 3.12},
{-139.3, 18.25, 3.12},
{-140.61, 14.81, 3.12},
{-141.92, 11.36, 3.12},
{-143.19, 8, 3.12},
{-144.62, 4.45, 3.12},
{-146.44, 0.26, 3.12},
{-147.92, -3.12, 3.12},
{-149.83, -7.49, 3.12},
{-151.31, -10.88, 3.12},
{-152.82, -14.33, 3.12},
{-154.3, -17.85, 3.12},
{-155.73, -21.82, 3.12},
{-156.83, -25.13, 3.12},
{-158.27, -29.06, 3.12},
{-160.04, -33.49, 3.12},
{-161.6, -37.5, 3.12},
{-163.13, -41.39, 3.12},
{-164.92, -45.96, 3.12},
{-166.54, -50.11, 3.12},
{-168.25, -54.45, 3.12},
{-170.35, -59.47, 3.12},
{-172.15, -64.26, 3.12},
{-173.89, -68.77, 3.12},
{-181.86, -83.27, 3.12},
{-180.38, -79.46, 3.12},
{-178.67, -74.61, 3.12},
{-177.17, -70.08, 3.12},
{-175.65, -65.51, 3.12},
{-174.5, -62.07, 3.12},
{-173.21, -58.43, 3.12},
{-171.76, -54.3, 3.12},
{-170.18, -50.15, 3.12},
{-168.61, -46.44, 3.12},
{-167.3, -43.08, 3.12},
{-165.74, -39.05, 3.12},
{-164.23, -35.17, 3.12},
{-162.91, -31.6, 3.12},
{-161.61, -28.21, 3.12},
{-160.25, -24.64, 3.12},
{-158.77, -20.78, 3.12},
{-156.89, -15.81, 3.12},
{-155.42, -11.9, 3.12},
{-154.05, -8.48, 3.12},
{-152.36, -4.2, 3.12},
{-150.55, 0.44, 3.12},
{-148.91, 4.67, 3.12},
{-147.15, 9.2, 3.12},
{-145.8, 12.67, 3.12},
{-144.17, 16.79, 3.12},
{-142.34, 21.27, 3.12},
{-140.77, 25.14, 3.12},
{-139.15, 28.96, 3.12},
{-137.2, 33.91, 3.12},
{-135.46, 38.31, 3.12},
{-133.94, 42.14, 3.12},
{-132.18, 46.51, 3.12},
{-130.41, 50.93, 3.12},
{-128.87, 54.86, 3.12},
{-127.25, 59.08, 3.12},
{-130.3, 64.08, 3.12},
{-131.73, 60.71, 3.12},
{-133.17, 57.28, 3.12},
{-134.74, 53.14, 3.12},
{-136.19, 49.08, 3.12},
{-137.49, 45.15, 3.12},
{-139.32, 40.08, 3.12},
{-140.55, 36.69, 3.12},
{-142.3, 31.56, 3.12},
{-143.68, 27.57, 3.12},
{-144.92, 24.13, 3.12},
{-146.18, 20.74, 3.12},
{-147.98, 16.08, 3.12},
{-149.3, 12.57, 3.12},
{-150.88, 8.41, 3.12},
{-152.31, 4.88, 3.12},
{-154.08, 0.26, 3.12},
{-155.39, -3.36, 3.12},
{-156.94, -7.38, 3.12},
{-158.36, -11.08, 3.12},
{-160.02, -15.22, 3.12},
{-161.39, -18.65, 3.12},
{-163.04, -22.73, 3.12},
{-164.36, -26.04, 3.12},
{-165.73, -29.46, 3.12},
{-167.19, -33.2, 3.12},
{-168.72, -37.35, 3.12},
{-170.11, -40.86, 3.12},
{-171.74, -44.93, 3.12},
{-173.35, -48.99, 3.12},
{-174.71, -52.58, 3.12},
{-176.35, -56.91, 3.12},
{-177.76, -60.53, 3.12},
{-179.06, -64.51, 3.12},
{-180.66, -68.99, 3.12},
{-181.97, -72.96, 3.12},
{-183.22, -76.99, 3.12},
{-184.61, -80.93, 3.12},
{-189.07, -84.33, 3.12},
{-188.16, -80.38, 3.12},
{-186.68, -76.54, 3.12},
{-185.28, -73.13, 3.12},
{-183.51, -69.14, 3.12},
{-181.99, -65.42, 3.12},
{-180.39, -61.3, 3.12},
{-179.37, -57.73, 3.12},
{-178.21, -53.27, 3.12},
{-176.75, -48.89, 3.12},
{-175.67, -45.84, 3.12},
{-173.87, -41.29, 3.12},
{-172.45, -37.62, 3.12},
{-171.05, -33.85, 3.12},
{-169.73, -30.26, 3.12},
{-168.42, -26.75, 3.12},
{-166.91, -22.66, 3.12},
{-165.64, -19.21, 3.12},
{-164.18, -15.27, 3.12},
{-162.71, -11.42, 3.12},
{-161.11, -7.52, 3.12},
{-159.49, -3.65, 3.12},
{-157.87, 0.19, 3.12},
{-156.24, 4.07, 3.12},
{-154.68, 7.89, 3.12},
{-153.11, 11.73, 3.12},
{-151.6, 15.56, 3.12},
{-150.36, 18.92, 3.12},
{-149, 22.91, 3.12},
{-147.78, 26.52, 3.12},
{-146.62, 29.95, 3.12},
{-145.53, 33.35, 3.12},
{-144.2, 37.35, 3.12},
{-142.76, 41.27, 3.12},
{-141.53, 44.62, 3.12},
{-140.24, 48.54, 3.12},
{-138.9, 52.57, 3.12},
{-137.48, 56.54, 3.12},
{-136.3, 60.01, 3.12},
{-135, 64.04, 3.12},
{-137.62, 65.85, 3.12},
{-139.02, 63.13, 3.12},
{-140.68, 59.35, 3.12},
{-142.02, 55.64, 3.12},
{-143.24, 52.02, 3.12},
{-144.8, 47.56, 3.12},
{-123.23, 59.59, 3.12},
{-123.71, 58.34, 3.12},
{-124.84, 55.41, 3.12},
{-126.01, 52.38, 3.12},
{-126.91, 50.05, 3.12},
{-128.31, 46.41, 3.12},
{-129.43, 43.59, 3.12},
{-131.02, 39.7, 3.12},
{-132.44, 36.36, 3.12},
{-133.94, 32.41, 3.12},
{-135.43, 28.47, 3.12},
{-136.73, 25.03, 3.12},
{-138.02, 21.63, 3.12},
{-139.3, 18.25, 3.12},
{-140.61, 14.81, 3.12},
{-141.92, 11.36, 3.12},
{-143.19, 8, 3.12},
{-144.62, 4.45, 3.12},
{-146.44, 0.26, 3.12},
{-147.92, -3.12, 3.12},
{-149.83, -7.49, 3.12},
{-151.31, -10.88, 3.12},
{-152.82, -14.33, 3.12},
{-154.3, -17.85, 3.12},
{-155.73, -21.82, 3.12},
{-156.83, -25.13, 3.12},
{-158.27, -29.06, 3.12},
{-160.04, -33.49, 3.12},
{-161.6, -37.5, 3.12},
{-163.13, -41.39, 3.12},
{-164.92, -45.96, 3.12},
{-166.54, -50.11, 3.12},
{-168.25, -54.45, 3.12},
{-170.35, -59.47, 3.12},
{-172.15, -64.26, 3.12},
{-173.89, -68.77, 3.12},
{-181.86, -83.27, 3.12},
{-180.38, -79.46, 3.12},
{-178.67, -74.61, 3.12},
{-177.17, -70.08, 3.12},
{-175.65, -65.51, 3.12},
{-174.5, -62.07, 3.12},
{-173.21, -58.43, 3.12},
{-171.76, -54.3, 3.12},
{-170.18, -50.15, 3.12},
{-168.61, -46.44, 3.12},
{-167.3, -43.08, 3.12},
{-165.74, -39.05, 3.12},
{-164.23, -35.17, 3.12},
{-162.91, -31.6, 3.12},
{-161.61, -28.21, 3.12},
{-160.25, -24.64, 3.12},
{-158.77, -20.78, 3.12},
{-156.89, -15.81, 3.12},
{-155.42, -11.9, 3.12},
{-154.05, -8.48, 3.12},
{-152.36, -4.2, 3.12},
{-150.55, 0.44, 3.12},
{-148.91, 4.67, 3.12},
{-147.15, 9.2, 3.12},
{-145.8, 12.67, 3.12},
{-144.17, 16.79, 3.12},
{-142.34, 21.27, 3.12},
{-140.77, 25.14, 3.12},
{-139.15, 28.96, 3.12},
{-137.2, 33.91, 3.12},
{-135.46, 38.31, 3.12},
{-133.94, 42.14, 3.12},
{-132.18, 46.51, 3.12},
{-130.41, 50.93, 3.12},
{-128.87, 54.86, 3.12},
{-127.25, 59.08, 3.12},
{-130.3, 64.08, 3.12},
{-131.73, 60.71, 3.12},
{-133.17, 57.28, 3.12},
{-134.74, 53.14, 3.12},
{-136.19, 49.08, 3.12},
{-137.49, 45.15, 3.12},
{-139.32, 40.08, 3.12},
{-140.55, 36.69, 3.12},
{-142.3, 31.56, 3.12},
{-143.68, 27.57, 3.12},
{-144.92, 24.13, 3.12},
{-146.18, 20.74, 3.12},
{-147.98, 16.08, 3.12},
{-149.3, 12.57, 3.12},
{-150.88, 8.41, 3.12},
{-152.31, 4.88, 3.12},
{-154.08, 0.26, 3.12},
{-155.39, -3.36, 3.12},
{-156.94, -7.38, 3.12},
{-158.36, -11.08, 3.12},
{-160.02, -15.22, 3.12},
{-161.39, -18.65, 3.12},
{-163.04, -22.73, 3.12},
{-164.36, -26.04, 3.12},
{-165.73, -29.46, 3.12},
{-167.19, -33.2, 3.12},
{-168.72, -37.35, 3.12},
{-170.11, -40.86, 3.12},
{-171.74, -44.93, 3.12},
{-173.35, -48.99, 3.12},
{-174.71, -52.58, 3.12},
{-176.35, -56.91, 3.12},
{-177.76, -60.53, 3.12},
{-179.06, -64.51, 3.12},
{-180.66, -68.99, 3.12},
{-181.97, -72.96, 3.12},
{-183.22, -76.99, 3.12},
{-184.61, -80.93, 3.12},
{-189.07, -84.33, 3.12},
{-188.16, -80.38, 3.12},
{-186.68, -76.54, 3.12},
{-185.28, -73.13, 3.12},
{-183.51, -69.14, 3.12},
{-181.99, -65.42, 3.12},
{-180.39, -61.3, 3.12},
{-179.37, -57.73, 3.12},
{-178.21, -53.27, 3.12},
{-176.75, -48.89, 3.12},
{-175.67, -45.84, 3.12},
{-173.87, -41.29, 3.12},
{-172.45, -37.62, 3.12},
{-171.05, -33.85, 3.12},
{-169.73, -30.26, 3.12},
{-168.42, -26.75, 3.12},
{-166.91, -22.66, 3.12},
{-165.64, -19.21, 3.12},
{-164.18, -15.27, 3.12},
{-162.71, -11.42, 3.12},
{-161.11, -7.52, 3.12},
{-159.49, -3.65, 3.12},
{-157.87, 0.19, 3.12},
{-156.24, 4.07, 3.12},
{-154.68, 7.89, 3.12},
{-153.11, 11.73, 3.12},
{-151.6, 15.56, 3.12},
{-150.36, 18.92, 3.12},
{-149, 22.91, 3.12},
{-147.78, 26.52, 3.12},
{-146.62, 29.95, 3.12},
{-145.53, 33.35, 3.12},
{-144.2, 37.35, 3.12},
{-142.76, 41.27, 3.12},
{-141.53, 44.62, 3.12},
{-140.24, 48.54, 3.12},
{-138.9, 52.57, 3.12},
{-137.48, 56.54, 3.12},
{-136.3, 60.01, 3.12},
{-135, 64.04, 3.12},
{-137.62, 65.85, 3.12},
{-139.02, 63.13, 3.12},
{-140.68, 59.35, 3.12},
{-142.02, 55.64, 3.12},
{-143.24, 52.02, 3.12},
{-144.8, 47.56, 3.12},
}
