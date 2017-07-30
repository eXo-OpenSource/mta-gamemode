-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
RaceManager = inherit(Singleton)
addRemoteEvents{"RaceManager:sendMap", "RaceManager:destroyMap"}

function RaceManager:constructor()
	setTimer(bind(RaceManager.checkWater, self), 1000, 0)

	addEventHandler("RaceManager:sendMap", root, bind(RaceManager.receiveMap, self))
	addEventHandler("RaceManager:destroyMap", root, bind(RaceManager.destroyMap, self))
end

-- Todo: Only check when race map is running
function RaceManager:checkWater()
	if not localPlayer.vehicle then return end

	local x, y, z = getElementPosition(localPlayer)
	local waterZ = getWaterLevel(x, y, z)

	if waterZ and z < waterZ - 0.5 then
		triggerServerEvent("RaceMananger:requestKillPlayer", localPlayer)
	end
end

function RaceManager:receiveMap(map, dimension)
	self.m_Map = MapParser:new(nil, true)
	self.m_Map.m_MapData = map
	self.m_Map:create(dimension)

	triggerServerEvent("RaceManager:onPlayerReady", localPlayer)
end

function RaceManager:destroyMap()
	if self.m_Map then
		delete(self.m_Map)
		self.m_Map = nil
	end
end
