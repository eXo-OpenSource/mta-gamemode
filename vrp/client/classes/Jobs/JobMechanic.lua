-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobMechanic.lua
-- *  PURPOSE:     Trashman job
-- *
-- ****************************************************************************
JobMechanic = inherit(Job)

function JobMechanic:constructor()
	Job.constructor(self, 682.4, -1577.6, 13.1, "Mechanic.png", "files/images/Jobs/HeaderMechanic.png", _"Mechaniker", _(HelpTexts.Jobs.Mechanic))

end

function JobMechanic:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Mechanic), _(HelpTexts.Jobs.Mechanic))
end

function JobMechanic:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end
