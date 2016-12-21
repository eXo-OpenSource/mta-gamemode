local Bar = {}

addRemoteEvents{"barOpenMusicGUI", "barCloseMusicGUI", "barUpdateMusic"}

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

addEventHandler("barCloseMusicGUI", root, function()
	delete(StreamGUI:getSingleton())
end)

addEventHandler("barUpdateMusic", root, function(stream)
	if Bar.Music then Bar.Music:destroy() end
	if stream then
		Bar.Music = playSound(stream)
		Bar.Music:setVolume(0.5)
	end
end)

