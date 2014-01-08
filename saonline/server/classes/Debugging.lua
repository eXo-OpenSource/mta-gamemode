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
		local codeString = table.concat({...}, " ")
		runString(codeString, root, player)
	end
	
	function Debugging:vehicle(player, cmd, model)
		model = tonumber(model) or 411
		local x, y, z = getElementPosition(player)
		Vehicle.create(player, model, x+3, y, z)
	end
	
	function Debugging:xp(player, cmd, xp)
		xp = tonumber(xp)
		if xp then
			player:giveXP(xp)
		end
	end
	
	function Debugging:karma(player, cmd, karma)
		karma = tonumber(karma)
		if karma then
			player:giveKarma(karma)
		end
	end
end
