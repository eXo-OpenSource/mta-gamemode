function camtool(player, cmd, pw)
	if pw and pw == "eXoTrailerTeam" then
		outputChatBox("Camera-Tool Access erlaubt!", player, 255, 0, 0)
		triggerClientEvent(player, "onAllowPlayer", player)
	else
		outputChatBox("Falsches/Kein Passwort!", player, 255, 0, 0)
	end
end
addCommandHandler("camtool", camtool)