-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Jail.lua
-- *  PURPOSE:     Client Jail class
-- *
-- ****************************************************************************

local jailCountdownGUI

local Jail = {}

addEvent("playerJailed", true)
addEventHandler("playerJailed", root,
	function(jailTime, bCutscene)
		-- Play arrest cutscene
		if bCutscene then
			CutscenePlayer:getSingleton():playCutscene("Arrest",
			function()
				Jail.startCountdown(jailTime)
			end)
		else
			Jail.startCountdown(jailTime)
		end
	end
)

function Jail.startCountdown(jailTime)
	InfoBox:new(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %d Minuten verweilen!", jailTime))
	jailCountdownGUI = Countdown:getSingleton():startCountdown(jailTime*60, "Frei in:")
	jailCountdownGUI:addTickEvent(function()
			toggleControl("fire", false)
			toggleControl("aim_weapon", false)
			toggleControl("jump", false)
		end)
end

addEvent("playerLeftJail", true)
addEventHandler("playerLeftJail", root,
	function()
		if jailCountdownGUI then
			delete(jailCountdownGUI)
			jailCountdownGUI = nil
		end
	end
)
