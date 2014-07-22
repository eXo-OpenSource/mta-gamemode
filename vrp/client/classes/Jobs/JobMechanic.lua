-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobMechanic.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobMechanic = inherit(Job)

function JobMechanic:constructor()
	Job.constructor(self, 682.4, -1577.6, 13.1, "Mechanic.png", "files/images/Jobs/HeaderTrashman.png", _"Mechaniker", _([[
		Als Mechaniker ist es vor allem deine Aufgabe andere Spieler in Situationen zu unterstützen, in denen sie durch kaputte Autos behindert werden.
	]]))
	
end

function JobMechanic:start()
	
end

function JobMechanic:stop()
	
end
