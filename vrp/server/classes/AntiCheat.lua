-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AntiCheat.lua
-- *  PURPOSE:     Anticheat class
-- *
-- ****************************************************************************
AntiCheat = inherit(Singleton)
addRemoteEvents{"AntiCheat:ReportBlip"}

AntiCheat.AllowedDataChange = {
	["playingTime"] = true,
	["writing"] = true,
	["i:left"] = true,
	["i:right"] = true,
	["i:warn"] = true,
	["Neon"] = true,
	["NeonColor"] = true,
	["heligrab.vehicle"] = true,
	["heligrab.legsUp"] = true,
	["heligrab.side"] = true,
	["heligrab.linePercent"] = true,
	["heligrab.offsets"] = true,
	["abseiling"] = true,
	["abseilped"] = true,
	["abseilspeed"] = true,
	["parachuting"] = true,
	["animation_state"] = true,
	["skydiving"] = true,
}

function AntiCheat:constructor()
	-- Disable clientside synced element data setting entirely (even though we don't store anything important via elementdatas)
	addEventHandler("onElementDataChange", root,
		function(name, oldValue)
			if AntiCheat.AllowedDataChange[name] then return end

			-- Serverside changes are okay
			if not client then
				return
			end

			setElementData(source, name, oldValue)
		end
	)
end

function AntiCheat:report(player, name, severity)
	if type(player) ~= "userdata" or type(name) ~= "string" or type(severity) ~= "number" then
		outputServerLog("Bad argument @ Anticheat.report")
		outputServerLog(debug.traceback())
		return
	end
	outputServerLog(("AntiCheat:report(%s, %s, %i)"):format(player:getName(), name, severity))

	sql:queryExec("INSERT INTO ??_cheatlog (UserId, Name, Severity) VALUES(?, ?, ?)", sql:getPrefix(), player:getId(), name, severity)
end

addEventHandler("AntiCheat:ReportBlip", root,
	function(blipCount)
		AntiCheat:getSingleton():report(client, ("Invalid Blip Count: %s"):format(tostring(blipCount)), CheatSeverity.High)
	end
)
