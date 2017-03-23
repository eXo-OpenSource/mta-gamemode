-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GPS.lua
-- *  PURPOSE:     Simple GPS class
-- *
-- ****************************************************************************
GPS = inherit(Singleton)
addEvent("GPS.retrieveRoute", true)

function GPS:constructor()
	self.m_Destination = nil
	self.m_Arrow = nil
	self.m_ColShape = nil
	self.m_UpdateFunc = bind(GPS.update, self)

	addEventHandler("GPS.retrieveRoute", root,
		function(nodes)
			-- unserialise vectors
			for i, v in pairs(nodes) do
				nodes[i] = normaliseVector(v)
			end

			HUDRadar:getSingleton():setGPSRoute(nodes)
		end
	)
end

function GPS:startNavigationTo(pos)
	self.m_Destination = pos
	self.m_Arrow = createObject(1318, 0, 0, 0)
	setElementCollisionsEnabled(self.m_Arrow, false)
	self.m_ColShape = createColSphere(pos, 20)

	addEventHandler("onClientPreRender", root, self.m_UpdateFunc)
	addEventHandler("onClientColShapeHit", self.m_ColShape, bind(self.colShapeHit, self))

	triggerServerEvent("GPS.calcRoute", localPlayer, "GPS.retrieveRoute", serialiseVector(localPlayer:getPosition()), serialiseVector(pos))
end
addEvent("navigationStart", true)
addEventHandler("navigationStart", root, function(x, y, z) GPS:getSingleton():startNavigationTo(Vector3(x, y,z)) end)

function GPS:stopNavigation()
	if self.m_Arrow and isElement(self.m_Arrow) then
		destroyElement(self.m_Arrow)
		self.m_Arrow = nil
	end
	if self.m_ColShape and isElement(self.m_ColShape) then
		destroyElement(self.m_ColShape)
	end
	self.m_Destination = nil
	removeEventHandler("onClientPreRender", root, self.m_UpdateFunc)
end
addEvent("navigationStop", true)
addEventHandler("navigationStop", root, function() GPS:getSingleton():stopNavigation() end)

function GPS:update()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		self:stopNavigation()
		return
	end

	local x, y, z = getElementPosition(vehicle)
	local horizontalRotation = findRotation(x, y, self.m_Destination.x, self.m_Destination.y) - 90
	local verticalRotation = math.deg(math.asin((self.m_Destination.z - z) / getDistanceBetweenPoints3D(self.m_Destination.x, self.m_Destination.y, self.m_Destination.z, x, y, z)))

	setElementPosition(self.m_Arrow, x, y, z + 1)
	setElementRotation(self.m_Arrow, 0, 90 + verticalRotation, horizontalRotation)
end

function GPS:colShapeHit(hitElement, matchingDimension)
	if hitElement == localPlayer and matchingDimension then
		self:stopNavigation()
		localPlayer:sendMessage(_"Du hast das Ziel erreicht!", 0, 255, 0)
	end
end
