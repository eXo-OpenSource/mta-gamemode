-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Elevator.lua
-- *  PURPOSE:     Elevator class
-- *
-- ****************************************************************************
Elevator = inherit(Object)
Elevator.Map = {}

addRemoteEvents{"elevatorStartDrive", "elevatorDrive"}

function Elevator.drive(elevatorId, stationId)
	Elevator.Map[elevatorId]:driveToStation(client, stationId)
end
addEventHandler("elevatorDrive", root, Elevator.drive)

function Elevator.startDrive(elevatorId, stationId)
	client.elevator = Elevator.Map[elevatorId]
	client.elevatorStationId = stationId
end
addEventHandler("elevatorStartDrive", root, Elevator.startDrive)

function Elevator:constructor(checkFunction)
	self.m_Stations = {}
	self.m_Id = #Elevator.Map+1
	self.Check = checkFunction
	Elevator.Map[self.m_Id] = self
end

function Elevator:addStation(name, position, rot, int, dim) 
	local stationID = #self.m_Stations+1
	ElevatorManager.Map[self] = stationID
	self.m_Stations[stationID] = {}
	self.m_Stations[stationID].name = name
	self.m_Stations[stationID].position = position
	self.m_Stations[stationID].interior = int or 0
	self.m_Stations[stationID].dimension = dim or 0
	self.m_Stations[stationID].rotation = rot or 0
	self.m_Stations[stationID].marker = createMarker(Vector3(position.x, position.y, position.z-1), "cylinder", 1, 255, 255, 255, 125)
	local markerColShape = createColSphere(Vector3(position.x, position.y, position.z-0.4), 2)
	markerColShape.m_Marker = self.m_Stations[stationID].marker
	self.m_Stations[stationID].marker.id = stationID
	if int then
		self.m_Stations[stationID].marker:setInterior(int)
		markerColShape:setInterior(int)
	end
	if dim then
		self.m_Stations[stationID].marker:setDimension(dim)
		markerColShape:setDimension(dim)
	end
	ElementInfo:new(self.m_Stations[stationID].marker, "Aufzug", 1.2, "ArrowsAlt", true)
	addEventHandler("onColShapeHit", markerColShape, bind(self.onStationMarkerHit, self) )
	addEventHandler("onColShapeLeave", markerColShape, bind(self.onStationMarkerLeave, self) )
end

function Elevator:showElevator(player, marker)
	if marker and isElement(marker) and player:getType() == "player" and (player:getDimension() == marker:getDimension()) and (player:getInterior() == marker:getInterior()) then
		if not player.vehicle then
			if not player.elevatorUsed then
				if self.Check then
					if self.Check(player) then 
						local pVec = self.m_Stations[marker.id].position
						hitElement:triggerEvent("showElevatorGUI", self.m_Id, self.m_Stations[source.id].name, self.m_Stations, {pVec.x,pVec.y,pVec.z} , self.m_Stations[source.id].interior)
					end
				else
					local pVec = self.m_Stations[marker.id].position
					player:triggerEvent("showElevatorGUI", self.m_Id, self.m_Stations[marker.id].name, self.m_Stations, {pVec.x,pVec.y,pVec.z} , self.m_Stations[marker.id].interior)
				end
			end
		end
	end
end

function Elevator:onStationMarkerHit(hitElement, dim)
	if source.m_Marker and hitElement:getType() == "player" and hitElement:getDimension() == source:getDimension() then
		hitElement.m_ElevatorData = {self, source.m_Marker}
		hitElement:triggerEvent("onTryEnterExit", source.m_Marker, "Aufzug")
	end
end

function Elevator:onStationMarkerLeave(hitElement, dim)
	if hitElement:getType() == "player" and hitElement:getDimension() == source:getDimension() then
		hitElement.m_ElevatorData = nil
		hitElement.elevatorUsed = false
	end
end

function Elevator:driveToStation(player, stationID)
	player.elevatorUsed = true
	player.m_ElevatorData = nil
	player.elevator = false
	player.elevatorStationId = false

	-- Workaround TODO
	nextframe(
		function()
			setElementInterior(player, self.m_Stations[stationID].interior)
			player:setPosition(self.m_Stations[stationID].position)
		end
	)
	player:setInterior(0)
	--

	player:setRotation(Vector3(0, 0, self.m_Stations[stationID].rotation))
	setElementDimension(player, self.m_Stations[stationID].dimension)
	setElementFrozen(player, false)
end

function Elevator:forceStationPosition(player, stationID)
	setElementInterior(player, self.m_Stations[stationID].interior)
	player:setPosition(self.m_Stations[stationID].position)
	setElementDimension(player,self.m_Stations[stationID].dimension)
end
