DrivingSchool = inherit(Singleton)
addRemoteEvents{"DrivingLesson:setMarker", "addDrivingSchoolAutoTestSpeechBubble", "DrivingLesson:endLesson"}
function DrivingSchool:constructor() 	
	addEventHandler("DrivingLesson:setMarker", localPlayer, bind(self.Event_onNextMarker, self))
	addEventHandler("addDrivingSchoolAutoTestSpeechBubble", localPlayer,self.Event_getSpeakBubble)
	addEventHandler("DrivingLesson:endLesson", localPlayer, bind(self.Event_endLesson, self))
	triggerServerEvent("requestAutomaticTestPedBubble", localPlayer)
	self.m_NonCollidingArea = NonCollidingArea:new(1367.10-15, -1624.27, 15, 5)
end

function DrivingSchool:Event_onNextMarker( pos, vehicle ) 
	if pos then 
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
		self.m_CurrentBlip = Blip:new("Marker.png", x, y, 9999, false, tocolor(200,200,0,255))
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
end

function DrivingSchool.Event_getSpeakBubble( ped )
	local name = _"Automatische Fahrprüfung"
	local description = _"Falls zu wenig Fahrlehrer online sind!"
	ped.SpeakBubble = SpeakBubble3D:new(ped, name, description, 270)
end

function DrivingSchool:destructor() 
	delete(self.m_NonCollidingArea)
end