-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobPickpocket.lua
-- *  PURPOSE:     Pickpocket job class
-- *
-- ****************************************************************************
JobPickpocket = inherit(Job)

function JobPickpocket:constructor()
	Job.constructor(self, 1990.09961, -1778, 16.3, "files/images/Blips/Pickpocket.png", "files/images/Jobs/HeaderPickpocket.png", [[
		Als Taschendieb kannst du Getränkeautomaten ausrauben
	]])
	
end

function JobPickpocket:start()
end