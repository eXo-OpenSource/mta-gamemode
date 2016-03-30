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
	function(jailTime)
		local jailedTime = getTickCount()

		-- Play arrest cutscene
		CutscenePlayer:getSingleton():playCutscene("Arrest",
			function()
				local remainingTime = math.floor(jailTime - (getTickCount() - jailedTime)/1000)

				InfoBox:new(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %ds verweilen!", remainingTime))
				jailCountdownGUI = JailCountdownGUI:new(remainingTime)
			end
		)
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
