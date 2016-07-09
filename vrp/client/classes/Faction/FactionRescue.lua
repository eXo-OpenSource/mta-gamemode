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
