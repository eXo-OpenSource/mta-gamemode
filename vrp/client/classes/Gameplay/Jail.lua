-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Jail.lua
-- *  PURPOSE:     Client Jail class
-- *
-- ****************************************************************************

local jailCountdownGUI

addEvent("playerJailed", true)
addEventHandler("playerJailed", root,
	function(jailTime, bCutscene)
		local jailedTime = getTickCount()

		-- Play arrest cutscene
		if bCutscene then
			CutscenePlayer:getSingleton():playCutscene("Arrest",
			function()
				InfoBox:new(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %d Minuten verweilen!", jailTime))
				jailCountdownGUI = Countdown:getSingleton():startCountdown(jailTime*60, "Frei in:")
			end)
		else
			if not jailCountdownGUI then
				InfoBox:new(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %d Minuten verweilen!", jailTime))
				jailCountdownGUI = Countdown:getSingleton():startCountdown(jailTime*60, "Frei in:")
			end
		end
	end
)

addEvent("playerLeftJail", true)
addEventHandler("playerLeftJail", root,
	function()
		if jailCountdownGUI then
			delete(jailCountdownGUI)
			jailCountdownGUI = nil
		end
	end
)
