-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobFarmer.lua
-- *  PURPOSE:     Farmer job
-- *
-- ****************************************************************************
JobFarmer = inherit(Job)
addRemoteEvents{"Job.updateFarmPlants", "Job.updatePlayerPlants", "onReciveFarmerData", "Job.updateIncome"}

function JobFarmer:constructor()
	Job.constructor(self, 1, -62.62, 76.34, 3.12, 250, "Farmer.png", {117, 93, 65}, "files/images/Jobs/HeaderFarmer.png", _(HelpTextTitles.Jobs.Farmer):gsub("Job: ", ""), _(HelpTexts.Jobs.Farmer), self.onInfo)

	self.m_Ped2 = createPed(1, -19.04, 1175.55, 19.56, 0)
	setElementData(self.m_Ped2, "clickable", true)
	self.m_Ped2:setData("Job", self)
	self.m_Ped2:setData("NPC:Immortal", true)
	self.m_Ped2:setFrozen(true)
	SpeakBubble3D:new(self.m_Ped2, _("Job: %s", self.m_Name), _"Für einen Job klicke mich an!")

	self.m_Blip2 = Blip:new("Farmer.png", -19.04, 1175.55, 500)
	self.m_Blip2:setDisplayText(_(HelpTextTitles.Jobs.Farmer):gsub("Job: ", ""), BLIP_CATEGORY.Job)
	self.m_Blip2:setOptionalColor({117, 93, 65})

	self:setJobLevel(JOB_LEVEL_FARMER)

	self.m_TickFarmerJob = bind(self.tickFarmerJob, self)
	self.m_TickFarmerTimer = nil
