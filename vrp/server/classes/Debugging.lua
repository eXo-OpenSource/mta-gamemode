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
		addCommandHandler("xp", bind(Debugging.xp, self))
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
	
	function Debugging:xp(player, cmd, xp)
		--[[if player:getRank() < RANK.Administrator then
			return
		end]]
		xp = tonumber(xp)
		if xp then
			player:giveXP(xp)
		end
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
end
