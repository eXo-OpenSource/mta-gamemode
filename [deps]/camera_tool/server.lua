function camtool(player, cmd, pw)
	if pw and pw == "eXoTrailerTeam" then
		outputChatBox("Camera-Tool / Freecam Access erlaubt!", player, 255, 0, 0)
		triggerClientEvent(player, "onAllowPlayer", player)
		local x, y, z = getElementPosition(player)
		triggerClientEvent(player,"doSetFreecamEnabled", player, x, y, z)
	else
		outputChatBox("Falsches/Kein Passwort!", player, 255, 0, 0)
	end
end
addCommandHandler("camtool", camtool)