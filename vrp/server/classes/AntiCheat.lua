-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AntiCheat.lua
-- *  PURPOSE:     Anticheat class
-- *
-- ****************************************************************************
AntiCheat = inherit(Singleton)
addRemoteEvents{"AntiCheat:ReportBlip", "AntiCheat:ReportFarmerTeleport"}

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
	["W_A:w0"] = true,
	["W_A:w1"] = true,
	["W_A:w2"] = true,
	["W_A:w3"] = true,
	["W_A:w4"] = true,
	["W_A:w5"] = true,
	["W_A:w6"] = true,
	["W_A:alt_w5"] = true,
	["syncer"] = true,
	["lastSync"] = true,
	["superman:flying"] = true,
	["isEquipmentGUIOpen"] = true,
	["clickable"] = true,
	["FactionChatEnabled"] = true, 
	["CompanyChatEnabled"] = true, 
	["AllianceChatEnabled"] = true, 
	["StateChatEnabled"] = true,
	["GroupChatEnabled"] = true,
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

	addEventHandler("onPlayerACInfo", root, bind(self.Event_playerAcInfo, self))
end

function AntiCheat:Event_playerAcInfo(detectedACList, d3d9Size, d3d9MD5, d3d9SHA256)
	-- TODO implement whitelist for wine and vm's
end

function AntiCheat:report(player, name, severity)
	if type(player) ~= "userdata" or type(name) ~= "string" or type(severity) ~= "number" then
		outputServerLog("Bad argument @ Anticheat.report")
		outputServerLog(debug.traceback())
		return
	end
	outputServerLog(("AntiCheat:report(%s, %s, %i)"):format(player:getName(), name, severity))

	sql:queryExec("INSERT INTO ??_cheatlog (UserId, Name, Severity, Date) VALUES(?, ?, ?, NOW())", sql:getPrefix(), player:getId(), name, severity)
end

addEventHandler("AntiCheat:ReportBlip", root,
	function(blipCount)
		AntiCheat:getSingleton():report(client, ("Invalid Blip Count: %s"):format(tostring(blipCount)), CheatSeverity.High)
	end
)

addEventHandler("AntiCheat:ReportFarmerTeleport", root,
	function(dist)
		AntiCheat:getSingleton():report(client, ("used teleport bug on farmer job (%sm)"):format(dist), CheatSeverity.High)
	end
)
