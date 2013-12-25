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
	end

	function Debugging:runString(player, cmd, ...)
		local codeString = table.concat({...}, " ")
		runString(codeString, root, player)
	end
	
	function Debugging:vehicle(player, cmd, model)
		model = tonumber(model) or 411
		local x, y, z = getElementPosition(player)
		Vehicle.create(player:getId(), model, x+3, y, z)
	end

end
