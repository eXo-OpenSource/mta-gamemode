-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/DeathmatchEvent.lua
-- *  PURPOSE:     Deathmatch event class
-- *
-- ****************************************************************************
DeathmatchEvent = inherit(Event)

function DeathmatchEvent:constructor()
	Event.constructor(self)
end

function DeathmatchEvent:start()
	-- Spawn all participating player at the spawnpoint
	for k, player in ipairs(getElementsByType("player")) do
		setElementPosition(player, x, y, z)
	end
end
