-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
RaceManager = inherit(Singleton)
addRemoteEvents{"RaceManager:sendMap"}


function RaceManager:constructor()
	addEventHandler("RaceManager:sendMap", root, bind(RaceManager.receiveMap, self))
end

function RaceManager:receiveMap(map, dimension)
	outputChatBox("Received Map, create a dummy MapParser instance")
	self.m_Map = MapParser:new(nil, true)
	self.m_Map.m_MapData = map
	self.m_Map:create(dimension)
end
