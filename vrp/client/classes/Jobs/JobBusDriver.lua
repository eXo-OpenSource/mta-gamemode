-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobBusDriver.lua
-- *  PURPOSE:     Bus driver job class
-- *
-- ****************************************************************************
JobBusDriver = inherit(Job)

function JobBusDriver:constructor()
	Job.constructor(self, 1108.823, -1748.504, 12.570, "Bus.png", "files/images/Jobs/HeaderRoadSweeper.png", _(HelpTextTitles.Jobs.BusDriver):gsub("Job: ", ""), _(HelpTexts.Jobs.BusDriver))

	addEvent("busReachNextStop", true)
	addEventHandler("busReachNextStop", root, bind(self.Event_busReachNextStop, self))

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.BusDriver):gsub("Job: ", ""), _(HelpTexts.Jobs.BusDriver))
end

function JobBusDriver:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.BusDriver), _(HelpTexts.Jobs.BusDriver))
end

function JobBusDriver:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end
