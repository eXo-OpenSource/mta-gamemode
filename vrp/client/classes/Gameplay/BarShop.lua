local Bar = {}

addEvent("barOpenMusicGUI", true)
addEventHandler("barOpenMusicGUI", root, function(barId, stream)
	StreamGUI:new("Bar Musik ändern",
		function(url)
			triggerServerEvent("barShopMusicChange", localPlayer, barId, url)
		end,
		function()
			triggerServerEvent("barShopMusicStop", localPlayer, barId)
		end,
		stream
		)

end)

addEvent("barUpdateMusic", true)
addEventHandler("barUpdateMusic", root, function(stream)
	if Bar.Music then Bar.Music:destroy() end
	if stream then
		Bar.Music = playSound(stream)
		Bar.Music:setVolume(0.5)
	end
end)

