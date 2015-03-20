-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobPolice.lua
-- *  PURPOSE:     Police job class
-- *
-- ****************************************************************************
JobPolice = inherit(Job)

function JobPolice:constructor()
	Job.constructor(self, 1549.5, -1681.6, 12.6, "Police.png", "files/images/Jobs/HeaderPolice.png", _"Polizist/-in", HelpTexts.Jobs.Police)
end

function JobPolice:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Police), _(HelpTexts.Jobs.Police))
end

function JobPolice:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end