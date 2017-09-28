DrivingSchool = inherit(Singleton)
addRemoteEvents{"DrivingLesson:setMarker", "DrivingLesson:endLesson"}

function DrivingSchool:constructor()
	self:createPed()
	self.m_NonCollidingArea = NonCollidingArea:new(1367.10-15, -1624.27, 15, 5)

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

function DrivingSchool:destructor()
	delete(self.m_NonCollidingArea)
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
