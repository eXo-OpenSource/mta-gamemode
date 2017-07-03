-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)

function JobLogistician:constructor()
	Job.constructor(self, 16, 1589.32, 2286.20, 10.82, 270, "Logistician.png", "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	Job.constructor(self, 16, -1741.941, 36.493, 3.555, 90, "Logistician.png", "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	Job.constructor(self, 16, -244.92, -246.35, 1.43, 180, "Logistician.png", "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	--last one should always be "Docks LS" because that's e.g. the point where the townhall navigation leads to
	Job.constructor(self, 16, 2407.25, -2439.00, 13.63, 227, "Logistician.png", "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	self:setJobLevel(JOB_LEVEL_LOGISTICAN)

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), "jobs.logistican")
end

function JobLogistician:start()
  -- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Logistician), _(HelpTexts.Jobs.Logistician))
end

function JobLogistician:stop()
  -- Reset text in help menu
  HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end
