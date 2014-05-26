-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobBusDriver.lua
-- *  PURPOSE:     Bus driver job class
-- *
-- ****************************************************************************
JobBusDriver = inherit(Job)

function JobBusDriver:constructor()
	Job.constructor(self, 1797, -1756, 12.5, "files/images/Blips/Bus.png", "files/images/Jobs/HeaderRoadSweeper.png", _"Busfahrer", _([[
		Als Busfahrer fährst du von Haltestelle zu Haltestelle und verdienst dabei Geld.
		Wenn du an Haltestellen zusätzlich Spieler einsteigen lässt, steigt dein Verdienst.
	]]))
end

function JobBusDriver:start()
end

function JobBusDriver:stop()
end