end
function JobFarmer:onInfo()
	if localPlayer.vehicle then
		ErrorBox:new(_"Bitte erst aus dem Fahrzeug aussteigen!")
		return
	end

	if (localPlayer.position - Vector3(-62.62, 76.34, 3.12)).length > 10 then
		triggerServerEvent("AntiCheat:ReportFarmerTeleport", localPlayer, (localPlayer.position - Vector3(-62.62, 76.34, 3.12)).length)
		return
	end

	setCameraMatrix(-1.8428000211716, 135.26879882813, 35.644901275635, -2.3047368526459, 134.49794006348, 35.206272125244, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Es gibt verschiedene Aufgaben auf der Farm.",255,255,255,true)
	-- ### 1
	setTimer(function()
	setCameraMatrix(-98.922798156738, 65.984901428223, 44.70890045166, -99.658416748047, 65.534629821777, 44.202819824219, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Eine davon ist es mit dem Traktor die Saat auszulegen.",255,255,255,true)
	end, 3500, 1)
	-- ### 2
	setTimer(function()
	setCameraMatrix(-110.18440246582, 59.231700897217, 25.98390007019, -109.43939208984, 59.41569519043, 25.342723846436, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Fahrzeuge kannst du hier (Marker sichtbar nach dem annehmen) abholen.",255,255,255,true)
	end, 7000, 1)
	-- ### 3
	setTimer(function()
	setCameraMatrix(-44.745899200439, 84.956596374512, 24.216800689697, -44.504783630371, 84.290466308594, 23.511016845703, 0, 70)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Mit dem Mähdrescher kannst du das Korn ernten und mit dem Walton",255,255,255,true)
	outputChatBox(_"#0000FF[Farmer]#FFFFFF kannst du das Getreide zur Abgabe bringen.",255,255,255,true)
	end, 12000, 1)
	--- ### 4

	setTimer(function()
	setCameraMatrix( -2132.4262695313 , -2465.71875 , 56.393901824951 , -2132.8205566406 , -2465.2470703125 , 55.605262756348 , 0 , 70 )
	outputChatBox(_"#0000FF[Farmer]#FFFFFF Bringe das Getreide zu diesem Punkt!",255,255,255,true)
	end, 18000, 1)
	-- ### LAST
	setTimer(function()
	setCameraTarget(localPlayer,localPlayer)
	localPlayer:setPosition(-59.908, 76.689,3.117)
	end, 21500,1)
end

function JobFarmer:hasPlayerFieldVehicle()
	if not localPlayer.vehicle then return false end
	if not localPlayer.vehicle:getData("JobVehicle") then return false end
	if localPlayer.vehicleSeat ~= 0 then return false end
	return (localPlayer.vehicle.model == 531 or localPlayer.vehicle.model == 532)  -- Tractor or Combine 
end

function JobFarmer:start()
	-- Show text in help menu
	HelpBar:getSingleton():setLexiconPage(LexiconPages.JobOverview)

	-- Create info display
	self.m_FarmerImage = GUIImage:new(screenWidth/2-300/2, 10, 300, 50, "files/images/Jobs/Farmerdisplay.png")
	self.m_SeedLabel = GUILabel:new(55, 4, 55, 40, "0", self.m_FarmerImage):setFont(VRPFont(40))
	self.m_FarmLabel = GUILabel:new(150, 4, 55, 40, "0", self.m_FarmerImage):setFont(VRPFont(40))
	self.m_TruckLabel = GUILabel:new(245, 4, 50, 40, "0", self.m_FarmerImage):setFont(VRPFont(40))
	--self.m_FarmerRectangle = GUIRectangle:new(screenWidth/2-300/2, 60, 300, 40, rgb(3, 17, 39))
	--self.m_EarnLabel = GUILabel:new(10, 5, 280, 17, _"Einkommen bisher: 0$", self.m_FarmerRectangle):setFont(VRPFont(20))
	--self.m_EarnInfoLabel = GUILabel:new(10, 25, 280, 15, "Steig aus um das Geld zu erhalten!", self.m_FarmerRectangle):setFont(VRPFont(15))

	-- Register update events
	addEventHandler("Job.updateFarmPlants", root, function (plants, seeds)
		self.m_FarmLabel:setText(tostring(plants))
		self.m_SeedLabel:setText(tostring(seeds))
	end)
	addEventHandler("Job.updatePlayerPlants", root, function (num, num2)
		self.m_TruckLabel:setText(tostring((num and num or 0) + (num2 and num2 or 0)))
	end)
	addEventHandler("Job.updateIncome", root, function (num)
		--self.m_EarnLabel:setText(_("Einkommen bisher: %d$", num))
	end)

	self.m_PlantShapes = {}

	local col, x, y, z
	local id = 1

	self.m_OnFieldEnterFunc = bind(self.onFieldEnter, self)
	self.m_OnFieldLeaveFunc = bind(self.onFieldLeave, self)

	for key, value in ipairs (JobFarmer.PlantField) do
		local col = createColPolygon(unpack(value))
		self.m_PlantShapes[#self.m_PlantShapes+1] = col
		col.m_Id = id
		col.m_Data = value
		id = id + 1
		addEventHandler("onClientColShapeHit", col, self.m_OnFieldEnterFunc)
		addEventHandler("onClientColShapeLeave", col, self.m_OnFieldLeaveFunc)
	end
end

function JobFarmer:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():setLexiconPage(nil)

	-- delete infopanels
	delete(self.m_FarmerImage)
	--delete(self.m_FarmerRectangle)
	if isTimer(self.m_TickFarmerTimer) then killTimer(self.m_TickFarmerTimer) end

	for index, col in pairs(self.m_PlantShapes) do
		col:destroy()
	end
end

function JobFarmer:onFieldEnter(hitEle, dim)
	if hitEle ~= localPlayer or not dim then return end
	if not self:hasPlayerFieldVehicle() or self.m_CurrentField then return end
	self.m_CurrentField = source
	self.m_TickFarmerTimer = setTimer(self.m_TickFarmerJob, 250, 0) 
end

function JobFarmer:onFieldLeave(hitEle, dim)
	if hitEle ~= localPlayer or not dim or not self.m_CurrentField then return end
	self.m_CurrentField = nil
	triggerServerEvent("jobFarmerLeaveField", localPlayer)
	killTimer(self.m_TickFarmerTimer)
end

function JobFarmer:renderOnField()
	if not localPlayer.vehicle then return end
end

function JobFarmer:tickFarmerJob()
	local distBetweenPlants = 5.5
	if localPlayer.vehicle and localPlayer.vehicle.model == 531 and localPlayer.vehicleSeat == 0 and localPlayer.vehicle:getData("JobVehicle") and localPlayer.vehicle.towedByVehicle then
		if localPlayer.vehicle.towedByVehicle:isWithinColShape(self.m_CurrentField) and localPlayer.vehicle.towedByVehicle.onGround then
			-- cancel plant attempt if player is too close to own plant
			if self.m_LastPlantPosition and getDistanceBetweenPoints3D(localPlayer.vehicle.towedByVehicle.position, self.m_LastPlantPosition) < distBetweenPlants then return end

			local position = localPlayer.vehicle.towedByVehicle.position
			local found = false
			local objectsOnField = getElementsByType("object", resourceRoot, true) 

			for i = 1, #objectsOnField do
				local v = objectsOnField[i]
				if v.model == 818 and getDistanceBetweenPoints3D(position, v.position) < 5.5 then
					found = true
					break
				end
			end

			if not found then
				triggerServerEvent("jobFarmerCreatePlant", localPlayer, {position.x, position.y, position.z}, localPlayer.vehicle)
				self.m_LastPlantPosition = position
			end
		end
	end
end

JobFarmer.PlantField = {
	{ -- Feld 1
		Vector2(-117.3076171875, 95.1875),
		Vector3(-117.3076171875, 95.1875, 3.1171875),
		Vector3(-99.8349609375, 150.2138671875, 3.1247665882111),
		Vector3(-140.244140625, 162.8740234375, 5.2273964881897),
		Vector3(-168.455078125, 171.83203125, 8.1895599365234),
		Vector3(-183.658203125, 176.6015625, 9.0283603668213),
		Vector3(-202.5029296875, 177.134765625, 8.5964212417603),
		Vector3(-216.7275390625, 142.2314453125, 3.3410317897797),
		Vector3(-187.0126953125, 119.7060546875, 3.4534635543823),
		Vector3(-142.08203125, 101.568359375, 3.1216146945953)
	},

	{ -- Feld 2
		Vector3(-121.192, 59.8359, 3.11719),
		Vector3(-121.142, 59.8809, 3.11719),
		Vector3(-168.634, -61.1416, 3.11719),
		Vector3(-181.129, -83.9355, 3.11719),
		Vector3(-209.049, -85.707, 3.11719),
		Vector3(-239.911, -80.3516, 3.11719),
		Vector3(-267.244, -67.9668, 3.11719),
		Vector3(-277.023, -54.5674, 3.11719),
		Vector3(-278.003, -40.0596, 1.99573),
		Vector3(-273.949, -19.1064, 1.98942),
		Vector3(-268.456, 0.746094, 1.91468),
		Vector3(-264.523, 16.9658, 1.88016),
		Vector3(-244.035, 78.2598, 1.84003),
		Vector3(-230.666, 103.516, 1.87275),
		Vector3(-201.754, 93.1406, 3.06277),
		Vector3(-144.372, 70.7051, 3.11719)
	},

	{ -- Feld 3
		Vector3(18.6904, 66.7637, 3.11719),
		Vector3(18.6445, 66.6426, 3.10965),
		Vector3(35.2695, 60.498, 3.11719),
		Vector3(57.5986, 43.2744, 0.74116),
		Vector3(80.5508, 26.1797, 0.609375),
		Vector3(77.2354, -15.3135, 0.609375),
		Vector3(71.1914, -48.1816, 0.609375),
		Vector3(63.3008, -38.165, 0.657878),
		Vector3(40.2109, -7.4541, 3.11719),
		Vector3(23.0195, 10.8975, 3.11719),
		Vector3(8.74121, 36.6924, 3.11719)
	},

	{ -- Feld 4
		Vector3(-11.1279, 2.11816, 3.11719),
		Vector3(-11.1621, 2.18457, 3.11719),
		Vector3(-1.22949, -9.21875, 3.11719),
		Vector3(19.0156, -31.2549, 3.11719),
		Vector3(28.9023, -44.2568, 3.11719),
		Vector3(43.5723, -68.4268, 0.616019),
		Vector3(55.7617, -97.625, 0.609375),
		Vector3(44.5625, -115.549, 0.616854),
		Vector3(26.9961, -121.288, 0.616854),
		Vector3(7.9541, -118.968, 0.609375),
		Vector3(-20.7803, -114.163, 3.06371),
		Vector3(-50.6807, -108.506, 3.11719),
		Vector3(-44.4609, -85.4902, 3.11719),
		Vector3(-34.9805, -54.8271, 3.11719),
		Vector3(-28.915, -36.9336, 3.11719),
		Vector3(-20.209, -18.4727, 3.11719)
	}
}
