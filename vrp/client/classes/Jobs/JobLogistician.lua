-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)

function JobLogistician:constructor()
	Job.constructor(self, 0, 0, 3, "Logistician.png", "files/images/Jobs/HeaderLogistician.png", "Foo", LOREM_IPSUM)

	-- add job to help menu
	--HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
end
