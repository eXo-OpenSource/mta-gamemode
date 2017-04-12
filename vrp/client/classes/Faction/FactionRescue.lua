local DeathBlips = {}

addRemoteEvents{"rescueCreateDeathBlip", "rescueRemoveDeathBlip"}
addEventHandler("rescueCreateDeathBlip", root, function(player)

	if DeathBlips[player] then delete(DeathBlips[player]) end

	local pos = player:getPosition()
	DeathBlips[player] = Blip:new("NeedHelp.png", pos.x, pos.y)
	DeathBlips[player]:setStreamDistance(2000)
end)

addEventHandler("rescueRemoveDeathBlip", root, function(player)
	if DeathBlips[player] then delete(DeathBlips[player]) end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if source:getType() == "vehicle" and source:getModel() == 544 then
		setVehicleComponentVisible(source, "misc_a", false)
		setVehicleComponentVisible(source, "misc_b", false)
		setVehicleComponentVisible(source, "misc_c", false)
	end
end)
