-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)




function JobPizza:constructor()
	Job.constructor(self,2104.20, -1815.21, 12.55, "Pizza.png", "files/images/Jobs/HeaderPizzaDelivery.png", _(HelpTextTitles.Jobs.Trashman):gsub("Job: ", ""), _(HelpTexts.Jobs.Trashman), self.onInfo)
	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Trashman):gsub("Job: ", ""), _(HelpTexts.Jobs.Trashman))
end
