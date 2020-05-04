DrivingSchool = inherit(Singleton)
addRemoteEvents{"DrivingLesson:setMarker", "DrivingLesson:endLesson"}

function DrivingSchool:constructor()
	self:createPed()
	self:createLowLodObjects()
	NonCollisionArea:new("Cuboid", {Vector3(1352, -1624, 12.5), 15, 5, 5})

	addEventHandler("DrivingLesson:setMarker", localPlayer, bind(self.Event_onNextMarker, self))
	addEventHandler("DrivingLesson:endLesson", localPlayer, bind(self.Event_endLesson, self))
end

function DrivingSchool:Event_onNextMarker( pos, vehicle )
	if pos then
		setPedCanBeKnockedOffBike(localPlayer,false)
		local x,y,z, rot = unpack(pos)
		if self.m_CurrentMarker then
			if isElement(self.m_CurrentMarker) then
				destroyElement(self.m_CurrentMarker)
			end
		end
		if self.m_CurrentBlip then
			delete(self.m_CurrentBlip)
		end
		self.m_CurrentVehicle = vehicle
		self.m_CurrentMarker = createMarker(x,y,z-0.1, "checkpoint",3,200,200,0)
		self.m_CurrentBlip = Blip:new("Marker.png", x, y, 9999, {200,200,0})
		addEventHandler("onClientMarkerHit", self.m_CurrentMarker ,function(hE, dim)
			if dim then
				if hE.vehicle then
					if hE.vehicle == self.m_CurrentVehicle then
						playSoundFrontEnd(13)
						triggerServerEvent("drivingSchoolHitRouteMarker", localPlayer)
					end
				end
			end
		end)
	end
end

function DrivingSchool:Event_endLesson()
	if self.m_CurrentMarker then
		if isElement(self.m_CurrentMarker) then
			destroyElement(self.m_CurrentMarker)
		end
	end
	if self.m_CurrentBlip then
		delete(self.m_CurrentBlip)
	end
	self.m_CurrentVehicle = nil
	setPedCanBeKnockedOffBike(localPlayer,true)
end

function DrivingSchool:createPed()
	local ped = Ped.create(295, Vector3( -2035.32, -117.65, 1035.17), 270)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped:setInterior(3)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Fahrschule", "Theorietest und mehr!")
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			if DrivingSchoolTheoryGUI:isInstantiated() then return end

			local onlinePlayers = CompanyManager:getSingleton():getFromId(CompanyStaticId.DRIVINGSCHOOL):getOnlinePlayers()
			DrivingSchoolPedGUI:new(#onlinePlayers < 3)
		end
	)
end

function DrivingSchool:createLowLodObjects()
	house = createObject(6134, 1783, -1720.7002, 16, 0, 0, 0)
	houseLOD = createObject(6134, 1783, -1720.7002, 15.5, 0, 0, 0, true)
	setLowLODElement(house, houseLOD)


	ground = createObject(6959, 1784.5, -1701.5, 12.39, 0, 0, 0)
	ground:setScale(1.45, 1.2, 1)
	groundLOD = createObject(6959, 1784.5, -1701.5, 11.7, 0, 0, 0, true)
	groundLOD:setScale(1.45, 1.1, 1)
	setLowLODElement(ground, groundLOD)

	groundNorth = createObject(6959, 1784.5, -1657.5, 12.3)
	groundNorth:setScale(1.45, 1, 1)

	groundEast = createObject(6959, 1835.15, -1701.500, 12.3)
	groundEast:setScale(1, 1.2, 1)

	groundSouth = createObject(6959, 1784.5, -1745.5, 12.3)
	groundSouth:setScale(1.45, 1, 1)

	FileTextureReplacer:new(ground, "files/images/Textures/DrivingSchool/ground.png", "greyground256128", {}, true, true)
	FileTextureReplacer:new(groundLOD, "files/images/Textures/DrivingSchool/ground.png", "greyground256128", {}, true, true)

	FileTextureReplacer:new(groundNorth, "files/images/Textures/DrivingSchool/ground.png", "greyground256128", {}, true, true)
	FileTextureReplacer:new(groundEast, "files/images/Textures/DrivingSchool/ground.png", "greyground256128", {}, true, true)
	FileTextureReplacer:new(groundSouth, "files/images/Textures/DrivingSchool/ground.png", "greyground256128", {}, true, true)
end