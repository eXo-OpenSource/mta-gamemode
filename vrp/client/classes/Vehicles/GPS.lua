-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GPS.lua
-- *  PURPOSE:     Simple GPS class
-- *
-- ****************************************************************************
GPS = inherit(Singleton)
addremoteEvents({ "GPS.retrieveRoute", "navigationStart", "navigationStop" })

function GPS:constructor()
	self.m_Destination = nil

	addEventHandler("navigationStart", root, function(x, y, z) self:startNavigationTo(Vector3(x, y, z)) end)
	addEventHandler("navigationStop", root, bind(self.stopNavigation, self))
	addEventHandler("GPS.retrieveRoute", root, bind(self.Event_retrieveRoute, self))
end

function GPS:startNavigationTo(position)
	self.m_Destination = position

	triggerServerEvent("GPS.calcRoute", localPlayer, "GPS.retrieveRoute", serialiseVector(localPlayer:getPosition()), serialiseVector(position))
end

function GPS:stopNavigation()
	self.m_Destination = nil
end

function GPS:Event_retrieveRoute(nodes)
	-- unserialise vectors
	for i, v in pairs(nodes) do
		nodes[i] = normaliseVector(v)
	end

	HUDRadar:getSingleton():setGPSRoute(nodes)
end
