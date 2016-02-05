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
			runString(codeString, player)
		end
	end

	function Debugging:vehicle(player, cmd, model)
		if player:getRank() < RANK.Moderator then
			return
		end
		model = tonumber(model) or 411
		local pos = player:getPosition()
		local veh = TemporaryVehicle.create(model, pos + player.matrix.forward*3)
		veh:setRotation(player:getRotation() + Vector3(0, 0, 90))
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