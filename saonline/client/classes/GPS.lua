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
	self.m_UpdateFunc = bind(GPS.update, self)
end

function GPS:startNavigationTo(x, y, z)
	self.m_Destination = Vector(x, y, z)
	self.m_Arrow = createObject(1318, 0, 0, 0)
	setElementCollisionsEnabled(self.m_Arrow, false)
	
	addEventHandler("onClientPreRender", root, self.m_UpdateFunc)
end
addEvent("navigationStart", true)
addEventHandler("navigationStart", root, function(x, y, z) GPS:getSingleton():startNavigationTo(x, y, z) end)

function GPS:stopNavigation()
	if self.m_Arrow and isElement(self.m_Arrow) then
		destroyElement(self.m_Arrow)
		self.m_Arrow = nil
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
	--local arrowRotation = findRotation(x, y, self.m_Destination.X, self.m_Destination.Y)
	local arrowRotation = findRotation(x, y, self.m_Destination.X, self.m_Destination.Y) - 90
	
	setElementPosition(self.m_Arrow, x, y, z + 1)
	setElementRotation(self.m_Arrow, 0, 90, arrowRotation)
end
