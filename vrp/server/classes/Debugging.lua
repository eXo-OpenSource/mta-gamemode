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
		addCommandHandler("vehicle", bind(Debugging.vehicle, self))
	end

	function Debugging:vehicle(player, cmd, model)
		if player:getRank() < RANK.Moderator then
			return
		end
		model = tonumber(model) or (model ~= nil and getVehicleModelFromName(model) or 411)
		local pos = player:getPosition()
		local veh = TemporaryVehicle.create(model, pos + player.matrix.forward*3)
		veh:setRotation(player:getRotation() + Vector3(0, 0, 90))
	end
end
