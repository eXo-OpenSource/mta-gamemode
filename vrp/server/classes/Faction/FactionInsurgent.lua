-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionInsurgent.lua
-- *  PURPOSE:     Insurgent Faction Class
-- *
-- ****************************************************************************

FactionInsurgent = inherit(Singleton)
local MOVE_DAY_TIME = 36*((60*1000)*60)
local SHIP_SPEED_IN_MS = 900000
function FactionInsurgent:constructor() 

	addRemoteEvents{"onTransmitterHit", "onInsurgentShipArriveWaypoint"}

	self:createIslandMap() 
	self:createAirportMap()
	self:createShip()
	addEventHandler("onInsurgentShipArriveWaypoint", self.m_OceanNavigationColShape, function() 
		
	end)

end

function FactionInsurgent:createIslandMap() 
	self.m_Map = MapParser:new(":exo_maps/fraktionen/terroristtown.map")
	self.m_Map:create(0)
	local x, y, z = getElementPosition(self.m_Map:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	setElementAlpha(bin, 0)
	setElementCollisionsEnabled(bin, false)
	for key, obj in ipairs(self.m_Map.m_Maps[1]) do 
		if isElement(obj) then
			attachRotationAdjusted ( obj, bin)
		end
	end
	self.m_MapIslandRoot = bin
	moveObject(bin, MOVE_DAY_TIME/2, -1*math.random(4819, 6000), -3000, z) 
	setTimer(moveObject, MOVE_DAY_TIME/2, 1, bin, MOVE_DAY_TIME/2, -1*math.random(4819, 6000), 3000, z)
	self.m_IslandDockColShape = createObject(1337, -4984.70, 1944.32, 13.02)
	setElementAlpha(self.m_IslandDockColShape, 0)
	setObjectScale(bin, 0)
	setElementCollisionsEnabled( self.m_IslandDockColShape, false) 
	setElementFrozen(self.m_IslandDockColShape, true)
	attachRotationAdjusted( self.m_IslandDockColShape, bin)
	setObjectScale(self.m_IslandDockColShape, 0)
end

function FactionInsurgent:createAirportMap() 
	self.m_Map2 = MapParser:new(":exo_maps/fraktionen/island_airport.map")
	self.m_Map2:create(0)
	local x, y, z = getElementPosition(self.m_Map2:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	setElementAlpha(bin, 0)
	setElementCollisionsEnabled(bin, false)
	for key, obj in ipairs(self.m_Map2.m_Maps[1]) do 
		if isElement(obj) then
			attachRotationAdjusted ( obj, bin)
		end
	end
	self.m_MapAirportRoot = bin
	setObjectScale(bin, 0)
	self.m_AirportDockColShape = createObject(1337, 6894.94, -3137.65, 2.58)
	setElementAlpha(self.m_AirportDockColShape, 0)
	setElementCollisionsEnabled( self.m_AirportDockColShape, false) 
	setElementFrozen(self.m_AirportDockColShape, true)
	setObjectScale(self.m_AirportDockColShape, 0)
	attachRotationAdjusted( self.m_AirportDockColShape, bin)
end

function FactionInsurgent:createShip() 
	self.m_Map3 = MapParser:new(":exo_maps/fraktionen/terror_ship.map")
	self.m_Map3:create(0)
	local x, y, z = getElementPosition(self.m_Map3:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	setElementAlpha(bin, 0)
	setElementCollisionsEnabled(bin, false)
	for key, obj in ipairs(self.m_Map3.m_Maps[1]) do 
		if isElement(obj) then
			attachRotationAdjusted ( obj, bin)
		end
	end
	self.m_MapShipRoot = bin
	stopObject(bin)
	setElementRotation(bin , 0, 0, 180)
	x,y = self:getShipPosition() 
	setObjectScale(bin, 0)
	setElementPosition(self.m_MapShipRoot, x-20, y-30, z)
	self.m_OceanNavigationColShape = createObject(1337, -4263.92, -3792.22, 15.618)
	setElementAlpha(self.m_OceanNavigationColShape, 0)
	setObjectScale(self.m_OceanNavigationColShape, 0)
	setElementCollisionsEnabled( self.m_OceanNavigationColShape, false) 
	setElementFrozen(self.m_OceanNavigationColShape, true)

end

function FactionInsurgent:getIslandPosition() 
	local x, y, z = getElementPosition(self.m_MapIslandRoot) 
	return x, y, z
end

function FactionInsurgent:getAirportPosition() 
	local x, y, z = getElementPosition(self.m_MapAirportRoot) 
	return x, y, z
end

function FactionInsurgent:getShipPosition() 
	local x, y, z = getElementPosition(self.m_MapShipRoot) 
	return x, y, z
end

function FactionInsurgent:moveShipToElement( object ) 
	local x,y,z = getElementPosition(object) 
	local x2, y2, z2 = self:getShipPosition()
	local _, _, rotZ = getElementRotation(self.m_MapShipRoot)
	local targetRotZ = findRotation(x2, y2, x, y)
	self.m_ShipTravelDistance =  getDistanceBetweenPoints3D( x, y, z, x2, y2, z2) 
	if targetRotZ > rotZ then 
		targetRotZ = targetRotZ - rotZ
	else 
		targetRotZ = rotZ - targetRotZ
	end
	if self.m_ShipMoveTimer then 
		if isTimer(self.m_ShipMoveTimer) then 
			killTimer(self.m_ShipMoveTimer)
		end
	end
	moveObject(self.m_MapShipRoot, SHIP_SPEED_IN_MS, x, y, z2)
	moveObject(self.m_MapShipRoot, 30000, x2, y2, z2, 0, 0, targetRotZ)
	self.m_ShipMoveTimer = setTimer( 
	function() 
		local x,y,z = getElementPosition(object) 
		local x2, y2, z2 = self:getShipPosition()
		local _, _, rotZ = getElementRotation(self.m_MapShipRoot)
		local targetRotZ = findRotation(x2, y2, x, y)
		local currentDistance = getDistanceBetweenPoints3D( x, y, z, x2, y2, z2)
		local deltaDistance = self.m_ShipTravelDistance / currentDistance
		local adjustSpeed = SHIP_SPEED_IN_MS/deltaDistance
		if adjustSpeed <= 20000 then  adjustSpeed = 20000 end
		if targetRotZ > rotZ then 
			targetRotZ = targetRotZ - rotZ
		else 
			targetRotZ = rotZ - targetRotZ
		end
		stopObject(self.m_MapShipRoot)
		
		moveObject(self.m_MapShipRoot, adjustSpeed, x, y, z2 , 0, 0, targetRotZ)
		if currentDistance <= 10 then
			outputChatBox(currentDistance)
			if self.m_ShipMoveTimer then 
				if isTimer(self.m_ShipMoveTimer) then 
					killTimer(self.m_ShipMoveTimer)
				end
			end
			triggerEvent("onInsurgentShipArriveWaypoint", object)
		end
	end, 30000, 0)
end

function FactionInsurgent:Event_onTransmitterHit() 

end

function FactionInsurgent:destructor() 

end

