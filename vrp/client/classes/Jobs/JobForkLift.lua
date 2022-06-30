-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobForkLift.lua
-- *  PURPOSE:     Client Fork Lift job class
-- *
-- ****************************************************************************
JobForkLift = inherit(Job)

function JobForkLift:constructor()
	Job.constructor(self, 16, 91.70, -221.12, 1.6, 0, "ForkLift.png", {190, 160, 4}, "files/images/Jobs/HeaderForkLift.png", _(HelpTextTitles.Jobs.ForkLift):gsub("Job: ", ""), _(HelpTexts.Jobs.ForkLift), LexiconPages.JobForkLift)
	self:setJobLevel(JOB_LEVEL_FORKLIFT)

	self:generateLoadMarkers()

end

function JobForkLift:generateLoadMarkers()
	local markers = {Vector3(52.6,-243.3,2), Vector3(62.6, -243.7, 2), Vector3(73.1, -244.3, 2), Vector3(82.9, -245.1, 2), Vector3(159.7, -283.60001, 2.3)}

	for index, pos in pairs(markers) do
		createMarker(pos, "corona", 2.0, 0, 255, 0, 100)
		local colshape = createColSphere(pos, 2)
		addEventHandler("onClientColShapeHit", colshape, bind(self.onLoadMarkerHit, self))
	end
end

function JobForkLift:onLoadMarkerHit(hitElement, dim)
	if getElementType(hitElement) == "player" and hitElement == localPlayer and dim then
		if hitElement:getOccupiedVehicle() and hitElement:getOccupiedVehicle():getModel() == 530 then
			local box
			for index, boxItem in pairs(source:getElementsWithin()) do
				if boxItem:getModel() == 1558 then
					box = boxItem
				end
			end
			if isElement(box) then
				triggerServerEvent("JobForkLiftonBoxLoad", localPlayer, box)
			end
		end
	end
end

function JobForkLift:start()
	HelpBar:getSingleton():setLexiconPage(LexiconPages.JobForkLift)
end

function JobForkLift:stop()
	HelpBar:getSingleton():setLexiconPage(nil)
end
