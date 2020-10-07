-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)

function JobLogistician:constructor()
	Job.constructor(self, 16, 1589.32, 2286.20, 10.82, 270, "Logistician.png", {120, 70, 0}, "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	Job.constructor(self, 16, -1741.941, 36.493, 3.555, 90, "Logistician.png", {120, 70, 0}, "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	Job.constructor(self, 16, -244.92, -246.35, 1.43, 180, "Logistician.png", {120, 70, 0}, "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	--last one should always be "Docks LS" because that's e.g. the point where the townhall navigation leads to
	Job.constructor(self, 16, 2407.25, -2439.00, 13.63, 227, "Logistician.png", {120, 70, 0}, "files/images/Jobs/HeaderLogistician.png", _(HelpTextTitles.Jobs.Logistician):gsub("Job: ", ""), _(HelpTexts.Jobs.Logistician))
	self:setJobLevel(JOB_LEVEL_LOGISTICAN)

end

function JobLogistician:start()
  -- Show text in help menu
  HelpBar:getSingleton():setLexiconPage(LexiconPages.JobLogistician)
end

function JobLogistician:stop()
  -- Reset text in help menu
  HelpBar:getSingleton():setLexiconPage(nil)
end
