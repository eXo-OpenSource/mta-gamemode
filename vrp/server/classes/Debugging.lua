-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Debugging.lua
-- *  PURPOSE:     Debugging class
-- *
-- ****************************************************************************
if DEBUG then

	Debugging = inherit(Singleton)

	function Debugging:constructor()
		addCommandHandler("drun", bind(Debugging.runString, self))
		addCommandHandler("vehicle", bind(Debugging.vehicle, self))
		addCommandHandler("karma", bind(Debugging.karma, self))
	end

	function Debugging:runString(player, cmd, ...)
		if getPlayerName(player) == "Console" or player:getRank() == RANK.Developer then
			local codeString = table.concat({...}, " ")
			runString(codeString, root, player)
		end
	end

	function Debugging:vehicle(player, cmd, model)
		if player:getRank() < RANK.Moderator then
			return
		end
		model = tonumber(model) or 411
		local x, y, z = getElementPosition(player)
		TemporaryVehicle.create(model, x+3, y, z)
	end

	function Debugging:karma(player, cmd, karma)
		--[[if player:getRank() < RANK.Administrator then
			return
		end]]
		karma = tonumber(karma)
		if karma then
			player:giveKarma(karma)
		end
	end
	
	
	-- Temporray debug overrides
	local _xmlCreateFile = xmlCreateFile
	function xmlCreateFile(...)
		outputServerLog(debug.traceback())
		return _xmlCreateFile(...)
	end
	
	local _xmlLoadFile = xmlLoadFile
	function xmlLoadFile(...)
		outputServerLog(debug.traceback())
		return _xmlLoadFile(...)
	end
end
