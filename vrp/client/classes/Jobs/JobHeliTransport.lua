-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobHeliTransport.lua
-- *  PURPOSE:     Heli Transport job class
-- *
-- ****************************************************************************
JobHeliTransport = inherit(Job)

function JobHeliTransport:constructor()
	Job.constructor(self, 16, 1786.09, -2271.62, 26.80, 180, "HeliTransport.png", {120, 70, 0}, "files/images/Jobs/HeaderHeliTransport.png", _(HelpTextTitles.Jobs.HeliTransport):gsub("Job: ", ""), _(HelpTexts.Jobs.HeliTransport))
	self.m_Target = {}
	self:setJobLevel(JOB_LEVEL_HELITRANSPORT)

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.HeliTransport):gsub("Job: ", ""), "jobs.helitransport")

	addRemoteEvents{"jobHeliTransportCreateMarker", "endHeliTransport"}
	addEventHandler("jobHeliTransportCreateMarker", root, bind(self.createTarget, self))
	addEventHandler("endHeliTransport", root, bind(self.endHeliTransport, self))
end

function JobHeliTransport:start()
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.HeliTransport), _(HelpTexts.Jobs.HeliTransport))
end

function JobHeliTransport:stop()
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end

function JobHeliTransport:endHeliTransport()
	if isElement(self.m_Target["marker"]) then self.m_Target["marker"]:destroy() end
	if self.m_Target["blip"] then delete(self.m_Target["blip"]) end
end

function JobHeliTransport:createTarget(type)
	local pos
	if type == "pickup" then
		pos = Vector3(2322.13, -2078.09, 15.19)
	elseif type == "delivery" then
		pos = JobHeliTransport.m_Targets[math.random(1, #JobHeliTransport.m_Targets)]
	end

	if self.m_Target["marker"] then self.m_Target["marker"]:destroy() end
	if self.m_Target["blip"] then delete(self.m_Target["blip"]) end

	self.m_Target["type"] = type
	self.m_Target["marker"] = createMarker(pos, "corona", 3, 0, 0, 255, 255)
	self.m_Target["blip"] = Blip:new("Marker.png", pos.x, pos.y, 9999, BLIP_COLOR_CONSTANTS.Red)
	self.m_Target["blip"]:setDisplayText("Paket-Abgabe")
	addEventHandler("onClientMarkerHit", self.m_Target["marker"], function(hitElement, dim)
		if hitElement == localPlayer and dim then
			if self.m_Target["type"] == "pickup" then
				triggerServerEvent("jobHeliTransportOnPickupLoad", localPlayer)
			elseif self.m_Target["type"] == "delivery" then
				triggerServerEvent("jobHeliTransportOnDelivery", localPlayer)
			end
		end
	end)
end

JobHeliTransport.m_Targets = {
	Vector3(1544.1999511719, -1353.4000244141, 329.5),
	Vector3(-1186, 25.799999237061, 14.10000038147),
	Vector3(-2023.1999511719, 440.60000610352, 139.69999694824),
	Vector3(-2227.8999023438, 2326.6000976563, 7.5),
	Vector3(365.39999389648, 2536.8999023438, 16.700000762939),
	Vector3(2094, 2415.1999511719, 74.599998474121),
	Vector3(2416.27, 2471.68, 69.47)
}
