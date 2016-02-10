-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobMechanic.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobMechanic = inherit(Job)

function JobMechanic:constructor()
	--Job.constructor(self, 1080.9, -1204.9, 17, "Mechanic.png", "files/images/Jobs/HeaderMechanic.png", _(HelpTextTitles.Jobs.Mechanic):gsub("Job: ", ""), _(HelpTexts.Jobs.Mechanic))
	Job.constructor(self,  920.160, -1166.879, 15.977, "Mechanic.png", "files/images/Jobs/HeaderMechanic.png", _(HelpTextTitles.Jobs.Mechanic):gsub("Job: ", ""), _(HelpTexts.Jobs.Mechanic))

	--NonCollidingArea:new(1083, -1189.7-62.6, 38.3, 62.6)
	NonCollidingArea:new(807.755, -1309.98, 123, 152)

	-- Add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Mechanic):gsub("Job: ", ""), _(HelpTexts.Jobs.Mechanic))
end

function JobMechanic:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Mechanic), _(HelpTexts.Jobs.Mechanic))
end

function JobMechanic:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end
