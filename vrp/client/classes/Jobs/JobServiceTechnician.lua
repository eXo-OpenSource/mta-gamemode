-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobServiceTechnician.lua
-- *  PURPOSE:     Service technician job class
-- *
-- ****************************************************************************
JobServiceTechnician = inherit(Job)

function JobServiceTechnician:constructor()
    --Job.constructor(self, 260, 900.80, -1447.34, 14.09, 270, "ServiceTechnician.png", "files/images/Jobs/HeaderServiceTechnician.png", _(HelpTextTitles.Jobs.ServiceTechnician):gsub("Job: ", ""), _(HelpTexts.Jobs.ServiceTechnician))

end

function JobServiceTechnician:start()
  -- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.ServiceTechnician), _(HelpTexts.Jobs.ServiceTechnician))
end

function JobServiceTechnician:stop()
  -- Reset text in help menu
  HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end
