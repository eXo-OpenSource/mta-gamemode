-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/LasertagEvent.lua
-- *  PURPOSE:     Lasertag event class
-- *
-- ****************************************************************************
LasertagEvent = inherit(Event)
local LASERTAG_DIMENSION = 5

function LasertagEvent:constructor()
	self.m_MapParser = MapParser:new("files/maps/Lasertag/Lasertag1.map")
	self.m_MapParser:create(LASERTAG_DIMENSION)
end

function LasertagEvent:destructor()
	delete(self.m_MapParser)
end

function LasertagEvent:onStart()
	-- Spawn all participating player at the spawnpoint
	for k, player in pairs(self:getPlayers()) do
		player:setPosition(x, y, z)
		
		player:giveWeapon(22, 100, true)
	end
	
	
end

function LasertagEvent:onPlayerLeave(player)
	player:takeWeapon(player, 22, 100)
end

function LasertagEvent:getName()
	return "Lasertag"
end

function LasertagEvent:getPositions()
	return {Vector3(2669.9, -1757.5, 10.8)}
end
