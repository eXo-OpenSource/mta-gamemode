-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/ZombieSurvivalRoom.lua
-- *  PURPOSE:     ZombieSurvivalRoom for Deathmatch-Script
-- *
-- ****************************************************************************

ZombieSurvivalRoom = inherit(Object)

function ZombieSurvivalRoom:constructor(player)
	self.m_Dimension = math.random(1, 999) -- Testing
	player:setDimension(self.m_Dimension)
	player:setPosition(183.62, 1764.55, 17.64)
	player:setInterior(0)
	self:loadMap()
	self:addZombieSpawner(Vector3(179.66, 1786.36, 17.64))
	addEventHandler("onZombieWasted", root, function(ped, player)
		player:sendInfo("Du hast einen Zombie getötet!")
	end)


end

function ZombieSurvivalRoom:loadMap()
	local map = {
		createObject ( 987, 213.2, 1787.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1775.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1763.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1751.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1739.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1727.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 201.3, 1727.2, 16.6 ),
		createObject ( 987, 189.3, 1727.2, 16.6 ),
		createObject ( 987, 177.3, 1727.2, 16.6 ),
		createObject ( 987, 165.3, 1727.2, 16.6 ),
		createObject ( 987, 153.3, 1727.2, 16.6 ),
		createObject ( 987, 141.3, 1727.2, 16.6 ),
		createObject ( 987, 129.3, 1727.2, 16.6 ),
		createObject ( 987, 117.3, 1727.2, 16.6 ),
		createObject ( 987, 105.2, 1727.2, 16.6 ),
		createObject ( 987, 93.2, 1727.2, 16.6 ),
		createObject ( 987, 81.2, 1727.2, 16.6 ),
		createObject ( 987, 81.2, 1739.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1751.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1763.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1775.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1787.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1799, 16.6, 0, 0, 270 ),
		createObject ( 987, 93.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 105.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 117.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 129.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 141.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 153.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 165.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 177.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 189.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 201.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 213.2, 1799, 16.6, 0, 0, 180 )
	}
	for index, object in pairs(map) do
		object:setDimension(self.m_Dimension)
	end
end

function ZombieSurvivalRoom:addZombieSpawner(pos)
	setTimer(function()
		 Zombie:new(pos.x, pos.y, pos.z, 264, self.m_Dimension)
	end, 5000, 0)

end

addCommandHandler("zombiegame", function(player)
	ZombieSurvivalRoom:new(player)
end)
