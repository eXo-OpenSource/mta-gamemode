-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Object)

function Job:constructor(posX, posY, posZ, blipPath, headerImage, description)
	-- Create the customblip
	exports.customblips:createCustomBlip(posX, posY, 32, 32, blipPath)
	
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
