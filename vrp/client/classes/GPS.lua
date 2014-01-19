-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GPS.lua
-- *  PURPOSE:     Simple GPS class
-- *
-- ****************************************************************************
GPS = inherit(Singleton)

function GPS:constructor()
	self.m_Destination = nil
	self.m_Arrow = nil
	self.m_ColShape = nil
	self.m_UpdateFunc = bind(GPS.update, self)
end

function GPS:startNavigationTo(x, y, z)
	self.m_Destination = Vector(x, y, z)
	self.m_Arrow = createObject(1318, 0, 0, 0)
	setElementCollisionsEnabled(self.m_Arrow, false)
	self.m_ColShape = createColSphere(x, y, z, 20)
	
	addEventHandler("onClientPreRender", root, self.m_UpdateFunc)
	addEventHandler("onClientColShapeHit", self.m_ColShape, bind(self.colShapeHit, self))
end
addEvent("navigationStart", true)
addEventHandler("navigationStart", root, function(x, y, z) GPS:getSingleton():startNavigationTo(x, y, z) end)

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
	local horizontalRotation = findRotation(x, y, self.m_Destination.X, self.m_Destination.Y) - 90
	local verticalRotation = math.deg(math.asin((self.m_Destination.Z - z) / getDistanceBetweenPoints3D(self.m_Destination.X, self.m_Destination.Y, self.m_Destination.Z, x, y, z)))
	
	setElementPosition(self.m_Arrow, x, y, z + 1)
	setElementRotation(self.m_Arrow, 0, 90 + verticalRotation, horizontalRotation)
end

function GPS:colShapeHit(hitElement, matchingDimension)
	if hitElement == localPlayer and matchingDimension then
		self:stopNavigation()
		localPlayer:sendMessage(_"You have reached your destination!", 0, 255, 0)
	end
end
