-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Singleton)

function Job:constructor(posX, posY, posZ, blipPath, headerImage, name, description)
	-- Create the customblip
	HUDRadar:getSingleton():addBlip(blipPath, posX, posY)
	self.m_Name = name
	
	-- Create a job marker
	self.m_Marker = createMarker(posX, posY, posZ, "cylinder", 1.5, 255, 255, 0, 200)
	addEventHandler("onClientMarkerHit", self.m_Marker,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				local jobGUI = JobGUI:getSingleton()
				jobGUI:setDescription(description)
				jobGUI:setHeaderImage(headerImage)
				jobGUI:setAcceptCallback(bind(Job.acceptHandler, self))
				jobGUI:open()
			end
		end
	)
end

function Job:acceptHandler()
	triggerServerEvent("jobAccepted", root, self:getId())
end

function Job:getId()
	return self.m_Id
end

function Job:setId(Id)
	self.m_Id = Id
end

function Job:getName()
	return self.m_Name
end
