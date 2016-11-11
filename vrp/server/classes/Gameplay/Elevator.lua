-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Elevator.lua
-- *  PURPOSE:     Elevator class
-- *
-- ****************************************************************************
Elevator = inherit(Object)
Elevator.Map = {}

addRemoteEvents{"elevatorDrive"}

function Elevator.drive(elevatorId, stationId)
	Elevator.Map[elevatorId]:driveToStation(client, stationId)
end
addEventHandler("elevatorDrive", root, Elevator.drive)

function Elevator:constructor()
	self.m_Stations = {}
	self.m_Id = #Elevator.Map+1

	Elevator.Map[self.m_Id] = self
end

function Elevator:addStation(name, position)
	local stationID = #self.m_Stations+1
	self.m_Stations[stationID] = {}
	self.m_Stations[stationID].name = name
	self.m_Stations[stationID].position = position
	self.m_Stations[stationID].marker = createMarker(position, "corona", 1.5, 255, 255, 0)
	self.m_Stations[stationID].marker.id = stationID

	addEventHandler("onMarkerHit", self.m_Stations[stationID].marker, bind(self.onStationMarkerHit, self) )
	addEventHandler("onMarkerLeave", self.m_Stations[stationID].marker, bind(self.onStationMarkerLeave, self) )
end

function Elevator:onStationMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if not hitElement.vehicle then
			if not hitElement.elevatorUsed then
				hitElement:triggerEvent("showElevatorGUI", self.m_Id, self.m_Stations[source.id].name, self.m_Stations)
			end
		end
	end
end

function Elevator:onStationMarkerLeave(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		hitElement.elevatorUsed = false
	end
end

function Elevator:driveToStation(player, stationID)
	player.elevatorUsed = true
	player:setPosition(self.m_Stations[stationID].position)
end
